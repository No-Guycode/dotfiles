from flask import Flask, render_template
import requests
import json

# Create a Flask application instance
app = Flask(__name__)

def get_meme():
    # Try multiple APIs in order of preference
    apis = [
        {
            "url": "https://meme-api.com/gimme",
            "parser": "reddit_style"
        },
        {
            "url": "https://api.imgflip.com/get_memes",
            "parser": "imgflip_style"
        }
    ]
    
    for api in apis:
        try:
            print(f"Trying API: {api['url']}")
            response = requests.get(api['url'], timeout=10)
            response.raise_for_status()
            
            if not response.headers.get('content-type', '').startswith('application/json'):
                print(f"Expected JSON but got: {response.headers.get('content-type')}")
                continue
                
            data = response.json()
            
            # Parse based on API type
            if api['parser'] == 'reddit_style':
                if 'preview' in data and len(data['preview']) >= 2:
                    meme_large = data["preview"][-2]
                else:
                    meme_large = data.get("url", "")
                subreddit = data.get("subreddit", "Unknown")
                title = data.get("title", "No title")
                return meme_large, subreddit, title
                
            elif api['parser'] == 'imgflip_style':
                if 'data' in data and 'memes' in data['data']:
                    import random
                    meme = random.choice(data['data']['memes'])
                    return meme['url'], 'Imgflip', meme['name']
                    
        except Exception as e:
            print(f"API {api['url']} failed: {e}")
            continue
    
    # If all APIs fail, return a placeholder
    return "https://via.placeholder.com/500x300?text=No+Meme+Available", "Error", "API temporarily unavailable"

@app.route('/')
def index():
    # Fix: Unpack all 3 values that get_meme() returns
    meme_pic, subreddit, title = get_meme()
    
    # Now we always get something back, so no need for error template
    return render_template("meme_index.html", 
                         meme_pic=meme_pic, 
                         subreddit=subreddit,
                         title=title)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)