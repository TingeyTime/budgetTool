import streamlit as st
import pandas as pd
import numpy as np
import plotly.graph_objects as go

from tools.api import get_root, get_categories


# ---- Page configuration ----
st.set_page_config(
    page_title="Budget Tool",
    page_icon="📊",
    layout="wide"
)
st.title("Budget Tool")
st.caption("A tool to help you manage your budget effectively.")

# ---- Test Database Connection ----
st.header("Test Database connection")

st.write("Testing connection to the API...")
try:
    root_response = get_root()
    st.success(f"Connected to API: {root_response['message']}")
except Exception as e:
    st.error(f"Failed to connect to API: {e}")

st.write("Getting categories from the API...")
try:
    categories_response = get_categories()
    st.success(f"Found {len(categories_response)} categories.")
    categories_df = pd.DataFrame(categories_response)
    st.dataframe(categories_df)
except Exception as e:
    st.error(f"Failed to get categories: {e}")