--------------------
--A. Pizza Metrics--
--------------------

--Author: Ela Wajdzik
--Date: 18.09.2024 (update 20.09.2024)
--Tool used: Microsoft SQL Server


--USE pizza_runner;

-- 1. How many pizzas were ordered?

SELECT COUNT(*) AS number_of_ordered_pizzas
FROM customer_orders;

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS number_of_orders
FROM customer_orders;

-- 3. How many successful orders were delivered by each runner?

SELECT 
	runner_id,
	COUNT(*) AS number_of_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?

SELECT 
	pn.pizza_name,
	COUNT(*) AS number_of_orders
FROM customer_orders co
INNER JOIN runner_orders ro
ON ro.order_id = co.order_id
INNER JOIN pizza_names pn
ON pn.pizza_id = co.pizza_id

WHERE ro.cancellation IS NULL
GROUP BY pn.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT 
	co.customer_id,
	pn.pizza_name,
	COUNT(*) AS number_of_orders
FROM customer_orders co
--INNER JOIN runner_orders ro
--ON ro.order_id = co.order_id
INNER JOIN pizza_names pn
ON pn.pizza_id = co.pizza_id

--WHERE ro.cancellation IS NULL
GROUP BY co.customer_id, pn.pizza_name;

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT 
	TOP(1)
	co.order_id,
	COUNT(*) AS number_of_pizzas_in_order
FROM customer_orders co
INNER JOIN runner_orders ro
ON co.order_id = ro.order_id

WHERE ro.cancellation IS NULL
GROUP BY co.order_id
ORDER BY COUNT(*) DESC;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

WITH pizza_with_changes AS (
	SELECT 
		DISTINCT customer_order_id,
		1 AS had_change
	FROM change_orders)

SELECT 
	co.customer_id,
	CASE had_change WHEN 1 THEN 1 ELSE 0 END AS had_change,
	COUNT(*) AS number_of_pizzas
FROM customer_orders co
INNER JOIN runner_orders ro
ON co.order_id = ro.order_id
LEFT JOIN pizza_with_changes pc
ON pc.customer_order_id = co.customer_order_id

WHERE ro.cancellation IS NULL
GROUP BY co.customer_id,
	CASE had_change WHEN 1 THEN 1 ELSE 0 END;

-- 8. How many pizzas were delivered that had both exclusions and extras?

WITH pizza_with_exclusions_and_extras AS (
	SELECT DISTINCT customer_order_id
	FROM change_orders
	WHERE change_type_id = 1

	INTERSECT

	SELECT DISTINCT customer_order_id
	FROM change_orders
	WHERE change_type_id = 2)

SELECT COUNT(*) AS number_of_pizzas
FROM customer_orders co
INNER JOIN runner_orders ro
ON ro.order_id = co.order_id
INNER JOIN pizza_with_exclusions_and_extras p
ON p.customer_order_id = co.customer_order_id

WHERE ro.cancellation IS NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT
	DATEPART(hour, order_time) AS order_hour,
	COUNT(*) AS number_of_pizzas
FROM customer_orders
GROUP BY DATEPART(hour, order_time);

-- 10. What was the volume of orders for each day of the week?

--set Monday is first day of week
SET DATEFIRST 1;

SELECT 
	DATEPART(WEEKDAY, order_time) AS weekday,
	COUNT(DISTINCT order_id) AS number_of_orders
FROM customer_orders
GROUP BY DATEPART(WEEKDAY, order_time);
