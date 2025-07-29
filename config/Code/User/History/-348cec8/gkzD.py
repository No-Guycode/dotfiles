from flask import Flask, render_template
import requests
import json

# Create a Flask application instance
app = Flask(__name__)

def get_meme():
    url = "https://meme-api.herokuapp.com/gimme"
    
    try:
        # Make the request with error handling
        response = requests.get(url, timeout=10)
        response.raise_for_status()  # Raises an HTTPError for bad responses
        
        # Check if response is actually JSON
        if response.headers.get('content-type', '').startswith('application/json'):
            data = response.json()  # Use .json() instead of json.loads()
        else:
            print(f"Expected JSON but got: {response.headers.get('content-type')}")
            print(f"Response content: {response.text[:200]}...")  # First 200 chars
            return None, None, None
            
        # Extract the data with error checking
        if 'preview' in data and len(data['preview']) >= 2:
            meme_large = data["preview"][-2]
        else:
            meme_large = data.get("url", "")  # Fallback to main URL
            
        subreddit = data.get("subreddit", "Unknown")
        title = data.get("title", "No title")
        
        return meme_large, subreddit, title
        
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None, None, None
    except json.JSONDecodeError as e:
        print(f"JSON decode error: {e}")
        print(f"Response text: {response.text}")
        return None, None, None
    except Exception as e:
        print(f"Unexpected error: {e}")
        return None, None, None

@app.route('/')
def index():
    # Fix: Unpack all 3 values that get_meme() returns
    meme_pic, subreddit, title = get_meme()
    
    # Handle the case where get_meme() fails
    if meme_pic is None:
        return render_template("error.html", 
                             error_message="Failed to fetch meme. Please try again later.")
    
    return render_template("meme_index.html", 
                         meme_pic=meme_pic, 
                         subreddit=subreddit,
                         title=title)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)