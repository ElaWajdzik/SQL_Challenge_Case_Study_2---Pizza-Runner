------------------------------
--C. Ingredient Optimisation--
------------------------------

--Author: Ela Wajdzik
--Date: 18.09.2024 (update 20.09.2024)
--Tool used: Microsoft SQL Server


--USE pizza_runner;

-- 1. What are the standard ingredients for each pizza?

SELECT
	pn.pizza_name,
	STRING_AGG (pt.topping_name, ', ') AS ingredients
FROM pizza_recipes pr
INNER JOIN pizza_names pn
ON pn.pizza_id = pr.pizza_id
INNER JOIN pizza_toppings pt
ON pt.topping_id = pr.topping_id
GROUP BY pn.pizza_name;

-- 2. What was the most commonly added extra?

SELECT 
	pt.topping_name,
	COUNT(*) AS number_of_added_toppings
FROM change_orders co
INNER JOIN change_type ct
ON co.change_type_id = ct.change_type_id
INNER JOIN pizza_toppings pt
ON pt.topping_id = co.topping_id

WHERE ct.change_name = 'extra'
GROUP BY pt.topping_name
ORDER BY COUNT(*) DESC;

-- 3. What was the most common exclusion?

SELECT 
	pt.topping_name,
	COUNT(*) AS number_of_added_toppings
FROM change_orders co
INNER JOIN change_type ct
ON co.change_type_id = ct.change_type_id
INNER JOIN pizza_toppings pt
ON pt.topping_id = co.topping_id

WHERE ct.change_name = 'exclusion'
GROUP BY pt.topping_name
ORDER BY COUNT(*) DESC;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--			Meatlovers
--			Meatlovers - Exclude Beef
--			Meatlovers - Extra Bacon
--			Meatlovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH pizza_exclusions AS (
	SELECT 
		co.customer_order_id,
		'Exclude ' + STRING_AGG(pt.topping_name, ', ') AS list_of_exclusions
	FROM change_orders co
	INNER JOIN pizza_toppings pt
	ON co.topping_id = pt.topping_id
	wHERE co.change_type_id = 1 --1 is exclusion
	GROUP BY co.customer_order_id),

pizza_extras AS (
	SELECT 
		co.customer_order_id,
		'Extra ' + STRING_AGG(pt.topping_name, ', ') AS list_of_extras
	FROM change_orders co
	INNER JOIN pizza_toppings pt
	ON co.topping_id = pt.topping_id
	wHERE co.change_type_id = 2 --2 is extras
	GROUP BY co.customer_order_id)

SELECT
	co.customer_order_id,
	CONCAT(pn.pizza_name, ' - ' + exc.list_of_exclusions, ' - ' + ext.list_of_extras)
FROM customer_orders co
INNER JOIN pizza_names pn
ON pn.pizza_id = co.pizza_id
LEFT JOIN pizza_exclusions exc
ON co.customer_order_id = exc.customer_order_id
LEFT JOIN pizza_extras ext
ON co.customer_order_id = ext.customer_order_id;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--			For example: "Meatlovers: 2xBacon, Beef, ... , Salami"

WITH all_ingredient AS (
	SELECT 
		co.customer_order_id,
		co.pizza_id,
		pr.topping_id,
		1 AS number
	FROM customer_orders co
	INNER JOIN pizza_recipes pr
	ON co.pizza_id = pr.pizza_id

	UNION ALL

	SELECT 
		cho.customer_order_id,
		co.pizza_id,
		cho.topping_id,
		CASE cho.change_type_id WHEN 1 THEN -1 ELSE 1 END AS number
	FROM change_orders cho
	LEFT JOIN customer_orders co
	ON co.customer_order_id = cho.customer_order_id),

all_count_ingredient AS (
	SELECT 
		ai.customer_order_id,
		pn.pizza_name,
		pt.topping_name,
		SUM(ai.number) AS number
	FROM all_ingredient ai
	INNER JOIN pizza_names pn
	ON ai.pizza_id = pn.pizza_id
	INNER JOIN pizza_toppings pt
	ON ai.topping_id = pt.topping_id
	GROUP BY ai.customer_order_id, pn.pizza_name, pt.topping_name
	HAVING SUM(ai.number) > 0)
	
SELECT 
	customer_order_id,
	pizza_name,
	STRING_AGG(CASE number 
					WHEN 1 THEN topping_name
					ELSE CAST(number AS VARCHAR(3)) + 'x' + topping_name
				END, ', ') 
			WITHIN GROUP (ORDER BY topping_name ASC) AS list_of_ingredient
FROM all_count_ingredient
GROUP BY customer_order_id, pizza_name;


-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

WITH all_ingredient AS (
	SELECT 
		co.customer_order_id,
		co.pizza_id,
		pr.topping_id,
		1 AS number
	FROM customer_orders co
	INNER JOIN pizza_recipes pr
	ON co.pizza_id = pr.pizza_id
	INNER JOIN runner_orders ro
	ON co.order_id = ro.order_id
	WHERE ro.cancellation IS NULL

	UNION ALL

	SELECT 
		cho.customer_order_id,
		co.pizza_id,
		cho.topping_id,
		CASE cho.change_type_id WHEN 1 THEN -1 ELSE 1 END AS number
	FROM change_orders cho
	LEFT JOIN customer_orders co
	ON co.customer_order_id = cho.customer_order_id
	INNER JOIN runner_orders ro
	ON co.order_id = ro.order_id
	WHERE ro.cancellation IS NULL)


SELECT 
	--ai.customer_order_id,
	--pn.pizza_name,
	pt.topping_name,
	SUM(ai.number) AS total_quantity
FROM all_ingredient ai
INNER JOIN pizza_names pn
ON ai.pizza_id = pn.pizza_id
INNER JOIN pizza_toppings pt
ON ai.topping_id = pt.topping_id
GROUP BY pt.topping_name
HAVING SUM(ai.number) > 0
ORDER BY SUM(number) DESC;