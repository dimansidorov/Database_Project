/*
 * 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
*/

USE shop;
/*
 * INSERT INTO orders(id, user_id)
VALUES
	(1, 2),
	(2, 3);
 */

SELECT o.user_id AS `ID заказчика`, 
	u.name AS `Имя заказчика`
FROM users u JOIN orders o ON u.id = o.user_id;


/*
 * 2. Выведите список товаров products и разделов catalogs, который соответствует товару.
 */

SELECT 	c.name AS `Тип товара`,
	p.name AS `Наименование товара`,
	p.description AS `Описание товара`,
	p.price AS `Стоимость`
FROM products p JOIN catalogs c ON p.catalog_id = c.id
ORDER BY 1, 4;


