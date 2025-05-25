from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.middlewares import timer
from app.logger_utility import get_my_logger

logger = get_my_logger("API", [])


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Application is starting up")

    yield

    logger.info("Application is shutting down")
    return

app = FastAPI(
    title="Budget Tool API",
    description="API for managing budget data and operations",
    version="0.1.0",
)

origins = [
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,  # If credentials like cookies or authentication tokens are allowed
    allow_methods=["*"],  # Which HTTP methods are allowed, "*" allows all methods
    allow_headers=["*"],  # Which headers are allowed, "*" allows all headers
)

app.middleware("https")(timer)

@app.get("/")
async def root():
    return {"message": "Hello World"}