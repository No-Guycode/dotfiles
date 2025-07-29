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
            print(f"API Response: {data}")  # Debug: print the full response
            
            # Parse based on API type
            if api['parser'] == 'reddit_style':
                # Try different image URL fields in order of preference
                meme_url = None
                
                # Method 1: Try the 'url' field first (most common)
                if 'url' in data and data['url']:
                    meme_url = data['url']
                    print(f"Using 'url' field: {meme_url}")
                
                # Method 2: Try preview array if url doesn't work
                elif 'preview' in data and len(data['preview']) >= 2:
                    meme_url = data["preview"][-2]
                    print(f"Using 'preview' field: {meme_url}")
                
                # Method 3: Try other possible fields
                elif 'postLink' in data:
                    meme_url = data['postLink']
                    print(f"Using 'postLink' field: {meme_url}")
                
                if meme_url:
                    # Validate that the URL is an image
                    if any(ext in meme_url.lower() for ext in ['.jpg', '.jpeg', '.png', '.gif', '.webp']):
                        subreddit = data.get("subreddit", "Unknown")
                        title = data.get("title", "No title")
                        return meme_url, subreddit, title
                    else:
                        print(f"URL doesn't appear to be an image: {meme_url}")
                        continue
                
            elif api['parser'] == 'imgflip_style':
                if 'data' in data and 'memes' in data['data']:
                    import random
                    meme = random.choice(data['data']['memes'])
                    return meme['url'], 'Imgflip', meme['name']
                    
        except Exception as e:
            print(f"API {api['url']} failed: {e}")
            continue
    
    # If all APIs fail, return a working placeholder
    return "https://i.imgflip.com/1bij.jpg", "Error", "API temporarily unavailable"

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