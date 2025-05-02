# Trainer Demo Deploy Guide

## Azure Demo: Load-Balanced Windows VMs using Bicep and azd

---

## 📌 Problem Statement

Deploy scalable Windows Server VMs behind a Public Load Balancer using Azure Bicep and Azure Developer CLI.

---

## 🎯 Objective

Provision two Windows Server virtual machines (2022) in Azure:

- Hosted within a virtual network subnet
- Protected by a Network Security Group (NSG)
- Placed behind a Public Azure Load Balancer
- Allow HTTP (port 80) and RDP (port 3389) traffic
- Automatic IIS installation via custom script
- Load Balancer distributes HTTP requests across both VMs

---

## 📦 Key Requirements

- Use Infrastructure-as-Code (IaC) with Azure Bicep
- Deploy using Azure Developer CLI (`azd`)
- Include the following resources:
  - Virtual Network (VNet) and Subnet
  - Network Security Group (NSG) for traffic control
  - Two Windows Server VMs (2022)
  - Standard Public Load Balancer
  - NSG rules for HTTP (80) and RDP (3389)
  - Health Probe and Load Balancing Rule
  - Custom Script Extension to install IIS

---

## 🧰 Prerequisites

- Azure Subscription
- Installed tools:
  - [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
  - [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview)
  - [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
- Windows Terminal, PowerShell, or Command Prompt

---

## 🗂 Folder Structure

```plaintext
trainer-demo-deploy/
├── .azure.yaml                     # Pass environmentName automatically
├── README.md                       # Project overview and usage
├── demoguide/
│   └── demoguide.md               # This deployment guide
├── images/
│   └── architecture.png           # Azure architecture diagram
└── infra/
    ├── main.bicep                 # Entry Bicep file for AZD
    ├── resources.bicep            # Infra components: VNet, NSG, LB, VMs
    ├── vm.bicep                   # VM-specific deployment logic
    ├── main.parameters.json       # Parameters file (no location hardcoded)
    └── abbreviations.json         # Optional naming conventions (e.g., vnet, nsg, pip)


   