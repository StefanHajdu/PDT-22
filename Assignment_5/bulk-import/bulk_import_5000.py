from elasticsearch import Elasticsearch
from datetime import datetime
import psycopg2
import yaml
from yaml.loader import SafeLoader
from collections import deque
from elasticsearch.helpers import bulk, parallel_bulk
import time

INDEX_NAME = "tweets_index"

with open("Assignment_5/login.yaml") as f:
    login = yaml.load(f, Loader=SafeLoader)


conn = psycopg2.connect(
    host=login["host"],
    database=login["database"],
    user=login["username"],
    password=login["password"],
)

es = Elasticsearch("http://localhost:9200")


def get_docs(cursor):
    docs = []
    for r in cursor.fetchall():
        r[0]["_index"] = INDEX_NAME
        docs.append(r[0])
    deque(parallel_bulk(es, docs, thread_count=8, chunk_size=500))


if __name__ == "__main__":
    t_start = datetime.now()

    with conn.cursor(name="custom_cursor") as cursor:
        cursor.execute(
            """
            select tweet from z_tweet_json
            limit 5000;
            """
        )
        get_docs(cursor)

    elapsed_time = round((datetime.now() - t_start).total_seconds(), 2)
    print(f"Completed records in {elapsed_time}")
