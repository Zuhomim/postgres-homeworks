-- Напишите запросы, которые выводят следующую информацию:
-- 1. Название компании заказчика (company_name из табл. customers) и ФИО сотрудника, работающего над заказом этой компании (см таблицу employees),
-- когда и заказчик и сотрудник зарегистрированы в городе London, а доставку заказа ведет компания United Package (company_name в табл shippers)
SELECT customers.company_name AS customer,
CONCAT(employees.first_name, ' ', employees.last_name) as employee
FROM orders
JOIN customers USING(customer_id)
JOIN employees USING(employee_id)
WHERE
(
	EXISTS
	(
		SELECT * FROM customers WHERE city IN ('London')
		AND orders.customer_id=customers.customer_id
	)
	AND
	    EXISTS
        (
            SElECT * FROM employees WHERE city IN ('London')
            AND orders.employee_id=employees.employee_id
        )
	AND
	    EXISTS
        (
            SELECT * FROM shippers WHERE company_name IN ('United Package')
            AND orders.ship_via=shippers.shipper_id
        )
);

-- 2. Наименование продукта, количество товара (product_name и units_in_stock в табл products),
-- имя поставщика и его телефон (contact_name и phone в табл suppliers) для таких продуктов,
-- которые не сняты с продажи (поле discontinued) и которых меньше 25 и которые в категориях Dairy Products и Condiments.
-- Отсортировать результат по возрастанию количества оставшегося товара.
SELECT product_name, units_in_stock, suppliers.contact_name, suppliers.phone
FROM products
JOIN suppliers USING(supplier_id)
WHERE (
	category_id IN
	(
		SELECT category_id FROM categories
		WHERE categories.category_name IN ('Dairy Products', 'Condiments')
	)
	AND
		discontinued = 0
	AND
		units_in_stock < 25
)
ORDER BY units_in_stock;


-- 3. Список компаний заказчиков (company_name из табл customers), не сделавших ни одного заказа
SELECT company_name
FROM customers
WHERE NOT EXISTS(
	SELECT * FROM orders
	WHERE orders.customer_id = customers.customer_id
);

-- 4. уникальные названия продуктов, которых заказано ровно 10 единиц (количество заказанных единиц см в колонке quantity табл order_details)
-- Этот запрос написать именно с использованием подзапроса.
SELECT product_name FROM products
WHERE product_id IN (
	SELECT DISTINCT product_id FROM order_details WHERE quantity = 10
);
