import streamlit as st
import pandas as pd
import numpy as np
import requests
import plotly.graph_objects as go
# Set page configuration
st.set_page_config(
    page_title="Budget Tool",
    page_icon="📊",
    layout="wide"
)
# Title of the app
st.title("Budget Tool")