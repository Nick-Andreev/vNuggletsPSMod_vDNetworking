## Sample code to set Class of Service (CoS) and Differentiated Service Code Point (DSCP) values on vDPGs on a VDSwitch
## params to take for new FilterPolicy
vDPG
Name
RuleAction
[switch]Enabled = $true
[int]CoSValue -- nullable
[int]DSCPValue -- nullable
[ValidateSet("incomingPackets","outgoingPackets","both")][VMware.Vim.DvsNetworkRuleDirectionType]TrafficDirection
[VMware.Vim.DvsNetworkRuleQualifier[]]RuleQualifier


Need:
Get-VNVDTrafficRuleSet
Get-VNVDTrafficRuleAction
New-VNVDTrafficFilterPolicy
New-VNVDTrafficRuleSet

New-VNVDTrafficRule

Done (to at least some extent -- some may have further features to implement):
Get-VNVDTrafficFilterPolicyConfig
Get-VNVDTrafficRule
Get-VNVDTrafficRuleQualifier

New-VNVDNetworkRuleQualifier
New-VNVDTrafficRuleAction
    remaining Action types to implement: DvsCopyNetworkRuleAction, DvsGreEncapNetworkRuleAction, DvsLogNetworkRuleAction, DvsMacRewriteNetworkRuleAction, DvsPuntNetworkRuleAction, DvsRateLimitNetworkRuleAction


## something like
#  gets
# get-vdpg | get-vdtrafficfilter | new-vdtrafficrule
# get-vdpg | get-vdtrafficfilter | get-vdtrafficrule
#  new
# $oTraffQualifier0 = New-VNVDNetworkRuleQualifier -ParmsHere
# $oTraffQualifier1 = New-VNVDNetworkRuleQualifier -ParmsHere
# $oTraffRule = New-VNVDTrafficRule -Direction blahh -Qualifier $oTraffQualifier0, $oTraffQualifier1
# get-vdpg someVdpg | New-VNVDTrafficPolicy -Enabled -Rule $oTraffRule
# or
# get-vdpg someVdpg | New-VNVDTrafficPolicy -Enabled -Rule (New-VNVDTrafficRule -Direction blahh -Qualifier (New-VNVDNetworkRuleQualifier -ParmsHere))


<# couple of examples
## from https://communities.vmware.com/thread/493610?q=distributed%20switch%20traffic%20filter
$dvSwName = 'dvSw1'
$dvPgNames = 'dvPg1'

$dvSw = Get-VDSwitch -Name $dvSwName

foreach($pg in (Get-View -Id  $dvSw.ExtensionData.Portgroup | Where {$dvPgNames -contains $_.Name})){
    $spec = New-Object VMware.Vim.DVPortgroupConfigSpec
    $spec.ConfigVersion = $pg.Config.ConfigVersion
    $spec.DefaultPortConfig = New-Object VMware.Vim.VMwareDVSPortSetting
    $spec.DefaultPortConfig.FilterPolicy = New-Object VMware.Vim.DvsFilterPolicy

    $filter = New-Object VMware.Vim.DvsTrafficFilterConfig
    $filter.AgentName = 'dvfilter-generic-vmware'

    $ruleSet = New-Object VMware.Vim.DvsTrafficRuleset
    $ruleSet.Enabled = $true

    $rule =New-Object VMware.Vim.DvsTrafficRule
    $rule.Description = 'Traffic Rule Name'
    $rule.Direction = 'outgoingPackets'

    $action = New-Object VMware.Vim.DvsUpdateTagNetworkRuleAction
    $action.QosTag = 4

    $rule.Action += $action

    $ruleSet.Rules += $rule

    $filter.TrafficRuleSet += $ruleSet

    $spec.DefaultPortConfig.FilterPolicy.FilterConfig += $filter

    $pg.ReconfigureDVPortgroup($spec)
}



# or, partially working, from https://www.reddit.com/r/vmware/comments/6ughyq/powercli_configure_traffic_filtering_and_marking/
$dvSwName = 'name-of-dvsw'
$dvPgNames = 'name-of-pg'

$dvSw = Get-VDSwitch -Name $dvSwName


foreach($pg in (Get-View -Id  $dvSw.ExtensionData.Portgroup | Where {$dvPgNames -contains $_.Name})){
    $spec = New-Object VMware.Vim.DVPortgroupConfigSpec
    $spec.ConfigVersion = $pg.Config.ConfigVersion
    $spec.DefaultPortConfig = New-Object VMware.Vim.VMwareDVSPortSetting
    $spec.DefaultPortConfig.FilterPolicy = New-Object VMware.Vim.DvsFilterPolicy

    $filter = New-Object VMware.Vim.DvsTrafficFilterConfig
    $filter.AgentName = 'dvfilter-generic-vmware'

    $ruleSet = New-Object VMware.Vim.DvsTrafficRuleset
    $ruleSet.Enabled = $true


    $bu01ip4 = New-Object VMware.Vim.DvsTrafficRule
    $bu01ip4.Description = 'Tag AF23 to IP4 BU01'
    $bu01ip4.Direction = 'both'
# of basetype VMware.Vim.DvsNetworkRuleQualifier
    $bu01ip4Props = New-Object VMware.Vim.DvsIpNetworkRuleQualifier
    $bu01ip4Props.protocol = ${6}
    $bu01ip4Props.destinationAddress = ${ip:172.16.14.31}
    $bu01ip4.qualifier += $bu01ip4Props


    $action = New-Object VMware.Vim.DvsUpdateTagNetworkRuleAction
    $action.DSCPTag = 22


    $bu01ip4.Action += $action
    $ruleSet.Rules += $bu01ip4

    $filter.TrafficRuleSet += $ruleSet
    spec.DefaultPortConfig.FilterPolicy.FilterConfig += $filter
    $pg.ReconfigureDVPortgroup($spec)
}
#>


  ## get VDTrafficFilterPolicyConfig:
  #$viewVDPG.Config.DefaultPortConfig.FilterPolicy.FilterConfig
  ## can get:
  # VDTrafficFilterPolicyConfig:  Key, Enabled, Precedence, Key, AgentName, SlotNumber, Parameters, OnFailure, Inherited
  # --> VDTrafficFilterPolicyConfig.VDTrafficRule: Key, Description, Sequence, Qualifier, Action, Direction
  # --> VDTrafficFilterPolicyConfig.VDTrafficRule.VDTrafficRuleQualifier:  VMware.Vim.DvsSystemTrafficNetworkRuleQualifier or VMware.Vim.DvsIpNetworkRuleQualifier or one other
  <#
  {
  "FilterConfig":  [
         {
         "TrafficRuleset":  {
              "Key":  "51_255_ _13461229",
              "Enabled":  true,
              "Precedence":  null,
              "Rules":  [
                  {
                    "Key":  "51_255_ _13461229_71622573",
                    "Description":  "test VSAN rule0",
                    "Sequence":  10,
                    "Qualifier":  [
                        {
                        "TypeOfSystemTraffic":  {
                                "Value":  "vsan",
                                "Negate":  false
                              },
                        "Key":  "51_255_ _13461229_71622573_99129637"
                        }
                      ],
                    "Action":  {
                       "QosTag":  null,
                       "DscpTag":  25
                       },
                    "Direction":  "incomingPackets"
                  },
                  {
                    "Key":  "51_255_ _13461229_16439589",
                    "Description":  "test BUR rule",
                    "Sequence":  20,
                    "Qualifier":  [
                        {
                        "SourceAddress":  {
                              "AddressPrefix":  "255.255.255.255",
                              "PrefixLength":  0,
                              "Negate":  null
                              },
                        "DestinationAddress":  {
                                 "AddressPrefix":  "10.5.64.0",
                                 "PrefixLength":  20,
                                 "Negate":  false
                               },
                        "Protocol":  {
                             "Value":  6,
                             "Negate":  false
                             },
                        "SourceIpPort":  null,
                        "DestinationIpPort":  null,
                        "TcpFlags":  null,
                        "Key":  "51_255_ _13461229_16439589_25543994"
                        }
                      ],
                    "Action":  {
                       "QosTag":  null,
                       "DscpTag":  8
                       },
                    "Direction":  "incomingPackets"
                  }
                  ]
              },
         "Key":  "51_255_ _91108317",
         "AgentName":  "dvfilter-generic-vmware",
         "SlotNumber":  null,
         "Parameters":  null,
         "OnFailure":  null,
         "Inherited":  false
         }
       ],
  "Inherited":  false
  }
#>