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
