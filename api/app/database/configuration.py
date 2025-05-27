import os
from app.logger_utility import get_my_logger
from app.cred_manager import get_key

logger = get_my_logger("Database Configuration Manager", [])

class ConfigManager:
    def __init__(self) -> None:
        self.env = "dev"
        logger.info(f"Configuration Manager will be using the {self.env} database.")

    def get_secret(self, config=None, key=None, name=None):
        return get_key(config, key)
        

class PostgresDatabaseConfiguration:
    def __init__(self) -> None:
        c = ConfigManager()
        self.database = get_key("postgres", "db")
        self.host = c.get_secret(config="postgres", key="host")
        self.port = c.get_secret(config="postgres", key="port")
        self.user = c.get_secret(config="postgres", key="user")
        self.password = c.get_secret(config="postgres", key="password")

    def get_config(self):
        return {
            "database": self.database,
            "host": self.host,
            "port": self.port,
            "user": self.user,
            "password": self.password,
        }
    
class RedisDatabaseConfiguration:
    def __init__(self) -> None:
        c = ConfigManager()

        self.host = c.get_secret(config = f"redis_{c.env}", key="host")
        self.port = c.get_secret(config = f"redis_{c.env}", key="port")
        self.password = c.get_secret(config = f"redis_{c.env}", key="password")

    def get_config(self):
        return {
            "host": self.host,
            "port": self.port,
            "password": self.password,
        }
