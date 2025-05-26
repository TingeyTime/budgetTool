import logging
from enum import Enum
from typing import List
import os

from pydantic import BaseModel


class LoggingLevel(Enum):
    """
    Use with LoggingInfo Class to decide what level of logging you want
    """
    DEBUG = logging.DEBUG
    INFO = logging.INFO
    WARNING = logging.WARNING
    ERROR = logging.ERROR
    CRITICAL = logging.CRITICAL


class LoggerInfo(BaseModel):
    """
    Logging Info class provides you way to log different thing differently
    """
    name: str
    level: LoggingLevel


def get_my_logger(my_logger, logging_infos: List[LoggerInfo] = None, *, write_to_file: bool = False, file_path: str = "temp.log"):
    """
    Get a logger with the specified name and logging level.

    :param my_logger: name of logger
    :param logging_infos: what you want to log
    :param write_to_file: whether to write to file
    :param file_path: name of file to write to
    :return:
    """
    TEXT_FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'

    logging.basicConfig(level=logging.INFO, format=TEXT_FORMAT)
    logger = logging.getLogger(my_logger)
    logger.propagate = False  # Prevent double logging if root logger is configured elsewhere

    # Add console handler
    if not any(isinstance(handler, logging.StreamHandler) for handler in logger.handlers):
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(logging.Formatter(TEXT_FORMAT))
        logger.addHandler(console_handler)

    # Add file handler if requested
    if write_to_file:
        if not (file_path.endswith(".txt") or file_path.endswith(".log")):
            raise ValueError(f"file_path '{file_path}' must be a .txt or .log file")
        if os.path.dirname(file_path):
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
        if not any(isinstance(handler, logging.FileHandler) for handler in logger.handlers):
            file_handler = logging.FileHandler(file_path)
            file_handler.setFormatter(logging.Formatter(TEXT_FORMAT))
            logger.addHandler(file_handler)

        # Ensure root logger also writes to the file
        root_logger = logging.getLogger()
        if not any(isinstance(handler, logging.FileHandler) for handler in root_logger.handlers):
            root_file_handler = logging.FileHandler(file_path)
            root_file_handler.setFormatter(logging.Formatter(TEXT_FORMAT))
            root_logger.addHandler(root_file_handler)

    if logging_infos:
        for li in logging_infos:
            logging.getLogger(li.name).setLevel(li.level.value)

    return logger