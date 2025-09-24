@description('Name of the Bot Service.')
param name string
@description('Azure region for the Bot Service.')
param location string
@description('SKU name (F0 or S1).')
param skuName string
@description('Enabled channels (e.g., MsTeamsChannel).')
param enabledChannels array = []
@description('Existing Entra ID application (client) ID to associate as msaAppId (pre-created).')
param msaAppId string
@description('Messaging endpoint (must be https). Provide placeholder if not yet available.')
param endpoint string
@description('Tags to apply.')
param tags object = {}

resource botService 'Microsoft.BotService/botServices@2022-09-15' = {
  name: name
  location: location
  sku: {
    name: skuName
  }
  properties: {
    displayName: name
    description: 'AI Foundry agent channel bridge'
    endpoint: endpoint
    msaAppId: msaAppId
  }
  tags: tags
}

resource botChannels 'Microsoft.BotService/botServices/channels@2022-09-15' = [for ch in enabledChannels: {
  name: ch
  parent: botService
  properties: {
    channelName: ch
    properties: {}
  }
}]

output resourceId string = botService.id
output botServiceName string = name
output botServiceSkuName string = skuName
