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

st.dataframe(transactions_df, use_container_width=True, hide_index=True)

# Calculate cumulative sum by date
nw_agg = transactions_df.groupby('transaction_date').agg(**{
    'amount': pd.NamedAgg('amount', np.cumsum)
}).reset_index()
st.dataframe(nw_agg, use_container_width=True, hide_index=True)

# Calculate daily percent change
nw_agg['daily_pct_change'] = nw_agg['amount'].pct_change()

# Resample and calculate weekly percent change
weekly_change = nw_agg.set_index('transaction_date').resample('W')['amount'].last().pct_change()

# Resample and calculate monthly percent change
monthly_change = nw_agg.set_index('transaction_date').resample('M')['amount'].last().pct_change()

# Display metrics
st.subheader("Percent Changes")
metric_col1, metric_col2, metric_col3 = st.columns(3)
with metric_col1:
    st.metric("Daily Change", f"{nw_agg['daily_pct_change'].iloc[-1]:.2%}")
with metric_col2:
    st.metric("Weekly Change", f"{weekly_change.iloc[-1]:.2%}")
with metric_col3:
    st.metric("Monthly Change", f"{monthly_change.iloc[-1]:.2%}")