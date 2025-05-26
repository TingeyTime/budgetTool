from fastapi import Depends
from starlette.requests import Request


async def get_postgres_session(request: Request):
    async with request.app.state.pg_pool.acquire() as connection:
        yield connection


async def get_redis_session(request: Request):
    async with request.app.state.redis_pool.client() as connection:
        yield connection