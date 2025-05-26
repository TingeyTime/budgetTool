import requests
import json
import os
from dotenv import load_dotenv
load_dotenv()

api_url = f"http://{os.environ.get('API_HOST', 'api')}:{os.environ.get('API_PORT', '8000')}"


def get_root() -> dict:
    response = requests.get(f"{api_url}/")
    if response.status_code != 200:
        raise Exception(f"Failed to get root: {response.status_code} - {response.text}")
    return response.json()

def get_categories() -> dict:
    response = requests.get(f"{api_url}/categories/all")
    if response.status_code != 200:
        raise Exception(f"Failed to get categories: {response.status_code} - {response.text}")
    return response.json()