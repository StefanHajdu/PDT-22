EXPLAIN SELECT * FROM conversations WHERE language='ger' OR language='ru' OR language='cro';

EXPLAIN SELECT DISTINCT language FROM conversations;
SELECT DISTINCT language FROM conversations;

CREATE INDEX idx_langs ON conversations USING BTREE (language);

EXPLAIN ANALYZE SELECT * FROM conversations WHERE language='sl' OR language='ru';
EXPLAIN ANALYZE SELECT * FROM conversations WHERE language='sl';

-- Now small class field
EXPLAIN ANALYZE SELECT * FROM conversations WHERE possibly_sensitive=True;

CREATE INDEX idx_pos_sensi ON conversations USING BTREE (possibly_sensitive);

EXPLAIN ANALYZE SELECT * FROM conversations WHERE possibly_sensitive=False;

-- Now intervals
EXPLAIN ANALYZE SELECT * FROM authors WHERE (followers_count > 100) AND (followers_count <= 200);

CREATE INDEX idx_follow_cnt ON authors USING BTREE (followers_count);

EXPLAIN ANALYZE SELECT * FROM authors WHERE (followers_count >= 100) AND (followers_count <= 120);

CREATE INDEX idx_follow_interval ON authors USING BTREE (followers_count) WHERE (followers_count > 100) AND (followers_count <= 200);

SELECT to_tsvector('english', 
						'Once upon a midnight dreary, while I pondered, weak and weary,
						 Over many a quaint and curious volume of forgotten lore—
				   		 While I nodded, nearly napping, suddenly there came a tapping,');
						 
						 
SELECT to_tsvector('english', 
						'Once upon a midnight dreary, while I pondered, weak and weary,
						 Over many a quaint and curious volume of forgotten lore—
				   		 While I nodded, nearly napping, suddenly there came a tapping,') @@
to_tsquery('english', 'tap & hello');

SELECT * FROM ts_debug('english', 'Once upon a midnight dreary, while I pondered');

SELECT to_tsquery('english', 'tap & hello');

--
-- ZADANIE II
--

-- 1
select * from authors where username = 'mfa_russia';
create index idx_authors_username on authors using BTREE (username);
set max_parallel_workers_per_gather to 2;

-- 4
create index idx_authors_follow_cnt on authors using BTREE (followers_count);
select * from authors where followers_count >= 100 and followers_count <= 200;
select * from authors where followers_count >= 100 and followers_count <= 120;

-- 5
create index idx_authors_name on authors using BTREE (name);
create index idx_authors_follow_cnt on authors using BTREE (followers_count);
create index idx_authors_desc on authors using BTREE (description);

insert into authors values (99, 'StefanHajdu', 'stevexo', 'james bond fan', 1212, 1516, 22, 565);

drop index idx_authors_name;
drop index idx_authors_follow_cnt;
drop index idx_authors_desc;
drop index idx_authors_username;

insert into authors values (9898595, 'StefanHajdu', 'stevexo', 'james bond fan', 1212, 1516, 22, 565);

-- 10

select * from conversations where content like '% Gates%';

create index on conversations using BTREE (content);

-- 11
