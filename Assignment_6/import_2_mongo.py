import yaml
from yaml.loader import SafeLoader
import urllib
import pandas as pd
from sqlalchemy import create_engine
from pymongo import MongoClient, InsertOne

client = MongoClient("localhost", port=27017)
db = client.tweet_db
collection = db.tweets_all

INDEX_NAME = "all_tweets_index"
SQL_QUERY = """select tweet from z_data_4_mongo"""
CHUNKSIZE = 100000

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

if __name__ == "__main__":

    engine = create_engine(CONNECT_STRING)
    connection = engine.connect().execution_options(
        stream_results=True, max_row_buffer=CHUNKSIZE
    )

    for df in pd.read_sql(SQL_QUERY, connection, chunksize=CHUNKSIZE):
        rows = df["tweet"].values.tolist()
        rows_insert = [InsertOne(row) for row in rows]

        result = collection.bulk_write(rows_insert)

    client.close()
