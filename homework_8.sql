/*
1.Пусть задан некоторый пользователь. 
Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
*/

USE vk;

SELECT
    m.from_user_id as `From User Id`,
    -- выбираем отправителя
    CONCAT(u.firstname,' ', u.lastname) AS 'Full Name',
    -- создаем графу с его именем
    COUNT(*) as `Number of Sent Messages`
    -- считаем колличество сообщений
FROM messages m 
JOIN users u ON m.from_user_id = u.id
JOIN friend_requests fr ON (m.from_user_id = fr.initiator_user_id AND m.to_user_id = fr.target_user_id)
							OR 
							(m.from_user_id = fr.target_user_id AND m.to_user_id = fr.initiator_user_id)
WHERE  m.to_user_id = 1 AND fr.status = 'approved'
GROUP BY 1
ORDER BY 3 DESC;


/*
2. Подсчитать общее количество лайков, которые получили пользователи младше 11 лет.
*/

SELECT COUNT(*) AS `Колличество`
FROM likes l 
JOIN media m ON m.id = l.media_id 
JOIN profiles p ON p.user_id = l.user_id 
WHERE TIMESTAMPDIFF(YEAR, p.birthday, NOW()) < 11;

/*
3. Определить кто больше поставил лайков (всего): мужчины или женщины.
*/

SELECT
CASE (p.gender)
         WHEN 'm' THEN 'МУЖ'
         WHEN 'f' THEN 'ЖЕН'
    END AS `Пол` , 
    COUNT(*) AS `Колличество`
FROM profiles p 
JOIN likes l ON p.user_id = l.user_id 
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 1;