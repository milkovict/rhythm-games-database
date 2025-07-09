# Rhythm Game Database

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)

A comprehensive database project for a rhythm video game, developed as a seminar paper for the "Modern Database Systems" course at the Faculty of Applied Mathematics and Informatics in Osijek.

## About The Project

This project models the backend database required to run an online rhythm game. It handles user authentication, score tracking, beatmap management, and social features like friendships.
The model, while simplified, is built on solid database principles and implemented in **PostgreSQL**.

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Key Features Implemented

-   **Complex Queries:** Multi-table joins, aggregations, and subqueries to generate leaderboards and statistics.
-   **Constraints:** `CHECK` constraints to ensure data integrity (e.g., accuracy is between 0-100).
-   **Default Values:** Smart defaults for fields like `level` or `friendship status`.
-   **Indexing:** B-tree indexes on frequently searched columns (`username`, `user_id`, `beatmap_id`) to optimize query performance.
-   **Stored Procedures:**
    -   `add_new_user`: Automates the user registration process by creating entries in both `user` and `profile` tables.
    -   `accept_friend_request`: Manages the social graph by updating a friendship status from 'Pending' to 'Accepted'.
-   **Triggers:**
    -   `trig_effective_score`: Before a score is inserted, it checks for a 'DT' (Double Time) mod and calculates the `effective_bpm` and `effective_difficulty_rating`.
    -   `trg_before_score_insert_improvement`: Prevents the insertion of a new score if it's not better than the user's personal best on that specific beatmap, thus saving space and storing only meaningful progress.

## Setup and Usage

To set up the database locally:

1.  **Create a new PostgreSQL database.**

2.  **Create the schema and insert data:** Execute the entire `01_schema_and_inserts.sql` script. This will create all the necessary tables (`user`, `profile`, `beatmap`, `score`, `replay`, `friends`) and populate them with initial data.
    ```bash
    psql -U your_username -d your_database -f sql_scripts/01_schema_and_inserts.sql
    ```

3.  **Add advanced logic:** Execute the logic-related parts (steps 9-14) from the `02_features_and_queries.sql` script to add constraints, indexes, procedures, and triggers to the database.

4.  **Explore the queries:** The `02_features_and_queries.sql` file also contains numerous example queries (steps 5-8) that demonstrate how to retrieve data from the database.

## Author

* **Tibor Milković**
