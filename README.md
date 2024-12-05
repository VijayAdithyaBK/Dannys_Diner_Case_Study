# Case Study Document: Danny's Diner

**Prepared by:** Vijay Adithya B K

**Experience:** 3 Years as Data Analyst

**Portfolio:** https://vijayadithyabk.framer.website/

## Introduction

In early 2021, Danny Ma opened Danny’s Diner, a restaurant specializing in his favorite Japanese dishes: sushi, curry, and ramen. Despite the initial excitement, the restaurant faced challenges in understanding customer behavior and preferences based on the limited data collected during the first few months of operation. This case study explores how to leverage SQL to analyze this data, providing insights to enhance customer engagement and improve business decisions.

## Problem Statement

Danny aims to analyze customer spending habits, visitation frequency, and favorite menu items to strengthen relationships with loyal customers and evaluate the potential expansion of the customer loyalty program. The insights derived from the data will assist in creating a more personalized dining experience.

## Data Overview

The following datasets were provided for analysis:

1. **Sales Table:** Captures customer purchases along with order dates and product IDs.
    - Columns: `customer_id`, `order_date`, `product_id`
2. **Menu Table:** Maps product IDs to product names and prices.
    - Columns: `product_id`, `product_name`, `price`
3. **Members Table:** Contains information on when customers joined the loyalty program.
    - Columns: `customer_id`, `join_date`

### Entity Relationship Diagram

![ERD.png](https://github.com/VijayAdithyaBK/Dannys-Diner/blob/main/ERD.png)

## SQL Queries and Results

The following SQL queries were executed to answer key questions regarding customer behavior at Danny's Diner:

### 1. Total Amount Spent by Each Customer

```sql
SELECT
    s.customer_id,
    SUM(m.price) AS total_spent
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

```

### 2. Days Visited by Each Customer

```sql
SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS visit_days
FROM dannys_diner.sales
GROUP BY customer_id;

```

### 3. First Item Purchased by Each Customer

```sql
WITH ranked_purchases AS (
    SELECT
        s.customer_id,
        m.product_name,
        s.order_date,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS purchase_rank
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m ON s.product_id = m.product_id
)
SELECT
    customer_id,
    product_name AS first_time
FROM ranked_purchases
WHERE purchase_rank = 1;

```

### 4. Most Purchased Item on the Menu

```sql
SELECT
    m.product_name,
    COUNT(s.product_id) AS purchase_count
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchase_count DESC
LIMIT 1;

```

### 5. Most Popular Item for Each Customer

```sql
SELECT
    s.customer_id,
    m.product_name,
    COUNT(s.product_id) AS purchase_count
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
HAVING COUNT(s.product_id) = (
    SELECT MAX(count)
    FROM (
        SELECT COUNT(s2.product_id) AS count
        FROM dannys_diner.sales s2
        WHERE s2.customer_id = s.customer_id
        GROUP BY s2.product_id
    ) AS subquery
);

```

### 6. First Item Purchased After Membership

```sql
WITH post_member_purchases AS (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS purchase_rank
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m ON m.product_id = s.product_id
    JOIN dannys_diner.members mem ON mem.customer_id = s.customer_id
    WHERE s.order_date >= mem.join_date
)
SELECT
    customer_id,
    product_name AS first_item_after_membership
FROM post_member_purchases
WHERE purchase_rank = 1;

```

### 7. Item Purchased Just Before Membership

```sql
WITH pre_member_purchase AS (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS purchase_rank
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m ON m.product_id = s.product_id
    JOIN dannys_diner.members mem ON mem.customer_id = s.customer_id
    WHERE s.order_date < mem.join_date
)
SELECT
    customer_id,
    product_name AS item_ordered_before_membership
FROM pre_member_purchase
WHERE purchase_rank = 1;

```

### 8. Total Items and Amount Spent Before Membership

```sql
SELECT
    s.customer_id,
    COUNT(s.product_id) AS total_items,
    SUM(m.price) AS total_spent
FROM dannys_diner.sales s
JOIN members mem ON mem.customer_id = s.customer_id
JOIN dannys_diner.menu m ON m.product_id = s.product_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id;

```

### 9. Total Points Accumulated by Each Customer

```sql
SELECT
    s.customer_id,
    SUM(
        CASE
            WHEN m.product_name = 'sushi' THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS total_points
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

```

### 10. Points Earned by Customers A and B by End of January

```sql
SELECT
    s.customer_id,
    SUM(
        CASE
            WHEN s.order_date BETWEEN mem.join_date AND mem.join_date + INTERVAL '6 DAYS' THEN CASE
                            WHEN m.product_name = 'sushi' THEN m.price * 2 * 20
                            ELSE m.price * 2 * 10
                        END
            ELSE CASE
                    WHEN m.product_name = 'sushi' THEN m.price * 20
                    ELSE m.price * 10
                END
            END
    ) AS total_points
FROM dannys_diner.sales s
JOIN dannys_diner.members mem ON s.customer_id = mem.customer_id
JOIN dannys_diner.menu m ON m.product_id = s.product_id
WHERE s.order_date <= '2021-01-31'
    AND s.customer_id IN ('A', 'B')
GROUP BY s.customer_id;

```

## Conclusion

Through this case study, we were able to extract valuable insights from Danny’s Diner's data to enhance customer relations and inform business strategies. The SQL queries developed offer a robust framework for understanding customer behavior and preferences, which can ultimately drive revenue growth and improve customer satisfaction.

---

## Author - Vijay Adithya B K

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/vijayadithyabk/)
