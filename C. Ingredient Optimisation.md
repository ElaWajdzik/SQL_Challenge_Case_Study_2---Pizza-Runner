# <p align="center"> Case Study #2: 🍕 Pizza Runner

## <p align="center"> C. Ingredient Optimisation

### 1. What are the standard ingredients for each pizza?

````sql
SELECT
	pn.pizza_name,
	STRING_AGG (pt.topping_name, ', ') AS ingredients
FROM pizza_recipes pr
INNER JOIN pizza_names pn
ON pn.pizza_id = pr.pizza_id
INNER JOIN pizza_toppings pt
ON pt.topping_id = pr.topping_id
GROUP BY pn.pizza_name;
````
![Zrzut ekranu 2024-09-23 153655](https://github.com/user-attachments/assets/7f172604-fd39-4008-b88d-fd231bdc500e)

### 2. What was the most commonly added extra?

````sql
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
````
![Zrzut ekranu 2024-09-23 153823](https://github.com/user-attachments/assets/57b73660-1b22-47b8-b329-60f6c23e7d86)

Customers of Pizza Runner seem to like adding becon to their pizza. Creating a new kind of pizza with backon could be a good move for the business.

### 3. What was the most common exclusion?

````sql
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
````
![Zrzut ekranu 2024-09-23 154144](https://github.com/user-attachments/assets/15ea1fe3-4357-4ba0-9649-e10ac389c225)

The most commonly excluded ingredient was cheese. This suggests that some customers may be vegan, so adding vegan options to the menu could be a good idea.

### 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

````sql 
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
````

#### Steps:
- Create two temporary tables with lists of extras and exclusions using the ```STRING_AGG()``` functions: ```'Extra ' + STRING_AGG(pt.topping_name, ', ')```.
- Create the final list in the expected format using a ```CONCAT()``` function: ```CONCAT(pn.pizza_name, ' - ' + exc.list_of_exclusions, ' - ' + ext.list_of_extras)```.

#### Result:
![Zrzut ekranu 2024-09-23 154407](https://github.com/user-attachments/assets/6bdaea05-8eae-4d72-bc11-328ed685a049)

### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meatlovers: 2xBacon, Beef, ... , Salami"

````sql
WITH all_ingredients AS (
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

all_count_ingredients AS (
	SELECT 
		ai.customer_order_id,
		pn.pizza_name,
		pt.topping_name,
		SUM(ai.number) AS number
	FROM all_ingredients ai
	INNER JOIN pizza_names pn
	ON ai.pizza_id = pn.pizza_id
	INNER JOIN pizza_toppings pt
	ON ai.topping_id = pt.topping_id
	GROUP BY ai.customer_order_id, pn.pizza_name, pt.topping_name
	HAVING SUM(ai.number) > 0)
	
SELECT 
	customer_order_id,
	pizza_name,
	STRING_AGG(	CASE number 
				WHEN 1 THEN topping_name
				ELSE CAST(number AS VARCHAR(3)) + 'x' + topping_name
			END, ', ')
		WITHIN GROUP (ORDER BY topping_name ASC) AS list_of_ingredient
FROM all_count_ingredients
GROUP BY customer_order_id, pizza_name;
````

#### Steps:
- Create a temporary table ```all_ingredients``` containing the columns ```customer_order_id```, ```pizza_id```, ```topping_id``` and ```number```. The ```number``` column contains 1 if the toppings should be on the pizza and -1 if the topping shoud be excluded. 
- Create a second temporary table ```all_count_ingredients``` based on the ```all_ingredients``` table, which aggregates the informaction about toppings and adds the pizza name and topping names. In this table, filter out toppings that should not be used on the pizza (```HAVING SUM(ai.number) > 0```).
- Generate a list of topping names for each ordered pizza using the ```STRING_AGG()``` function and ```CASE``` to add the information about multiples (e.g., "2x" for toppings used twice).

#### Result:
![Zrzut ekranu 2024-09-23 162852](https://github.com/user-attachments/assets/d69a0f57-3046-4dba-bcdd-50942fbd0364)


### 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

````sql
WITH all_ingredients AS (
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
	pt.topping_name,
	SUM(ai.number) AS total_quantity
FROM all_ingredients ai
INNER JOIN pizza_names pn
ON ai.pizza_id = pn.pizza_id
INNER JOIN pizza_toppings pt
ON ai.topping_id = pt.topping_id
GROUP BY pt.topping_name
HAVING SUM(ai.number) > 0
ORDER BY SUM(number) DESC;
````

#### Steps:
- Create a temporary table ```all_ingredients``` with columns ```customer_order_id```, ```pizza_id```, ```topping_id``` and ```number```, where ```number``` is 1 for toppings should be included and -1 for toppings that shoud be excluded. The step is the same as in Question 5.
- Group all ingriedients by the name of topping and sort them by usage frequency. 

#### Result:
![Zrzut ekranu 2024-09-23 165448](https://github.com/user-attachments/assets/37d269a5-b2b7-4dae-9058-bb254eaf3eee)

The most common ingrediont is bacon. Customers of Pizza Runner seem to like becon on their pizza (it was also the most popular extra added). Creating a new kind of pizza with backon could be a good move for the business.