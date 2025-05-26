import os
from dotenv import load_dotenv
from pydantic import BaseModel

load_dotenv()

class EnvironmentConfiguration(BaseModel):
    environment: str
    secrets: str

def _get_config():
    return EnvironmentConfiguration(
        environment = os.environ.get('ENV'),
        secrets = os.environ.get('SECRETS_LOCATION')
    )