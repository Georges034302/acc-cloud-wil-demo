from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "<h1>Welcome to Azure App Service!</h1>"

# The block below is useful for local testing only. App Service will attempt to start
# a WSGI server when it detects this layout; the platform's detection will choose
# an appropriate server during deployment.
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)