# 🛡️ Smart Guardian: IoT Network Anomaly Detection System

Smart Guardian is an end-to-end network security monitoring application designed for smart homes and IoT environments. It features a cross-platform **Flutter** frontend interface connected to a robust **Flask (Python)** backend that utilizes a statistical anomaly detection algorithm to identify suspicious device traffic and potential data leaks in real-time.

---

## 🚀 Key Features

* **Smart Anomaly Detection:** Utilizes an algorithmic baseline analyzer (Mean & Standard Deviation) to dynamically detect unusual traffic spikes rather than relying on hardcoded thresholds.
* **Real-Time System Monitoring:** Live status updates ("SYSTEM SECURE" vs "SECURITY ALERT") directly rendered on the dashboard.
* **Persistent Security Logging:** Integrated with an **SQLite** database to automatically log every security event, capture timestamps, and maintain an audit trail for future forensics.
* **Cross-Platform UI:** Modern, responsive, and scannable interface built with Flutter, suitable for web and mobile ecosystem simulations.

---

## 📸 Dashboards & Live Demo

### 1. Normal Network Behavior (System Secure)
*Place your screenshot showing the green secure screen here*

```
```

### 2. Anomaly Detected (Security Alert)
*Place your screenshot showing the red/orange critical warning alert here*

```
## 🧠 Behind the Scenes: The Smart Threshold Algorithm
Instead of predefined legacy rule-sets, the Python backend continuously analyzes the historical device behavior:
 1. **Baseline Calculation:** The system computes the running Mean (\mu) and Standard Deviation (\sigma) of the network traffic telemetry.
 2. **Dynamic Threshold:** The critical threshold is dynamically set using statistical bounds:
   
 3. **Detection:** Any live traffic payload exceeding this boundary triggers an immediate network anomaly state (with a 95% statistical confidence interval), alerting the user of potential unauthorized outbound data exfiltration.
## 🛠️ System Architecture & Tech Stack
 * **Frontend:** Flutter (Dart) — Custom stateful widgets, asynchronous HTTP network streaming.
 * **Backend:** Flask (Python) — RESTful API endpoints, CORS security policy handling.
 * **Database:** SQLite — Structured transactional log persistence.
## ⚙️ Installation & Setup
### 1. Backend Setup
```bash
cd smart_guardian_backend
pip install flask flask-cors
python app.py

```
### 2. Frontend Setup
```bash
cd smart_guardian_frontend
flutter pub get
flutter run -d chrome

```
## 📌 Future Roadmap
 * Integrating a lightweight Machine Learning classifier (Isolation Forest) for complex multi-variant threat modeling.
 * Implementing live push notifications via WebSockets.
