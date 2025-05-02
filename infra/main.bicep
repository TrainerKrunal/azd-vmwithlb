targetScope = 'subscription'

param location string
param adminUsername string
@secure()
param adminPassword string
@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module resources 'resources.bicep' = {
  name: 'deployResources'
  scope: rg
  params: {
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}