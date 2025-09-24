# Examples — AI Landing Zone (Bicep AVM Pattern)

Use these **parameter snippets** as starting points. Omit anything you do not need; sensible defaults apply.

---

## Table of Contents

* [1) Greenfield — everything created & isolated](#1-greenfield--everything-created--isolated)
* [2) Minimal app footprint (no perimeter)](#2-minimal-app-footprint-no-perimeter)
* [3) Reuse shared VNet + LAW/Insights + ACR (and reuse PDNS)](#3-reuse-shared-vnet--lawinsights--acr-and-reuse-pdns)
* [4) AI Foundry scenarios](#4-ai-foundry-scenarios)
  * [4.1) Full Foundry — Agent Service **on**, auto‑deps **on**, with model deployments](#41-full-foundry--agent-service-on-auto-deps-on-with-model-deployments)
  * [4.2) Project only — **no Agent Service**, no auto‑deps (BYOR)](#42-project-only--no-agent-service-no-auto-deps-byor)
* [5) Platform Landing Zone integration (PDNS/PE managed by platform)](#5-platform-landing-zone-integration-pdnspe-managed-by-platform)
* [6) Use the pattern as an AVM module (in your repo)](#6-use-the-pattern-as-an-avm-module-in-your-repo)
* [7) Dual VNets + Fabric + Bot + Enterprise Policy (advanced)](#7-dual-vnets--fabric--bot--enterprise-policy-advanced)

---

## 1) Greenfield — everything created & isolated

Everything new in a private, isolated spoke. **Agent Service ON**, **auto‑deps ON**, with two example model deployments.

```json
{
  "parameters": {
    "location": { "value": "westus3" },
    "tags": { "value": { "env": "dev", "owner": "ai-team" } },

    "aiFoundryDefinition": {
      "value": {
        "includeAssociatedResources": true,
        "aiFoundryConfiguration": {
          "accountName": "af-${baseName}",
          "createCapabilityHosts": true,
          "project": { "name": "proj-${baseName}", "displayName": "AI Project" }
        },
        "aiModelDeployments": [
          {
            "name": "chat",
            "model": { "format": "OpenAI", "name": "gpt-4o", "version": "2024-11-20" },
            "scale": { "type": "Standard", "capacity": 1 }
          },
          {
            "name": "text-embedding",
            "model": { "format": "OpenAI", "name": "text-embedding-3-large", "version": "1" },
            "scale": { "type": "Standard", "capacity": 1 }
          }
        ]
      }
    }
  }
}
```

*No perimeter changes needed; WAF/AGW/APIM/Firewall follow defaults. VNet/PDNS/PE are created automatically (isolated posture).*

---

## 2) Minimal app footprint (no perimeter)

Deploy the core app stack without AGW/APIM/Firewall, and keep Foundry light (**no Agent Service**, **no auto‑deps**).

```json
{
  "parameters": {
    "tags": { "value": { "env": "dev" } },

    "deployToggles": {
      "value": {
        "apiManagement": false,
        "applicationGateway": false,
        "firewall": false,
        "wafPolicy": false,
        "buildVm": false,
        "jumpVm": false
      }
    },

    "aiFoundryDefinition": {
      "value": {
        "includeAssociatedResources": false,
        "aiFoundryConfiguration": {
          "createCapabilityHosts": false,
          "project": { "name": "proj-${baseName}", "displayName": "Project Only" }
        }
      }
    }
  }
}
```

---

## 3) Reuse shared VNet + LAW/Insights + ACR (and reuse PDNS)

Point the pattern at **existing platform assets** and **existing Private DNS zones**.

```json
{
  "parameters": {
    "resourceIds": {
      "value": {
        "virtualNetworkResourceId": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>",
        "logAnalyticsWorkspaceResourceId": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<law>",
        "appInsightsResourceId": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Insights/components/<appi>",
        "containerRegistryResourceId": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.ContainerRegistry/registries/<acr>"
      }
    },

    "privateDnsZoneIds": {
      "value": {
        "cognitiveservices": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com",
        "openai": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com",
        "aiServices": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.services.ai.azure.com",
        "search": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.search.windows.net",
        "cosmosSql": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.com",
        "blob": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.blob.<region>.core.windows.net",
        "keyVault": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net",
        "appConfig": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.azconfig.io",
        "containerApps": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.<location>.azurecontainerapps.io",
        "acr": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io",
        "appInsights": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.applicationinsights.azure.com"
      }
    }
  }
}
```

> Optional: If you also want Foundry to **reuse** your own Search/Cosmos/KV/Storage, set `existingResourceId` inside `aiFoundryDefinition.aiSearchConfiguration`, `cosmosDbConfiguration`, `keyVaultConfiguration`, and `storageAccountConfiguration`.

---

## 4) AI Foundry scenarios

### 4.1) Full Foundry — Agent Service **on**, auto‑deps **on**, with model deployments

```json
{
  "parameters": {
    "aiFoundryDefinition": {
      "value": {
        "includeAssociatedResources": true,
        "aiFoundryConfiguration": {
          "accountName": "af-${baseName}",
          "createCapabilityHosts": true,
          "project": { "name": "proj-${baseName}", "displayName": "AI Project" }
        },
        "aiModelDeployments": [
          {
            "name": "chat",
            "model": { "format": "OpenAI", "name": "gpt-4o", "version": "2024-11-20" },
            "scale": { "type": "Standard", "capacity": 1 }
          }
        ]
      }
    }
  }
}
```

### 4.2) Project only — **no Agent Service**, no auto‑deps (BYOR)

```json
{
  "parameters": {
    "aiFoundryDefinition": {
      "value": {
        "includeAssociatedResources": false,
        "aiFoundryConfiguration": {
          "createCapabilityHosts": false,
          "project": { "name": "proj-${baseName}", "displayName": "Project Only" }
        }
      }
    }
  }
}
```

> In BYOR mode, provision Search/Cosmos/Storage/KV separately and point your application to them.

---

## 5) Platform Landing Zone integration (PDNS/PE managed by platform)

Use when **platform** owns Private DNS and Private Endpoints. The pattern will **not** create PDNS/PE; it will bind to the zones you supply.

```json
{
  "parameters": {
    "flagPlatformLandingZone": { "value": true },

    "privateDnsZoneIds": {
      "value": {
        "cognitiveservices": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com",
        "openai": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com",
        "aiServices": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.services.ai.azure.com",
        "search": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.search.windows.net",
        "cosmosSql": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.com",
        "blob": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.blob.<region>.core.windows.net",
        "keyVault": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net",
        "appConfig": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.azconfig.io",
        "containerApps": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.<location>.azurecontainerapps.io",
        "acr": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io",
        "appInsights": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.applicationinsights.azure.com"
      }
    }
  }
}
```

---

## 6) Use the pattern as an AVM module (in your repo)

Reference the Azure Verified Pattern Module from your own Bicep file:

**Registry‑based reference (example placeholder):**

```bicep
module landingZone 'br/public:avm/ptn/aiml-landing-zone:<version>' = {
  name: 'landingZone'
  params: {
    location: resourceGroup().location
    tags: { env: 'dev' }
    aiFoundryDefinition: {
      includeAssociatedResources: true
      aiFoundryConfiguration: {
        createCapabilityHosts: true
        project: { name: 'proj-${uniqueString(resourceGroup().id)}' }
      }
    }
  }
}
```

> Pin a specific `<version>` and adjust parameters as in the examples above.

---

## 7) Dual VNets + Fabric + Bot + Enterprise Policy (advanced)

End-to-end scenario combining:

* **Primary + Secondary VNet** (segmentation + future growth)
* **Microsoft Fabric Capacity** (analytics / OneLake workloads)
* **Azure Bot Service** (F0) bound to an existing Entra application
* **Power Platform Enterprise Policy** (NetworkInjection) with subnet inference (auto-targets `powerplatform-subnet` in both VNets)
* **Core GenAI backing services** shared via AI Foundry definition

Prerequisites:

1. Providers registered: `Microsoft.PowerPlatform`, `Microsoft.Fabric`, `Microsoft.BotService` (if not already).
2. Entra application created; record client ID → `botServiceAppId`.
3. Non-overlapping CIDRs for primary & secondary VNets.

```json
{
  "parameters": {
    "baseName": { "value": "<baseName>" },
    "deployToggles": { "value": {
      "logAnalytics": true,
      "appInsights": true,
      "containerEnv": true,
      "containerRegistry": true,
      "containerApps": true,
      "cosmosDb": true,
      "keyVault": true,
      "storageAccount": true,
      "searchService": true,
      "groundingWithBingSearch": true,
      "appConfig": true,
      "apiManagement": false,
      "applicationGateway": false,
      "firewall": false,
      "fabricCapacity": true,
      "botService": true,
      "buildVm": false,
      "jumpVm": false,
      "virtualNetwork": true,
      "secondaryVirtualNetwork": true,
      "enterprisePolicy": true,
      "wafPolicy": false
    }},
    "fabricCapacityDefinition": { "value": {
      "name": "",
      "skuName": "F4",
      "administrators": [ "<aadObjectId1>", "<aadObjectId2>" ],
      "tags": { "environment": "dev", "workload": "fabric" }
    }},
    "botServiceDefinition": { "value": {
      "name": "",
      "skuName": "F0",
      "enabledChannels": [ "MsTeamsChannel" ],
      "tags": { "environment": "dev", "workload": "bot" }
    }},
    "botServiceAppId": { "value": "<entra-app-client-id-guid>" },
    "botServiceEndpoint": { "value": "https://placeholder.invalid/" },
    "enterprisePolicyDefinition": { "value": {
      "name": "",
      "virtualNetworks": [],
      "tags": { "environment": "dev", "workload": "powerplatform" }
    }},
    "vnetDefinition": { "value": {
      "addressSpace": "192.168.0.0/16",
      "subnets": [
        { "enabled": true, "name": "agent-subnet", "addressPrefix": "192.168.0.0/24", "delegation": "Microsoft.app/environments" },
        { "enabled": true, "name": "pe-subnet", "addressPrefix": "192.168.1.0/24", "privateEndpointNetworkPolicies": "Disabled" },
        { "enabled": true, "name": "powerplatform-subnet", "addressPrefix": "192.168.5.0/24" },
        { "enabled": true, "name": "dataingestion-subnet", "addressPrefix": "192.168.7.0/24" }
      ],
      "tags": { "networkRole": "primary" }
    }},
    "secondaryVnetDefinition": { "value": {
      "addressSpace": "192.169.0.0/16",
      "subnets": [
        { "enabled": true, "name": "agent-subnet", "addressPrefix": "192.169.0.0/24", "delegation": "Microsoft.app/environments" },
        { "enabled": true, "name": "pe-subnet", "addressPrefix": "192.169.1.0/24", "privateEndpointNetworkPolicies": "Disabled" },
        { "enabled": true, "name": "powerplatform-subnet", "addressPrefix": "192.169.5.0/24" },
        { "enabled": true, "name": "dataingestion-subnet", "addressPrefix": "192.169.7.0/24" }
      ],
      "tags": { "networkRole": "secondary" }
    }},
    "aiFoundryDefinition": { "value": {
      "includeAssociatedResources": true,
      "aiFoundryConfiguration": {
        "createCapabilityHosts": true,
        "project": { "name": "proj-${baseName}", "displayName": "AI Project" }
      },
      "aiModelDeployments": [
        { "name": "chat", "model": { "format": "OpenAI", "name": "gpt-4o", "version": "2024-11-20" }, "scale": { "type": "Standard", "capacity": 1 } }
      ]
    }},
    "jumpVmAdminPassword": { "value": "<StrongP@ssw0rd!>" }
  }
}
```

> To **reuse** an existing Enterprise Policy instead of creating one, set:
> ```json
> "resourceIds": { "value": { "enterprisePolicyResourceId": "/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.PowerPlatform/enterprisePolicies/<policyName>" } }
> ```
> and optionally disable creation by omitting `enterprisePolicyDefinition` or turning off its toggle.

