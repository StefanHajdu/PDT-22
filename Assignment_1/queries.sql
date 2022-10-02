SELECT * FROM authors

SELECT COUNT(*) FROM authors

SELECT  authors.id, COUNT(authors.id) FROM authors
GROUP BY authors.id
HAVING COUNT(authors.id) > 1

SELECT COUNT(*) FROM authors
SELECT COUNT(*) FROM conversations
SELECT COUNT(*) FROM annotations
SELECT COUNT(*) FROM context_annotations
SELECT COUNT(*) FROM context_domains
SELECT COUNT(*) FROM context_entities
SELECT COUNT(*) FROM conversation_hashtags
SELECT COUNT(*) FROM conversation_references
SELECT COUNT(*) FROM links
SELECT COUNT(*) FROM hashtags

SELECT * FROM authors
SELECT * FROM conversations
SELECT * FROM annotations
SELECT * FROM context_annotations
SELECT * FROM context_domains
SELECT * FROM context_entities
SELECT * FROM conversation_hashtags
SELECT * FROM conversation_references
SELECT * FROM links
SELECT * FROM hashtags

SELECT COUNT(*) FROM authors -- 5'871'810
SELECT COUNT(*) FROM conversations -- 32'347'011
SELECT COUNT(*) FROM annotations -- 19'458'972
SELECT COUNT(*) FROM context_annotations -- 133'941'462
SELECT COUNT(*) FROM context_domains -- 89
SELECT COUNT(*) FROM context_entities -- 26'940
SELECT COUNT(*) FROM conversation_hashtags -- 54'613'745
SELECT COUNT(*) FROM conversation_references -- 28'391'530
SELECT COUNT(*) FROM links -- 11'540'704
SELECT COUNT(*) FROM hashtags -- 773'865