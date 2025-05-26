from fastapi import APIRouter, Depends
from app.database.postgres.connections import postgres
# TODO: Import Models
from app.logger_utility import get_my_logger
from app.dependencies import get_postgres_session

logger = get_my_logger("CategoriesRouter", [])
router = APIRouter()

@router.get("/all")
async def get_all_categories(pg = Depends(get_postgres_session)):
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