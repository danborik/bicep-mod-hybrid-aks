
// - Global params -
@description('Optional. The Azure region where the resources will be deployed to.')
param parLocation string = resourceGroup().location

@description('Optional. The Azure Tags for the resources.')
param parTags object?

// - Logical Network params -
@description('Required. Name of the logical network resource.')
param parLogicalNetworkName string

@description('Optional. The name of the VM switch for the logical network.')
param parLogicalNetworkVmSwitchName string = 'ConvergedSwitch(compute_management)'

@description('Required. The list of subnet definitions for the logical network.')
param parLogicalNetworkSubnets array
  // name string - Required
  // addressPrefix string - Optional (either addressPrefix or addressPrefixes is required)
  // ipPools object[] - Required
    // name string - Required
    // ipPoolType string - Required (Valid values: 'vippool', 'vm')
    // start string - Required
    // end string - Required
  // routes object[] - Required
    // name string - Required
    // addressPrefix string - Required
    // nextHopIpAddress string - Required
  // vlan int - Optional

@description('Required. The list of DNS servers IP addresses.')
param parDnsServers array

// - Custom Location params -
@description('Required. The name of the custom location resource.')
param parCustomLocationName string

@description('Required. The resource group name of the custom location resource.')
param parCustomLocationResourceGroupName string

// - Connected Cluster params -
@description('Required. The name of the connected cluster resource.')
param parConnectedClusterName string

@description('Required. Base64 encoded public certificate used by the agent to do the initial handshake to the backend services in Azure.')
param parConnectedClusterAgentPublicKeyCertificate string = '' // Required, but it is currently unclear where to get this value

@allowed([
  'None'
  'SystemAssigned'
])
@description('Optional. The identity type for the connected cluster.')
param parConnectedClusterIdentityType string = 'SystemAssigned'

@description('Optional. Enable Azure Active Directory profile for the connected cluster.')
param parConnectedClusterEnableAadProfile bool

@description('Conditional. Use if the parConnectedClusterEnableAadProfile is set to true. The list of Azure Active Directory admin group object IDs.')
param parConnectedClusterAadAdminGroupObjectIds array?

@description('Conditional. Use if the parConnectedClusterEnableAadProfile is set to true. Enable Azure RBAC for the connected cluster.')
param parConnectedClusterEnableAzureRbac bool?

@description('Conditional. Use if the parConnectedClusterEnableAadProfile is set to true. The Azure Active Directory tenant ID. Defaults to the current tenant ID.')
param parConnectedClusterAadTenantId string = tenant().tenantId

@description('Optional. Enable Azure Arc agent profile for the connected cluster.')
param parConnectedClusterEnableArcAgentProfile bool = true

@allowed(
  [
    'Disabled'
    'Enabled'
  ]
)
@description('Conditional. Use if the parConnectedClusterEnableArcAgentProfile is set to true. Enables auto-upgrade of ARC agent for the connected cluster.')
param parConnectedClusterArcAgentAutoUpgrade string = 'Enabled'

@description('Conditional. Use if the parConnectedClusterEnableArcAgentProfile is set to true. The desired ARC agent version for the connected cluster.')
param parConnectedClusterDesiredArcAgentVersion string?

@allowed([
  'True'
  'False' 
  'NotApplicable'
])
@description('Optional. The Azure Hybrid Benefit for the connected cluster. Defaults to NotApplicable.')
param parConnectedClusterAzureHybridBenefit string = 'True'

@description('Optional. The Kubernetes distribution running on the connected cluster.')
param parConnectedClusterDistribution string?

@description('Optional. The version of the Kubernetes distribution running on the connected cluster.')
param parConnectedClusterDistributionVersion string?

@description('Optional. The infrastructure on which the Kubernetes cluster represented by this connected cluster is running on.')
param parConnectedClusterInfrastructure string?

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. State of the private link for the connected cluster.')
param parConnectedClusterPrivateLinkState string = 'Disabled'

@description('Optional. The resource ID of the private link scope for the connected cluster.')
param parConnectedClusterPrivateLinkScopeResourceId string?

// - Provisioned Cluster Instance params -
@description('Optional. The number of nodes in the system pool.')
param parHybridAksSystemPoolNodeCount int

@description('Optional. The minimum number of nodes in the system pool.')
param parHybridAksSystemPoolNodeCountMin int?

@description('Optional. The maximum number of nodes in the system pool.')
param parHybridAksSystemPoolNodeCountMax int?

@description('Optional. The maximum number of pods in the system pool.')
param parHybridAksSystemPoolMaxPods int = 110

@description('Optional. Enable auto-scaling for the system pool.')
param parHybridAksSystemPoolEnableAutoScaling bool

@description('Optional. Key-value pairs of the required node labels for the system pool.')
param parHybridAksSystemPoolNodeLabels object?

@description('Optional. The string array of taints for the system pool nodes. Example: [\'key=value:NoSchedule\']')
param parHybridAksSystemPoolNodeTaints array?

@allowed([
  'CBLMariner'
  'Windows2019'
  'Windows2022'
])
@description('Optional. The OS SKU for the system pool nodes.')
param parHybridAksSystemPoolNodeOsSku string = 'CBLMariner'

@allowed([
  'Linux'
  'Windows'
])
@description('Optional. The OS type for the system pool nodes.')
param parHybriAksSystemPoolNodeOsType string = 'Linux'

@allowed([
  'Standard_A2_v2'
  'Standard_A4_v2'
  'Standard_D4s_v3'
  'Standard_D8s_v3'
  'Standard_K8S3_v1'
])
@description('Optional. The VM size for the system pool nodes.')
param parHybridAksSystemPoolNodeVmSize string 

@description('Optional. The authorized IP ranges for SSH acces to the cluster VMs.')
param parHybridAksAuthorizedIPRanges string?

@description('Optional. AutoScaler Profile for the Hybrid AKS cluster.')
param parHybridAksAutoScalerProfile object? /*= {
//  AutoScaler default profile.
//  https://learn.microsoft.com/en-us/azure/templates/microsoft.hybridcontainerservice/provisionedclusterinstances?pivots=deployment-language-bicep

// Detects similar node pools and balances the number of nodes between them.
 balance-similar-node-groups:	false
// Type of node pool the expander uses in scale up. Possible values include most-pods, random , least-waste, and priority.
//      random - this is the default expander, and should be used when you don't have a particular need for the node groups to scale differently.
//      most-pods - selects the node group that would be able to schedule the most pods when scaling up. This is useful when you are using nodeSelector to make sure certain pods land on certain nodes. Note that this won't cause the autoscaler to select bigger nodes vs. smaller, as it can add multiple smaller nodes at once.
//      least-waste - selects the node group that will have the least idle CPU (if tied, unused memory) after scale-up. This is useful when you have different classes of nodes, for example, high CPU or high memory nodes, and only want to expand those when there are pending pods that need a lot of those resources.
//      priority - selects the node group that has the highest priority assigned by the user. It's configuration is described in more details here
expander: 'random'
// Maximum number of empty nodes that can be deleted at the same time.
max-empty-bulk-delete:	'10' // nodes
// Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node.
max-graceful-termination-sec:	'600' // seconds
// Maximum time the autoscaler waits for a node to be provisioned.
max-node-provision-time:	'15m' // minutes
// Maximum percentage of unready nodes in the cluster. After this percentage is exceeded, CA halts operations.
max-total-unready-percentage:	'45' // %
// For scenarios such as burst/batch scale where you don't want CA to act before the Kubernetes scheduler could schedule all the pods, you can tell CA to ignore unscheduled pods before they reach a certain age.
new-pod-scale-up-delay:	'0s' // seconds
// This must be an integer. The default is 3.
ok-total-unready-count: 3
// How long after scale up that scale down evaluation resumes.
scale-down-delay-after-add: '10m' // minutes
// How long after node deletion that scale down evaluation resumes.
scale-down-delay-after-delete: '10m' // default scan-interval
// How long after scale down failure that scale down evaluation resumes.
scale-down-delay-after-failure: '3m'	// minutes
// How long a node should be unneeded before it's eligible for scale down.
scale-down-unneeded-time:	'10m' // minutes
// How long an unready node should be unneeded before it's eligible for scale down.
scale-down-unready-time:	'20m' // minutes
// Node utilization level, defined as sum of requested resources divided by capacity, in which a node can be considered for scale down.
scale-down-utilization-threshold:	'0.5'
// How often the cluster is reevaluated for scale up or down.
scan-interval: '10' // seconds
// If true, cluster autoscaler doesn't delete nodes with pods with local storage; for example, EmptyDir or HostPath.
skip-nodes-with-local-storage:	true
// If true, cluster autoscaler doesn't delete nodes with pods from kube-system (except for DaemonSet or mirror pods).
skip-nodes-with-system-pods:	true
}*/

@description('Required. The host IP address for the control plane.')
param parHybridAksControlPlaneHostIp string?

@description('Optional. The AKS control plane node count. Default is 3.')
param parHybridAksControlPlaneNodeCount int?

@allowed([
  'Standard_A2_v2'
  'Standard_A4_v2'
  'Standard_D4s_v3'
  'Standard_D8s_v3'
  'Standard_K8S3_v1'
])
@description('Optional. The VM size for the control plane nodes.')
param parHybridAksControlPlaneNodeVmSize string = 'Standard_A4_v2'

@description('Optional. The Kubernetes version for the Hybrid AKS cluster.')
param parHybridAksKubernetesVersion string?

@description('Required. The SSH public key data for the Linux profile.')
param parHybridAksSshPublicKeyData array

@description('Optional. The number of HA Proxy VMs for the load balancer profile.')
param parHybridAksLoadBalancerVmCount int = 0

@description('Optional. A CIDR notation IP Address range from which to assign pod IPs.')
param parHybridAksPodCidr string?

@description('Optional. Enable NFS CSI driver for the Hybrid AKS cluster.')
param parHybridAksEnableNfsCsiDriver bool = false

@description('Optional. Enable SMB CSI driver for the Hybrid AKS cluster.')
param parHybridAksEnableSmbCsiDriver bool = false

@description('Optional. The definition of additional worker pools for the Hybrid AKS cluster.')
param parHybridAksWorkerPoolsDefinition workerPoolType?

// OidcIssuerProfile
@description('Optional. OIDC issuer profile.')
param parConnectedClusterOidcIssuerProfile oidcIssuerProfileType?

// SecurityProfile
@description('Optional. Security profile.')
param parConnectedClusterSecurityProfile securityProfileType?

// - Monitoring params -
@description('Optional. Onboard Connected Cluster into Container Insights.')
param parDeployContainerInsights bool = false

@description('Conditional. Use if the parDeployContainerInsights is set to true. The name of the Data Collection Rule for Container insights.')
param parContainerInsightsDataCollectionRuleName string = ''

@description('Conditional. Use if the parDeployContainerInsights is set to true. The name of the Resource Group containing central monitoring resources like Log Analytics & Data Collection Rules.')
param parMonitoringResourceGroupName string = ''

@description('Conditional. Use if the parDeployContainerInsights is set to true. The name of the Log Analytics workspace.')
param parLogAnalyticsWorkspaceName string = ''

@description('Optional. Onboard Connected Cluster into Managed Prometheus.')
param parDeployManagedPrometheus bool = false

@description('Conditional. Use if the parDeployManagedPrometheus is set to true. The name of the Data Collection Rule for Managed Prometheus.')
param parManagedPrometheusDataCollectionRuleName string = ''


// - Resources -
// -- Custom Location --
resource resCustomLocation 'Microsoft.ExtendedLocation/customLocations@2021-08-15' existing = {
  name: parCustomLocationName
  scope: resourceGroup(parCustomLocationResourceGroupName)
}

// -- Logical Network --
resource resLogicalNetwork 'Microsoft.AzureStackHCI/logicalNetworks@2024-01-01' = {
  name: parLogicalNetworkName
  location: parLocation
  tags: parTags
  extendedLocation: {
    name: resCustomLocation.id
    type: 'CustomLocation'
  }
  properties: {
    dhcpOptions: {
      dnsServers: parDnsServers
    }
    vmSwitchName: parLogicalNetworkVmSwitchName
    subnets: [
      for (snet, index) in parLogicalNetworkSubnets: {
        name: snet.name
        properties: {
          addressPrefix: !empty(snet.?addressPrefix) ? snet.addressPrefix : null
          // addressPrefixes: !empty(snet.?addressPrefixes) ? snet.addressPrefixes : null
          ipAllocationMethod: 'Static'
          ipPools: map(snet.ipPools, (pool, index) => {
              name: pool.?name
              ipPoolType: pool.?ipPoolType
              start: pool.start
              end: pool.end
          })
          routeTable: {
            properties: {
              routes: map(snet.routes, (route, index) => {
                  name: route.?name
                  properties: {
                    addressPrefix: route.addressPrefix
                    nextHopIpAddress: route.nextHopIpAddress
                  }
              })
            }
          }
          vlan: snet.vlan
        }
      }
    ]
  }
}

// -- Connected Cluster --
resource resConnectedCluster 'Microsoft.Kubernetes/connectedClusters@2024-12-01-preview' = {
  name: parConnectedClusterName  // required
  location: parLocation  // required
  identity: { // required
    type: parConnectedClusterIdentityType
  }
  kind: 'ProvisionedCluster'
  tags: parTags
  properties: {
    agentPublicKeyCertificate: parConnectedClusterAgentPublicKeyCertificate // required
  
    aadProfile: parConnectedClusterEnableAadProfile ? {
      adminGroupObjectIDs: parConnectedClusterAadAdminGroupObjectIds
      enableAzureRBAC: parConnectedClusterEnableAzureRbac
      tenantID: parConnectedClusterAadTenantId
    } : null
  
    arcAgentProfile: parConnectedClusterEnableArcAgentProfile ? {
      agentAutoUpgrade: parConnectedClusterArcAgentAutoUpgrade
      desiredAgentVersion: parConnectedClusterDesiredArcAgentVersion
    } : null
  
    // azureHybridBenefit is applicable only on provisionedClusterInstances
    azureHybridBenefit: 'NotApplicable'
    distribution: parConnectedClusterDistribution
    distributionVersion: parConnectedClusterDistributionVersion
    infrastructure: parConnectedClusterInfrastructure
    privateLinkScopeResourceId: parConnectedClusterPrivateLinkScopeResourceId
    privateLinkState: parConnectedClusterPrivateLinkState
  
    oidcIssuerProfile: parConnectedClusterOidcIssuerProfile
    securityProfile: parConnectedClusterSecurityProfile
  }
}

// --- Container Insights ---
module modContainerInsights 'modules/container-insights/main.bicep' = if (parDeployContainerInsights) {
  name: 'deploy-container-insights'
  dependsOn: [
    resHybridAks
  ]
  params: {
    connectedClusterName: resConnectedCluster.name
    dataCollectionRuleName: parContainerInsightsDataCollectionRuleName
    logAnalyticsWorkspaceName: parLogAnalyticsWorkspaceName
    monitoringResourceGroupName: parMonitoringResourceGroupName
  }
}

// --- Managed Prometheus ---
module modManagedPrometheus 'modules/managed-prometheus/main.bicep' = if (parDeployManagedPrometheus) {
  name: 'deploy-managed-prometheus'
  dependsOn: [
    resHybridAks
  ]
  params: {
    connectedClusterName: resConnectedCluster.name
    dataCollectionRuleName: parManagedPrometheusDataCollectionRuleName
    monitoringResourceGroupName: parMonitoringResourceGroupName
  }
}

// -- Provisioned Cluster Instance --
resource resHybridAks 'Microsoft.HybridContainerService/provisionedClusterInstances@2024-01-01' = {
  name: 'default'
  scope: resConnectedCluster
  extendedLocation: {
    name: resCustomLocation.id
    type: 'CustomLocation'
  }
  properties: {
    agentPoolProfiles: [
      {
        count: parHybridAksSystemPoolEnableAutoScaling ? 1 : parHybridAksSystemPoolNodeCount
        minCount: parHybridAksSystemPoolNodeCountMin
        maxCount: parHybridAksSystemPoolNodeCountMax
        maxPods: parHybridAksSystemPoolMaxPods
        enableAutoScaling: parHybridAksSystemPoolEnableAutoScaling
        name: 'systempool'
        nodeLabels: parHybridAksSystemPoolNodeLabels
        nodeTaints: parHybridAksSystemPoolNodeTaints
        osSKU: parHybridAksSystemPoolNodeOsSku
        osType: parHybriAksSystemPoolNodeOsType 
        vmSize: parHybridAksSystemPoolNodeVmSize 
      }
    ]
    cloudProviderProfile: {
      infraNetworkProfile: {
        vnetSubnetIds: [
          resLogicalNetwork.id
        ]
      }
    }
    clusterVMAccessProfile: !empty(parHybridAksAuthorizedIPRanges) ? {
      authorizedIPRanges: parHybridAksAuthorizedIPRanges
    } : null
    autoScalerProfile: parHybridAksAutoScalerProfile
    controlPlane: {
      controlPlaneEndpoint: {
        hostIP: parHybridAksControlPlaneHostIp
      }
      count: parHybridAksControlPlaneNodeCount
      vmSize: parHybridAksControlPlaneNodeVmSize
    }
    kubernetesVersion: parHybridAksKubernetesVersion
    licenseProfile: {
      azureHybridBenefit: parConnectedClusterAzureHybridBenefit
    }
    linuxProfile: {
      ssh: {
        publicKeys: [
          for key in parHybridAksSshPublicKeyData: {
            keyData: key
          }
        ]
      }
    }
    networkProfile: {
      loadBalancerProfile: {
        count: parHybridAksLoadBalancerVmCount
      }
      networkPolicy: 'calico'
      podCidr: parHybridAksPodCidr
    }
    storageProfile: {
      nfsCsiDriver: {
        enabled: parHybridAksEnableNfsCsiDriver
      }
      smbCsiDriver: {
        enabled: parHybridAksEnableSmbCsiDriver
      }
    }
  }
}

// --- Additional worker pools ---
resource resHybridAksWorkerPool 'Microsoft.HybridContainerService/provisionedClusterInstances/agentPools@2024-01-01' = [
  for (pool, index) in parHybridAksWorkerPoolsDefinition ?? []: {
  #disable-next-line BCP335
  name: 'workerpool${index}'
  parent: resHybridAks
  properties: {
    count: pool.count
    enableAutoScaling: pool.?autoScaling.?enabled ? pool.autoScaling.enabled : false
    maxCount: pool.?autoScaling.?maxCount ? pool.autoScaling.maxCount : pool.count
    maxPods: pool.?maxPods ? pool.maxPods : 110
    minCount: pool.?autoScaling.?minCount ? pool.autoScaling.minCount : pool.count
    nodeLabels: (!empty(pool.?nodeLabels)) ? pool.nodeLabels : {}
    nodeTaints: (!empty(pool.?nodeTaints)) ? pool.nodeTaints : []
    osSKU: 'CBLMariner'
    osType: 'Linux'
    vmSize: pool.vmSize
  }
}]


output outConnectedClusterName string = resConnectedCluster.name


// Definitions

type dynamicMemoryConfigType = {
  @description('The maximum amount of memory that can be allocated to the virtual machine.')
  maximumMemoryMB: int?

  @description('The minimum amount of memory that can be allocated to the virtual machine.')
  minimumMemoryMB: int?

  @description('The target memory buffer for the virtual machine.')
  targetMemoryBuffer: int?
}?

type oidcIssuerProfileType = {
  @description('Whether to enable oidc issuer for workload identity integration.')
  enabled: bool?

  @description('The issuer url for public cloud clusters - AKS, EKS, GKE - used for the workload identity feature..')
  selfHostedIssuerUrl: string?
}

type securityProfileType = {
  workloadIdentity: {
    @description('Whether to enable or disable the workload identity Webhook.')
    enabled: bool?
  }
}?

type workerPoolType = {
  @description('Required. The number of nodes in the worker pool.')
  count: int

  @description('Required. The VM size for the worker pool nodes.')
  vmSize: ('Standard_A2_v2' | 'Standard_A4_v2' | 'Standard_D4s_v3' | 'Standard_D8s_v3' | 'Standard_K8S3_v1')

  autoScaling: {
    @description('Optional. Whether to enable auto-scaling for the worker pool.')
    enabled: bool

    @description('Optional. The maximum number of nodes in the worker pool.')
    maxCount: int?

    @description('Optional. The minimum number of nodes in the worker pool.')
    minCount: int?
  }?

  @description('Optional. List of node labels for the worker pool.')
  nodeLabels: object?

  @description('Optional. List of node taints for the worker pool.')
  nodeTaints: string[]?

}[]?
