"""
Code designed to be run as an Azure Function
and triggered by HTTP requests from Telegram.
"""

import logging
import azure.functions as func
from .handler import handle_request

def main(req: func.HttpRequest) -> func.HttpResponse:
    """Azure Function entry point."""
    logging.info("Function triggered")
    return handle_request(req)
