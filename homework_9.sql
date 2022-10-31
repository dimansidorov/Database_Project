/* “Транзакции, переменные, представления”
1.В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. 
Используйте транзакции.
*/
USE sample;

START TRANSACTION;
INSERT INTO sample.users (SELECT id, name FROM shop.users WHERE shop.users.id = 1);
COMMIT;

SELECT * FROM users;


/*
2.Создайте представление, 
которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.
*/

USE shop;

CREATE OR REPLACE VIEW test_view AS
	SELECT p.name AS `Наименование товара`,
		c.name AS `Категория товара`
	FROM products p 
	JOIN catalogs c ON p.catalog_id = c.id;
	
SELECT * FROM test_view;



/* “Хранимые процедуры и функции, триггеры"
 * 1.Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
 * С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
 * с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
 */

DROP PROCEDURE IF EXISTS hello;
DELIMITER //
CREATE PROCEDURE hello()
BEGIN
	IF(CURRENT_TIME() BETWEEN '06:00:00' AND '12:00:00') THEN
		SELECT 'Доброе утро';
	ELSEIF(CURRENT_TIME() BETWEEN '12:00:00' AND '18:00:00') THEN
		SELECT 'Добрый день';
	ELSEIF(CURRENT_TIME() BETWEEN '18:00:00' AND '00:00:00') THEN
		SELECT 'Добрый вечер';
	ELSE
		SELECT 'Доброй ночи';
	END IF;
END //
DELIMITER ;

CALL hello();