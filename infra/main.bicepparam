using './main.bicep'

param aiFoundryDefinition = {
  includeAssociatedResources: true
  aiFoundryConfiguration: {
    createCapabilityHosts: true
  }       
  aiModelDeployments: [
    {
      name: 'gpt-4o'
      raiPolicyName: ''
      versionUpgradeOption: ''
      model: {
        format: 'OpenAI'
        name: 'gpt-4o'
        version: '2024-11-20'
      }
      scale: {
        type: 'Standard'
        capacity: 1
        family: ''
        size: ''
        tier: ''
      }
    }
  ]
}

param jumpVmAdminPassword = '$(secretOrRandomPassword)'

// Enable Fabric capacity deployment and provide optional configuration
param deployToggles = {
  logAnalytics: true
  appInsights: true
  containerEnv: true
  containerRegistry: true
  containerApps: true
  cosmosDb: true
  keyVault: true
  storageAccount: true
  searchService: true
  groundingWithBingSearch: true
  appConfig: true
  apiManagement: true
  applicationGateway: true
  firewall: true
  fabricCapacity: true
  botService: true
  enterprisePolicy: true
  buildVm: false
  jumpVm: false
  virtualNetwork: true
  secondaryVirtualNetwork: false
  wafPolicy: true
}

param fabricCapacityDefinition = {
  name: ''
  skuName: 'F2'
  administrators: []
  tags: {
    workload: 'fabric'
  }
}

// TODO: Replace with the existing Entra (Microsoft Entra ID) application client ID (app registration) you
// want to associate with the Bot Service (msaAppId). This app must have a secret/certificate you will configure
// later in the Azure Portal for channel messaging. Keep the GUID format.
param botServiceAppId = '12345678-1234-1234-1234-123456789abc'

param botServiceDefinition = {
  name: ''
  skuName: 'F0'
  enabledChannels: []
  tags: {}
}

param enterprisePolicyDefinition = {
  name: ''
  virtualNetworks: []
  tags: {}
}
