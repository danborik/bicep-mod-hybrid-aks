
@description('Required. Name of the data collection rule.')
param dataCollectionRuleName string

@description('Required. Resource group name of the central monitoring resources like Log Analytics workspace & Data Collection Rules.')
param monitoringResourceGroupName string

@description('Required. Connected cluster name.')
param connectedClusterName string


// Connected Cluster reference
resource connectedCluster 'Microsoft.Kubernetes/connectedClusters@2024-01-01' existing = {
  name: connectedClusterName
}

// Data collection rule reference for Managed Prometheus
resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' existing = {
  name: dataCollectionRuleName
  scope: resourceGroup(monitoringResourceGroupName)
}

// Managed Prometheus Data Collection Rule Assosiation
resource dataCollectionRuleAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: 'ContainerInsightsMetricsExtension'
  scope: connectedCluster
  properties: {
    dataCollectionRuleId: dataCollectionRule.id
  }
}

// Managed Prometheus extension
resource prometheusExtension 'Microsoft.KubernetesConfiguration/extensions@2022-03-01' = {
  name: 'azuremonitor-metrics'
  scope: connectedCluster
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    extensionType: 'Microsoft.AzureMonitor.Containers.Metrics'
    autoUpgradeMinorVersion: true
    releaseTrain: 'Stable'
    scope: {
      cluster: {
        releaseNamespace: 'kube-system'
      }
    }
  }
}
