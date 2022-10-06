import gzip
import psycopg2
import yaml
from yaml.loader import SafeLoader

from config import Config
import utils
import db_api

if __name__ == "__main__":

    author_lines_iter = (
        line for line in gzip.open(Config.AUTHORS_JSONL_PATH, "rt", encoding="utf-8")
    )
    conv_lines_iter = (
        line for line in gzip.open(Config.CONV_JSONL_PATH, "rt", encoding="utf-8")
    )
    conv_refs_lines_iter = (
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
        print("Successful connection to PostgreSQL")

    db_api.create_authors_table(conn)
    db_api.create_context_domains_table(conn)
    db_api.create_context_entities_table(conn)
    db_api.create_hashtags_table(conn)
    db_api.create_conversations_table(conn)
    db_api.create_annotations_table(conn)
    db_api.create_links_table(conn)
    db_api.create_context_annotations_table(conn)
    db_api.create_conversation_hashtags_table(conn)
    db_api.create_conversations_references_table(conn)

    for chunk in utils.load_chunk(author_lines_iter, size=100000):
        db_api.insert_authors_copy(connection=conn, authors=chunk)

    for chunk in utils.load_chunk(conv_lines_iter, size=100000):
        db_api.insert_conversations_copy(connection=conn, tweets=chunk)

    for chunk in utils.load_chunk(conv_refs_lines_iter, size=100000):
        db_api.insert_conversation_refs_copy(connection=conn, tweets=chunk)
