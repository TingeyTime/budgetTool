import requests
import os
import streamlit as st
import pandas as pd
from dotenv import load_dotenv
load_dotenv()

api_url = f"http://{os.environ.get('API_HOST', 'api')}:{os.environ.get('API_PORT', '8000')}"

@st.cache_data()
def get_accounts() -> dict:
    response = requests.get(f"{api_url}/data/accounts")
    if response.status_code != 200:
        raise Exception(f"Failed to get accounts: {response.status_code} - {response.text}")
    return pd.DataFrame(response.json())

@st.cache_data()
def get_transactions() -> dict:
    response = requests.get(f"{api_url}/data/transactions")
    if response.status_code != 200:
        raise Exception(f"Failed to get transactions: {response.status_code} - {response.text}")
    return pd.DataFrame(response.json())

@st.cache_data()
def get_budgets() -> dict:
    response = requests.get(f"{api_url}/data/budgets")
    if response.status_code != 200:
        raise Exception(f"Failed to get budgets: {response.status_code} - {response.text}")
    return pd.DataFrame(response.json())

@st.cache_data()
def get_categories() -> dict:
    response = requests.get(f"{api_url}/data/categories")
    if response.status_code != 200:
        raise Exception(f"Failed to get categories: {response.status_code} - {response.text}")
    return pd.DataFrame(response.json())
