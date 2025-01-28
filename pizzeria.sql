-- Retrieve the total number of orders placed.
SELECT count(order_id) AS 'Total Orders' FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT floor(sum(quantity*price)) AS Total_Revenue
FROM pizzas p 
JOIN order_details od 
ON p.pizza_id=od.pizza_id;

-- Identify the highest-priced pizza.
SELECT pt.name, p.price
FROM pizzas p 
JOIN pizza_types pt
ON p.pizza_type_id=pt.pizza_type_id
ORDER BY price DESC LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT size, sum(quantity) AS Total_orders  
FROM order_details od JOIN pizzas p
ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY Total_orders DESC LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name, SUM(od.quantity) AS Total_pizzas
FROM pizza_types pt JOIN pizzas p ON pt.pizza_type_id= p.pizza_type_id
JOIN order_details od ON od.pizza_id=p.pizza_id
GROUP BY pt.name
ORDER BY Total_pizzas DESC LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category, SUM(od.quantity) AS Quantity
FROM pizza_types pt JOIN pizzas p ON pt.pizza_type_id= p.pizza_type_id
JOIN order_details od ON od.pizza_id=p.pizza_id
GROUP BY pt.category
ORDER BY Quantity;

-- Determine the distribution of orders by hour of the day.
Select HOUR(order_time) AS Hour, COUNT(order_id) as Orders
FROM orders
GROUP BY Hour;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT Category, COUNT(name) AS Pizza_types
FROM pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT Round(AVG(Total_quantity), 2) AS Average FROM
	(SELECT o.order_date, SUM(od.quantity) AS Total_quantity
	FROM orders o JOIN order_details od
	ON o.order_id = od.order_id
	GROUP BY order_date) AS Order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name, SUM(od.quantity * p.price) AS Revenue
FROM pizza_types pt 
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od on od.pizza_id=p.pizza_id
GROUP BY pt.name
ORDER BY Revenue DESC LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.category, ROUND(
	(SUM(od.quantity*p.price) / 
	(SELECT SUM(od.quantity*p.price) AS total_sales 
     FROM pizzas p JOIN order_details od ON p.pizza_id=od.pizza_id) 
     )*100, 2) AS Percent
FROM pizzas p 
JOIN pizza_types pt ON p.pizza_type_id=pt.pizza_type_id
JOIN order_details od ON p.pizza_id=od.pizza_id
GROUP BY pt.category;

-- Analyze the cumulative revenue generated over time.
SELECT order_date, SUM(Revenue) OVER(ORDER BY order_date) AS Cumulative_Revenue 
FROM
	(SELECT o.order_date, SUM(od.quantity*p.price) as Revenue
	FROM order_details od
	JOIN pizzas p ON p.pizza_id=od.pizza_id
	JOIN orders o ON o.order_id=od.order_id
	GROUP BY order_date) AS Sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category, name, Revenue FROM
	(SELECT category, name, Revenue, RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS pizza_rank 
	FROM
		(SELECT pt.category, pt.name, SUM(od.quantity*p.price) as Revenue
		FROM order_details od
		JOIN pizzas p ON p.pizza_id=od.pizza_id
		JOIN pizza_types pt ON pt.pizza_type_id=p.pizza_type_id
		GROUP BY pt.category, pt.name) AS Output1 
	) AS Output2
WHERE pizza_rank<=3;


