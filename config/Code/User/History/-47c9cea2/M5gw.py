from flask import Flask
# Create a Flask application instance
app = Flask(__name__)
@app.route('/')
# Define the route for the index page and show a message
def index ():
    return "Hi, this is a Flask web application!"
# Run the application
app.run(host="0.0.0.0", port=5000)
