from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database.postgres.connections import get_postgres_pool
from contextlib import asynccontextmanager
from app.routers.categories import router as categories_router
from app.routers.data import router as data_router
from app.middlewares import timer
from app.logger_utility import get_my_logger

logger = get_my_logger("API", [])


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Application is starting up")

    logger.info("Getting Postgres Database Connection.")
    pg_pool = await get_postgres_pool()
    app.state.pg_pool = pg_pool

    yield

    logger.info("Application is shutting down")

    await app.state.pg_pool.close()
    logger.info("Postgres Database connection pool closed.")

    return

app = FastAPI(
    title="Budget Tool API",
    description="API for managing budget data and operations",
    lifespan=lifespan,
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

app.include_router(
    router=data_router,
    prefix="/data",
    tags=["Data"],
)
app.include_router(
    router=categories_router,
    prefix="/categories",
    tags=["Categories"],
)

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/health")
async def health_check():
    return {"status": "ok", "message": "API is running smoothly."}

@app.get("/version")
async def version():
    return {"version": "0.1.0", "description": "Budget Tool API"}