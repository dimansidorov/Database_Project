/*
1.Пусть задан некоторый пользователь. 
Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
*/
USE vk;

SELECT
    from_user_id as 'From User Id',
    -- выбираем отправителя
    (SELECT CONCAT(firstname,' ', lastname) FROM users WHERE id = messages.from_user_id) AS 'Full Name',
    -- создаем графу с его именем
    COUNT(*) as `Number of Sent Messages`
    -- считаем колличество сообщений
FROM messages 
WHERE  to_user_id = 1 
AND from_user_id IN (
     SELECT initiator_user_id as friends FROM friend_requests 
     WHERE status ='approved' AND target_user_id = 1
     UNION
     SELECT target_user_id FROM friend_requests 
     WHERE status ='approved' AND initiator_user_id = 1
)
-- условие, где мы отсеиваем только друзей для юзера 1
GROUP BY from_user_id
ORDER BY `Number of Sent Messages` DESC;
-- группируем, сортируем от максимального и выводим ответ согласно условию задачи

/*
2. Подсчитать общее количество лайков, которые получили пользователи младше 11 лет.
*/

/*
 * SELECT id, CONCAT(firstname,' ', lastname) 
	FROM users 
	WHERE id IN (SELECT user_id FROM profiles WHERE YEAR(NOW()) - YEAR(birthday) < 11)
	ORDER BY id;
	-- делал для себя, чтобы посмотреть пользователей младше 11 лет
*/

SELECT COUNT(*) AS 'Колличество'
FROM likes
WHERE media_id IN (
	SELECT id 
	FROM media 
	WHERE user_id IN (
		SELECT user_id 
		FROM profiles 
		WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 11));


/*
 * 3. Определить кто больше поставил лайков (всего): мужчины или женщины.
 */


SELECT
CASE (gender)
         WHEN 'm' THEN 'МУЖ'
         WHEN 'f' THEN 'ЖЕН'
    END AS `Пол` , 
    COUNT(*) AS `Колличество`
FROM (SELECT user_id AS u,
		(SELECT gender 
			FROM vk.profiles
			WHERE u = user_id) AS gender
			FROM likes) AS d
-- где юзер есть в лайках
GROUP BY `Пол`
ORDER BY `Колличество` DESC 
LIMIT 2;
-- -- группируем, сортируем от максимального и выводим ответ согласно условию задачи
