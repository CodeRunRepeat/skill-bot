#az login --scope https://management.core.windows.net//.default
#az account set --subscription <<subscription>>
#az account show

resource_group_name="skill-bot-rg"
app_website_name="skill-bot-sprintwave-test-appservice"

dotnet build --configuration Release --os win

zip -r bot.zip . -x "bot.zip" -x "DeploymentTemplates/*" -x ".env" -x "*.template.*" -x ".git/*" -x ".gitignore" -x ".vscode/*" 

# Deploy the bot
echo "Deploying the bot to $app_website_name"
az webapp deploy --name $app_website_name --resource-group $resource_group_name --src-path ./bot.zip