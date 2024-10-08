# Instructions in https://learn.microsoft.com/en-us/azure/bot-service/provision-and-publish-a-bot?view=azure-bot-service-4.0&tabs=userassigned%2Ccsharp

#az login --scope https://management.core.windows.net//.default
#az account set --subscription <<subscription>>
#az account show

# -------------------------------- Functions- --------------------------------
warning () { 
    echo -e "\e[93m$1\e[0m" 
}

function guid() {
    echo $(cat /proc/sys/kernel/random/uuid | cut -c-8)
}

# -------------------------------- Parameters --------------------------------
tenant_id=$(az account show --query tenantId -o tsv)
subscription_id=$(az account show --query id -o tsv)
resource_group_name="skill-bot-rg"
location="westeurope"
app_type="MultiTenant" # or "SingleTenant"

guid=$(guid)
app_display_name="skill-bot-$guid"
bot_display_name="skill-bot-$guid"

echo "Using the following parameters:"
echo "tenant_id=$tenant_id"

echo "resource_group_name=$resource_group_name"
if [ $(az group exists --name $resource_group_name) == "true" ]; then
    warning "Resource group $resource_group_name already exists."
fi

echo "location=$location"
echo "app_type=$app_type"

echo "app_display_name=$app_display_name"
app_website_name=$app_display_name-appservice
echo "app_website_name=$app_website_name"

app_name_available=$(az rest --method post --uri https://management.azure.com/subscriptions/$subscription_id/providers/Microsoft.Web/checknameavailability?api-version=2023-12-01 --body "{\"name\":\"$app_website_name\",\"type\":\"Microsoft.Web/sites\"}" | jq -r '.nameAvailable')
if [ $app_name_available != "true" ]; then
    warning "App service $app_website_name already exists."
fi

if [ $(az ad app list --display-name $app_display_name --query 'length(@)' -o tsv) -gt 0 ]; then
    warning "App registration $app_display_name already exists."
fi

echo "bot_display_name=$bot_display_name"

echo "Do you want to continue? (y/n)"
read continue
if [ $continue != "Y" ] && [ $continue != "y" ]; then
    echo "Exiting"
    exit 1
fi

# ----------------------------------------------------------------------------
# Create the resource group
resource_group_id=$(az group create --name $resource_group_name --location $location --query id -o tsv)
echo "Resource group $resource_group_name created: $resource_group_id"

# Set the audience argument depending on app type
if [ $app_type == "MultiTenant" ]; then
    audience="AzureADMultipleOrgs"
else
    audience="AzureADMyOrg"
fi
echo "Audience set to $audience"

# ----------------------------------------------------------------------------
# Create app registration
response=$(az ad app create --display-name $app_display_name --sign-in-audience $audience)
app_id=$(echo $response | jq -r '.appId')
echo "App registration $app_display_name created: $app_id"

# Set the app registration home page URL
az ad app update --id $app_id --web-home-page-url "https://$app_website_name.azurewebsites.net"

# Create client secret
response=$(az ad app credential reset --id $app_id)
client_secret=$(echo $response | jq -r '.password')
echo "Client secret created: $client_secret"

# ----------------------------------------------------------------------------
# Create the bot registration (probably not needed as included in the deployment template below)
if [ $app_type == "MultiTenant" ]; then
    echo "Creating a MultiTenant bot"
    response=$(az bot create --app-type $app_type --name $bot_display_name --resource-group $resource_group_name --appid $app_id)
else
    echo "Creating a SingleTenant bot"
    response=$(az bot create --app-type $app_type --name $bot_display_name --resource-group $resource_group_name --appid $app_id --tenant-id $tenant_id)
fi
bot_id=$(echo $response | jq -r '.id')
echo "Bot registration $bot_display_name created: $bot_id"

# ----------------------------------------------------------------------------
# Generate environment file with the necessary values
echo "export RESOURCE_GROUP_NAME=$resource_group_name" > .env
echo "export LOCATION=$location" >> .env
echo "export RESOURCE_GROUP_ID=$resource_group_id" >> .env
echo "export APP_ID=$app_id" >> .env
echo "export APP_TYPE=$app_type" >> .env
echo "export APP_DISPLAY_NAME=$app_display_name" >> .env
echo "export APP_WEBSITE_NAME=$app_website_name" >> .env
echo "export CLIENT_SECRET=$client_secret" >> .env
echo "export BOT_ID=$bot_id" >> .env
echo "export BOT_DISPLAY_NAME=$bot_display_name" >> .env
echo "export TENANT_ID=$tenant_id" >> .env
echo "export SUBSCRIPTION_ID=$subscription_id" >> .env
echo 'export schema=\$schema' >> .env
echo 'export id=\$id' >> .env

echo "Environment file .env created with the necessary values"
cat .env

# ----------------------------------------------------------------------------
# Replace placeholders in the app json parameter files with values in .env
source .env
envsubst < ./DeploymentTemplates/DeployUseExistResourceGroup/parameters-for-template-BotApp-with-rg.json > ./DeploymentTemplates/DeployUseExistResourceGroup/parameters-for-template-BotApp-with-rg.replaced.json

# Deploy the bot app
echo "Deploying the bot app with template-BotApp-with-rg.json"
az deployment group create --resource-group $resource_group_name --template-file ./DeploymentTemplates/DeployUseExistResourceGroup/template-BotApp-with-rg.json --parameters ./DeploymentTemplates/DeployUseExistResourceGroup/parameters-for-template-BotApp-with-rg.replaced.json

# Replace placeholders in the bot json parameter files with values in .env
envsubst < ./DeploymentTemplates/DeployUseExistResourceGroup/parameters-for-template-AzureBot-with-rg.json > ./DeploymentTemplates/DeployUseExistResourceGroup/parameters-for-template-AzureBot-with-rg.replaced.json

# Deploy the bot
echo "Deploying the bot with template-AzureBot-with-rg.json"
az deployment group create --resource-group $resource_group_name --template-file ./DeploymentTemplates/DeployUseExistResourceGroup/template-AzureBot-with-rg.json --parameters ./DeploymentTemplates/DeployUseExistResourceGroup/parameters-for-template-AzureBot-with-rg.replaced.json

# ----------------------------------------------------------------------------
# Update the appsettings.json file
envsubst < ./appsettings.template.json > ./appsettings.json
# Update the manifest file
envsubst < ./wwwroot/manifest/echoskillbot-manifest-1.0.template.json > ./wwwroot/manifest/echoskillbot-manifest-1.0.json
echo "appsettings.json and manifest files updated with the necessary values"

# Prepare the bot
echo "Preparing the bot for deployment"
rm .deployment
az bot prepare-deploy --lang Csharp --code-dir "." --proj-file-path "./EchoSkillBot.csproj"
dotnet clean
dotnet build --configuration Release --os win

zip -r bot.zip . -x "bot.zip" -x "DeploymentTemplates/*" -x ".env" -x "*.template.*" -x ".git/*" -x ".gitignore" -x ".vscode/*" 

# Deploy the bot
echo "Deploying the bot to $app_website_name"
az webapp deploy --name $app_website_name --resource-group $resource_group_name --src-path ./bot.zip

# ----------------------------------------------------------------------------
echo "Deployment completed"