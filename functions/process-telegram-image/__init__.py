"""
Code designed to be run as an Azure Function
and triggered by HTTP requests from Telegram.
"""

import azure.functions as func
from handler import handle_request

def main(req: func.HttpRequest) -> func.HttpResponse:
    """Azure Function entry point."""
    return handle_request(req)
