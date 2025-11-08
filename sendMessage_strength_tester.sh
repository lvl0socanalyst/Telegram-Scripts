import os
import requests
import threading
import time

#HARD CODE BOT TOKEN AND CHAT ID
BOT_TOKEN = ""
CHAT_ID = ""
if not BOT_TOKEN or not CHAT_ID:
    raise SystemExit("Set BOT_TOKEN and CHAT_ID environment variables")

BASE_URL = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
NUM_THREADS = 50
MESSAGES_PER_THREAD = 20

results = {"ok":0, "429":0, "other":0}

def worker(thread_idx):
    for j in range(MESSAGES_PER_THREAD):
        try:
            r = requests.post(BASE_URL, json={"chat_id": CHAT_ID, "text": f"burst {thread_idx}-{j}"}, timeout=10)
        except Exception as e:
            print("Request error:", e)
            continue
        if r.status_code == 200:
            results["ok"] += 1
        elif r.status_code == 429:
            results["429"] += 1
            try:
                info = r.json()
                retry = info.get("parameters", {}).get("retry_after")
            except Exception:
                retry = None
            print(f"\nThread {thread_idx} got 429; retry_after={retry}")
        else:
            results["other"] += 1

threads = [threading.Thread(target=worker, args=(i,)) for i in range(NUM_THREADS)]
start = time.time()
for t in threads: t.start()
for t in threads: t.join()
dur = time.time() - start
print("Done. duration:", dur)
print(results)
