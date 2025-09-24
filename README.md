# AI Landing Zone (Bicep AVM Pattern)

This repository contains the **Bicep code** for the **AI Landing Zone Architecture**, published as an [Azure Verified Module](https://aka.ms/avm) Pattern. It provides a landing zone tailored for **generative AI application workloads**, automating deployment of a secure and configurable environment on Azure.

Recent enhancements add:

* **Dual Virtual Network support** (primary + optional secondary) for isolation and workload segmentation.
* **Power Platform Enterprise Policy (Network Injection)** with automatic subnet inference (targets `powerplatform-subnet`).
* **Microsoft Fabric Capacity** provisioning (create or reuse) including administrators and tagging.
* **Azure Bot Service** integration (F0/S tiers) bound to a pre-created Entra application (bring your own `botServiceAppId`).
* New **purpose-specific subnets** (`powerplatform-subnet`, `powerbi-subnet`, `dataingestion-subnet`) to enable governed analytics and Power Platform gateway scenarios.

## Architecture

The architecture delivers a complete **AI Landing Zone** with **Azure AI Foundry** at its core. The **AI Foundry Agent service** operates alongside its main dependencies — **Azure AI Search, Cosmos DB, Storage, and Key Vault** — within a secure and integrated setup. In addition, a dedicated **Azure Container Apps environment** is provisioned, enabling you to build and run your own **GenAI applications**. Supporting services for configuration, data management, and observability are also included. Thanks to the component-based design, you can deploy the full stack or only the parts that best match your project needs.

![Architecture](./docs/architecture.png)
*AI Landing Zone*

Flexibility comes from **feature toggles**: you choose whether to create or reuse each service (including Fabric, Bot Service, Enterprise Policy, and a secondary VNet). This approach supports both greenfield deployments and integration with an existing platform landing zone.

By default, network isolation is enabled, ensuring that all traffic flows exclusively through Private Endpoints. Name resolution is handled via Private DNS zones, either created during deployment or linked to zones already managed at the platform level. When enabled, the Enterprise Policy applies Power Platform network injection across the deployed VNets.

## Documentation

* [**How to deploy the Landing Zone.**](./docs/how_to_use.md)
  Step-by-step instructions on creating or reusing resources, setting up isolation, and configuring parameters. Includes a minimal example and notes on running `azd provision` (make sure the CLI is installed and logged in before you start).

* [**Parameter reference.**](./docs/parameters.md)
  Full list of parameters and objects, aligned with the strongly-typed contracts defined in `types.bicep`.

* [**Examples.**](./docs/examples.md)
  Progressive scenarios (greenfield, reuse, platform-integrated) plus advanced combined example (dual VNets + Fabric + Bot + Enterprise Policy).

## Prerequisites (Feature-Specific)

| Feature | Prerequisite | Notes |
| :-- | :-- | :-- |
| Power Platform Enterprise Policy | Provider `Microsoft.PowerPlatform` registered | Subnets named `powerplatform-subnet` must exist in each VNet you want injected (auto‑inferred when policy `virtualNetworks` list empty). |
| Microsoft Fabric Capacity | Provider `Microsoft.Fabric` registered | Assign at least one administrator object ID. |
| Azure Bot Service | Entra application (App Registration) created; capture client ID | Supply `botServiceAppId`; endpoint can be placeholder initially and updated later. |
| Dual Virtual Networks | Non-overlapping CIDR planning | Secondary VNet gated by `deployToggles.secondaryVirtualNetwork`. |

> For reuse scenarios, populate corresponding `resourceIds.*ResourceId` entries; creation paths are automatically skipped.
