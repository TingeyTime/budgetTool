import os
from dotenv import load_dotenv
import keyring
from app.logger_utility import get_my_logger

load_dotenv()
logger = get_my_logger("Cred Manager", [])

def _get_key_from_env(config, key):
    t = os.environ.get(f"{config}_{key}")
    if t:
        return t

    t1 = os.environ.get(f"{config.upper()}_{key.upper()}")
    if t1:
        return t1

    return os.environ.get(f"{config.capitalize()}_{key.capitalize()}")


def _get_key_from_keyring(config, key):
    return keyring.get_password(config, key)


def _get_key_from_folder(config, key):
    locations = ['', '/']
    for location in locations:
        file = f"{location}cred/{config}/{config}_{key}"
        if os.path.isfile(file):
            with open(file, 'rb') as f:
                return f.read().decode('utf-8')


def get_key(config, key, default=None):
    """

    :param config: config is group name like aws, analytics, aws-us, production_db
    :param key: key is individual key within group like password, username, port, database
    :param default: use if you want to provide default value if missing all places
    :return:
    """
    env = _get_key_from_env(config, key)
    if env:
        return env

    file_data = _get_key_from_folder(config, key)
    if file_data:
        return file_data

    # _keyring = _get_key_from_keyring(config, key)
    # if _keyring:
    #     return _keyring

    if default:
        return default

    raise Exception("No Key Found")