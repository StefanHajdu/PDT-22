import time
import itertools
import json
from functools import wraps

total_time_cnt = 0


def measure(func):
    @wraps(func)
    def measure_wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        end = time.perf_counter()
        checkpoint = end - start

        global total_time_cnt
        total_time_cnt += checkpoint
        mm_ch, ss_ch = divmod(checkpoint, 60)
        mm_t, ss_t = divmod(total_time_cnt, 60)

        # 2022-09-16T19:35Z;81:22;10:22
        print(
            time.strftime("%Y-%m-%dT%H:%MZ;")
            + f"{int(mm_t)}:{int(ss_t)}"
            + f";{int(mm_ch)}:{int(ss_ch)}"
        )

        return result

    return measure_wrapper


def load_chunk(iterable, size):
    it = iter(iterable)
    while True:
        chunk = list(itertools.islice(it, size))
        if not chunk:
            break
        yield chunk


def clean_4_csv(data):
    if data is None:
        # same as NULL in Postgres
        return r"\N"
    return (
        str(data)
        .replace("\n", "\\n")
        .replace("\t", "\\t")
        .replace("\r", "\\r")
        .replace("\x00", "")
        .replace("\\", "\\\\")
    )


def load_N(rator, n):
    for i in range(0, n):
        yield next(rator)


# 32'383'787 convesations
def count_lines(rator):
    cnt = 0
    for i in rator:
        cnt += 1
        if cnt % 10000:
            print(f"counted: {cnt}")

    return cnt


def print_lines(n_lines):
    for line in n_lines:
        data_json = json.loads(line)
        print()
        print(f"{data_json}")
