import os, requests
from flask import Flask
app = Flask(__name__)

STUDENT_SERVICE_APP = os.environ.get("STUDENT_SERVICE_APP")

@app.route('/')
def home():
    return "Report Service is running!"

@app.route('/report/<id>')
def get_report(id):
    url = f"https://{STUDENT_SERVICE_APP}.azurewebsites.net/student/{id}"
    r = requests.get(url)
    student = r.json()
    return f"Student {student['name']} is majoring in {student['major']}"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8000)