#az login --scope https://management.core.windows.net//.default
#az account set --subscription <<subscription>>
#az account show

# Load values from .env into variables
source .env
resource_group_name=${RESOURCE_GROUP_NAME}
app_website_name=${APP_WEBSITE_NAME}

# Update the appsettings.json file
envsubst < ./appsettings.template.json > ./appsettings.json
# Update the manifest file
envsubst < ./wwwroot/manifest/echoskillbot-manifest-1.0.template.json > ./wwwroot/manifest/echoskillbot-manifest-1.0.json
echo "appsettings.json and manifest files updated with the necessary values"

dotnet build --configuration Release --os win

zip -r bot.zip . -x "bot.zip" -x "DeploymentTemplates/*" -x ".env" -x "*.template.*" -x ".git/*" -x ".gitignore" -x ".vscode/*" 

# Deploy the bot
echo "Deploying the bot to $app_website_name"
az webapp deploy --name $app_website_name --resource-group $resource_group_name --src-path ./bot.zip