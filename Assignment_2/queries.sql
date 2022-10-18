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


CREATE TABLE documents  
(
    document_id SERIAL,
    document_text TEXT,

    CONSTRAINT documents_pkey PRIMARY KEY (document_id)
)

INSERT INTO documents (document_text) VALUES  
('Pack my box with five dozen liquor jugs.'),
('Jackdaws love my big sphinx of quartz.'),
('The five boxing wizards jump quickly.'),
('How vexingly quick daft zebras jump!'),
('Bright vixens jump; dozy fowl quack.'),
('Sphinx of black quartz, judge my vow.');

select to_tsvector(document_text) from documents;


INSERT INTO documents (document_text) VALUES  
('Putin is dooche, and it is new world order'),
('new jackass world order, having putin'),
('sdadasd asd as das dasd as das dasd as das putin');

select to_tsvector(document_text) from documents;


create index idx_docu_text_gist on documents using GIST (to_tsvector('simple', document_text));

explain analyze
select 
	document_text
from 
	documents 
where 
	to_tsvector(document_text) @@ to_tsquery('simple', 'Putin & New <-> World <-> Order');

--

create index idx_conv_content_gist on conversations using gist (to_tsvector('english', content));
create index idx_conv_content_gin on conversations using gin (to_tsvector('english', content));

explain 
select 
	* 
from 
	conversations 
where 
	fts_content_eng @@ to_tsquery('english', 'Putin & New <-> World <-> Order') and possibly_sensitive=true;
	

select * from links where url like '%darujme.sk%';

select pg_size_pretty(pg_relation_size('idx_conv_content_gist'));

alter table conversations
	add column fts_content_eng tsvector
		generated always as (to_tsvector('english', coalesce(content,''))) stored;
		
		
select fts_content_eng from conversations limit 10;


create index idx_content_gin on conversations using gin (fts_content_eng);
create index idx_content_gist on conversations using gist (fts_content_eng);

SELECT to_tsvector('english', 
						'Once upon a midnight dreary, while I pondered, weak and weary,
						 Over many a quaint and curious volume of forgotten lore—
				   		 While I nodded, nearly napping, suddenly there came a tapping, Володимир Президент'); 

						 
SELECT to_tsvector('english', 
						'Once upon a midnight dreary, while I pondered, weak and weary,
						 Over many a quaint and curious Президент, volume of forgotten lore—
				   		 While I nodded, nearly napping, suddenly there came a tapping, Володимир ')				 
		@@
		to_tsquery('english', 'Володимир & Президент');
	
	
SELECT to_tsvector('english', 'japanese. FtMゲイ🏳️‍🌈. like：LArc-en-Ciel，ACID ANDROID，Aimer，Yellow Studs．遠藤達哉。yukihiroさんと相馬武志(ex.Jake stone garage)を尊敬。政治家：枝野幸男、石川大我、Володимир Зеленський🇺🇦'); 


SELECT to_tsvector('english', 'japanese. FtMゲイ🏳️‍🌈. like：LArc-en-Ciel，ACID ANDROID，Aimer，Yellow Studs．遠藤達哉。yukihiroさんと相馬武志(ex.Jake stone garage)を尊敬。政治家：枝野幸男、石川大我、Володимир Зеленський🇺🇦') 
		@@
		to_tsquery('english', 'Володимир & Президент');
		
-- #############################	
		
select authors.description 
from authors 
where to_tsvector('english', authors.description) 
		@@ 
	  to_tsquery('english', 'Володимир & Президент');
	  
select authors.username 
from authors 
where to_tsvector('english', authors.username) 
		@@ 
	  to_tsquery('english', 'Володимир & Президент');

-- #############################

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
