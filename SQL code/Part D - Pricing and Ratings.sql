--------------------------
--D. Pricing and Ratings--
--------------------------

--Author: Ela Wajdzik
--Date: 18.09.2024 (update 20.09.2024)
--Tool used: Microsoft SQL Server


--USE pizza_runner;


-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

--1 meatlovers -> $12
--2 vegetarian -> $10

SELECT 
	SUM(CASE co.pizza_id
			WHEN 1 THEN 12
			WHEN 2 THEN 10
		END) AS total_revenue
FROM customer_orders co
INNER JOIN runner_orders ro
ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL;

-- 2. What if there was an additional $1 charge for any pizza extras?
--		* Add cheese is $1 extra

WITH pizza_extras AS (
	SELECT	
		customer_order_id,
		COUNT(*) AS number_of_extras
	FROM change_orders
	WHERE change_type_id = 2 --only extras
	GROUP BY customer_order_id)

SELECT 
	SUM(
		CASE co.pizza_id WHEN 1 THEN 12 WHEN 2 THEN 10 END 
			+
		CASE WHEN pe.number_of_extras IS NULL THEN 0 ELSE pe.number_of_extras END
	) AS total_revenue

FROM customer_orders co
INNER JOIN runner_orders ro
ON ro.order_id = co.order_id
LEFT JOIN pizza_extras pe
ON pe.customer_order_id = co.customer_order_id
WHERE ro.cancellation IS NULL;

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you 
-- design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for 
-- each successful customer order between 1 to 5.


DROP TABLE IF EXISTS runner_ratings;
CREATE TABLE runner_ratings (
	order_id INT PRIMARY KEY,
	rating INT,
	CONSTRAINT ruuner_rating_rating_chk CHECK(rating BETWEEN 1 AND 5),
	CONSTRAINT runner_ratings_order_id_fk FOREIGN KEY(order_id) REFERENCES runner_orders(order_id)
)

INSERT INTO runner_ratings(order_id, rating)
VALUES
	(1, 2),
	(2, 3),
	(3, 5),
	(4, 3),
	(5, 5),
	(6, NULL),
	(7, 4),
	(8, 4),
	(9, NULL),
	(10, 5);


-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
--		0* customer_id
--		0* order_id
--		0* runner_id
--		* rating
--		0* order_time
--		0* pickup_time
--		0* Time between order and pickup
--		0* Delivery duration
--		0* Average speed
--		0* Total number of pizzas

WITH customer_order_temp AS (
	SELECT 
		order_id,
		customer_id,
		COUNT(*) AS number_of_pizzas,
		MIN(CAST(order_time AS DATETIME2)) AS order_time
	FROM customer_orders
	GROUP BY order_id, customer_id)

SELECT 
	co.customer_id,
	ro.order_id,
	ro.runner_id,
	rr.rating,
	co.order_time,
	ro.pickup_time,
	DATEDIFF(minute, (co.order_time), (ro.pickup_time)) AS prepare_time_min,
	ro.distance_km,
	ro.duration_min,
	CAST(ro.distance_km / (duration_min / 60.0) AS NUMERIC(3,0)) AS avg_speed,
	co.number_of_pizzas
FROM runner_orders ro
LEFT JOIN customer_order_temp co
ON ro.order_id = co.order_id
LEFT JOIN runner_ratings rr
ON ro.order_id = rr.order_id
WHERE ro.cancellation IS NULL;

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre 
-- traveled - how much money does Pizza Runner have left over after these deliveries?


--1 meatlovers -> $12
--2 vegetarian -> $10

DECLARE @v_cost NUMERIC(6,2);  
DECLARE @v_revenue NUMERIC(6,2); 

SET @v_cost =
	(SELECT 
		CAST(SUM(distance_km) * 0.30 AS NUMERIC(6,2)) AS delivery_cost
	FROM runner_orders ro
	WHERE ro.cancellation IS NULL);

SET @v_revenue =
	(SELECT 
		SUM(CASE co.pizza_id
				WHEN 1 THEN 12
				WHEN 2 THEN 10
			END) AS total_revenue
	FROM customer_orders co
	INNER JOIN runner_orders ro
	ON ro.order_id = co.order_id
	WHERE ro.cancellation IS NULL)

PRINT @v_revenue - @v_cost;

