# <p align="center"> Case Study #2: 🍕 Pizza Runner

## <p align="center"> Database Cleaning Process 

The complete SQL syntax can be found in the file [pizza_runner - Database and Cleaning](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_2---Pizza-Runner/blob/main/SQL%20code/pizza_runner%20-%20Database%20and%20Cleaning.sql)

The existing data model has several issues that need to be addressed before performing any analysis. First, I remodeled the database from its old structure to a new one. The new model includes two additional tables: ```change_orders``` and ```change_types```. These tables contain information about ingredient changes and also help clean up data types in the existing tables.

Old Relationship Diagram
![Pizza Runner](https://github.com/user-attachments/assets/d946f0d3-b188-42a6-b0cd-f6f888e1e6d2 "The old relationship diagram")

New Relationship Diagram After Remodeling
![New Relationship Diagram - pizza_runners](https://github.com/user-attachments/assets/cb63fa9f-a670-406d-89d0-f890aad68097 "The new relationship diagram")

### 🔨 ```runner_orders```

1. Standardized the null values in ```pickup_time``` and ```cancellation``` columns.
2. Added two new numeric columns, distance_km and duration_min, and populated them with data from the distance and duration columns, excluding any text.

````sql

--add new columns
ALTER TABLE runner_orders
ADD 	distance_km NUMERIC(4,1),
	duration_min NUMERIC(3,0);

--insert the numeric values into the new column
UPDATE runner_orders
SET distance_km = CAST(
			CASE distance
				WHEN 'null' THEN NULL
				ELSE TRIM('km' FROM distance)
			END 
			AS NUMERIC(4,1));

--insert the numericvalues to the new column
UPDATE runner_orders
SET duration_min = CAST(
			TRIM('minutes' FROM 
				CASE duration WHEN 'null' THEN NULL ELSE duration END) 
			AS NUMERIC(3,0));

--delate the old columns
ALTER TABLE runner_orders
DROP COLUMN duration, distance;
````

After these stepes, the table changes from the old vesrion (left table) to the new version (right table).
![8WC - week2 - runner_orders](https://github.com/user-attachments/assets/3005dc23-2252-4643-94af-38fd09d59b1d "The table runners_orders")

### 🔨 ```pizza_recipes```

1. Created a new table containing ```pizza_id``` and ```topping_id```, as the old table had non-atomical values in the ```toppings``` column.
2. Inserted the data from old ```pizza_recipes``` table into the new one.

````sql
-- rename the old table
EXEC sp_rename 'pizza_recipes', 'pizza_recipes_temp';

-- create the new pizza_recipes table
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
	id INT IDENTITY PRIMARY KEY NOT NULL,
	pizza_id INT,
	topping_id INT NOT NULL
);

-- insert data into the new table using the STRING_SPLIT() function
INSERT INTO pizza_recipes(pizza_id, topping_id)
SELECT 
	pizza_id, 
	TRIM(value) AS topping_id
FROM pizza_recipes_temp
	CROSS APPLY STRING_SPLIT(toppings, ',');
````

After these steps, the table changes from the old version (left table) to the new version (right table).
![8WC - week 2 - pizza_recipes](https://github.com/user-attachments/assets/186ddf50-9a80-424b-8b20-ad912e3ef835 "The table runners_orders")

### 🔨 ```customer_orders```

1. Create two new tables: ```change_orders``` which include information about extras and exclusions, and ```change_types``` which defines the unique codes for extras and exclusions.
2. Creat a primary key in the ```customer_orders``` table to establish a relationship with the ```change_orders``` table.
3. Insert the data into the ```change_orders``` table.


````sql
--creat the change_types table and insert data
DROP TABLE IF EXISTS change_types;
CREATE TABLE change_types (
	change_type_id INT PRIMARY KEY,
	change_name VARCHAR(16) NOT NULL
);

INSERT INTO change_types
  (change_type_id, change_name)
VALUES
  (1, 'exclusion'),
  (2, 'extra');

--creat the change_orders table
DROP TABLE IF EXISTS change_orders;
CREATE TABLE change_orders (
  change_id INTEGER IDENTITY PRIMARY KEY,
  customer_order_id INTEGER NOT NULL,
  change_type_id INTEGER,
  topping_id INTEGER,
  CONSTRAINT change_orders_change_type_id_fk FOREIGN KEY (change_type_id) REFERENCES change_type(change_type_id),
  CONSTRAINT change_orders_topping_id_fk FOREIGN KEY (topping_id) REFERENCES pizza_toppings(topping_id),
);

--add the ID column to custumer_orders to build relationship with change_orders
ALTER TABLE customer_orders
ADD customer_order_id INT IDENTITY PRIMARY KEY NOT NULL;

--insert the data into change_orders for extras and exclusions
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
````

After these steps, the table changes from the old version (left table) to three new tables (right tables).
![8WC - week 2 - customer_orders](https://github.com/user-attachments/assets/77b8a282-3a77-44dd-8069-f5704227b131 "The table runners_orders")

Update 26.09.2024
In the ```customer_orders``` table, the ```customer_id``` and ```order_time``` columns contain duplicate information. Therefore, it would be beneficial to consider splitting the data into two tables. One table would include the columns ```customer_order_id```, ```order_id```, and ```pizza_id```, while the second one would include ```order_id```, ```customer_id```, and ```order_time```.

This approach would follow the principles of database normalization, which helps reduce redundancy and ensures data integrity in relational databases.

</br>

***
## <p align="center"> E. Bonus Questions

### If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an ``INSERT`` statement to demonstrate what would happen if a new ``Supreme`` pizza with all the toppings was added to the Pizza Runner menu?

````sql
-- add a new type of pizza

INSERT INTO pizza_names(pizza_id, pizza_name)
VALUES (3, 'Supreme');

-- add information about the toppings for the new pizza

INSERT INTO pizza_recipes(pizza_id, topping_id)
SELECT 
	3,
	topping_id
FROM pizza_toppings;
````


<br></br>
***

Thank you for your attention! 🫶️

[Next Section: *Pizza Metrics* ➔](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_2---Pizza-Runner/blob/main/A.%20Pizza%20Metrics.md)

[Return to README ➔](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_2---Pizza-Runner/blob/main/README.md)

