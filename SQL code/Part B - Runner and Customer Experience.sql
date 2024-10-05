-------------------------------------
--B. Runner and Customer Experience--
-------------------------------------

--Author: Ela Wajdzik
--Date: 18.09.2024 (update 20.09.2024)
--Tool used: Microsoft SQL Server


--USE pizza_runner;

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
	CEILING(DATEPART(dayofyear, registration_date) / 7.0) AS number_of_week,
	COUNT(*) AS number_of_runners
FROM runners
GROUP BY CEILING(DATEPART(dayofyear, registration_date) / 7.0);

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH runner_pickup_times AS (
	SELECT 
		ro.order_id,
		ro.runner_id,
		DATEDIFF(minute, co.order_time, ro.pickup_time) AS pickup_time
	FROM runner_orders ro
	LEFT JOIN customer_orders co
	ON co.order_id = ro.order_id

	WHERE ro.cancellation IS NULL
	GROUP BY 	ro.order_id, ro.runner_id, ro.pickup_time, co.order_time)

SELECT
	runner_id,
	AVG(pickup_time) AS avg_pickup_time
FROM  runner_pickup_times
GROUP BY runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH orders_with_prepare_times AS (
	SELECT 
		co.order_id,
		COUNT(*) AS number_of_pizzas,
		DATEDIFF(minute, MIN(co.order_time), MIN(ro.pickup_time)) AS prepare_time_min
	FROM customer_orders co
	INNER JOIN runner_orders ro
	ON ro.order_id = co.order_id

	WHERE ro.cancellation IS NULL
	GROUP BY co.order_id)

SELECT 
	number_of_pizzas AS number_of_pizzas_in_order,
	AVG(prepare_time_min) AS avg_prepare_time_min,
	MIN(prepare_time_min) AS min_prepare_time_min,	-- it is not necessary 
	MAX(prepare_time_min) AS max_prepare_time_min	-- it is not necessary 
FROM orders_with_prepare_times
GROUP BY number_of_pizzas;

-- 4. What was the average distance travelled for each customer?

WITH orders_with_distance AS (
	SELECT 
		co.order_id,
		co.customer_id,
		MIN(ro.distance_km) AS distance_km
	FROM customer_orders co
	INNER JOIN runner_orders ro
	ON co.order_id = ro.order_id

	WHERE ro.cancellation IS NULL
	GROUP BY co.order_id, co.customer_id)

SELECT 
	customer_id,
	CAST (AVG(distance_km) AS NUMERIC(4,1)) AS avg_distance_km
FROM orders_with_distance 
GROUP BY customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT 
	MAX(duration_min) - MIN(duration_min) AS difference_delivery_time
FROM runner_orders
WHERE cancellation IS NULL;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
	order_id,
	runner_id,
	CAST (distance_km / (duration_min /60.0) AS NUMERIC(3,0)) AS avg_speed
	--DATEPART(HOUR, pickup_time)
FROM runner_orders
WHERE cancellation IS NULL;

-- 7. What is the successful delivery percentage for each runner?

SELECT 
	runner_id,
	CAST( SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END)* 100.0 / COUNT(*) AS NUMERIC(4,0)) AS perc_of_successful_delivery
FROM runner_orders
GROUP BY runner_id;