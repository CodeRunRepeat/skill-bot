# Simple skill bot

This project is a derivative of the [Bot Builder Samples](https://github.com/microsoft/BotBuilder-Samples) example for
[simple bot-to-bot skill based communication](https://github.com/microsoft/BotBuilder-Samples/tree/main/samples/csharp_dotnetcore/80.skills-simple-bot-to-bot).
This example demonstrates how to create a simple bot that can be called as a skill from Copilot Studio. See
the [relevant documentation](https://learn.microsoft.com/en-us/azure/bot-service/skill-pva?view=azure-bot-service-4.0)
for more details.

## Prerequisites

- [.NET SDK](https://dotnet.microsoft.com/download) version 8.0

  ```bash
  # determine dotnet version
  dotnet --version
  ```

- An Azure subscription and a user with Contributor permissions
- Copilot Studio in the same tenant as the Azure subscription

## To try this sample

1. Open Azure Cloud Shell or your local shell and clone the repository:

    ```bash
    git clone https://github.com/CodeRunRepeat/skill-bot.git
    ```

1. Change to the directory of the sample:

    ```bash
    cd skill-bot/echo-skill-bot
    ```

1. Review and adjust the parameters (see the [Parameters](#parameters) section) in the relevant section of `setup-bot.sh`.

1. Run the setup script:

    ```bash
    chmod +x setup-bot.sh
    ./setup-bot.sh
    ```

    You may have to authenticate with Azure and select the subscription to use. Relevant commands are at the beginning of the script, commented out.

    After the setup completes, your bot should be up and running and you can test it in the Azure portal
    or using the [Bot Framework Emulator](https://github.com/microsoft/botframework-emulator).

1. Locate and review the bot manifest file that is used to register the bot with Copilot Studio:

    ```bash
    cat echo-skill-bot/wwwroot/manifest/echoskillbot-manifest-1.0.json
    ```

    View the manifest file in the browser.

    ```url
    https://<app_display_name>-appservice.azurewebsites.net/manifest/echoskillbot-manifest-1.0.json
    ```

1. Register the bot with Copilot Studio using the manifest file.

### Updating code

If you have made changes to the bot code and want to update the bot, you can use the `deploy-bot-code.sh` script.
First, update the `resource_group_name` and `app_website_name` parameters in the script to match the values used during setup.
Then run the script:

```bash
chmod +x deploy-bot-code.sh
./deploy-bot-code.sh
```

## Parameters

The following parameters can be adjusted in the `setup-bot.sh` script:

| Parameter | Description | Default |
| --- | --- | --- |
| tenant_id | The Entra ID tenant that hosts all the solution components | Tenant retrieved by `az account show` |
| subscription_id | The Azure subscription to host solution components | Subscription retrieved by `az account show` |
| resource_group_name | The name of the resource group that will contain all solution components | `skill-bot-rg` |
| location | Resource location; should be one of the values returned from `az account list-locations --query "[].name" --output tsv`' | westeurope |
| app_type | The type of the app registration created for bot authentication. Can be SingleTenant or MultiTenant. | MultiTenant |
| app_display_name | The root name for the Entra ID app, web app, and app plan for the solution | skill-bot-<first 8 characters of a new GUID> |
| bot_display_name | The name of the Azure Bot resource | skill-bot-<first 8 characters of a new GUID> |
