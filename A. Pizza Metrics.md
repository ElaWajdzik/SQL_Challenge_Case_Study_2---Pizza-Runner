# <p align="center"> Case Study #2: 🍕 Pizza Runner

## <p align="center"> A. Pizza Metrics


### 1. How many pizzas were ordered?

````sql
SELECT COUNT(*) AS number_of_ordered_pizzas
FROM customer_orders;
````

#### Result:
| number_of_ordered_pizzas | 
| ------------------------ | 
| 14                       |

Customers ordered 14 pizzas. . This corresponds to the number of rows in the ```customer_orders``` table.

### 2. How many unique customer orders were made?

````sql
SELECT COUNT(DISTINCT order_id) AS number_of_orders
FROM customer_orders;
````

#### Result:
| number_of_orders | 
| ---------------- | 
| 10               | 

Customers made 10 unique orders. This is determined by counting the distinct ```order_id``` values in the ```customer_orders``` table.

### 3. How many successful orders were delivered by each runner?

````sql
SELECT 
	runner_id,
	COUNT(*) AS number_of_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;
````

#### Result:
| runner_id | number_of_orders |
| --------- | ---------------- |
| 1         | 4                |
| 2         | 3                |
| 3         | 1                |

Three runners delivered orders, and they completed 8 successful deliveries in total.

### 4. How many of each type of pizza was delivered?

````sql
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
````

#### Steps:
- Join the ```customer_orders``` table with the ```runer_orders``` and ```pizza_names``` tables. The data from the ```customer_orders``` table provides information about the number of pizzas ordered.  To filter only the delivered orders, use the ```runner_orders``` and apply the condition ```WHERE ro.cancellation IS NULL```. To show the pizza names instead of their numeric IDs, join with the ```pizza_names``` table.
- Group the resulting data by pizza type and count the number of each type ordered.

#### Result:
| pizza_name | number_of_orders |
| ---------- | ---------------- |
| Meatlovers | 9                |
| Vegetarian | 3                |

The Meatlovers pizza (9 orders) was more popular than the Vegetarian pizza (3 orders).

### 5. How many Vegetarian and Meatlovers were ordered by each customer?

````sql
SELECT 
	co.customer_id,
	pn.pizza_name,
	COUNT(*) AS number_of_orders
FROM customer_orders co
INNER JOIN pizza_names pn
ON pn.pizza_id = co.pizza_id

GROUP BY co.customer_id, pn.pizza_name;
````

#### Result:
| pizza_name | pizza_name | number_of_orders |
|------------|------------|------------------|
| 101        | Meatlovers | 2                |
| 102        | Meatlovers | 2                |
| 103        | Meatlovers | 3                |
| 104        | Meatlovers | 3                |
| 101        | Vegetarian | 1                |
| 102        | Vegetarian | 1                |
| 103        | Vegetarian | 1                |
| 105        | Vegetarian | 1                |

### 6. What was the maximum number of pizzas delivered in a single order?

````sql
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
````

#### Steps:
- Joined the data from ```customer_orderes``` table with the ```runner_orderes``` table to filter for only delivered orders (using the condition ```WHERE ro.cancellation IS NULL```).
- Group the data by  each order using ```GROUP BY co.order_id```.
- Select the largest order using the ```TOP()``` function, sorting the data by the number of pizzas in descending order. ```TOP(1)``` and ```ORDER BY COUNT(*) DESC```.

#### Result:
| order_id | number_of_pizzaa_in_order |
|----------|---------------------------|
| 4        | 3                         |


### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
WITH pizza_with_changes AS (
	SELECT 
		DISTINCT customer_order_id,
		1 AS had_change
	FROM change_orders)

SELECT 
	co.customer_id,
	CASE had_change WHEN 1 THEN 1 ELSE 0 END AS had_change, -- 1 if the pizza was changed, 0 if the pizza was not changed
	COUNT(*) AS number_of_pizzas
FROM customer_orders co
INNER JOIN runner_orders ro
ON co.order_id = ro.order_id
LEFT JOIN pizza_with_changes pc
ON pc.customer_order_id = co.customer_order_id

WHERE ro.cancellation IS NULL
GROUP BY co.customer_id,
	CASE had_change WHEN 1 THEN 1 ELSE 0 END;
````


#### Steps:
- Create a temporary ```pizza_with_changes``` table, which includes the ```customer_order_id``` values that had any changes. I used a ```CTE``` on the data from the ```change_orders``` table. 
- Select olny the delivery orders with ```WHERE ro.cancellation IS NULL```
- Group the data by ```customer_id``` and use a ```CASE``` clause to differentiate between pizzas that had changes and those that didn't: ```CASE had_change WHEN 1 THEN 1 ELSE 0 END```. The ```had_change``` column flags whether the pizza was changed (1) or not changed (0).


#### Result:
| customer_id | had_change | number_of_pizzas |
|-------------|------------|------------------|
| 101         | 0          | 2                |
| 102         | 0          | 3                |
| 104         | 0          | 1                |
| 103         | 1          | 3                |
| 104         | 1          | 2                |
| 105         | 1          | 1                |


### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
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
````

#### Steps:
- Create a temporary table ```pizza_with_exclusions_and_extras``` containing the ```customer_order_id```values that include both exclusions and extras. To combine the two conditions, use an ```INSERSECT``` clause with the ```CTE```. 
- Select only the delivered orders and count the number of pizzas.

#### Result:
| number_of_pizzas | 
|------------------|
| 1                |


### 9. What was the total volume of pizzas ordered for each hour of the day?

````sql
SELECT
	DATEPART(hour, order_time) AS order_hour,
	COUNT(*) AS number_of_pizzas
FROM customer_orders
GROUP BY DATEPART(hour, order_time);
````

#### Steps:
- Select the hour from the ```order_time``` column using the ```DATAPART()``` function.
- Group the data by the hour of the order. This calculation includes all orders, not just the delivered one.

#### Result:
| order_hour | number_of_pizzas | 
|------------|------------------|
| 11         | 1                |
| 13         | 3                |
| 18         | 3                |
| 19         | 1                |
| 21         | 3                |
| 23         | 3                |


### 10. What was the volume of orders for each day of the week?

````sql
--set Monday is first day of week
SET DATEFIRST 1;

SELECT 
	DATEPART(WEEKDAY, order_time) AS weekday,
	COUNT(DISTINCT order_id) AS number_of_orders
FROM customer_orders
GROUP BY DATEPART(WEEKDAY, order_time);
````

#### Steps:
- Set the first day of the week to Monday using ```SET DATEFIRST 1```.
- Group the data by the hour of the order. This calculation includes all orders, not just the delivered one.


#### Result:
| weekday | number_of_orders | 
|---------|------------------|
| 3       | 5                |
| 4       | 2                |
| 5       | 1                |
| 6       | 2                |