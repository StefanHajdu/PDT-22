SELECT COUNT(*) FROM authors -- 5'895'176
SELECT COUNT(*) FROM conversations -- 32'347'011
SELECT COUNT(*) FROM annotations -- 19'458'972
SELECT COUNT(*) FROM context_annotations -- 133'941'462
SELECT COUNT(*) FROM context_domains -- 89
SELECT COUNT(*) FROM context_entities -- 26'940
SELECT COUNT(*) FROM conversation_hashtags -- 54'613'745
SELECT COUNT(*) FROM conversation_references -- 27'950'190
SELECT COUNT(*) FROM links -- 11'540'704
SELECT COUNT(*) FROM hashtags -- 773'865

SELECT pg_size_pretty(pg_total_relation_size('public.authors')); -- 1071 MB
SELECT pg_size_pretty(pg_total_relation_size('public.conversations')); -- 8659 MB
SELECT pg_size_pretty(pg_total_relation_size('public.annotations')); -- 1721 MB
SELECT pg_size_pretty(pg_total_relation_size('public.context_annotations')); -- 10 GB
SELECT pg_size_pretty(pg_total_relation_size('public.context_domains')); -- 80 kB
SELECT pg_size_pretty(pg_total_relation_size('public.context_entities')); -- 3312 kB
SELECT pg_size_pretty(pg_total_relation_size('public.conversation_hashtags')); -- 3888 MB
SELECT pg_size_pretty(pg_total_relation_size('public.conversation_references')); -- 2402 MB
SELECT pg_size_pretty(pg_total_relation_size('public.links')); -- 2022 MB
SELECT pg_size_pretty(pg_total_relation_size('public.hashtags')); -- 88 MB