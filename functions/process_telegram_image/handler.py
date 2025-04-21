"""
This function processes incoming Telegram messages with images,
downloads the images, and uploads them to Azure Blob Storage.
"""

import os
import requests
from azure.storage.blob import BlobServiceClient
import azure.functions as func

TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
STORAGE_CONN = os.getenv("AzureWebJobsStorage")
CONTAINER = "telegram-images"

def get_file_path(file_id: str) -> str:
    """Retrieve file path from Telegram API."""
    response = requests.get(
        f"https://api.telegram.org/bot{TOKEN}/getFile?file_id={file_id}"
    ).json()
    return response["result"]["file_path"]

def download_image(file_path: str) -> bytes:
    """Download image content from Telegram servers."""
    url = f"https://api.telegram.org/file/bot{TOKEN}/{file_path}"
    return requests.get(url).content

def upload_to_blob(image_content: bytes, file_name: str) -> None:
    """Upload image to Azure Blob Storage."""
    blob_service = BlobServiceClient.from_connection_string(STORAGE_CONN)
    blob_client = blob_service.get_blob_client(CONTAINER, file_name)
    blob_client.upload_blob(image_content, overwrite=True)

def handle_request(req: func.HttpRequest) -> func.HttpResponse:
    """Process incoming Telegram webhook or provide GET confirmation."""
    
    if req.method == "GET":
        return func.HttpResponse(
            "🔍 This endpoint is active and ready to receive POST requests from Telegram.",
            status_code=200
        )

    try:
        update = req.get_json()
        photo = update.get("message", {}).get("photo")

        if photo:
            file_id = photo[-1]["file_id"]
            file_path = get_file_path(file_id)
            image_content = download_image(file_path)
            upload_to_blob(image_content, f"{file_id}.jpg")

        return func.HttpResponse("✅ Image processed successfully.", status_code=200)

    except ValueError:
        return func.HttpResponse("❌ Invalid JSON in request.", status_code=400)

    except Exception as e:
        return func.HttpResponse(f"🚨 Internal server error: {str(e)}", status_code=500)
