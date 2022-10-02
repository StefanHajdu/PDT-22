import gzip
from html import entities
import json
from config import Config
import io

conv_ref_cnt = 0
links_cnt = 0
annot_cnt = 0
hashtag_cnt = 0
conv_hash_cnt = 0
domain_cnt = 0
entity_cnt = 0
context_annot_cnt = 0

def first_N(rator, n):
    for i in range(0, n):
        yield next(rator)

# There are: 32'383'787 convesations
def count_records(rator):
    cnt = 0
    for i in rator:
        cnt += 1
    return cnt

def clean_4_csv(value):
    if value is None:
        return r'\N'
    return str(value).replace('\n', '\\n')

def print_tweets(tweets):
    for tweet in tweets:
        print(tweet)
        print()


tweets_iter = (
    line for line in gzip.open(Config.CONV_JSONL_PATH, "rt", encoding="utf-8")
)

def create_csv_like_objects(tweets):
    csv_4_convs = io.StringIO()
    csv_4_convs_refs = io.StringIO()
    csv_4_annots = io.StringIO()
    csv_4_links = io.StringIO()
    csv_4_convs_htags = io.StringIO()
    csv_4_htags = io.StringIO()
    csv_4_cont_domains = io.StringIO()
    csv_4_cont_entities = io.StringIO()
    csv_4_cont_annots = io.StringIO()
    for tweet in tweets:
        tweet = json.loads(tweet)
        csv_4_convs.write('\t'.join(map(clean_4_csv, (
            tweet['id'],
            tweet['author_id'],
            tweet['text'],
            tweet['possibly_sensitive'],
            tweet['lang'],
            tweet['source'],
            tweet['public_metrics']['retweet_count'],
            tweet['public_metrics']['reply_count'],
            tweet['public_metrics']['like_count'],
            tweet['public_metrics']['quote_count'],
            tweet['created_at']
        ))) + '\n')

        for ref in tweet.get('referenced_tweets', []):
            global conv_ref_cnt
            csv_4_convs_refs.write('\t'.join(map(clean_4_csv, (
                conv_ref_cnt,
                tweet['id'],
                ref['id'],
                ref['type']
            ))) + '\n')
            conv_ref_cnt += 1

        if 'entities' in tweet:
            urls = tweet['entities'].get('urls')
            if urls:
                for url in urls:
                    global links_cnt
                    csv_4_links.write('\t'.join(map(clean_4_csv, (
                        links_cnt,
                        tweet['id'],
                        url['expanded_url'],
                        url.get('title', None),
                        url.get('description', None)
                    ))) + '\n')
                    links_cnt += 1
        
        if 'annotations' in tweet:
            annotations = tweet['entities'].get('annotations')
            if annotations:
                for annot in annotations:
                    global annot_cnt
                    csv_4_annots.write('\t'.join(map(clean_4_csv, (
                        annot_cnt,
                        tweet['id'],
                        annot['normalized_text'],
                        annot['type'],
                        annot['probability']
                    ))) + '\n')
                    annot_cnt += 1
            
        if 'entities' in tweet:
            hashtags = tweet['entities'].get('hashtags')
            if hashtags:
                for hash in hashtags:
                    global hashtag_cnt, conv_hash_cnt
                    csv_4_htags.write('\t'.join(map(clean_4_csv, (
                            hashtag_cnt,
                            hash['tag']
                    ))) + '\n')   

                    csv_4_convs_htags.write('\t'.join(map(clean_4_csv, (
                            conv_hash_cnt,
                            tweet['id'],
                            hashtag_cnt
                    ))) + '\n')

                    hashtag_cnt += 1
                    conv_hash_cnt += 1

            context_annotations = tweet.get('context_annotations')
            if context_annotations:
                for item in context_annotations:
                    global domain_cnt, entity_cnt, context_annot_cnt
                    csv_4_cont_domains.write('\t'.join(map(clean_4_csv, (
                            domain_cnt,
                            item['domain'].get('name', None),
                            item['domain'].get('description', None)
                    ))) + '\n')

                    csv_4_cont_entities.write('\t'.join(map(clean_4_csv, (
                            entity_cnt,
                            item['domain'].get('name', None),
                            item['domain'].get('description', None)
                    ))) + '\n')

                    csv_4_cont_entities.write('\t'.join(map(clean_4_csv, (
                            context_annot_cnt,
                            tweet['id'],
                            domain_cnt,
                            entity_cnt
                    ))) + '\n')

                    domain_cnt += 1
                    entity_cnt += 1
                    context_annot_cnt += 1

            csv_4_convs.seek(0)
            csv_4_convs_refs.seek(0)
            csv_4_annots.seek(0)
            csv_4_links.seek(0)
            csv_4_convs_htags.seek(0)
            csv_4_htags.seek(0)
            csv_4_cont_domains.seek(0)
            csv_4_cont_entities.seek(0)
            csv_4_cont_annots.seek(0)

            print("[Conversations Table]")
            print(csv_4_convs.getvalue())
            print('\n\n')
            print("[Conversation_references Table]")
            print(csv_4_convs_refs.getvalue())
            print('\n\n')
            print("[Links Table]")
            print(csv_4_convs_refs.getvalue())
            print('\n\n')
            print("[Annotation Table]")
            print(csv_4_annots.getvalue())
            print('\n\n')
            print("[Hashtag Table]")
            print(csv_4_htags.getvalue())
            print('\n\n')
            print("[Conversation_hashtag Table]")
            print(csv_4_convs_htags.getvalue())
            print('\n\n')
            print("[Context_Domain Table]")
            print(csv_4_cont_domains.getvalue())
            print('\n\n')
            print("[Context_Entity Table]")
            print(csv_4_cont_entities.getvalue())
            print('\n\n')
            print("[Context_Annotation Table]")
            print(csv_4_cont_annots.getvalue())
            print('\n\n')

create_csv_like_objects(list(first_N(tweets_iter, 10)))
# print_tweets(first_N(tweets_iter, 1))
# print_tweets(first_N(tweets_iter, 1))

def parse_tweets(tweets_iter):
    for tweet in tweets_iter:
        print()
        print()
        tweet = json.loads(tweet)
        print(tweet)
        print()

        print("[Conversations Table]")
        print(f"    id: {tweet['id']}")
        print(f"    author_id: {tweet['author_id']}")
        print(f"    content: {tweet['text']}")
        print(f"    possibly_sensitive: {tweet['possibly_sensitive']}")
        print(f"    language: {tweet['lang']}")
        print(f"    source: {tweet['source']}")
        print(f"    retweet: {tweet['public_metrics']['retweet_count']}")
        print(f"    reply: {tweet['public_metrics']['reply_count']}")
        print(f"    like: {tweet['public_metrics']['like_count']}")
        print(f"    quote: {tweet['public_metrics']['quote_count']}")
        print(f"    created_at: {tweet['created_at']}")

        print("[Conversation_references Table]")
        refs = tweet.get('referenced_tweets')
        if refs:
            for ref in tweet['referenced_tweets']:
                global conv_ref_cnt
                print(f"    id: {conv_ref_cnt}")
                print(f"    conv_id: {tweet['id']}")
                print(f"    parent_id: {ref['id']}")
                print(f"    type: {ref['type']}")

                conv_ref_cnt += 1

        print("[Links Table]")
        if 'entities' in tweet:
            urls = tweet['entities'].get('urls')
            if urls:
                for url in urls:
                    global links_cnt
                    print(f"    id: {links_cnt}")
                    print(f"    conv_id: {tweet['id']}")
                    print(f"    url: {url['expanded_url']}")
                    print(f"    title: {url.get('title', 'NULL')}")
                    print(f"    description: {url.get('description', 'NULL')}")
                    
                    links_cnt += 1

        print("[Annotation Table]")
        if 'annotations' in tweet:
            annotations = tweet['entities'].get('annotations')
            if annotations:
                for annot in annotations:
                    global annot_cnt
                    print(f"    id: {annot_cnt}")
                    print(f"    conv_id: {tweet['id']}")
                    print(f"    value: {annot['normalized_text']}")
                    print(f"    type: {annot['type']}")
                    print(f"    probability: {annot['probability']}")

                    annot_cnt += 1

        
        print("[Hashtag Table]")
        if 'entities' in tweet:
            hashtags = tweet['entities'].get('hashtags')
            if hashtags:
                for hash in hashtags:
                    global hashtag_cnt, conv_hash_cnt
                    print(f"    id: {hashtag_cnt}")
                    print(f"    tag: {hash['tag']}")

                    print("             [Conversation_hashtag Table]")
                    print(f"                id: {conv_hash_cnt}")
                    print(f"                conv_id: {tweet['id']}")
                    print(f"                hashtag_id: {hashtag_cnt}")

                    hashtag_cnt += 1
                    conv_hash_cnt += 1
            
        context_annotations = tweet.get('context_annotations')
        if context_annotations:
            for item in context_annotations:
                global domain_cnt, entity_cnt, context_annot_cnt
                print("[Context_Domain Table]")
                print(f"    id: {domain_cnt}")
                print(f"    name: {item['domain'].get('name', 'NULL')}")
                print(f"    description: {item['domain'].get('description', 'NULL')}")

                print("[Context_Entity Table]")
                print(f"    id: {entity_cnt}")
                print(f"    name: {item['entity'].get('name', 'NULL')}")
                print(f"    description: {item['entity'].get('description', 'NULL')}")

                print("     [Context_Annotation Table]")
                print(f"        id: {context_annot_cnt}")
                print(f"        conv_id: {tweet['id']}")
                print(f"        context_domain_id: {domain_cnt}")
                print(f"        context_entity_id: {entity_cnt}")
        
                domain_cnt += 1
                entity_cnt += 1
                context_annot_cnt += 1

# parse_tweets(n_tweets)
