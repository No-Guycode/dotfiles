from flask import Flask, render_template
import requests
import json
# Create a Flask application instance
app = Flask(__name__)

def get_meme():


    url = "https://meme-api.herokuapp.com/gimme"
    response = json.loads(requests.request("GET", url).text)
    meme_large = response["preview"][-2]
    subreddit = response["subreddit"]
    title = response["title"]
    return meme_large, subreddit, title

@app.route('/')
def index():
    meme_pic, subreddit = get_meme()
    return render_template("meme_index.html", meme_pic=meme_pic, subreddit=subreddit)

app.run(host="0.0.0.0", port=5000)
