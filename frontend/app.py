import streamlit as st
import pandas as pd
import numpy as np
import plotly.graph_objects as go

from tools.api import get_accounts, get_transactions, get_budgets, get_categories


# ---- Page configuration ----
st.set_page_config(
    page_title="Budget Tool",
    page_icon="📊",
    layout="wide"
)
st.title("Budget Tool")
st.caption("A tool to help you manage your budget effectively.")

# ---- Load data ----
accounts_df = get_accounts()
transactions_df = get_transactions()
budgets_df = get_budgets()
categories_df = get_categories()

# ---- Metrics ----
col1, col2, col3 = st.columns(3)

with col1:
    st.metric("Total Accounts", len(accounts_df), delta=None)

with col2:
    st.metric("Total Transactions", len(transactions_df), delta=None)

with col3:
    st.metric("Total Budgets", len(budgets_df), delta=None)

# ---- Accounts Overview ----
st.metric("Net Worth", f"${transactions_df['amount'].sum():,.2f}")