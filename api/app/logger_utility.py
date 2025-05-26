import logging
from enum import Enum
from typing import List

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


def get_my_logger(my_logger, logging_infos: List[LoggerInfo] = None):
    """

    :param my_logger: name of logger
    :param logging_infos: what you want to log
    :return:
    """
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    logger = logging.getLogger(my_logger)
    if logging_infos is None:
        return logger

    for li in logging_infos:
        logging.getLogger(li.name).setLevel(li.level.value)

    return logger