# 🐋 Lab 5-B: Build and Run a Dockerized Joke API Locally

<img width="1536" height="1024" alt="ZIMG" src="https://github.com/user-attachments/assets/20592bad-de74-4347-9568-002a84367afd" />

## 🎯 Objective

Build and run a fun, lightweight **Joke API** using **Flask** and **Docker**, completely on your local system—no Azure or cloud involved.

---


## 💡 App Idea: **Joke REST API**

A small REST API that returns jokes from a static list. It exposes two endpoints:

```
GET /jokes   # Returns all jokes as a list
GET /joke    # Returns a single random joke
```

---

## 🧭 Prerequisites

- Docker installed and running
- Python (for local testing before containerization, optional)

---

## 👣 Step-by-Step Instructions

---

### 1️⃣ Create Project Files

```bash
mkdir joke-api
cd joke-api
touch app.py requirements.txt Dockerfile
```
#### ✅ Expected Outcome:

```
joke-api/
├── app.py
├── requirements.txt
├── Dockerfile
```


#### 🔹 `app.py`

```python
from flask import Flask, jsonify
import random

app = Flask(__name__)

jokes = [
    "Why don’t developers like nature? It has too many bugs.",
    "Why did the developer go broke? Because he used up all his cache.",
    "Why do programmers prefer dark mode? Because light attracts bugs.",
    "What is a programmer’s favorite hangout place? The Foo Bar."
]

@app.route("/jokes")
def get_jokes():
    return jsonify({"jokes": jokes})

@app.route("/joke")
def get_joke():
    return jsonify({"joke": random.choice(jokes)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

#### 🔹 `requirements.txt`

```
flask
```

#### 🔹 `Dockerfile`

```Dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD ["python", "app.py"]
```

---

### 2️⃣ Build Docker Image

```bash
docker build -t joke-api:v1 .
```

✅ You should see:  
`Successfully tagged joke-api:v1`

---

### 3️⃣ Run the Docker Container Locally

```bash
docker run -d -p 5000:5000 --name joke-api-local joke-api:v1
```


✅ Test your API endpoints:

- List all jokes:
    ```bash
    "$BROWSER" "http://localhost:5000/jokes"
    ```
    Example output:
    ```json
    {
        "jokes": [
            "Why don’t developers like nature? It has too many bugs.",
            "Why did the developer go broke? Because he used up all his cache.",
            "Why do programmers prefer dark mode? Because light attracts bugs.",
            "What is a programmer’s favorite hangout place? The Foo Bar."
        ]
    }
    ```

- Get a random joke:
    ```bash
    "$BROWSER" "http://localhost:5000/joke"
    ```
    Example output:
    ```json
    {
        "joke": "Why do programmers prefer dark mode? Because light attracts bugs."
    }
    ```

---

### 🛠️ Optional: Stop and Remove the Container

```bash
docker stop joke-api-local
docker rm joke-api-local
```

---

### 🧼 Clean Up Image (Optional)

```bash
docker rmi joke-api:v1
```

---

✅ **Demo Complete** — You built a Docker container locally and ran a fun Joke API on your machine.
