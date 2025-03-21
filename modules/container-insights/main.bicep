@description('Required. Name of the data collection rule.')
param dataCollectionRuleName string

@description('Required. Log Analytics workspace name where the Container Insights logs should be send to.')
param logAnalyticsWorkspaceName string

@description('Required. Resource group name of the central monitoring resources like Log Analytics workspace & Data Collection Rules.')
param monitoringResourceGroupName string

@description('Required. Connected cluster name.')
param connectedClusterName string


// Log Analytics workspace reference
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(monitoringResourceGroupName)
}

// Connected Cluster reference
resource connectedCluster 'Microsoft.Kubernetes/connectedClusters@2024-01-01' existing = {
  name: connectedClusterName
}

// Data collection rule reference for Container Insights
resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' existing = {
  name: dataCollectionRuleName
  scope: resourceGroup(monitoringResourceGroupName)
}

// Container Insight Data Collection Rule Assosiation
resource dataCollectionRuleAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: 'ContainerInsightsExtension'
  scope: connectedCluster
  properties: {
    dataCollectionRuleId: dataCollectionRule.id
  }
}

// Container Insights Connected Cluster Extension
resource containerInsightsExtension 'Microsoft.KubernetesConfiguration/extensions@2022-03-01' = {
  name: 'azuremonitor-containers'
  scope: connectedCluster
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    extensionType: 'Microsoft.AzureMonitor.Containers'
    autoUpgradeMinorVersion: true
    releaseTrain: 'Stable'
    scope: {
      cluster: {
        releaseNamespace: 'azuremonitor-containers'
      }
    }
    configurationProtectedSettings: {
      'omsagent.secret.wsid': logAnalyticsWorkspace.properties.customerId
      'omsagent.secret.key': '<not_used>'
      'amalogs.secret.wsid': logAnalyticsWorkspace.properties.customerId
      'amalogs.secret.key': '<not_used>'
    }
    configurationSettings: {
      logAnalyticsWorkspaceResourceID: logAnalyticsWorkspace.id
      'omsagent.useAADAuth': 'true'
      'amalogs.useAADAuth': 'true'
      'omsagent.domain': 'opinsights.azure.com'
      'amalogs.domain': 'opinsights.azure.com'
    }
  }
}
