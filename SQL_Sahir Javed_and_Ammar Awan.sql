-- SQL Portfolio : M Sahir Javed and Ammar Awan
-- Tasks and Concepts
-- Part 1 : Basics
-- -- Section 1 Loading and Exploring Data
-- -- -- 1.1 Explore the structure and first 10 rows of each table
SELECT * FROM badges LIMIT 10;
SELECT * FROM comments LIMIT 10;
SELECT * FROM post_history LIMIT 10;
SELECT * FROM post_links LIMIT 10;
SELECT * FROM posts_answers LIMIT 10;
SELECT * FROM tags LIMIT 10;
SELECT * FROM users LIMIT 10;
SELECT * FROM votes LIMIT 10;
SELECT * FROM posts LIMIT 10;
-- -- -- 1.2 Identify the total number of records in each table
SELECT 'badges' AS table_name, COUNT(*) AS total_records FROM badges
UNION ALL
SELECT 'comments' AS table_name, COUNT(*) AS total_records FROM comments
UNION ALL
SELECT 'post_history' AS table_name, COUNT(*) AS total_records FROM post_history
UNION ALL
SELECT 'post_links' AS table_name, COUNT(*) AS total_records FROM post_links
UNION ALL
SELECT 'posts_answers' AS table_name, COUNT(*) AS total_records FROM posts_answers
UNION ALL
SELECT 'tags' AS table_name, COUNT(*) AS total_records FROM tags
UNION ALL
SELECT 'users' AS table_name, COUNT(*) AS total_records FROM users
UNION ALL
SELECT 'votes' AS table_name, COUNT(*) AS total_records FROM votes
UNION ALL
SELECT 'posts' AS table_name, COUNT(*) AS total_records FROM posts;
-- --------------------------------------------------------------------------------
-- -- Section 2 Filtering and Sorting
-- -- -- 2.1 Find all posts with a comment_count greater than 2
SELECT post_id, COUNT(*) AS comment_count
FROM comments
GROUP BY post_id;
SELECT post_id, COUNT(*) AS comment_count
FROM comments
GROUP BY post_id
HAVING COUNT(*) > 2;
-- -- -- 2.2 Display comments made in 2012, sorted by creation_date
SELECT * FROM comments 
WHERE YEAR(creation_date) = 2012 
ORDER BY creation_date;
-- -------------------------------------------------------------------------------------------
-- -- 3. Simple Aggregations

-- -- -- 3.1 Count the total number of badges
SELECT COUNT(*) AS total_badges FROM badges;

-- -- -- 3.2 Calculate the average score of posts grouped by post_type_id
SELECT post_type_id, AVG(score) AS average_score 
FROM posts_answers 
GROUP BY post_type_id;
-- ---------------------------------------------------------------------------------
-- PART 2: JOINS
-- -- Section 1 : Basic Joins
-- -- -- 1.1 Combine post_history and posts to display post titles and their history
SELECT p.title, p.creation_date, ph.text, ph.creation_date 
FROM post_history ph 
JOIN posts p ON ph.post_id = p.id;

-- -- -- 1.2 Join users with badges to find total badges earned by each user
SELECT u.display_name, COUNT(b.id) AS total_badges 
FROM users u 
JOIN badges b ON u.id = b.user_id 
GROUP BY u.display_name;

-- -- 2. Multi-Table Joins

-- -- -- 2.1 Fetch the titles of posts, their comments, and the users who made those comments
SELECT p.title, c.text AS comment_text, u.display_name AS user_who_made_comment
FROM posts p
JOIN comments c ON p.id = c.post_id
JOIN users u ON c.user_id = u.id;

-- -- -- 2.2 Combine post_links with posts to list related questions
SELECT p1.title AS post_title, p2.title AS related_post_title
FROM post_links pl
JOIN posts p1 ON pl.post_id = p1.id
JOIN posts p2 ON pl.related_post_id = p2.id;

-- -- -- 2.3 Join users, badges, and comments tables to find users who earned badges and made comments
SELECT u.display_name, COUNT(DISTINCT b.id) AS total_badges, COUNT(DISTINCT c.id) AS total_comments
FROM users u
LEFT JOIN badges b ON u.id = b.user_id
LEFT JOIN comments c ON u.id = c.user_id
GROUP BY u.display_name
HAVING total_badges > 0 AND total_comments > 0;
-- --------------------------------------------------------------------------------
-- PART 3: SUBQUERIES
-- -- Section 3.1
-- -- -- 3.1.1 Find the user with the highest reputation
SELECT * 
FROM users 
WHERE reputation = (SELECT MAX(reputation) FROM users);

-- -- -- 3.1.2 Retrieve posts with the highest score in each post_type_id
SELECT * 
FROM posts p1 
WHERE score = (SELECT MAX(score) FROM posts p2 WHERE p1.post_type_id = p2.post_type_id);

--  -- Section 3.2
-- -- -- 3.2.1 Correlated Subqueries: Fetch the number of related posts for each post
SELECT p.id, p.title, (
    SELECT COUNT(*) FROM post_links pl WHERE pl.post_id = p.id
) AS related_post_count
FROM posts p;
-- ------------------------------------------------------------------------------
-- PART 4: COMMON TABLE EXPRESSIONS (CTEs)

-- -- Section 4.1 Non-Recursive CTE to calculate the average score of posts by each user
WITH AvgScores AS (
    SELECT owner_user_id, AVG(score) AS avg_score 
    FROM posts
    GROUP BY owner_user_id
)
SELECT * FROM AvgScores;
-- -- -- 4.1.1 List users with an average score above 50
WITH AvgScores AS (
    SELECT owner_user_id, AVG(score) AS avg_score 
    FROM posts
    GROUP BY owner_user_id
)
SELECT * FROM AvgScores WHERE avg_score > 50;
-- -- -- 4.1.2 Rank users based on their average post score
WITH AvgScores AS (
    SELECT owner_user_id, AVG(score) AS avg_score 
    FROM posts_answers 
    GROUP BY owner_user_id
)
SELECT u.display_name, a.avg_score, RANK() OVER (ORDER BY a.avg_score DESC) AS ranking
FROM AvgScores a
JOIN users u ON a.owner_user_id = u.id;

-- 4.2 Recursive CTE to simulate hierarchy of linked posts
WITH RECURSIVE PostHierarchy AS (
    -- Base case: Start with all posts in the post_links table
    SELECT 
        pl.post_id, 
        p.title AS post_title,
        pl.related_post_id, 
        p2.title AS related_post_title,
        1 AS depth,
        CAST(pl.post_id AS CHAR(255)) AS visited_posts -- Track visited posts
    FROM post_links pl
    JOIN posts p ON pl.post_id = p.id
    JOIN posts p2 ON pl.related_post_id = p2.id
    
    UNION ALL
    
    -- Recursive case: Fetch related posts hierarchically, limit recursion depth and prevent revisiting posts
    SELECT 
        pl.post_id, 
        p.title AS post_title,
        pl.related_post_id, 
        p2.title AS related_post_title,
        ph.depth + 1,
        CONCAT(ph.visited_posts, ',', pl.post_id) AS visited_posts -- Add current post to visited list
    FROM post_links pl
    JOIN posts p ON pl.post_id = p.id
    JOIN posts p2 ON pl.related_post_id = p2.id
    JOIN PostHierarchy ph ON pl.post_id = ph.related_post_id
    WHERE ph.depth < 10
    AND FIND_IN_SET(pl.related_post_id, ph.visited_posts) = 0 -- Ensure the related post is not already visited
)

SELECT DISTINCT post_id, post_title, related_post_id, related_post_title, depth
FROM PostHierarchy
ORDER BY depth, post_id;
-- ----------------------------------------------------------------

-- -- 5.2 Calculate the running total of badges earned by users
SELECT user_id, date, COUNT(id) OVER (PARTITION BY user_id ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_badges
FROM badges;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Insights:
-- -- Which users have contributed the most in terms of comments, edits, and votes?
SELECT u.display_name, COUNT(DISTINCT c.id) AS total_comments, COUNT(DISTINCT ph.id) AS total_edits, COUNT(DISTINCT v.id) AS total_votes, 
(COUNT(DISTINCT c.id) + COUNT(DISTINCT ph.id) + COUNT(DISTINCT v.id)) AS total_contribution
FROM users u
LEFT JOIN comments c ON u.id = c.user_id
LEFT JOIN post_history ph ON u.id = ph.user_id
LEFT JOIN votes v ON u.id = v.post_id
GROUP BY u.id, u.display_name
ORDER BY total_contribution DESC;
-- -- Answer:  
-- -- -- Alice and Bob have contributed the most with three comments and three edits each
-- -- -- They are followed by charlie and dave who have two comments and two edits each.
-- -------------------------------------------------------------------------------------------------------------------------------------------------
-- -- What types of badges are most commonly earned, and which users are the top earners?
SELECT b.name AS badge_type, u.display_name AS top_user, COUNT(CASE WHEN b.user_id = u.id THEN 1 END) AS top_earners
FROM badges b
JOIN users u ON b.user_id = u.id
GROUP BY b.name, u.display_name
ORDER BY top_earners DESC;
-- -- Answer:
-- -- Gold contributor badge has been earned the most (4 times), twice by Alice and Twice by Dave. 
-- -- Whereas Alice has won a total of 4 badges (2 gold contributor, 1 silver helper and 1 bronze reviewer.)
-- ---------------------------------------------------------------------------------------------------------
-- -- Which tags are associated with the highest-scoring posts?
WITH post_tags AS (
SELECT 2001 AS post_id, 1 AS tag_id 
UNION ALL
SELECT 2002, 2 
UNION ALL
SELECT 2003, 1 
UNION ALL
SELECT 2004, 3 
UNION ALL
SELECT 2005, 10)

SELECT t.tag_name, SUM(p.score) AS total_score, AVG(p.score) AS avg_score
FROM post_tags pt
JOIN tags t ON pt.tag_id = t.id
JOIN posts p ON pt.post_id = p.id
GROUP BY t.tag_name
ORDER BY total_score DESC;
-- -- Answer: SQL and Database tags have the highest score as 30 each, followed by react and javascript with 25 and 15 score respectively.
-- --------------------------------------------------------------------------------------------------------------------------------
-- -- How often are related questions linked, and what does this say about knowledge sharing?
SELECT COUNT(*) AS total_links, COUNT(DISTINCT post_id) AS unique_posts_linked, COUNT(DISTINCT related_post_id) AS unique_related_posts
FROM post_links;
--  A total of 10 links were made between post. 5 unique_posts were linked with other posts whereas there were 6 unique related posts.

-- The End
