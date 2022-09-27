import gzip
import json
from config import Config


def first_N(rator, n):
    for i in range(0, n):
        yield rator.__next__()


def count_records(rator):
    cnt = 0
    for i in rator:
        cnt += 1
        if cnt % 10000:
            print(f"counted: {cnt}")

    return cnt


author_lines = (
    line for line in gzip.open(Config.ATHORS_JSONL_PATH, "rt", encoding="utf-8")
)
conv_lines = (
    line for line in gzip.open(Config.CONV_JSONL_PATH, "rt", encoding="utf-8")
)

n_lines = list(first_N(conv_lines, 5))

for line in n_lines:
    data_json = json.loads(line)
    print()
    print(f"{type(data_json)} > {data_json}")

# There are: 32383787 convesations
# print(f"There are: {count_records(conv_lines)} convesations")
