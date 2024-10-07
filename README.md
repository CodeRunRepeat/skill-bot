# Simple skill bot

This project is a derivative of the [Bot Builder Samples](https://github.com/microsoft/BotBuilder-Samples) example for
[simple bot-to-bot skill based communication](https://github.com/microsoft/BotBuilder-Samples/tree/main/samples/csharp_dotnetcore/80.skills-simple-bot-to-bot).
This example demonstrates how to create a simple bot that can be called as a skill from Copilot Studio.

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
    git clone xxxx.git
    ```

1. Change to the directory of the sample:

    ```bash
    cd skill-bot
    ```

1. Review and adjust the parameters (see the [Parameters](#parameters) section) in the relevant section of setup-bot.sh

1. Run the setup script:

    ```bash
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

## Parameters

TBD
