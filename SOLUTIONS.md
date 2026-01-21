# 🍜 Danny's Diner Case Study - Solutions

This document contains the SQL queries used to solve the 10 case study questions for Danny's Diner.

## 1. Total Amount Spent
**Question**: What is the total amount each customer spent at the restaurant?

```sql
SELECT
    s.customer_id,
    SUM(m.price) AS total_spent
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;
```
*Analysis: Joins sales with menu to sum prices per customer.*

---

## 2. Days Visited
**Question**: How many days has each customer visited the restaurant?

```sql
SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS visit_days
FROM dannys_diner.sales
GROUP BY customer_id;
```
*Analysis: Counts distinct order dates to find unique visit days.*

---

## 3. First Item Purchased
**Question**: What was the first item from the menu purchased by each customer?

```sql
WITH ranked_purchases AS (
    SELECT
        s.customer_id,
        m.product_name,
        s.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.order_date
        ) AS purchase_rank
    FROM dannys_diner.sales s
    JOIN dannys_diner.menu m ON s.product_id = m.product_id
)
SELECT
    customer_id,
    product_name AS first_time
FROM ranked_purchases
WHERE purchase_rank = 1;
```
*Analysis: Uses a Window Function (ROW_NUMBER) to rank purchases by date for each customer.*

---

## 4. Most Purchased Item
**Question**: What is the most purchased item on the menu and how many times was it purchased by all customers?

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
*Analysis: Aggregates purchase counts by product and orders descending to find the top one.*

---

## 5. Most Popular Item Per Customer
**Question**: Which item was the most popular for each customer?

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
*Analysis: Uses a subquery in the HAVING clause to filter for the product with the maximum count for each customer.*

---

## 6. First Item After Membership
**Question**: Which item was purchased first by the customer after they became a member?

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
*Analysis: Filters for orders on or after join_date and ranks them to find the first one.*

---

## 7. Last Item Before Membership
**Question**: Which item was purchased just before the customer became a member?

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
*Analysis: Filters for orders strictly before join_date and ranks descending to find the last one.*

---

## 8. Total Items and Spend Before Membership
**Question**: What is the total items and amount spent for each member before they became a member?

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
*Analysis: Aggregates count and sum for pre-membership orders.*

---

## 9. Points Calculation (Sustainability Strategy)
**Question**: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

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
*Analysis: Uses a CASE statement to apply different multipliers based on the product.*

---

## 10. Points with First Week Bonus
**Question**: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

```sql
SELECT
    s.customer_id,
    SUM(
        CASE
            WHEN s.order_date BETWEEN mem.join_date AND mem.join_date + INTERVAL '6 DAYS' THEN
                CASE
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
*Analysis: Complex condition checking both the promotional period (first week) and the product type for points modification.*
