-- SPOTIFY DATABASE CREATION
/* Описание проекта.

 Предлагаю свое видение структуры базы данных для стримингового сервиса (в данном случае - SPOTIFY).

 Данная база данных решает следующие задачи:
 - Хранение данных пользователей;
 - Хранение данных авторов контента;
 - Хранение данных о песне или о подкасте;
 - Хранение данных о предпочтениях пользователей (плейлисты, любимые песни, любимые исполнители);
 - Хранение настроек пользователя; 
 */

DROP DATABASE IF EXISTS spotify;
CREATE DATABASE spotify;
USE spotify;

-- База данных состоит из следующих таблиц:
-- Пользователи. Здесь хранятся первичный ключ, уникальный никнейм, электронная почта, хэш_пароль, номер телефона, метка об удалении аккаунта
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
	id SERIAL PRIMARY KEY,
	username VARCHAR(50) UNIQUE NOT NULL,
	email VARCHAR(100) UNIQUE NOT NULL,
	password_hash VARCHAR(100) NOT NULL,
	phone_number BIGINT UNIQUE NOT NULL,
	is_deleted BIT DEFAULT 0
);


/*
 Профиль пользователя. Здесь хранится более расширенная информация о пользователе. 
 Таблица хранит в себе: пол, дату рождения, id аватара пользователя, дату создания аккаунта, 
 страну проживания пользователя(очень полезная информация, если какую-то страну захочется отменить), метка о платной подписке.
 */

DROP TABLE IF EXISTS `profile`;
CREATE TABLE `profile`(
	user_id SERIAL PRIMARY KEY,
	gender CHAR(1),
	date_of_birthday DATE NOT NULL,
	photo_id BIGINT UNSIGNED,
    created_at DATETIME DEFAULT NOW(),
    country VARCHAR(100) NOT NULL,
    premium_account bit default 0,
    
    FOREIGN KEY (user_id) REFERENCES `users`(id) ON UPDATE CASCADE ON DELETE CASCADE
);


/*
 - Исполнитель. Такой же юзер, только по обратную сторону (не потребитель, а автор контента). Может являтся создателем музыки или подкаста.
 Таблица хранит в себе данные: первичный ключ, сценический псевдоним, электронная почта, хэш_пароль, страну проживания.
 */

DROP TABLE IF EXISTS `performer`;
CREATE TABLE `performer` (
	id SERIAL PRIMARY KEY,
	performer_name VARCHAR(50) NOT NULL,
	email VARCHAR(100) UNIQUE NOT NULL,
	password_hash VARCHAR(100) NOT NULL,
	phone_number BIGINT NOT NULL,
	country VARCHAR(100) NOT NULL,
	INDEX performer_performer_name(performer_name)
);


/*
 - Песни. Информация о песне. В таблице содержится информация о продукте творчеста, а именно: первичный ключ, 
 название песни, альбом, текст песни, дата релиза, жанр, размер файла.
 */

DROP TABLE IF EXISTS `songs`;
CREATE TABLE `songs` (
	id SERIAL PRIMARY KEY,
	title VARCHAR(50) NOT NULL,
	album VARCHAR(50) NOT NULL,
	lyrics TEXT,
	realise_date DATE,
	genre VARCHAR(20),
	 `size` INT,
	metadata JSON,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX song_title(title)
);


/*
 - Исполнители песен (т.к. одну песню может исполять несколько исполнителей). 
В таблице содержатся первичный ключ песни и первичный ключ исполнителя.
*/

DROP TABLE IF EXISTS `song_performer`;
CREATE TABLE `song_performer` (
	
	song_id BIGINT UNSIGNED NOT NULL, 
	performer_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (song_id, performer_id),
	FOREIGN KEY (performer_id) REFERENCES `performer`(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (song_id) REFERENCES `songs`(id) ON UPDATE CASCADE ON DELETE CASCADE
);


/*
 - Плейлист. В данной таблице хранятся данные о плейлисте: его первичный ключ и название.
 */

DROP TABLE IF EXISTS `playlists`;
CREATE TABLE `playlists` (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100)
);

-- песни в плейлисте
DROP TABLE IF EXISTS `song_playlists`;
CREATE TABLE `song_playlists` (
	
	song_id BIGINT UNSIGNED NOT NULL, 
	playlist_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (song_id, playlist_id),
	FOREIGN KEY (playlist_id) REFERENCES `playlists`(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (song_id) REFERENCES `songs`(id) ON UPDATE CASCADE ON DELETE CASCADE
);


/*
 - Подкасты. Здесь не делал отдельно таблицу для автора контента, а добавил внешний ключ к таблице performer.
 В остальном таблица фактически повторяется структуру таблицы songs
*/

DROP TABLE IF EXISTS `podcast`;
CREATE TABLE `podcast` (
	id SERIAL PRIMARY KEY,
	performer_id BIGINT UNSIGNED NOT NULL,
	title VARCHAR(50) NOT NULL,
	description TEXT,
	realise_date DATE,
	 `size` INT,
	metadata JSON,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
	FOREIGN KEY (performer_id) REFERENCES `performer`(id) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Плейлисты пользователей. Содержит внешний ключ к таблице пользователя и внешний ключ к таблице плейлистов.
DROP TABLE IF EXISTS `users_playlist`;
CREATE TABLE `users_playlist` (
	user_id BIGINT UNSIGNED NOT NULL, 
	playlist_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (user_id, playlist_id),
	FOREIGN KEY (playlist_id) REFERENCES `playlists`(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES `users`(id) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Подкасты пользователя. Содержит внешний ключ к таблице пользователя и внешний ключ к таблице подкастов.
DROP TABLE IF EXISTS `users_podcast`;
CREATE TABLE `users_podcast`(
	user_id BIGINT UNSIGNED NOT NULL,
	podcast_id BIGINT UNSIGNED NOT NULL,
	is_played BIT DEFAULT 0, 
	-- прослушан ли подкаст или нет
	PRIMARY KEY (user_id, podcast_id),
	FOREIGN KEY (podcast_id) REFERENCES podcast(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES `users`(id) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Любимые песни пользователя. Содержит внешний ключ к таблице пользователя и внешний ключ к таблице песен.
DROP TABLE IF EXISTS `favorite_song`;
CREATE TABLE `favorite_song` (
	user_id BIGINT UNSIGNED NOT NULL,
	song_id BIGINT UNSIGNED NOT NULL,
	
	PRIMARY KEY (song_id, user_id),
	FOREIGN KEY (song_id) REFERENCES `songs`(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES `users`(id) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Любимые исполниетли пользователя. Содержит внешний ключ к таблице пользователя и внешний ключ к таблице исполнителей.
DROP TABLE IF EXISTS `favorite performer`;
CREATE TABLE `favorite performer` (
	user_id BIGINT UNSIGNED NOT NULL,
	performer_id BIGINT UNSIGNED NOT NULL,
	
	PRIMARY KEY (user_id, performer_id),
	FOREIGN KEY (performer_id) REFERENCES `performer`(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES `users`(id) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Настройки пользователя.
DROP TABLE IF EXISTS `users_settings`;
CREATE TABLE `users_settings` (
	user_id SERIAL PRIMARY KEY,
	traffic_economy BIT DEFAULT 0,
	explicit_content BIT DEFAULT 0,
	quality ENUM('auto', 'low', 'standart', 'high', 'highest'),
	private_mode BIT DEFAULT 0,
	push_notification BIT DEFAULT 0,
	download_content BIT DEFAULT 0,
	using_cellular BIT DEFAULT 0,
	
	FOREIGN KEY (user_id) REFERENCES profile(user_id) ON UPDATE CASCADE ON DELETE CASCADE
);
