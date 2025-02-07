Project Title : Stack Overflow Post Analysis: A SQL Portfolio Project

Overview : This project is an in-depth SQL analysis of Stack Overflow post history, focusing on user activity, content evolution, and data relationships. It serves as a demonstration of intermediate SQL skills, including joins, subqueries, common table expressions (CTEs), window functions, and aggregate queries.

Dataset: The dataset used in this project is sourced from Stack Overflow and contains the following tables:

1.  badges – Tracks badges earned by users.
2.  comments – Contains comments on posts.
3.  post_history – Tracks edits, comments, and other changes made to posts.
4.  post_links – Links between related posts.
5.  posts_answers – Contains questions and answers.
6.  tags – Stores tags associated with posts.
7.  users – Details about Stack Overflow users.
8.  votes – Tracks voting activity on posts.
9.  posts – Contains Stack Overflow questions and answers.

Key SQL Concepts Demonstrated

1. Basic SQL Queries

Loading and exploring data
Filtering and sorting records
Simple aggregations

2. Joins

Combining multiple tables to retrieve meaningful insights
Multi-table joins for comprehensive analysis

3. Subqueries

Single-row and correlated subqueries for dynamic data extraction

4. Common Table Expressions (CTEs)

Non-recursive and recursive CTEs for improved query organization

5. Window Functions

Ranking posts based on their score within each year
Calculating running totals for earned badges

6. Advanced Queries for Insights

Identifying the most active contributors based on comments, edits, and votes
Analyzing the most commonly earned badges and top badge earners
Determining which tags are associated with the highest-scoring posts
Assessing the frequency of linked questions and its implications for knowledge sharing

File Structure

SQL_Sahir_Javed_and_Ammar_Awan.sql – The final SQL script containing all queries.
README.md – This documentation file providing project details.
How to Use

Clone this repository:
git clone https://github.com/yourusername/sql-portfolio-project.git
Import the dataset into your preferred SQL database.
Run the SQL script to execute the queries and analyze the results.

Contributors:
Sahir Javed
Ammar Awan

License

This project is open-source and available under the MIT License.

