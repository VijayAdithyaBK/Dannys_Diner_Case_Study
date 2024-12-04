/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT * FROM dannys_diner.sales;
SELECT * FROM dannys_diner.menu;
SELECT * FROM dannys_dinner.members;

-- Set the search path to the 'dannys_diner' schema to ensure all subsequent queries reference the correct context.
SET search_path = dannys_diner;
SELECT * FROM sales;
SELECT * FROM menu;
SELECT * FROM members;

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
    s.customer_id,  -- Selecting the unique identifier for customers from the sales table
    SUM(m.price) AS total_spent  -- Calculating the total amount spent by each customer by summing the prices from the menu
FROM dannys_diner.sales s  -- Specifying the sales table as the primary data source, aliased as 's'
JOIN dannys_diner.menu m ON s.product_id = m.product_id  -- Performing an inner join to combine sales data with menu items based on matching product IDs
GROUP BY s.customer_id;  -- Grouping the results by customer ID to aggregate total spending for each customer

-- 2. How many days has each customer visited the restaurant?
SELECT
    customer_id,  -- Selecting the unique identifier for each customer
    COUNT(DISTINCT order_date) AS visit_days  -- Counting the number of distinct days each customer placed an order to analyze customer engagement
FROM dannys_diner.sales  -- Querying the sales data from Danny's Diner, ensuring we are analyzing the correct dataset
GROUP BY customer_id;  -- Grouping results by customer ID to aggregate visit days for each individual customer


-- 3. What was the first item from the menu purchased by each customer?
WITH
    ranked_purchases AS (
        -- CTE (Common Table Expression) to rank purchases for each customer
        SELECT
            s.customer_id,                 -- Selecting customer ID from sales data
            m.product_name,                -- Selecting product name from the menu
            s.order_date,                  -- Including the order date for temporal ranking
            ROW_NUMBER() OVER (            -- Generating a sequential number for each purchase per customer
                PARTITION BY
                    s.customer_id         -- Partitioning by customer to rank purchases individually
                ORDER BY
                    s.order_date         -- Ordering by order date to identify the first purchase
            ) AS purchase_rank              -- Assigning rank to each purchase
        FROM
            dannys_diner.sales s           -- Accessing sales table from the "danny's diner" schema
            JOIN dannys_diner.menu m ON s.product_id = m.product_id  -- Joining sales and menu tables on product ID
    )
-- Main query to select the first-time purchases for each customer
SELECT
    customer_id,                      -- Selecting the customer ID for the output
    product_name AS first_time        -- Renaming the product name column to indicate it's the first purchase
FROM
    ranked_purchases                  -- Utilizing the CTE to filter ranked purchases
WHERE
    purchase_rank = 1;                -- Filtering to get only the first purchase for each customer
    
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- This query retrieves the product name and its purchase count from the "Danny's Diner" database.
-- It showcases the ability to analyze sales data effectively, a crucial skill for a Data Analyst.

SELECT
    m.product_name,  -- Selecting the product name from the menu table.
    COUNT(s.product_id) AS purchase_count  -- Counting the number of times each product has been sold, aliased as purchase_count.
FROM dannys_diner.sales s  -- Accessing the sales table to gather transactional data.
JOIN dannys_diner.menu m ON s.product_id = m.product_id  -- Joining the sales and menu tables on product_id to link sales with product details.
GROUP BY m.product_name  -- Grouping results by product name to aggregate purchase counts accurately.
ORDER BY purchase_count DESC  -- Sorting results in descending order to highlight the most purchased product.
LIMIT 1;  -- Limiting the results to only the top-selling product, demonstrating efficient data retrieval.

-- 5. Which item was the most popular for each customer?
SELECT
    s.customer_id,  -- Select the unique identifier for customers from the sales table
    m.product_name,  -- Select the name of the product from the menu table
    COUNT(s.product_id) AS purchase_count  -- Count the total number of purchases per product per customer
FROM dannys_diner.sales s  -- Specify the sales table as the main source of data
JOIN dannys_diner.menu m ON s.product_id = m.product_id  -- Join with the menu table to retrieve product names based on matching product IDs
GROUP BY s.customer_id, m.product_name  -- Group results by customer ID and product name to aggregate purchase counts
HAVING COUNT(s.product_id) = (  -- Filter results to include only those products with purchase counts equal to the maximum for each customer
    SELECT MAX(count)  -- Subquery to find the maximum purchase count for products purchased by each customer
    FROM (
        SELECT COUNT(s2.product_id) AS count  -- Count the purchases of each product by the customer in the subquery
        FROM dannys_diner.sales s2  -- Reference the sales table again for the subquery
        WHERE s2.customer_id = s.customer_id  -- Ensure we are counting purchases for the same customer
        GROUP BY s2.product_id  -- Group by product ID to get counts for each product
    ) AS subquery  -- Alias for the inner query to facilitate the outer query
);

-- 6. Which item was purchased first by the customer after they became a member?
-- Common Table Expression (CTE) to isolate member purchases and their ranks
WITH post_member_purchases AS (
    SELECT
        s.customer_id,                            -- Select customer ID for identification
        s.order_date,                             -- Select the order date for chronological analysis
        m.product_name,                           -- Select product name to understand purchase behavior
        ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS purchase_rank  -- Assign a rank to each purchase per customer based on order date
    FROM dannys_diner.sales s                     -- From the sales table to gather purchase information
    JOIN dannys_diner.menu m ON m.product_id = s.product_id  -- Join with menu to link products to sales
    JOIN dannys_diner.members mem ON mem.customer_id = s.customer_id  -- Join with members to filter purchases made by members only
    WHERE s.order_date >= mem.join_date          -- Ensure that only purchases made after membership are considered
)

-- Final selection of customers' first purchases after joining the membership
SELECT
    customer_id,                                   -- Select customer ID for final output
    product_name AS first_item_after_membership   -- Rename the product name for clarity in the result set
FROM post_member_purchases
WHERE purchase_rank = 1;                          -- Filter to return only the first item purchased after membership

-- 7. Which item was purchased just before the customer became a member?
-- CTE to identify purchases made by members before their membership join date
WITH pre_member_purchase AS (
    SELECT
        s.customer_id, -- Selecting customer ID to identify unique customers
        s.order_date, -- Capturing the order date to track purchase history
        m.product_name, -- Joining to retrieve product names from the menu
        ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS purchase_rank -- Assigning a rank to purchases per customer based on order date
        FROM dannys_diner.sales s -- Using the sales table as the primary data source
        JOIN dannys_diner.menu m ON m.product_id = s.product_id -- Joining menu to link products with sales
        JOIN dannys_diner.members mem ON mem.customer_id = s.customer_id -- Joining members to filter purchases made before membership
        WHERE s.order_date < mem.join_date -- Ensuring only pre-membership purchases are considered
)

-- Main query to retrieve the most recent purchase before membership for each customer
SELECT
    customer_id, -- Displaying the unique customer ID
    product_name AS item_ordered_before_membership -- Renaming product name for clarity in results
FROM pre_member_purchase
WHERE purchase_rank = 1; -- Filtering to get only the latest purchase for each customer

-- 8. What is the total items and amount spent for each member before they became a member?
-- Selecting the customer ID from the sales table
SELECT
    s.customer_id,
    -- Counting the total number of items purchased by each customer
    COUNT(s.product_id) AS total_items,
    -- Summing up the total amount spent by each customer on products
    SUM(m.price) AS total_spent
FROM dannys_diner.sales s
-- Joining the members table to link customers with their membership details
JOIN members mem ON mem.customer_id = s.customer_id
-- Joining the menu table to access product pricing information
JOIN dannys_diner.menu m ON m.product_id = s.product_id
-- Filtering records to include only orders placed before the customer's membership start date
WHERE s.order_date < mem.join_date
-- Grouping results by customer ID to aggregate item counts and total spending
GROUP BY s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
    s.customer_id,  -- Select the unique identifier for each customer from the sales table
    SUM(  -- Begin aggregation to calculate total points for each customer
        CASE  -- Utilize a CASE statement to differentiate point allocation based on product type
            WHEN m.product_name = 'sushi' THEN m.price * 20  -- Award 20 points for each sushi item sold
            ELSE m.price * 10  -- Award 10 points for all other menu items sold
        END
    ) AS total_points  -- Rename the result of the aggregation as 'total_points' for clarity
FROM dannys_diner.sales s  -- Specify the sales table as the primary data source, aliased as 's'
JOIN dannys_diner.menu m ON s.product_id = m.product_id  -- Perform an inner join with the menu table on product_id to link sales with menu items
GROUP BY s.customer_id;  -- Group the results by customer_id to aggregate points per customer

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT
    s.customer_id,  -- Selecting the unique identifier for each customer
    SUM(  -- Summing up the total points earned by each customer
        CASE
            WHEN s.order_date BETWEEN mem.join_date AND mem.join_date + INTERVAL '6 DAYS' THEN  -- Checking if the order date is within the first week of membership
                CASE
                    WHEN m.product_name = 'sushi' THEN m.price * 2 * 20  -- Applying a higher point multiplier for sushi during the promotional period
                    ELSE m.price * 2 * 10  -- Applying standard points for other products during the promotional period
                END
            ELSE CASE  -- For orders placed after the first week of membership
                WHEN m.product_name = 'sushi' THEN m.price * 20  -- Standard point calculation for sushi
                ELSE m.price * 10  -- Standard point calculation for other products
            END
        END
    ) AS total_points  -- Alias for the calculated total points earned by the customer
FROM dannys_diner.sales s  -- Main table containing sales data
JOIN dannys_diner.members mem ON s.customer_id = mem.customer_id  -- Joining member data to associate customers with their membership details
JOIN dannys_diner.menu m ON m.product_id = s.product_id  -- Joining menu data to access product details
WHERE s.order_date <= '2021-01-31'  -- Filtering sales to include only those before or on January 31, 2021
    AND s.customer_id IN ('A', 'B')  -- Focusing on specific customers identified by their IDs
GROUP BY s.customer_id;  -- Grouping results by customer to aggregate total points earned
