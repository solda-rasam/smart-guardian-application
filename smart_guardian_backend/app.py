from flask import Flask, jsonify
from flask_cors import CORS
import random
import math
import sqlite3
from datetime import datetime

app = Flask(__name__)
CORS(app)

DB_NAME = "security_system.db"

# تابع کمکی برای اتصال به دیتابیس و ساخت جدول در صورت عدم وجود
def init_db():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS security_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            is_secure INTEGER,
            traffic_mb REAL,
            message TEXT
        )
    ''')
    conn.commit()
    conn.close()

# فراخوانی تابع برای ساخت دیتابیس به محض اجرای سرور
init_db()

traffic_history = [45.2, 48.1, 52.0, 49.5, 47.3, 51.2, 46.8, 50.1, 48.9, 53.4]

def calculate_baseline(history):
    mean = sum(history) / len(history)
    variance = sum((x - mean) ** 2 for x in history) / len(history)
    std_dev = math.sqrt(variance)
    threshold = mean + (2 * std_dev)
    return mean, threshold

def detect_anomaly():
    mean, threshold = calculate_baseline(traffic_history)
    
    if random.random() < 0.3:  
        current_traffic = random.uniform(95.0, 140.0)
    else:
        current_traffic = random.uniform(43.0, 55.0)
        if len(traffic_history) > 20:
            traffic_history.pop(0)
        traffic_history.append(current_traffic)

    is_secure = current_traffic <= threshold
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    if not is_secure:
        message = f"Anomaly detected! Current traffic ({current_traffic:.2f} MB) exceeds threshold ({threshold:.2f} MB)."
    else:
        message = f"Normal behavior. Current traffic ({current_traffic:.2f} MB) is safe."

    # ذخیره سازی زنده در دیتابیس SQLite
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO security_logs (timestamp, is_secure, traffic_mb, message)
        VALUES (?, ?, ?, ?)
    ''', (timestamp, 1 if is_secure else 0, current_traffic, message))
    conn.commit()
    conn.close()

    return {
        "is_secure": is_secure,
        "status": "SYSTEM SECURE" if is_secure else "SECURITY ALERT: SUSPICIOUS ACTIVITY",
        "message": message
    }

@app.route('/api/status', methods=['GET'])
def get_security_status():
    status_data = detect_anomaly()
    return jsonify(status_data)

# آدرس جدید برای گرفتن ۱۰ گزارش آخر ذخیره شده در دیتابیس
@app.route('/api/logs', methods=['GET'])
def get_logs():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute('SELECT timestamp, is_secure, traffic_mb, message FROM security_logs ORDER BY id DESC LIMIT 10')
    rows = cursor.fetchall()
    conn.close()

    logs_list = []
    for row in rows:
        logs_list.append({
            "timestamp": row[0],
            "is_secure": bool(row[1]),
            "traffic_mb": row[2],
            "message": row[3]
        })
    return jsonify(logs_list)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)