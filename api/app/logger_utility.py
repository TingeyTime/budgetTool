import time
from fastapi import Request
from app.logger_utility import get_my_logger

logger = get_my_logger("Middleware", [])


async def timer(request: Request, call_next):
    start_time = time.time()
    logger.info("Starting timer")
    response = await call_next(request)
    logger.info(f"Request took: {round((time.time() - start_time), 3)} seconds.")
    return response