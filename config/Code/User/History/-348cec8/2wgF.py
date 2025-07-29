from flask import Flask, render_template
import requests
import json
# Create a Flask application instance
app = Flask(__name__)
@app.route('/')

def get_meme():


    url = "https://meme-api.com/gimme"
    response = json.loads(requests.request("GET", url).text)
    meme_large = response["preview"][-2]
    subreddit = response["subreddit"]
    title = response["title"]
    return meme_large, subreddit, title