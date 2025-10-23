from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/')
def home():
    return "Student Service is running!"

@app.route('/student/<id>')
def get_student(id):
    data = {"id": id, "name": "Ava", "major": "Computer Science"}
    return jsonify(data)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8000)