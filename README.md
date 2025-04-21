# TREP Monitor Platform – Complete Initialization & Usage Guide

A comprehensive guide to set up, develop, and deploy the TREP Monitor Platform: a serverless system that receives images via Telegram, processes them with Azure Functions, and stores them in Azure Blob Storage. 



## 📋 Prerequisites

Before you begin, ensure you have:

| Tool                                  | Check Command                         | Installation / Configuration                                                                                  |
|---------------------------------------|---------------------------------------|---------------------------------------------------------------------------------------------------------------|
| **Git**                               | `git --version`                       | [Install & configure Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)                      |
| **Azure CLI (az)**                    | `az --version`                        | [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) · [Authenticate](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli) |
| **Terraform (v1.0+)**                 | `terraform version`                   | [Install Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli)                           |
| **Python (3.10+)**                    | `python --version`<br>`python3 --version` | [Download Python](https://www.python.org/downloads/)                                                           |
| **Azure Functions Core Tools (func)** | `func --version`                      | [Install Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local) |
| **Telegram & BotFather**              | Chat with `@BotFather`                | [Telegram BotFather guide](https://core.telegram.org/bots#botfather)                                          |

<br>

---

## 🔐 Telegram Bot Creation

1. **Open BotFather** in Telegram or Web:
   - Search for `@BotFather` and start a chat.
2. **Create a new bot**:
   ```
   /newbot
   ```
3. **Follow prompts**:
   - **Name**: e.g., `TREP Monitor Bot`
   - **Username**: must end with `bot`, e.g., `trep_monitor_bot`
4. **Save the API Token**:
   - BotFather returns a token like `123456:ABC-DEF...`.
   - You will use this token in local settings and Terraform.

---

## 📂 Project Structure

```
trep-monitor-platform/
├── .gitignore
├── README.md                    # This guide
├── infra/                       # Terraform IaC
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── functions/                   # Azure Functions code
│   └── process-telegram-image/
│       ├── __init__.py          # Entry point
│       ├── handler.py           # Processing logic
│       ├── function.json        # HTTP trigger binding
│       ├── requirements.txt     # Python deps
│       └── local.settings.json.template
└── docs/                        # Additional documentation
    └── architecture.md
```

---

## ⚙️ 1. Infrastructure Provisioning (Terraform)

1. **Copy example vars**:
   ```bash
   cp infra/terraform.tfvars.example infra/terraform.tfvars
   ```
2. **Edit** `infra/terraform.tfvars`:
   ```hcl
   prefix               = "trepmon"
   location             = "eastus"
   telegram_bot_token   = "<YOUR_TELEGRAM_BOT_TOKEN>"
   subscription_id      = "<YOUR_SUBSCRIPTION_ID>"
   ```
3. **Initialize & Apply**:
   ```bash
   cd infra
   terraform init
   terraform plan
   terraform apply -auto-approve
   ```
4. **Record outputs**:
   - `resource_group_name`
   - `function_app_url`
   - `storage_connection_string`

---

## 🛠️ 2. Local Development & Testing

1. **Configure local.settings**:
   ```bash
   cd functions/process-telegram-image
   cp local.settings.json.template local.settings.json
   ```
   Edit `local.settings.json`:
   ```json
   {
     "IsEncrypted": false,
     "Values": {
       "AzureWebJobsStorage": "<storage_connection_string>",
       "FUNCTIONS_WORKER_RUNTIME": "python",
       "TELEGRAM_BOT_TOKEN": "<YOUR_TELEGRAM_BOT_TOKEN>"
     }
   }
   ```

2. **Create & activate virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate   # Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the Function locally**:
   ```bash
   func host start
   ```
   - Listening at `http://localhost:7071/api/process-telegram-image`

5. **Test with cURL or Postman**:
   ```bash
   curl -X POST http://localhost:7071/api/process-telegram-image \
        -H "Content-Type: application/json" \
        -d '{"message": {"photo": [{"file_id": "TEST_ID"}]}}'
   ```
   - The function should return `OK`.

---

## 🚀 3. Deployment to Azure

1. **Publish Function**:
   ```bash
   cd functions/process-telegram-image
   func azure functionapp publish <FUNCTION_APP_NAME>
   ```
2. **Set up Telegram Webhook**:
   ```bash
   curl -X POST "https://api.telegram.org/bot<YOUR_TELEGRAM_BOT_TOKEN>/setWebhook" \
        -d "url=https://<FUNCTION_APP_URL>/api/process-telegram-image"
   ```
   - Replace `<FUNCTION_APP_URL>` with the hostname from Terraform output.

3. **Verify in Azure Portal**:
   - Open the Function App under the Resource Group.
   - Check **Configuration** to confirm `TELEGRAM_BOT_TOKEN` and connection strings.

---

## 📦 4. Usage & Testing

- **Send an image** to your Telegram bot.
- **Monitor** the Azure Function logs in the portal.
- **Check** the `telegram-images` Blob container for uploaded files.

---

## 🤝 Contributing

1. **Fork** the repo.
2. **Create** a feature branch: `git checkout -b feature/xyz`
3. **Commit** your changes.
4. **Push** and open a Pull Request.

Please follow coding standards, add docstrings, and include unit tests if applicable.

---

## 📄 License

This project is licensed under the **MIT License**. See [LICENSE](./LICENSE) for details.

---

_For questions or support, open an issue in GitHub or contact the maintainers._

