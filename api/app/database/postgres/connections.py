from datetime import datetime
import pandas as pd
import asyncpg
from asyncpg.pool import PoolConnectionProxy
from app.database.configuration import PostgresDatabaseConfiguration
from app.logger_utility import get_my_logger

logger = get_my_logger("Postgres Connections", [])

# GET DATA POOL
async def get_postgres_pool(minconn=1, maxconn=2, connect_timeout=1000):
    pg = PostgresDatabaseConfiguration()

    pg_config = pg.get_config()

    logger.info(f"Postgres Configuration: {pg_config}")

    logger.info("Creating Postgres Connection Pool")
    pool = await asyncpg.create_pool(
        min_size=minconn,
        max_size=maxconn,
        timeout = connect_timeout,
        database= pg_config['database'],
        host = pg_config['host'],
        port = pg_config['port'],
        user = pg_config['username'],
        password = pg_config['password']
    )

    return pool


# PULL DATA
async def postgres(query: str, con: PoolConnectionProxy, table_format=True):
    statement = await con.prepare(query)
    data = await statement.fetch()

    attributes = statement.get_attributes()
    column_names = [attr.name for attr in attributes]

    if table_format == False:
        return data
    
    df = pd.DataFrame(data, columns=column_names)

    # Convert columns
    for column in df.columns:
        if pd.api.types.is_datetime64_any_dtype(df[column]):
            df[column] = df[column].astype(str)

    return df