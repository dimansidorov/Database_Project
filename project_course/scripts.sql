-- Скрипты 
USE spotify;

-- Узнать какие плейлисты добавил пользователь
SELECT p.name AS `Название плейлиста`
FROM playlists p 
JOIN users_playlist up ON p.id = up.playlist_id 
WHERE up.user_id = 1
ORDER BY 1;


-- Узнать список песен в плейлисте
SELECT p.performer_name AS `Исполнитель`, 
	s.title AS `Название песни`,
	s.album AS `Название альбома`
FROM songs s
JOIN song_playlists sp ON s.id = sp.song_id
JOIN song_performer sp2 ON sp2.song_id = s.id
JOIN performer p ON p.id = sp2.performer_id 
WHERE sp.playlist_id = 1
GROUP BY s.id 
ORDER BY 1;


-- Вывести список песен, дату выхода песни, которые исполняет конкретный исполнитель (через JOIN)
SELECT s.title AS `Название песни`,
	s.realise_date AS `Дата релиза`
FROM songs s 
JOIN song_performer sp ON s.id = sp.song_id 
WHERE sp.performer_id = 1
ORDER by 2;

-- Вывести список песен, дату выхода песни, которые исполняет конкретный исполнитель (через вложенный запрос)
SELECT title AS `Название песни`,
	realise_date AS `Дата релиза`
FROM songs
WHERE id IN (SELECT song_id FROM song_performer WHERE performer_id = 1)
ORDER BY 2;

-- Вывести любимые песни
SELECT p.performer_name AS `Исполнитель`,
	s.title AS `Название песни`
FROM songs s
JOIN favorite_song fs ON s.id = fs.song_id
JOIN song_performer sp ON sp.song_id = s.id 
JOIN performer p ON p.id = sp.performer_id 
WHERE fs.user_id = 1;


-- Вывести любимого(ых) исполнителя
SELECT p.performer_name AS `Любимые исполнители`
FROM performer p 
JOIN `favorite performer` fp ON fp.performer_id = p.id
WHERE fp.user_id = 1;


-- Представления
-- Вывести любимые песни
CREATE OR REPLACE VIEW v_favorite_song AS 
SELECT fs.user_id AS user_id,
	p.performer_name AS `Исполнитель`,
	s.title AS `Название песни`
FROM songs s
JOIN favorite_song fs ON s.id = fs.song_id
JOIN song_performer sp ON sp.song_id = s.id 
JOIN performer p ON p.id = sp.performer_id;

SELECT `Исполнитель`, `Название песни` 
FROM v_favorite_song
WHERE user_id = 1;

-- Посмотреть список песен в плейлисте
CREATE OR REPLACE VIEW v_song_playlist AS
SELECT sp.playlist_id AS playlist_id,
	p.performer_name AS `Исполнитель`, 
	s.title AS `Название песни`,
	s.album AS `Название альбома`
FROM songs s
JOIN song_playlists sp ON s.id = sp.song_id
JOIN song_performer sp2 ON sp2.song_id = s.id
JOIN performer p ON p.id = sp2.performer_id
GROUP BY s.id;

SELECT `Исполнитель`,
	`Название песни`,
	`Название альбома`
FROM v_song_playlist
WHERE playlist_id = 1;

-- Процедура добавления нового пользователя
DROP PROCEDURE IF EXISTS spotify.user_add;

DELIMITER //
//
CREATE DEFINER=`root`@`localhost` PROCEDURE spotify.user_add (IN
username VARCHAR(50), email VARCHAR(100), password_hash VARCHAR(100),
phone_number BIGINT, date_of_birthday DATE, photo_id BIGINT, country VARCHAR(100),
OUT  tran_result varchar(100))
BEGIN
	
	DECLARE `_rollback` BIT DEFAULT 0;
	DECLARE code varchar(100);
	DECLARE error_string varchar(100); 


	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
 		SET `_rollback` = 1;
 		GET stacked DIAGNOSTICS CONDITION 1
			code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
		SET tran_result = concat('Что-то пошло не так. Ошибка: ', code, ' Текст ошибки: ', error_string);
	END;

	START TRANSACTION;
	 INSERT INTO spotify.users (username, email, password_hash, phone_number)
	 VALUES (username, email, password_hash, phone_number) ;
	
	 INSERT INTO spotify.profile (user_id, date_of_birthday, photo_id, country)
	 VALUES (last_insert_id(), date_of_birthday, photo_id, country);
	
	IF `_rollback` THEN
		ROLLBACK;
	ELSE
		SET tran_result = 'Запись добавлена успешно.';
		COMMIT;
	END IF;
END//
DELIMITER ;

CALL spotify.user_add('newuser','newuser@example.com', 'ugsdflsad;k;OIGDP9W8P71', 89999999999, '2014-03-03', 2546869685,'Australia', @tran_result); 
SELECT @tran_result;


-- Процедура удаления пользователя
DROP PROCEDURE IF EXISTS spotify.user_delete;

DELIMITER //
//
CREATE DEFINER=`root`@`localhost` PROCEDURE spotify.user_delete(IN for_user_id BIGINT, 
OUT tran_result varchar(100))
BEGIN
	
	DECLARE `_rollback` BIT DEFAULT 0;
	DECLARE code varchar(100);
	DECLARE error_string varchar(100); 


	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
 		SET `_rollback` = 1;
 		GET stacked DIAGNOSTICS CONDITION 1
			code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
		SET tran_result = concat('Что-то пошло не так. Ошибка: ', code, ' Текст ошибки: ', error_string);
	END;

	START TRANSACTION;
	 DELETE FROM spotify.users u
	 WHERE u.id = for_user_id;
	
	IF `_rollback` THEN
		ROLLBACK;
	ELSE
		SET tran_result = 'Запись удалена успешно.';
		COMMIT;
	END IF;
END//
DELIMITER ;

CALL spotify.user_delete(20, @tran_result);
SELECT @tran_result;


-- Триггеры.
-- Если дата рождения 'из будущего'
DROP TRIGGER IF EXISTS check_user_age;
DELIMITER //
CREATE TRIGGER check_user_age
BEFORE INSERT 
ON profile FOR EACH ROW 
BEGIN 
	IF NEW.date_of_birthday > current_date() THEN 
		SET NEW.date_of_birthday = current_date();
	END IF;
END//
DELIMITER ;

-- Если текста песни нет.
DROP TRIGGER IF EXISTS empty_lyrics;
DELIMITER //
CREATE TRIGGER empty_lyrics
BEFORE INSERT 
ON songs FOR EACH ROW 
BEGIN 
	IF NEW.lyrics IS NULL THEN 
		SET NEW.lyrics = 'Текст отсутсвует';
	END IF;
END//
DELIMITER ;

-- Если дата релиза из будущего
DROP TRIGGER IF EXISTS check_reliase_date;
DELIMITER //
CREATE TRIGGER check_reliase_date
BEFORE INSERT 
ON songs FOR EACH ROW 
BEGIN 
	IF NEW.realise_date > current_date() THEN 
		SET NEW.realise_date = current_date();
	END IF;
END//
DELIMITER ;

-- Если жанр неопределен
DROP TRIGGER IF EXISTS empty_lyrics;
DELIMITER //
CREATE TRIGGER empty_lyrics
BEFORE INSERT 
ON songs FOR EACH ROW 
BEGIN 
	IF NEW.genre IS NULL THEN 
		SET NEW.genre = 'Жанр неопределен';
	END IF;
END//
DELIMITER ;
