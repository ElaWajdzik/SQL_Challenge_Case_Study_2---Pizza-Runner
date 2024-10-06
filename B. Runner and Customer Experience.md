# <p align="center"> Case Study #2: 🍕 Pizza Runner

## <p align="center"> B. Runner and Customer Experience

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
SELECT 
	CEILING(DATEPART(dayofyear, registration_date) / 7.0) AS number_of_week,
	COUNT(*) AS number_of_runners
FROM runners
GROUP BY CEILING(DATEPART(dayofyear, registration_date) / 7.0);
````

#### Steps:
- Calculate the week number using the ```DATAPART()``` function to get the day of the year, then divide it by 7 and round up to the whole number using the ```CEILING()``` function: ```CEILING(DATEPART(dayofyear, registration_date) / 7.0)```
- Group the data by the calculated week number.   

#### Result:
| number_of_week | number_of_runners | 
|----------------|-------------------|
| 1              | 2                 |
| 2              | 1                 |
| 3              | 1                 |


### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
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
````

#### Steps:
- Creat a temporary ```CTE``` table that includes the pickup time for every delivered orders. The pickup time is calculeted using the ```DATEDIFF()``` function with the parameter set to minutes: ```DATEDIFF(minute, co.order_time, ro.pickup_time)```.
- Using the data from the temporary table, calculate the average of pickup time for each runner.

#### Result:
| runner_id | avg_pickup_time | 
|-----------|-----------------|
| 1         | 14              |
| 2         | 20              |
| 3         | 10              |

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql 
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
````

In calculation ```DATEDIFF(minute, MIN(co.order_time), MIN(ro.pickup_time))``` I used the aggregation function ```MIN()```, but the ideal approach would be use the aggregation function ```ANY_VALUE()```. Unfortunately, ```ANY_VALUE()``` is not supported in Microsoft SQL Server (although it works in Oracle and Postgres).

#### Result:
![Zrzut ekranu 2024-09-23 140754](https://github.com/user-attachments/assets/91abd117-4d68-4bfb-a2f3-a0670e547cc7)

Base on the collected data, we can speculate that each pizza in an order adds around 10 minutes of preparation time. An order with one pizza takes approximately 10 minutes, with two pizzas around 20 minutes, and so on.

### 4. What was the average distance travelled for each customer?

````sql
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
````

#### Result:
![Zrzut ekranu 2024-09-23 144010](https://github.com/user-attachments/assets/de62c09e-eb9d-4490-8857-f9ea73b1d991)

All customers live approximately 20 km from the Pizza Runner headquarters.

### 5. What was the difference between the longest and shortest delivery times for all orders?

````sql
SELECT 
	MAX(duration_min) - MIN(duration_min) AS difference_delivery_time
FROM runner_orders
WHERE cancellation IS NULL;
````

#### Result:
| difference_delivery_time |
|--------------------------|
| 30                       | 

The differences is 30 minutes. The shortest delivery took 10 minutes, and the longest took 40 minutes.

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
SELECT 
	order_id,
	runner_id,
	CAST (distance_km / (duration_min /60.0) AS NUMERIC(3,0)) AS avg_speed
	--DATEPART(HOUR, pickup_time)
FROM runner_orders
WHERE cancellation IS NULL;
````

#### Result:
![Zrzut ekranu 2024-09-23 150354](https://github.com/user-attachments/assets/630e0948-a673-4d86-bbb0-da209f58569c)

It appears that Runner 2 is using a faster vehicle than the rest of the runners. We can assume that the average speed of delivery is around 40 kilometers per hour.

### 7. What is the successful delivery percentage for each runner?

````sql
SELECT 
	runner_id,
	CAST( SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END)* 100.0 / COUNT(*) AS NUMERIC(4,0)) AS perc_of_successful_delivery
FROM runner_orders
GROUP BY runner_id;
````

#### Result:
![Zrzut ekranu 2024-09-23 150613](https://github.com/user-attachments/assets/2f8eda6b-7511-4e6a-ae71-0abd2d9eb05b)

The first runner (runner_id = 1) has the highest success rate in delivering food.