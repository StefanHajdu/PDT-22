create table z_tweets_denormalized as
	select
		conversations.id,
		json_build_object(
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


create index idx_tweet_id on z_tweets_denormalized using btree(id); 


create table z_tweet_json as
	select
		z_tweets_denormalized.id,
		json_build_object(
			'metadata', z_tweets_denormalized.tweet->'metadata',
			'author', z_tweets_denormalized.tweet->'author',
			'annotations', z_tweets_denormalized.tweet->'annotations', 
			'links', z_tweets_denormalized.tweet->'links',  
			'domains', z_tweets_denormalized.tweet->'domains', 
			'entities', z_tweets_denormalized.tweet->'entities', 
			'hashtags', z_tweets_denormalized.tweet->'hashtags',
			'referencies', referencies
		) as tweet
	from 
		z_tweets_denormalized
	left join
		(
			select
				z_tweets_denormalized.id as ref_id,
				json_agg(
					json_build_object(
						'type', conversation_references.type,
						'ref_id', referenced_conv.tweet->'metadata'->'id', 
						'ref_content', referenced_conv.tweet->'metadata'->'content',
						'ref_author_id', referenced_conv.tweet->'author'->'id', 
						'ref_author_name', referenced_conv.tweet->'author'->'name', 
						'ref_author_username', referenced_conv.tweet->'author'->'username',
						'ref_hashtags', referenced_conv.tweet->'hashtags'
					)
				) as referencies
			from 
				z_tweets_denormalized
			left join
				conversation_references
			on
				conversation_references.conversation_id = z_tweets_denormalized.id
			left join
				z_tweets_denormalized as referenced_conv
			on
				conversation_references.parent_id = referenced_conv.id
			group by
				z_tweets_denormalized.id
		) as tweets_refs
	on
		z_tweets_denormalized.id = ref_id

----------------------------------------------------------------



select
	conversations_denormalized.id, string_agg(
		conversation_references.type || ',' ||  referenced_conv.id || ',' ||  referenced_conv.a_id || ',' ||  referenced_conv.a_name || ',' || referenced_conv.a_username || ',' || referenced_conv.conv_content || ',' || referenced_conv.hashtags, ';'
	)
from
	conversations_denormalized
left join
	conversation_references
on
	conversation_references.conversation_id = conversations_denormalized.id
left join
	conversations_denormalized as referenced_conv
on
	conversation_references.parent_id = referenced_conv.id
group by 
	conversations_denormalized.id
limit 10000



select
	conversations.id, authors.id
from
	conversations
inner join
	authors
on
	conversations.author_id = authors.id


select
	conversations.id, string_agg(context_annotations.id || ',' || context_domains.name || ',' || context_domains.description, ';')
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


select
	conversations.id, string_agg(referenced_conv.id || ',', ';')
from
	conversations
left join
	conversation_references
on
	conversation_references.conversation_id = conversations.id
left join
	conversations as referenced_conv
on
	conversation_references.parent_id = referenced_conv.id
group by 
	conversations.id





select
	conversations.id,
	json_agg(hashtags.tag) as hashtags
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
-- left join
-- 	context_annotations
-- on
-- 	conversations.id = context_annotations.conversation_id
-- left join
-- 	context_domains
-- on
-- 	context_annotations.context_domain_id = context_domains.id
group by
	conversations.id



select
	conversations.id,
	json_agg(
		json_build_object(
			'type', conversation_references.type, 
			'id', ref_conversation.id, 'content', ref_conversation.content,
			'a_id', ref_conversation_author.id, 'a_name', ref_conversation_author.name, 'a_username', ref_conversation_author.username
		)
	) ref_conversations
from
	conversations
left join
	conversation_references
on
	conversations.id = conversation_references.conversation_id
left join
	conversations as ref_conversation
on
	ref_conversation.id = conversation_references.parent_id
inner join
	authors as ref_conversation_author
on
	ref_conversation.author_id = ref_conversation_author.id
group by
	conversations.id
limit 10000


select
	conversations.id,
	json_agg(
		json_build_object(
			'type', conversation_references.type, 
			'id', ref_conversation.id, 'content', ref_conversation.content,
			'a_id', ref_conversation_author.id, 'a_name', ref_conversation_author.name, 'a_username', ref_conversation_author.username,
			json_build_object(
				'hashtags',
				(
					select
						json_agg(ref_hashtags.tag)
					from 
						conversations
					left join
						conversation_references
					on
						conversations.id = conversation_references.conversation_id
					left join
						conversations as ref_conversation
					on
						ref_conversation.id = conversation_references.parent_id
					left join
						conversation_hashtags as ref_conversation_hashtags
					on
						ref_conversation.id = ref_conversation_hashtags.conversation_id
					left join
						hashtags as ref_hashtags
					on
						ref_conversation_hashtags.hashtag_id = ref_hashtags.id
					group by
						conversations.id
				)
			)
		)
	) ref_conversations
from
	conversations
left join
	conversation_references
on
	conversations.id = conversation_references.conversation_id
left join
	conversations as ref_conversation
on
	ref_conversation.id = conversation_references.parent_id
inner join
	authors as ref_conversation_author
on
	ref_conversation.author_id = ref_conversation_author.id
group by
	conversations.id
limit 10000


create table conv_author_hashtag as
	select
		conversations.id, 
		json_agg(
			conversations
		) as conversation_parameters,
		json_agg(
			authors
		) as conversation_author,
		json_agg(
			hashtags
		) as conversation_hashtags
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
	inner join
		authors
	on
		conversations.author_id = authors.id
	group by
		conversations.id

create table conv_links as
	select
		conversations.id, json_agg(links) as links
	from
		conversations
	left join
		links
	on
		conversations.id = links.conversation_id
	group by
		conversations.id

create table conv_annotations as
	select
		conversations.id, json_agg(annotations) as annotations
	from
		conversations
	left join
		annotations
	on
		conversations.id = annotations.conversation_id
	group by
		conversations.id

create table conv_domains as
	select
		conversations.id, json_agg(context_domains) as domains
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



select
	conversations.id, annotations, links,  domains, entities, hashtags
from 
	conversations
left join
	(
		select
			conversations.id as conv_annot_id, json_agg(annotations.id) as annotations
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
			conversations.id as conv_links_id, json_agg(links.id) as links
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
			conversations.id as conv_domain_id, json_agg(context_domains.id) as domains
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
			conversations.id as conv_entity_id, json_agg(context_entities.id) as entities
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
			conversations.id as conv_tag_id, json_agg(hashtags.id) as hashtags
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
limit 100


973289729830535170	
"[""US is collecting #Russian #DNA for the US Air Force weapons laboratory, https://t.co/0TAltG74FI More: https://t.co/Kq1d1gHqVs #Neocon #genetics #peace #NATO #StopFundingHate https://t.co/rqeqc5WWOG"", 
""How a journalist gets expelled from the #EuropeanParliament when asking the Assistant Secretary at the US Department of Health questions about the Pentagon bio laboratories around #Russia, #China and #Iran. https://t.co/RB7cRZGDlG""]"	

"[[{""id"":36714,""tag"":""EuropeanParliament""}, 
 {""id"":10,""tag"":""Russia""}, 
 {""id"":300,""tag"":""China""}, 
 {""id"":1147,""tag"":""Iran""}, 
 {""id"":164352,""tag"":""StopFundingHate""}, 
 {""id"":12107,""tag"":""DNA""}, 
 {""id"":128766,""tag"":""Neocon""}, 
 {""id"":404126,""tag"":""genetics""}, 
 {""id"":50,""tag"":""Russian""}, 
 {""id"":539,""tag"":""peace""}, 
 {""id"":32,""tag"":""NATO""}], 
 [{""id"":36714,""tag"":""EuropeanParliament""}, 
 {""id"":10,""tag"":""Russia""}, 
 {""id"":300,""tag"":""China""}, 
 {""id"":1147,""tag"":""Iran""}, 
 {""id"":164352,""tag"":""StopFundingHate""}, 
 {""id"":12107,""tag"":""DNA""}, 
 {""id"":128766,""tag"":""Neocon""}, 
 {""id"":404126,""tag"":""genetics""}, 
 {""id"":50,""tag"":""Russian""}, 
 {""id"":539,""tag"":""peace""}, 
 {""id"":32,""tag"":""NATO""}]]"