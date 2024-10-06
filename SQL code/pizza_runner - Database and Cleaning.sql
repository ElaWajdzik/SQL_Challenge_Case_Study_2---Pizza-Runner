-------------------------------
--CASE STUDY #2: PIZZA RUNNER--
-------------------------------

--Author: Ela Wajdzik
--Date: 17.09.2024 (update 18.09.2024)
--Tool used: Microsoft SQL Server


--create tables with data

CREATE SCHEMA pizza_runner;
--SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INT,
  "registration_date" DATE
);

INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INT,
  "customer_id" INT,
  "pizza_id" INT,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME2 --the type TIMESTAMP is not correct in MS SQL Server
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INT,
  "runner_id" INT,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INT,
  "pizza_name" VARCHAR(20)
);

INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INT,
  "toppings" VARCHAR(40)
);

INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INT,
  "topping_name" VARCHAR(50)
);

INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');


-- CLEANING DATA proces

/*
When you take a closer look at the data, you can see some problems that need to be fixed before any analysis.

Table 2: customer_orders:
		column exclusions contains empty value and null -> I will change all values to null
		column extras contains empty value, null and NaN -> I will change all values to null
To improve the schema of this database, I can extract the information about exclusions and extras from the customer_orders table into a new table called change_orders.

Table 3: runner_orders:
		column distance is a VARCHAR type and the information about kilometers is recorded in many way -> I will change the column type to NUMERIC(4,1), exclude the information about kilometers (and include this information in the column name).
		column duration is a VARCHAR type and the information about minutes is recorded in many way -> I will change the column type to NUMERIC(3,0), exclude the information about minutes (and include this information in the column name).
		column cancellation contains empty value, null and NaN -> I will change all values to null

Table 5: pizza_recipes:
		column toppings contains not-atomic values -> I will modify this table to separate the information about toppings for each pizza.

*/

--Table 1: runners 
--		Add a primary key

ALTER TABLE runners
ALTER COLUMN runner_id INT NOT NULL;

ALTER TABLE runners 
ADD CONSTRAINT runners_pk PRIMARY KEY(runner_id);

-- Table 3: runner_orders
--		Add a primary key
--		Add a foreign key (runners)
--		Add two new columns (distance_km, duration_min)
--		Standardize the null values in the columns pickup_time and cancellation
--		Drop the old columns distance and duration

ALTER TABLE runner_orders
ALTER COLUMN order_id INT NOT NULL;

ALTER TABLE runner_orders
ADD CONSTRAINT runner_orders_pk PRIMARY KEY(order_id);

ALTER TABLE runner_orders
ADD CONSTRAINT runner_orders_runner_id_fk FOREIGN KEY (runner_id) REFERENCES runners(runner_id);

ALTER TABLE runner_orders
ADD 	distance_km NUMERIC(4,1),
	duration_min NUMERIC(3,0);

UPDATE runner_orders
SET distance_km = CAST(
			CASE distance
				WHEN 'null' THEN NULL
				ELSE TRIM('km' FROM distance)
			END 
			AS NUMERIC(4,1));

UPDATE runner_orders
SET duration_min = CAST(
			TRIM('minutes' FROM 
				CASE duration WHEN 'null' THEN NULL ELSE duration END) 
			AS NUMERIC(3,0));

UPDATE runner_orders
SET pickup_time = CASE pickup_time WHEN 'null' THEN NULL ELSE pickup_time END;

UPDATE runner_orders
SET cancellation =	CASE cancellation
				WHEN 'null' THEN NULL
				WHEN '' THEN NULL
				ELSE cancellation
			END;

ALTER TABLE runner_orders
DROP COLUMN duration, distance;

-- SELECT * FROM runner_orders;

-- Table 6: pizza_toppings
--		Add a primary key

ALTER TABLE pizza_toppings
ALTER COLUMN topping_id INT NOT NULL;

ALTER TABLE pizza_toppings
ADD CONSTRAINT pizza_toppings_pk PRIMARY KEY(topping_id);

-- Table 4: pizza_names
--		Add a primary key

ALTER TABLE pizza_names
ALTER COLUMN pizza_id INT NOT NULL;

ALTER TABLE pizza_names
ADD CONSTRAINT pizza_names_pk PRIMARY KEY(pizza_id);

-- Table 5: pizza_recipes
--		Rename the table pizza_recipes to pizza_recipes_temp
--		Create a new table pizza_recipies which containts id (pk), pizza_id and topping_id.
--		Insert values to the new table using informacion from the old one.
--		Add a foreign key (pizza_toppings)
--		Add a foreign key (pizza_names)

EXEC sp_rename 'pizza_recipes', 'pizza_recipes_temp';

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
	id INT IDENTITY PRIMARY KEY NOT NULL,
	pizza_id INT,
	topping_id INT NOT NULL
);

INSERT INTO pizza_recipes(pizza_id, topping_id)
SELECT 
	pizza_id, 
	TRIM(value) AS topping_id
FROM pizza_recipes_temp
	CROSS APPLY STRING_SPLIT(toppings, ',');

ALTER TABLE pizza_recipes
ADD CONSTRAINT pizza_recepies_topping_id_fk FOREIGN KEY (topping_id) REFERENCES pizza_toppings(topping_id);

ALTER TABLE pizza_recipes
ADD CONSTRAINT pizza_recepies_pizza_id_fk FOREIGN KEY (pizza_id) REFERENCES pizza_names(pizza_id);

-- Table 7: change_type - a new table
--		Create a new table
--		Add a primary key
--		Add values

DROP TABLE IF EXISTS change_type;
CREATE TABLE change_type (
	change_type_id INT PRIMARY KEY,
	change_name VARCHAR(16) NOT NULL
);

INSERT INTO change_type
  (change_type_id, change_name)
VALUES
  (1, 'exclusion'),
  (2, 'extra');


-- Table 8: change_orders - a new table
--		Create a new table
--		Add a primary key
--		Add a foreign key (change_type)
--		Add a foreign key (topping_id)

DROP TABLE IF EXISTS change_orders;
CREATE TABLE change_orders (
  change_id INTEGER IDENTITY PRIMARY KEY,
  customer_order_id INTEGER NOT NULL,
  change_type_id INTEGER,
  topping_id INTEGER,
  CONSTRAINT change_orders_change_type_id_fk FOREIGN KEY (change_type_id) REFERENCES change_type(change_type_id),
  CONSTRAINT change_orders_topping_id_fk FOREIGN KEY (topping_id) REFERENCES pizza_toppings(topping_id),
);

-- Table 2: customer_orders
--		Add a primary key
--		Update columns extras and exclusions

ALTER TABLE customer_orders
ADD customer_order_id INT IDENTITY PRIMARY KEY NOT NULL;

UPDATE customer_orders
SET exclusions = 	CASE exclusions
				WHEN 'null' THEN NULL
				WHEN '' THEN NULL
				ELSE exclusions
			END;

UPDATE customer_orders
SET extras = 	CASE extras
			WHEN '' THEN NULL
			WHEN 'null' THEN NULL
			ELSE extras
		END;

ALTER TABLE customer_orders
ADD CONSTRAINT customer_orders_pizza_id_fk FOREIGN KEY (pizza_id) REFERENCES pizza_names(pizza_id);

ALTER TABLE customer_orders
ADD CONSTRAINT customer_orders_order_id_fk FOREIGN KEY (order_id) REFERENCES runner_orders(order_id);

-- Insert data into table 8: change_orders

INSERT INTO change_orders(customer_order_id, topping_id, change_type_id)
SELECT 
	customer_order_id, 
	TRIM(value) AS topping_id,
	2 AS change_type_id
FROM customer_orders
	CROSS APPLY STRING_SPLIT(extras, ',');

INSERT INTO change_orders(customer_order_id, topping_id, change_type_id)
SELECT 
	customer_order_id, 
	TRIM(value) AS topping_id,
	1 AS change_type_id
FROM customer_orders
	CROSS APPLY STRING_SPLIT(exclusions, ',');

ALTER TABLE change_orders 
ADD CONSTRAINT change_orders_customer_order_id_fk FOREIGN KEY (customer_order_id) REFERENCES customer_orders(customer_order_id);

-- Drop the columns exclusions and extras from table 2: customer_orders

ALTER TABLE customer_orders
DROP COLUMN exclusions, extras;

-- Drop the table pizza_recipes_temp

DROP TABLE pizza_recipes_temp;



----------------------
--E. Bonus Questions--
----------------------

-- If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement 
-- to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

/*
SELECT *
FROM pizza_names;
*/

INSERT INTO pizza_names(pizza_id, pizza_name)
VALUES (3, 'Supreme');

/*
SELECT *
FROM pizza_recipes;

SELECT *
FROM pizza_toppings;
*/

INSERT INTO pizza_recipes(pizza_id, topping_id)
SELECT 
	3,
	topping_id
FROM pizza_toppings;

