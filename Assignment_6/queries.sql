create table z_4_mongo as -- 1840128
	select
		conversations.id,
		json_build_object(
			'_id',  (conversations.id)::text,
			'metadata', conversations,
			'author', authors,
			'annotations', annotations, 
			'links', links,  
			'domains', domains, 
			'entities', entities, 
			'hashtags', hashtags
		) as tweet
	from 
		conversations
	inner join
		authors
	on
		conversations.author_id = authors.id
	left join
		(
			select
				conversations.id as conv_annot_id, json_agg(annotations) as annotations
			from
				conversations
			left join
				annotations
			on
				conversations.id = annotations.conversation_id
			group by
				conversations.id
		) as conv_annot
	on
		conversations.id = conv_annot_id
	left join
		(
			select
				conversations.id as conv_links_id, json_agg(links) as links
			from
				conversations
			left join
				links
			on
				conversations.id = links.conversation_id
			group by
				conversations.id
		) as conv_links
	on
		conversations.id = conv_links_id
	left join
		(
			select
				conversations.id as conv_domain_id, json_agg(context_domains) as domains
			from
				conversations
			left join
				context_annotations
			on
				conversations.id = context_annotations.conversation_id
			left join
				context_domains
			on
				context_annotations.context_domain_id = context_domains.id
			group by 
				conversations.id
		) as conv_domain
	on
		conversations.id = conv_domain_id
	left join
		(
			select
				conversations.id as conv_entity_id, json_agg(context_entities) as entities
			from
				conversations
			left join
				context_annotations
			on
				conversations.id = context_annotations.conversation_id
			left join
				context_entities
			on
				context_annotations.context_domain_id = context_entities.id
			group by 
				conversations.id
		) as conv_entities
	on
		conversations.id = conv_entity_id
	left join
		(
			select
				conversations.id as conv_tag_id, json_agg(hashtags) as hashtags
			from
				conversations
			left join
				conversation_hashtags
			on
				conversations.id = conversation_hashtags.conversation_id
			left join
				hashtags
			on
				conversation_hashtags.hashtag_id = hashtags.id
			group by 
				conversations.id
		) as conv_hash
	on 
		conversations.id = conv_tag_id
	where conversations.created_at between '2022-02-24 00:00:00' and '2022-02-24 23:59:59';

create table z_data_4_mongo as
	select
		z_4_mongo.id,
		json_build_object(
			'_id', (z_4_mongo.id)::text,
			'metadata', z_4_mongo.tweet->'metadata',
			'author', z_4_mongo.tweet->'author',
			'annotations', z_4_mongo.tweet->'annotations', 
			'links', z_4_mongo.tweet->'links',  
			'domains', z_4_mongo.tweet->'domains', 
			'entities', z_4_mongo.tweet->'entities', 
			'hashtags', z_4_mongo.tweet->'hashtags',
			'referencies', referencies
		) as tweet
	from 
		z_4_mongo
	left join
		(
			select
				z_4_mongo.id as ref_id,
				json_agg(
					json_build_object(
						'type', conversation_references.type,
						'reference_id', (conversation_references.parent_id)::text
					)
				) as referencies
			from 
				z_4_mongo
			left join
				conversation_references
			on
				conversation_references.conversation_id = z_4_mongo.id
			group by
				z_4_mongo.id
		) as refs
	on 
		z_4_mongo.id = ref_id