param location string
@secure()
param adminUsername string
@secure()
param adminPassword string

var resourceToken = uniqueString(subscription().id, resourceGroup().id, location)
var abbrs = loadJsonContent('abbreviations.json')

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: '${abbrs.vnet}-${resourceToken}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'frontend-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${abbrs.nsg}-${resourceToken}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          priority: 100
          protocol: 'Tcp'
          direction: 'Inbound'
          access: 'Allow'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      },{
        name: 'Allow-RDP'
        properties: {
          priority: 200
          protocol: 'Tcp'
          direction: 'Inbound'
          access: 'Allow'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Subnet NSG Association
resource subnetNsg 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  parent: vnet
  name: 'frontend-subnet'
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

// Public IP
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: '${abbrs.pip}-${resourceToken}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Load Balancer
resource lb 'Microsoft.Network/loadBalancers@2023-04-01' = {
  name: '${abbrs.lb}-${resourceToken}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'lb-fe'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backend-pool'
      }
    ]
    probes: [
      {
        name: 'http-probe'
        properties: {
          protocol: 'Http'
          port: 80
          requestPath: '/'
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'http-rule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', format('${abbrs.lb}-{0}', resourceToken), 'lb-fe')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', format('${abbrs.lb}-{0}', resourceToken), 'backend-pool')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', format('${abbrs.lb}-{0}', resourceToken), 'http-probe')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
        }
      }
    ]
  }
}

// VM Modules
module vm1 'vm.bicep' = {
  name: 'vm1'
  params: {
    name: '${abbrs.vm}1-${resourceToken}'
    location: location
    subnetId: vnet.properties.subnets[0].id
    adminUsername: adminUsername
    adminPassword: adminPassword
    backendPoolId: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', format('${abbrs.lb}-{0}', resourceToken), 'backend-pool')
  }
}

module vm2 'vm.bicep' = {
  name: 'vm2'
  params: {
    name: '${abbrs.vm}2-${resourceToken}'
    location: location
    subnetId: vnet.properties.subnets[0].id
    adminUsername: adminUsername
    adminPassword: adminPassword
    backendPoolId: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', format('${abbrs.lb}-{0}', resourceToken), 'backend-pool')
  }
}