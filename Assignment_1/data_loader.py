import gzip
import json
import psycopg2
from io import StringIO
import yaml
from yaml.loader import SafeLoader

from config import Config
import utils
import db_api


conv_ref_cnt = 0
links_cnt = 0
annot_cnt = 0
hashtag_cnt = 0
conv_hash_cnt = 0
domain_cnt = 0
entity_cnt = 0
context_annot_cnt = 0


@utils.measure
def create_csv_like_objects_conv(tweets):
    csv_4_convs = StringIO()
    csv_4_convs_refs = StringIO()
    csv_4_annots = StringIO()
    csv_4_links = StringIO()
    csv_4_convs_htags = StringIO()
    csv_4_htags = StringIO()
    csv_4_cont_domains = StringIO()
    csv_4_cont_entities = StringIO()
    csv_4_cont_annots = StringIO()
    for tweet in tweets:
        tweet = json.loads(tweet)
        csv_4_convs.write(
            "\t".join(
                map(
                    utils.clean_4_csv,
                    (
                        tweet["id"],
                        tweet["author_id"],
                        tweet["text"],
                        tweet["possibly_sensitive"],
                        tweet["lang"],
                        tweet["source"],
                        tweet["public_metrics"]["retweet_count"],
                        tweet["public_metrics"]["reply_count"],
                        tweet["public_metrics"]["like_count"],
                        tweet["public_metrics"]["quote_count"],
                        tweet["created_at"],
                    ),
                )
            )
            + "\n"
        )

        for ref in tweet.get("referenced_tweets", []):
            global conv_ref_cnt
            csv_4_convs_refs.write(
                "\t".join(
                    map(
                        utils.clean_4_csv,
                        (conv_ref_cnt, tweet["id"], ref["id"], ref["type"]),
                    )
                )
                + "\n"
            )
            conv_ref_cnt += 1

        if "entities" in tweet:
            for url in tweet["entities"].get("urls", []):
                global links_cnt
                csv_4_links.write(
                    "\t".join(
                        map(
                            utils.clean_4_csv,
                            (
                                links_cnt,
                                tweet["id"],
                                url["expanded_url"],
                                url.get("title", None),
                                url.get("description", None),
                            ),
                        )
                    )
                    + "\n"
                )
                links_cnt += 1

        if "annotations" in tweet:
            for annot in tweet["entities"].get("annotations", []):
                global annot_cnt
                csv_4_annots.write(
                    "\t".join(
                        map(
                            utils.clean_4_csv,
                            (
                                annot_cnt,
                                tweet["id"],
                                annot["normalized_text"],
                                annot["type"],
                                annot["probability"],
                            ),
                        )
                    )
                    + "\n"
                )
                annot_cnt += 1

        if "entities" in tweet:
            for hash in tweet["entities"].get("hashtags", []):
                global hashtag_cnt, conv_hash_cnt
                csv_4_htags.write(
                    "\t".join(map(utils.clean_4_csv, (hashtag_cnt, hash["tag"]))) + "\n"
                )

                csv_4_convs_htags.write(
                    "\t".join(
                        map(
                            utils.clean_4_csv, (conv_hash_cnt, tweet["id"], hashtag_cnt)
                        )
                    )
                    + "\n"
                )

                hashtag_cnt += 1
                conv_hash_cnt += 1

            for item in tweet.get("context_annotations", []):
                global domain_cnt, entity_cnt, context_annot_cnt
                csv_4_cont_domains.write(
                    "\t".join(
                        map(
                            utils.clean_4_csv,
                            (
                                domain_cnt,
                                item["domain"].get("name", None),
                                item["domain"].get("description", None),
                            ),
                        )
                    )
                    + "\n"
                )

                csv_4_cont_entities.write(
                    "\t".join(
                        map(
                            utils.clean_4_csv,
                            (
                                entity_cnt,
                                item["entity"].get("name", None),
                                item["entity"].get("description", None),
                            ),
                        )
                    )
                    + "\n"
                )

                csv_4_cont_annots.write(
                    "\t".join(
                        map(
                            utils.clean_4_csv,
                            (
                                context_annot_cnt,
                                tweet["id"],
                                domain_cnt,
                                entity_cnt,
                            ),
                        )
                    )
                    + "\n"
                )

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


author_lines_iter = (
    line for line in gzip.open(Config.AUTHORS_JSONL_PATH, "rt", encoding="utf-8")
)
conv_lines_iter = (
    line for line in gzip.open(Config.CONV_JSONL_PATH, "rt", encoding="utf-8")
)

with open("login.yaml") as f:
    login = yaml.load(f, Loader=SafeLoader)

conn = psycopg2.connect(
    host=login["host"],
    database=login["database"],
    user=login["username"],
    password=login["password"],
)

conn.autocommit = True

if not conn.closed:
    print("Successful connection to PostgreSQL/tweets")

db_api.create_authors_table(connection=conn)
for chunk in utils.load_chunk(author_lines_iter, size=100000):
    db_api.insert_authors_copy(connection=conn, authors=chunk)

db_api.create_context_domains_table(connection=conn)
db_api.create_context_entities_table(connection=conn)
db_api.create_hashtags_table(connection=conn)
db_api.create_conversations_table(connection=conn)
db_api.create_annotations_table(connection=conn)
db_api.create_links_table(connection=conn)
db_api.create_conversations_references_table(connection=conn)
db_api.create_context_annotations_table(connection=conn)
db_api.create_conversation_hashtags_table(connection=conn)
for chunk in utils.load_chunk(conv_lines_iter, size=100000):
    db_api.insert_conversations_copy(connection=conn, tweets=chunk)
