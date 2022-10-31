/*
 * 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.
 */
USE SHOP;
-- Используем функцию NOW(), которая возвращает текущую дату и время
UPDATE users
	SET created_at = NOW();
UPDATE users
	SET updated_at = NOW();

/*
 * 2. Таблица users была неудачно спроектирована. 
 * Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате 20.10.2017 8:10. 
 * Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.
*/
USE SHOP;

-- создаем колонки с корректным типом поля
 ALTER TABLE users 
	ADD created_at_corrected DATETIME, 
	ADD updated_at_corrected DATETIME;

-- при помощи функции STR_TO_DATE() и регулярных выражений приводим дату в неккоректном формате в корректный и записываем в новую колонку
UPDATE users 
	SET created_at_corrected = STR_TO_DATE(created_at, '%d.%m.%Y %l:%i'),
	SET updated_at_corrected = STR_TO_DATE(updated_at, '%d.%m.%Y %l:%i');

-- удаляем старые колонки и переименовываем правильные колонки
ALTER TABLE users 
	DROP created_at, DROP updated_at,
	RENAME COLUMN created_at_corrected TO created_at,
	RENAME COLUMN updated_at_corrected TO updated_at;
	
/*
 * 3. В таблице складских запасов storehouses_products 
 * в поле value могут встречаться самые разные цифры: 0, если товар закончился и выше нуля,
 * если на складе имеются запасы. Необходимо отсортировать записи таким образом, 
 * чтобы они выводились в порядке увеличения значения value. 
 * Однако нулевые запасы должны выводиться в конце, после всех записей.
 */
USE SHOP;

SELECT * 
FROM storehouses_products
ORDER BY IF (value = 0, 1, 0), value;

/*
 * 4.Из таблицы users необходимо извлечь пользователей, 
 * родившихся в августе и мае. Месяцы заданы в виде списка английских названий (may, august)
 */

SELECT *
FROM users
WHERE monthname(birthday_at) IN ('may', 'august');


/*
5. (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. 
SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
Отсортируйте записи в порядке, заданном в списке IN.
*/

SELECT * 
FROM catalogs 
WHERE id IN (5, 1, 2)
ORDER BY FIELD(id, 5, 1, 2);



-- Практическое задание теме «Агрегация данных»

/*
 * 1.Подсчитайте средний возраст пользователей в таблице users.
 * 
*/

SELECT AVG(YEAR(now()) - YEAR(birthday_at)) AS 'Средний возраст'
FROM users;


/*
 * 2.Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели.
Следует учесть, что необходимы дни недели текущего года, а не года рождения.
 */


SELECT
    DAYNAME(CONCAT(YEAR(NOW()), SUBSTRING(birthday_at, 5, 10))) AS `weekday`,
    COUNT(DAYNAME(CONCAT(YEAR(NOW()), SUBSTRING(birthday_at, 5, 10)))) AS `amount of days`
FROM users
GROUP BY `weekday`
ORDER BY 2, 1;
-- получаем день недели при помощи concat, которая совмещает текущий год и оставшуюся часть даты с др
-- и оборачиваем в функцию dayname и считаем.

/*
3. (по желанию) Подсчитайте произведение чисел в столбце таблицы.
*/

DROP TABLE IF EXISTS `произведение чисел`;
CREATE TABLE `произведение чисел` (
	id SERIAL PRIMARY KEY,
	value INT NULL);
	
INSERT INTO `произведение чисел` (value)
VALUES
	(1),
	(2),
	(3),
	(4),
	(5);
	

SELECT exp(SUM(ln(value))) AS `СУММА`
FROM `произведение чисел`;

DROP TABLE IF EXISTS `произведение чисел`;