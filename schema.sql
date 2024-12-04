-- Create a new schema for the 'Danny's Diner' case study to organize the related database objects
CREATE SCHEMA dannys_diner;

-- Set the search path to the newly created schema for all subsequent operations
SET search_path = dannys_diner;

-- Create the 'menu' table to define the available products for sale
CREATE TABLE menu (
  "product_id" INTEGER,      -- Unique identifier for each product
  "product_name" VARCHAR(5), -- Name of the product (up to 5 characters)
  "price" INTEGER,           -- Price of the product in currency
  PRIMARY KEY(product_id)    -- Set 'product_id' as the primary key to ensure uniqueness
);

-- Insert sample data into the 'menu' table to define available products and their prices
INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),     -- Product 1: sushi priced at 10
  ('2', 'curry', '15'),     -- Product 2: curry priced at 15
  ('3', 'ramen', '12');      -- Product 3: ramen priced at 12

-- Create the 'members' table to track customer membership information
CREATE TABLE members (
  "customer_id" VARCHAR(1),  -- Unique identifier for each customer (1 character)
  "join_date" DATE,          -- Date when the customer joined
  PRIMARY KEY(customer_id)   -- Set 'customer_id' as the primary key to ensure uniqueness
);

-- Insert sample data into the 'members' table to simulate customer membership
INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),      -- Customer A joined on 2021-01-07
  ('B', '2021-01-09');      -- Customer B joined on 2021-01-09

-- Create the 'sales' table to track customer orders
CREATE TABLE sales (
  "customer_id" VARCHAR(1),  -- Unique identifier for each customer (1 character)
  "order_date" DATE,         -- Date when the order was placed
  "product_id" INTEGER,      -- Identifier for the product ordered
  -- Define foreign key constraint to ensure referential integrity with the 'menu' table
  CONSTRAINT fk_product
  FOREIGN KEY(product_id)
  REFERENCES menu(product_id)  
);

-- Insert sample data into the 'sales' table to simulate customer orders
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');