
-- 5. korak -> jednostavni upiti


SELECT username, email, date_joined FROM "user" ORDER BY date_joined DESC;

SELECT title, artist, bpm FROM beatmap WHERE bpm > 175;

SELECT score_id, score, accuracy FROM score WHERE accuracy = 100;

SELECT * from profile WHERE country = 'Croatia';

SELECT title, artist, difficulty_rating FROM beatmap WHERE difficulty_rating > 5.5;


-- 6. korak -> upiti nad više tablica


SELECT u.username, b.title, s.score, s.accuracy
FROM score s 
INNER JOIN "user" u USING(user_id)
INNER JOIN beatmap b USING(beatmap_id)
ORDER BY s.score DESC
LIMIT 10;


SELECT username, score, accuracy, achieved_pp 
FROM "user" 
INNER JOIN score s USING(user_id)
INNER JOIN beatmap b USING(beatmap_id)
WHERE s.max_combo = b.max_possible_combo
ORDER BY achieved_pp DESC;


SELECT u1.username AS player1, u2.username AS player2, f.status, f.friends_since
FROM friends f
INNER JOIN "user" u1 ON f.user_id_1 = u1.user_id
INNER JOIN "user" u2 ON f.user_id_2 = u2.user_id;



SELECT b.title, b.artist, b.difficulty_name, u.username FROM beatmap b
INNER JOIN "user" u USING(user_id);



SELECT u.username, s.score, b.title, r.upload_date 
FROM score s
INNER JOIN replay r USING(score_id)
INNER JOIN "user" u USING(user_id)
INNER JOIN beatmap b USING(beatmap_id);




-- 7. korak -> upiti s agregirajućim funkcijama


SELECT u.username, ROUND(AVG(s.accuracy), 2) AS average_accuracy
FROM score s
INNER JOIN "user" u USING(user_id)
GROUP BY u.username
ORDER BY average_accuracy DESC;


SELECT country, count(user_id) AS number_of_players
FROM profile
GROUP BY country
ORDER BY number_of_players DESC;



SELECT b.title, MAX(s.achieved_pp) AS max_pp_on_map
FROM beatmap b
INNER JOIN score s USING(beatmap_id)
GROUP BY b.title
ORDER BY max_pp_on_map DESC;


SELECT u.username, SUM(miss_count) AS total_misses
FROM score s
INNER JOIN "user" u USING(user_id)
GROUP BY u.username
ORDER BY total_misses ASC; 


SELECT u.username, COUNT(s.score_id) AS total_plays
FROM "user" u
JOIN score s USING(user_id)
GROUP BY u.username
ORDER BY total_plays DESC;


-- 8. korak -> podupiti/ugniježdeni upiti/skupovne operacije


SELECT username, total_pp
FROM "user" INNER JOIN profile USING(user_id)
WHERE total_pp > (SELECT AVG(total_pp) FROM profile);


SELECT title, artist
FROM beatmap
WHERE beatmap_id IN (SELECT beatmap_id FROM score
WHERE user_id = (SELECT user_id FROM "user" WHERE username = '-Milky'));


SELECT username 
FROM "user" u
WHERE NOT EXISTS (SELECT 1 FROM score s WHERE s.user_id = u.user_id);


SELECT username, country FROM "user" INNER JOIN profile USING(user_id) WHERE country = 'Croatia'
UNION
SELECT username, country FROM "user" INNER JOIN profile USING(user_id) WHERE country = 'Poland';


SELECT u.username, b.title, s.achieved_pp
FROM score s
INNER JOIN "user" u USING(user_id)
INNER JOIN beatmap b USING(beatmap_id)
WHERE s.achieved_pp = (SELECT MAX(achieved_pp) FROM score);


-- korak 9. -> dodavanje DEFAULT vrijednosti


ALTER TABLE profile ALTER COLUMN level SET DEFAULT 1;

ALTER TABLE profile ALTER COLUMN total_score SET DEFAULT 0;

ALTER TABLE friends ALTER COLUMN status SET DEFAULT 'Pending';


-- korak 10. -> CHECK (uvjeti)


ALTER TABLE profile ADD CONSTRAINT check_accuracy CHECK (accuracy >= 0 AND accuracy <= 100);

ALTER TABLE beatmap ADD CONSTRAINT check_bpm CHECK(bpm > 0);

ALTER TABLE friends ADD CONSTRAINT check_friends_order CHECK (user_id_1 < user_id_2);


-- korak 11. -> komentari na tablice


COMMENT ON TABLE "user" IS 'Pohranjuje osnovne podatke za prijavu i identifikaciju korisnika.';

COMMENT ON COLUMN beatmap.user_id IS 'ID korisnika koji je kreirao mapu.';

COMMENT ON COLUMN score.achieved_pp IS 'Performance points -> mjera vještine za određeni score.';

-- korak 12. -> dodavanje indeksa

CREATE INDEX user_username ON "user"(username);

CREATE INDEX score_user_beatmap ON score(user_id, beatmap_id);

CREATE INDEX friends_status ON friends(status);

-- korak 13. -> procedure

CREATE OR REPLACE PROCEDURE add_new_user(
    p_username VARCHAR,
    p_email VARCHAR,
    p_password VARCHAR,
    p_country VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    new_user_id INTEGER;
BEGIN
    INSERT INTO "user"(username, email, password, date_joined)
    VALUES(p_username, p_email, p_password, NOW())
    RETURNING user_id INTO new_user_id;

    INSERT INTO profile(user_id, country)
    VALUES(new_user_id, p_country);
END;
$$;


-- 2. procedura


CREATE OR REPLACE PROCEDURE accept_friend_request(
    p_requesting_user_id INTEGER,
    p_accepting_user_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_user1 INTEGER;
    v_user2 INTEGER;
    request_exists INTEGER;
BEGIN
    -- osigurava da je manji ID uvijek v_user1
    IF p_requesting_user_id < p_accepting_user_id THEN
        v_user1 := p_requesting_user_id;
        v_user2 := p_accepting_user_id;
    ELSE
        v_user1 := p_accepting_user_id;
        v_user2 := p_requesting_user_id;
    END IF;

    
    SELECT COUNT(*) INTO request_exists
    FROM friends
    WHERE user_id_1 = v_user1
      AND user_id_2 = v_user2
      AND status = 'Pending';

    
    IF request_exists = 1 THEN
        UPDATE friends
        SET status = 'Accepted',
            friends_since = CURRENT_DATE
        WHERE user_id_1 = v_user1
          AND user_id_2 = v_user2;
    ELSE
        
        RAISE EXCEPTION 
		'Nije pronađen zahtjev za prijateljstvo 
		na čekanju između korisnika % and %.', p_requesting_user_id, p_accepting_user_id;
    END IF;
END;
$$;

SELECT * FROM friends WHERE friends.user_id_1 = 4;

CALL accept_friend_request(4,5);


-- korak 14. -> okidaci

CREATE OR REPLACE FUNCTION trig_calc_effective_stats_func()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
	base_bpm INTEGER;
	base_difficulty NUMERIC;
BEGIN
	SELECT bpm, difficulty_rating INTO base_bpm, base_difficulty
	FROM beatmap
	WHERE beatmap_id = NEW.beatmap_id;

	IF NEW.mods_used ILIKE '%dt%' THEN
		NEW.effective_bpm := base_bpm * 1.5;
		NEW.effective_difficulty_rating := base_difficulty * 1.5;
	ELSE
		NEW.effective_bpm := base_bpm;
		NEW.effective_difficulty_rating := base_difficulty;
	END IF;

	RETURN NEW;
END;
$$;

CREATE TRIGGER trig_effective_score
BEFORE INSERT ON score
FOR EACH ROW
EXECUTE FUNCTION trig_calc_effective_stats_func();


SELECT score_id, score, effective_bpm, effective_difficulty_rating FROM score
ORDER BY score DESC
LIMIT 5;


-- 2. okidac

CREATE OR REPLACE FUNCTION check_score_improvement()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    highest_score BIGINT;
BEGIN
    SELECT MAX(score) INTO highest_score
    FROM score
    WHERE user_id = NEW.user_id AND beatmap_id = NEW.beatmap_id;

    IF highest_score IS NOT NULL AND NEW.score <= highest_score THEN
        RAISE EXCEPTION 
		'Novi rezultat (score: %) nije bolji od postojećeg 
		najboljeg rezultata (score: %). Unos je otkazan.', NEW.score, highest_score;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_before_score_insert_improvement
BEFORE INSERT ON score
FOR EACH ROW
EXECUTE FUNCTION check_score_improvement();


-- Rezultat: qxy na 'Desire (Cut Ver.)' -> manji score
INSERT INTO score (score, accuracy, max_combo, miss_count, achieved_pp, date_played, mods_used, user_id, beatmap_id) VALUES
(130000, 99.78, 493, 0, 446, '2023-10-14 11:23:34', 'HDDT',
    (SELECT user_id FROM "user" WHERE username = 'Quiligru'),
    (SELECT beatmap_id FROM beatmap WHERE title = 'Desire (Cut Ver.)')
);

