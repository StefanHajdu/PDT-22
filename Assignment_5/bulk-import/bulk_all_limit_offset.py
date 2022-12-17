from elasticsearch import Elasticsearch
from datetime import datetime
import psycopg2
import yaml
from yaml.loader import SafeLoader
from collections import deque
from elasticsearch.helpers import parallel_bulk
import time

INDEX_NAME = "all_tweets_index"

with open("Assignment_5/login.yaml") as f:
    login = yaml.load(f, Loader=SafeLoader)


conn = psycopg2.connect(
    host=login["host"],
    database=login["database"],
    user=login["username"],
    password=login["password"],
)
cursor = conn.cursor()

es = Elasticsearch(
    "http://localhost:9200", request_timeout=300, max_retries=5, retry_on_timeout=True
)

limit = 500_000
offset = 13_400_000


def get_docs(rows):
    docs = []
    for r in rows:
        r[0]["_index"] = INDEX_NAME
        docs.append(r[0])

    deque(parallel_bulk(es, docs, thread_count=8, chunk_size=100))
    print(f"     {offset+limit}")


if __name__ == "__main__":
    t_start = datetime.now()

    while True:
        start = time.perf_counter()
        cursor.execute(
            """
            select tweet from z_tweet_json
            limit %s offset %s
            """,
            (limit, offset),
        )
        offset += limit
        rows = cursor.fetchall()
        get_docs(rows)

        end = time.perf_counter()
        checkpoint = end - start
        print(f"    {checkpoint}")
        print(f"    {checkpoint/limit}")
        if not rows:
            break

    elapsed_time = round((datetime.now() - t_start).total_seconds(), 2)
    print(f"Completed records in {elapsed_time}")
