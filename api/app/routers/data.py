from fastapi import APIRouter, Depends
from app.database.postgres.connections import postgres
from app.models.accounts import Account
from app.models.categories import Category
from app.models.transactions import Transaction
from app.models.budgets import Budget, BudgetPeriod
from app.logger_utility import get_my_logger
from app.dependencies import get_postgres_session

logger = get_my_logger("DataRouter", [])
router = APIRouter()

@router.get("/accounts")
async def get_all_accounts(pg=Depends(get_postgres_session)):
    """
    Get all accounts from the database.
    """
    logger.info("Fetching all accounts from the database.")
    query = "SELECT * FROM accounts"
    data = await postgres(query, pg)

    if len(data) == 0:
        logger.warning("No accounts found in the database.")
        return {"message": "No accounts found."}
    
    logger.info(f"Found {len(data)} accounts.")
    return data.to_dict(orient="records")

@router.get("/categories")
async def get_all_categories(pg=Depends(get_postgres_session)):
    """
    Get all categories from the database.
    """
    logger.info("Fetching all categories from the database.")
    query = "SELECT * FROM categories"
    data = await postgres(query, pg)

    if len(data) == 0:
        logger.warning("No categories found in the database.")
        return {"message": "No categories found."}
    
    logger.info(f"Found {len(data)} categories.")
    return data.to_dict(orient="records")

@router.get("/transactions")
async def get_all_transactions(pg=Depends(get_postgres_session)):
    """
    Get all transactions from the database.
    """
    logger.info("Fetching all transactions from the database.")
    query = "SELECT * FROM transactions"
    data = await postgres(query, pg)

    if len(data) == 0:
        logger.warning("No transactions found in the database.")
        return {"message": "No transactions found."}
    
    logger.info(f"Found {len(data)} transactions.")
    return data.to_dict(orient="records")

@router.get("/budgets")
async def get_all_budgets(pg=Depends(get_postgres_session)):
    """
    Get all budgets from the database.
    """
    logger.info("Fetching all budgets from the database.")
    query = "SELECT * FROM budgets"
    data = await postgres(query, pg)

    if len(data) == 0:
        logger.warning("No budgets found in the database.")
        return {"message": "No budgets found."}
    
    logger.info(f"Found {len(data)} budgets.")
    return data.to_dict(orient="records")

@router.get("/budget-periods")
async def get_all_budget_periods(pg=Depends(get_postgres_session)):
    """
    Get all budget periods from the database.
    """
    logger.info("Fetching all budget periods from the database.")
    query = "SELECT * FROM budget_periods"
    data = await postgres(query, pg)

    if len(data) == 0:
        logger.warning("No budget periods found in the database.")
        return {"message": "No budget periods found."}
    
    logger.info(f"Found {len(data)} budget periods.")
    return data.to_dict(orient="records")