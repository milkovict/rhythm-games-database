DROP TABLE IF EXISTS "user", profile, beatmap, score, replay, friends CASCADE;


-- 3. korak -> kreiranje tablica

CREATE TABLE "user" (
    user_id       SERIAL		PRIMARY KEY,
    username      VARCHAR(50)	NOT NULL UNIQUE,
    email         VARCHAR(100)	NOT NULL UNIQUE,
    password      VARCHAR(255)	NOT NULL,     
    date_joined   TIMESTAMP		NOT NULL      
);



CREATE TABLE profile (
    user_id        INTEGER		PRIMARY KEY,
    country        VARCHAR(50),	
    total_score    BIGINT,		   
    global_rank    INTEGER,
    country_rank   INTEGER,
    accuracy       NUMERIC(5,2),
    level          SMALLINT,		
    total_pp	   INTEGER,			
    CONSTRAINT fk_profile_user FOREIGN KEY (user_id) REFERENCES "user"(user_id)
);



CREATE TABLE beatmap (
    beatmap_id       SERIAL         PRIMARY KEY,
    title            VARCHAR(200)   NOT NULL,
    artist           VARCHAR(200)   NOT NULL,
    max_possible_combo INTEGER,
    bpm              INTEGER,                
    length           INTEGER,                	-- izrazeno u sekundama
    difficulty_name  VARCHAR(100)	NOT NULL,
    difficulty_rating NUMERIC(4,2),
    user_id          INTEGER		NOT NULL, 	-- user_id kreatora mape
    CONSTRAINT fk_beatmap_creator FOREIGN KEY (user_id) REFERENCES user(user_id)
);


CREATE TABLE score (
    score_id        SERIAL			PRIMARY KEY,
    score           BIGINT			NOT NULL,    
    accuracy        NUMERIC(5,2)	NOT NULL,
    max_combo       INTEGER			NOT NULL,
    miss_count      INTEGER			NOT NULL,
    effective_bpm 	INTEGER,
    effective_difficulty_rating NUMERIC(4,2),
    date_played     TIMESTAMP      NOT NULL,    
    mods_used       VARCHAR(200),               
    achieved_pp     INTEGER,
    user_id         INTEGER        NOT NULL,
    beatmap_id      INTEGER        NOT NULL,
    CONSTRAINT fk_score_user FOREIGN KEY (user_id) REFERENCES user(user_id),
    CONSTRAINT fk_score_beatmap FOREIGN KEY (beatmap_id) REFERENCES beatmap(beatmap_id)
);


CREATE TABLE replay (
    replay_id     SERIAL         PRIMARY KEY,
    replay_data   BYTEA,                          
    upload_date   TIMESTAMP      NOT NULL,
    score_id      INTEGER        NOT NULL UNIQUE, 
    CONSTRAINT fk_replay_score FOREIGN KEY (score_id) REFERENCES score(score_id)
);


CREATE TABLE friends (
    user_id_1     INTEGER          NOT NULL,
    user_id_2     INTEGER          NOT NULL,
    friends_since DATE,
    status        VARCHAR(20)      NOT NULL,     
    PRIMARY KEY (user_id_1, user_id_2),
    CONSTRAINT fk_friends_user1 FOREIGN KEY (user_id_1) REFERENCES "user"(user_id),
    CONSTRAINT fk_friends_user2 FOREIGN KEY (user_id_2) REFERENCES "user"(user_id)
);



-- 4. korak -> unos podataka


INSERT INTO "user" (username, email, password, date_joined) VALUES
('-Milky', 'milky.game@example.com', 'hashed_milky_password', '2016-06-15 10:20:25'),
('Quiligru', 'quiligru.game@example.com', 'hashed_quiligru_password', '2017-01-20 10:41:05'),
('qxy', 'qxy.game@example.com', 'hashed_qxy_password', '2017-10-16 18:07:24'),
('Kuki', 'kuki.game@example.com', 'hashed_kuki_password', '2015-03-17 21:44:19'),
('Reform', 'reform.game@example.com', 'hashed_reform_password', '2013-12-11 18:50:52');


INSERT INTO profile (user_id, country, total_score, global_rank, country_rank, accuracy, level, total_pp) VALUES
((SELECT user_id FROM "user" WHERE username = '-Milky'), 'Croatia', 154889099268, 4284, 11, 98.92, 101, 10639),
((SELECT user_id FROM "user" WHERE username = 'Quiligru'), 'Bosnia and Herzegovina', 246615714160, 2419, 2, 98.50, 102, 11765),
((SELECT user_id FROM "user" WHERE username = 'qxy'), 'Croatia', 156178753560, 6301, 14, 98.62, 100, 9941),
((SELECT user_id FROM "user" WHERE username = 'Kuki'), 'Poland', 77975390415, 30057, 1320, 98.99, 100, 7051),
((SELECT user_id FROM "user" WHERE username = 'Reform'), 'Ireland', 225715238287, 3096, 13, 98.68, 102, 11289);


SELECT * FROM profile;

-- beatmaps

INSERT INTO beatmap (title, artist, max_possible_combo, bpm, length, difficulty_name, difficulty_rating, user_id) VALUES
('Bye Bye YESTERDAY', '3 Nen E Gumi Utatan', 557, 180, 90, 'Good Good Time', 5.43, 4),
('You Suck At Love (Speed Up Ver.)', 'Simple Plan', 428, 178, 77, 'Extra', 5.69, 5),
('Take You Down', 'Fox Stevenson', 432, 175, 59, 'Ultra', 5.25, 5),
('Desire (Cut Ver.)', 'Sub Focus, Dimension', 493, 174, 88, 'Expert', 4.95 , 5),
('Poison (Cut Ver.)', 'Groove Coverage', 100, 178, 100, 'Chaos Elixir', 5.44, 4),
('Horrible Kids', 'Set It Off', 315, 170, 62, 'Cataclysm', 5.43, 4);

-- Prijateljstva
INSERT INTO friends (user_id_1, user_id_2, status, friends_since) VALUES
((SELECT user_id FROM "user" WHERE username = '-Milky'), (SELECT user_id FROM "user" WHERE username = 'qxy'), 'Accepted', '2018-05-20'),
((SELECT user_id FROM "user" WHERE username = '-Milky'), (SELECT user_id FROM "user" WHERE username = 'Quiligru'), 'Accepted', '2019-11-11');

INSERT into friends(user_id_1, user_id_2, status) VALUES
((SELECT user_id FROM "user" WHERE username = 'Kuki'), (SELECT user_id FROM "user" WHERE username = 'Reform'), 'Pending');

-- Rezultati/scores

-- Rezultat: -Milky na 'Bye Bye YESTERDAY'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id)
VALUES (1145555, 99.41, 557, 0, 600, '2025-06-05 20:30:05', 'DTHD', (SELECT user_id FROM "user" WHERE username = '-Milky'), 
(SELECT beatmap_id FROM beatmap WHERE title = 'Bye Bye YESTERDAY'));

-- Rezultat: qxy na 'Bye Bye YESTERDAY'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id)
VALUES (705830, 96.83, 244, 5, 332, '2024-01-10 13:41:56', 'DT', (SELECT user_id FROM "user" WHERE username = 'qxy'), 
(SELECT beatmap_id FROM beatmap WHERE title = 'Bye Bye YESTERDAY'));

-- Rezultat: Quiligru na 'Bye Bye YESTERDAY'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id)
VALUES (801234, 98.10, 350, 1, 180, '2020-05-17 16:20:34', NULL, (SELECT user_id FROM "user" WHERE username = 'Quiligru'), 
(SELECT beatmap_id FROM beatmap WHERE title = 'Bye Bye YESTERDAY'));

-- Rezultat: -Milky na 'You Suck At Love (Speed Up Ver.)'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id)
VALUES (983046, 97.25, 369, 1, 563, '2025-05-29 20:47:03', 'HDDT', (SELECT user_id FROM "user" WHERE username = '-Milky'), 
(SELECT beatmap_id FROM beatmap WHERE title = 'You Suck At Love (Speed Up Ver.)'));

-- Rezultat: qxy na 'You Suck At Love (Speed Up Ver.)'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id)
VALUES (484192, 90.54, 155, 6, 100, '2020-11-12 13:25:42', NULL, (SELECT user_id FROM "user" WHERE username = 'qxy'), 
(SELECT beatmap_id FROM beatmap WHERE title = 'You Suck At Love (Speed Up Ver.)'));

-- Rezultat: -Milky na 'Take You Down'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id)
VALUES (1119453, 100.00, 432, 0, 545, '2022-11-19 20:55:20', 'HDDT', (SELECT user_id FROM "user" WHERE username = '-Milky'), 
(SELECT beatmap_id FROM beatmap WHERE title = 'Take You Down'));

-- Rezultat: Quiligru na 'Take You Down'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id)
VALUES (969672, 96.42, 402, 2, 348, '2022-11-19 23:54:30', 'HDDT', (SELECT user_id FROM "user" WHERE username = 'Quiligru'), 
(SELECT beatmap_id FROM beatmap WHERE title = 'Take You Down'));

-- Rezultat: qxy na 'Take You Down'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id)
VALUES (1027542, 97.13, 432, 0, 429, '2025-06-09 22:29:17', 'HDDT', (SELECT user_id FROM "user" WHERE username = 'qxy'), 
(SELECT beatmap_id FROM beatmap WHERE title = 'Take You Down'));

-- Rezultat: -Milky na 'Poison (Cut Ver.)'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id) VALUES
(951714, 99.03, 160, 2, 505, '2025-06-12 13:33:24', 'HDDT', (SELECT user_id FROM "user" WHERE username = '-Milky'),
    (SELECT beatmap_id FROM beatmap WHERE title = 'Poison (Cut Ver.)'));

-- Rezultat: qxy na 'Poison (Cut Ver.)'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id) VALUES
(1037411, 97.47, 320, 0, 502, '2025-03-30 20:59:41', 'HDDT', (SELECT user_id FROM "user" WHERE username = 'qxy'),
    (SELECT beatmap_id FROM beatmap WHERE title = 'Poison (Cut Ver.)'));

-- Rezultat: qxy na 'Horrible Kids'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id) VALUES
(994625, 98, 315, 0, 477, '2023-06-22 23:21:00', 'DT', (SELECT user_id FROM "user" WHERE username = 'qxy'),
    (SELECT beatmap_id FROM beatmap WHERE title = 'Horrible Kids'));

-- Rezultat: -Milky na 'Horrible kids'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id) VALUES
(1081632, 98.66, 299, 1, 507, '2024-02-22 23:23:05', 'HDDT', (SELECT user_id FROM "user" WHERE username = '-Milky'),
    (SELECT beatmap_id FROM beatmap WHERE title = 'Horrible Kids'));


-- Rezultat: Quiligru na 'Horrible kids'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id) VALUES
(1066772, 99.24, 304, 1, 509, '2022-10-22 23:10:24', 'HDDT', (SELECT user_id FROM "user" WHERE username = 'Quiligru'),
    (SELECT beatmap_id FROM beatmap WHERE title = 'Horrible Kids'));

-- Rezultat: -Milky na 'Desire (Cut Ver.)'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id) VALUES
(1138807, 99.83, 493, 0, 452, '2024-08-07 23:35:15', 'HDDT',
    (SELECT user_id FROM "user" WHERE username = '-Milky'),
    (SELECT beatmap_id FROM beatmap WHERE title = 'Desire (Cut Ver.)'));

-- Rezultat: qxy na 'Desire (Cut Ver.)'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id) VALUES
(480886, 89.58, 189, 10, 151, '2023-07-14 18:36:36', 'DT', (SELECT user_id FROM "user" WHERE username = 'qxy'),
    (SELECT beatmap_id FROM beatmap WHERE title = 'Desire (Cut Ver.)'));

-- Rezultat: qxy na 'Desire (Cut Ver.)'
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id) VALUES
(1112023, 99.78, 493, 0, 446, '2023-10-14 11:23:34', 'HDDT', (SELECT user_id FROM "user" WHERE username = 'Quiligru'),
    (SELECT beatmap_id FROM beatmap WHERE title = 'Desire (Cut Ver.)'));


-- replays

INSERT INTO replay(score_id, upload_date, replay_data) VALUES (1, NOW(), E'\\xDEADBEEFCAFEBABE');
