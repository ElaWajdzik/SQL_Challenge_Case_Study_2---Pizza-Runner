I practice my SQL skills with the #8WeekSQLChallenge prepared by Danny Ma. Thank you Danny for the excellent case study.
If you are also looking for materials to improve your SQL skills you can find it [here](https://8weeksqlchallenge.com/) and try it yourself.

# <p align="center"> Case Study #2: 🍕 Pizza Runner
<p align="center"> <img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" alt="Image Danny's Diner - the taste of success" height="400">

## Table of Contents
- [Business Case](#business-case)
- [Relationship Diagram](#relationship-diagram)
- [Available Data](#available-data)
- [Case Study Questions](#case-study-questions)


## Business Case
Did you know that over **115 million kilograms** of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.



## Relationship Diagram

<img width="430" alt="graf2" src="https://github.com/ElaWajdzik/8-Week-SQL-Challenge/assets/26794982/b8c108d2-0bf9-40af-867a-ae307acbf921">

## Available Data

<details><summary>
    All datasets exist in database schema.
  </summary> 

#### ``Table 1: runners``

runner_id | registration_date
-- |--
1 | 2021-01-01
2 | 2021-01-03
3 | 2021-01-08
4 | 2021-01-15

#### ``Table 2: customer_orders``

order_id | customer_id | pizza_id | exclusions | extras | order_time
-- |-- | -- | -- | -- | --
1 | 101 | 1 |  |  	 	 | 2021-01-01 18:05:02
2 | 101 | 1 |  	 |  	 | 2021-01-01 19:00:52
3 | 102 | 1 |  	 |  	 | 2021-01-02 23:51:23
3 | 102 | 2 |  	 | NaN	 | 2021-01-02 23:51:23
4 | 103 | 1 | 4 | 	 	 | 2021-01-04 13:23:46
4 | 103 | 1 | 4 |  	 | 2021-01-04 13:23:46
4 | 103 | 2 | 4 |   | 2021-01-04 13:23:46
5 | 104 | 1 | null | 1 | 2021-01-08 21:00:29
6 | 101 | 2 | null | null | 2021-01-08 21:03:13
7 | 105 | 2 | null | 1 | 2021-01-08 21:20:29
8 | 102 | 1 | null | null | 2021-01-09 23:54:33
9 | 103 | 1 | 4 | 1, 5 | 2021-01-10 11:22:59
10 | 104 | 1 | null | null | 2021-01-11 18:34:49
10 | 104 | 1 | 2, 6 | 1, 4 | 2021-01-11 18:34:49

#### ``Table 3: runner_orders``

order_id | runner_id | pickup_time | distance | duration | cancellation
-- |-- |-- |-- |-- |-- |
1 | 1 | 2021-01-01 18:15:34 | 20km | 32 minutes | 
2 | 1 | 2021-01-01 19:10:54 | 20km | 27 minutes | 
3 | 1 | 2021-01-03 00:12:37 | 13.4km | 20 mins | NaN
4 | 2 | 2021-01-04 13:53:03 | 23.4 | 40 | NaN
5 | 3 | 2021-01-08 21:10:57 | 10 | 15 | NaN
6 | 3 | null | null | null | Restaurant Cancellation
7 | 2 | 2020-01-08 21:30:45 | 25km | 25mins | null
8 | 2 | 2020-01-10 00:15:02 | 23.4 km | 15 minute | null
9 | 2 | null | null | null | Customer Cancellation
10 | 1 | 2020-01-11 18:50:20 | 10km | 10minutes | null

#### ``Table 4: pizza_names``

pizza_id | pizza_name
-- |--
1 | Meat Lovers
2 | Vegetarian

#### ``Table 5: pizza_recipes``

pizza_id | toppings
-- |--
1 | 1, 2, 3, 4, 5, 6, 8, 10
2 | 4, 6, 7, 9, 11, 12

#### ``Table 6: pizza_toppings``

topping_id | topping_name
-- |--
1 | Bacon
2 | BBQ Sauce
3 | Beef
4 | Cheese
5 | Chicken
6 | Mushrooms
7 | Onions
8 | Pepperoni
9 | Peppers
10 | Salami
11 | Tomatoes
12 | Tomato Sauce

  </details>


## Case Study Questions
This case study includes questions about:
- [Database cleaning process]()
- [A. Pizza Metrics](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_2---Pizza-Runner/blob/main/A.%20Pizza%20Metrics.md)
- [B. Runner and Customer Experience](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_2---Pizza-Runner/blob/main/B.%20Runner%20and%20Customer%20Experience.md)
- [C. Ingredient Optimisation](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_2---Pizza-Runner/blob/main/C.%20Ingredient%20Optimisation.md)
- [D. Pricing and Ratings](https://github.com/ElaWajdzik/SQL_Challenge_Case_Study_2---Pizza-Runner/blob/main/D.%20Pricing%20and%20Ratings.md)
- [E. Bonus DML Challenges (DML = Data Manipulation Language)]()

<br/>

*** 

 # <p align="center"> Thank you for your attention! 🫶️

**Thank you in advance for reading.** If you have any comments on my work, please let me know. My email address is ela.wajdzik@gmail.com.

Additionally, I am open to new work opportunities. If you are looking for someone with my skills (or know of someone who is), I would be grateful for any information.