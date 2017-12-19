<#	.Description
	Function to get the VDTrafficRule Qualifier for the TrafficRule from the given VDTrafficFilterPolicy configuration from VDPortgroup(s).

	.Example
	Get-VDSwitch -Name myVDSw0 | Get-VDPortGroup -Name myVDPG0 | Get-VDTrafficFilterPolicyConfig.ps1 | Get-VDTrafficRule.ps1 | Get-VDTrafficRuleQualifier.ps1
	Get the traffic rules qualifiers from the traffic rules from the TrafficeRuleset property of the TrafficFilterPolicyConfig

	.Outputs
	VMware.Vim.DvsNetworkRuleQualifier
#>
[CmdletBinding()]
[OutputType([VMware.Vim.DvsNetworkRuleQualifier])]
param (
	## The traffic ruleset qualifier from the traffic filter policy of the virtual distributed portgroup for which to get the traffic rule(s)
	[parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="ByTrafficRuleQualifier")][VMware.Vim.DvsNetworkRuleQualifier[]]$Qualifier
) ## end param

process {
	$Qualifier | Foreach-Object {
		## get the qualifier TypeName short name (like, if TypeName is "VMware.Vim.DvsIpNetworkRuleQualifier", this will be "DvsIpNetworkRuleQualifier")
		$strQualifierTypeShortname = ($_ | Get-Member | Select-Object -First 1).TypeName.Split(".") | Select-Object -Last 1
		## the properties to select for this Qualifier object
		$arrPropertyForSelectObject = @{n="QualifierType"; e={$strQualifierTypeShortname}}, "*"
		## if the Qualifier object is of type VMware.Vim.DvsSystemTrafficNetworkRuleQualifier, essentially "expand" the TypeOfSystemTraffic.Value property to be one level up in the return object
		if ($strQualifierTypeShortname -eq "DvsSystemTrafficNetworkRuleQualifier") {$arrPropertyForSelectObject += @{n="TypeOfSystemTraffic_Name"; e={$_.TypeOfSystemTraffic.Value}}}
		$_ | Select-Object -Property $arrPropertyForSelectObject
	} ## end foreach-object
} ## end process
