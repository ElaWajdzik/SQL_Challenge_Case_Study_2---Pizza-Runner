# <p align="center"> Case Study #2: 🍕 Pizza Runner

## <p align="center"> D. Pricing and Ratings

### 1. If a Meatlovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?


````sql
SELECT 
	SUM(CASE co.pizza_id
			WHEN 1 THEN 12
			WHEN 2 THEN 10
		END) AS total_revenue
FROM customer_orders co
INNER JOIN runner_orders ro
ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL; --the result includes only the delivered orders
````

#### Result:
| total_revenue |
|---------------|
| 138           | 


### 2. What if there was an additional $1 charge for any pizza extras?

````sql
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
````

#### Steps:
- Create a temporary table (```CTE```) with information about the number of extras.
- Calculate the total price using the ```CASE``` clause.

#### Result:
| total_revenue |
|---------------|
| 142           | 

### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

````sql
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
````

#### Relationship Diagram:
![Copy of Copy of Pizza Runner (11)](https://github.com/user-attachments/assets/1941e823-da78-455d-8166-2ef23ba56392)

### 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
* ``customer_id``
* ``order_id``
* ``runner_id``
* ``rating``
* ``order_time``
* ``pickup_time``
* Time between order and pickup
* Delivery duration
* Average speed
* Total number of pizzas

````sql
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
````

#### Result:
![Zrzut ekranu 2024-09-26 231753](https://github.com/user-attachments/assets/bd70e1e0-c28e-41dd-b8fb-1aba510069ce)

### 5. If a Meatlovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

````sql
DECLARE @v_cost NUMERIC(6,2);  
DECLARE @v_revenue NUMERIC(6,2); 

SET @v_cost =
	(SELECT 
		CAST(SUM(distance_km) * 0.30 AS NUMERIC(6,2)) AS delivery_cost![Uploading Zrzut ekranu 2024-09-26 231753.png…]()

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

PRINT @v_revenue - @v_cost
````

#### Steps:
- Declare two local variables: one for the total cost and one for the total revenue.
- Variable ```@v_cost``` containts the total delivery cost: ```SUM(distance_km) * 0.30```.
- Variable ```@v_revenue``` containts the total revenue from pizza sales: ```CASE co.pizza_id WHEN 1 THEN 12 WHEN 2 THEN 10 END```.
- Print the total profit for Pizza Runner ```PRINT @v_revenue - @v_cost```

#### Result:
$94,44