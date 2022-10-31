/* Написать cкрипт, добавляющий в БД vk, которую создали на 3 вебинаре, 3-4 новые таблицы (с перечнем полей, указанием индексов и внешних ключей).
(по желанию: организовать все связи 1-1, 1-М, М-М)
 */


USE vk;

-- Создаем таблицу Музыка
DROP TABLE IF EXISTS music; 
CREATE TABLE music(
	id SERIAL PRIMARY KEY,
	media_id BIGINT unsigned NOT NULL,
	perfomer VARCHAR(100),
	album VARCHAR(100) COMMENT 'Название альбома',
	title VARCHAR(100) COMMENT 'Название песни',
	lyrics TEXT COMMENT 'текст',
	`reliase date` DATE,
	INDEX music_perfomer_title_idx (perfomer, title),
	
	FOREIGN KEY (media_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Создаем таблицу Видео
DROP TABLE IF EXISTS videos;
CREATE TABLE videos(
	id SERIAL PRIMARY KEY,
	media_id BIGINT unsigned NOT NULL,
	title VARCHAR(100) COMMENT 'Название',
	description TEXT COMMENT 'Описание',
	user_id BIGINT UNSIGNED NOT NULL COMMENT 'Автор видео',
	INDEX videos_perfomer_title_idx (title),
	
	FOREIGN KEY (media_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE, 
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Создаем таблицу Обьявления
DROP TABLE IF EXISTS ads; 
CREATE TABLE ads(
	id SERIAL PRIMARY KEY,
	title VARCHAR(100) COMMENT 'Название',
	description TEXT COMMENT 'Описание объявления',
	location VARCHAR(100),
	user_id BIGINT UNSIGNED NOT NULL,
	`datetime` DATETIME COMMENT 'Дата публикации',
	INDEX ads_title_idx (title),
	
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);