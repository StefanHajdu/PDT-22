from elasticsearch import Elasticsearch
from elasticsearch.helpers import parallel_bulk
import yaml
from yaml.loader import SafeLoader
import time
import urllib
import pandas as pd
from sqlalchemy import create_engine
from collections import deque

INDEX_NAME = "all_tweets_index"
SQL_QUERY = """select tweet from z_tweet_json"""

with open("Assignment_5/login.yaml") as f:
    login = yaml.load(f, Loader=SafeLoader)

PG_USERNAME = login["username"]
PG_PASSWORD = login["password"]
PG_SERVER = login["host"]
PG_PORT = 5432
PG_DATABASE = login["database"]
CONNECT_STRING = (
    f"postgresql+psycopg2://{PG_USERNAME}:"
    + f"{urllib.parse.quote_plus(PG_PASSWORD)}@{PG_SERVER}:{PG_PORT}/{PG_DATABASE}"
)

es = Elasticsearch(
    "http://localhost:9200", request_timeout=300, max_retries=5, retry_on_timeout=True
)

if __name__ == "__main__":
    iter_cnt = 0
    total_time = 0
    engine = create_engine(CONNECT_STRING)
    connection = engine.connect().execution_options(
        stream_results=True, max_row_buffer=100000
    )

    for df in pd.read_sql(SQL_QUERY, connection, chunksize=100000):
        start = time.perf_counter()
        col_list = df["tweet"].values.tolist()

        docs = []
        for row in col_list:
            row["_index"] = INDEX_NAME
            docs.append(row)

        deque(parallel_bulk(es, docs, thread_count=8, chunk_size=100))

        end = time.perf_counter()
        checkpoint = end - start
        iter_cnt += 100000
        total_time += checkpoint
        print(f"    {checkpoint} - {iter_cnt}")

    print(f"{total_time/60} minutes")
