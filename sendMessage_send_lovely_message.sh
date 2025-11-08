import requests
import time

#HARD CODE BOT TOKEN AND CHAT ID
BOT_TOKEN = ""
CHAT_ID = ""
BASE_URL = f"https://api.telegram.org/bot{BOT_TOKEN}"

def flood_until_blocked(message, delay=3):
    count = 0
    while True:
        count += 1
        payload = {"chat_id": CHAT_ID, "text": f"ENTER LOVELY MESSAGE#{count}"}
        try:
            resp = requests.post(f"{BASE_URL}/sendMessage", json=payload, timeout=10)
            if resp.status_code == 200:
                print(f"Sent message #{count}")
                time.sleep(delay)
            else:
                print(f"Failed to send message #{count}: HTTP {resp.status_code}")
                print("Response:", resp.text)
                break
        except requests.exceptions.RequestException as e:
            print(f"Exception on message #{count}: {e}")
            break

if __name__ == "__main__":
    flood_until_blocked("Load test message")
