#region Update-TypeData

@(
	'Amazon.IdentityManagement.Model.GetGroupPolicyResponse'
	'Amazon.IdentityManagement.Model.GetGroupPolicyResponse'
	'Amazon.IdentityManagement.Model.GetRolePolicyResponse'
) | Update-TypeData -MemberType ScriptProperty -MemberName PolicyDocumentDecoded -Value {
	[System.Web.HttpUtility]::UrlDecode($this.PolicyDocument) | ConvertFrom-Json | ConvertTo-Json -Depth 8
} -ErrorAction Ignore

@(
	'Amazon.IdentityManagement.Model.PolicyVersion'
) | Update-TypeData -MemberType ScriptProperty -MemberName DocumentDecoded -Value {
	[System.Web.HttpUtility]::UrlDecode($this.Document) | ConvertFrom-Json | ConvertTo-Json -Depth 8
} -ErrorAction Ignore

@(
	'Amazon.IdentityManagement.Model.Role'
) | Update-TypeData -MemberType ScriptProperty -MemberName AssumeRolePolicyDocumentDecoded -Value {
	[System.Web.HttpUtility]::UrlDecode($this.AssumeRolePolicyDocument) | ConvertFrom-Json | ConvertTo-Json -Depth 8
} -ErrorAction Ignore

#endregion

$params = @(
	@{
		ParameterName = 'RoleName'
		ScriptBlock   = {
			param ($0, $1, $WordToComplete)
			[string[]]$list = Get-IAMRoleList -Select Roles.RoleName
			if ($list) { $list -like "$WordToComplete*" }
		}
	}
	@{
		ParameterName = 'PolicyName'
		ScriptBlock   = {
			param ($0, $1, $WordToComplete, $3, $FakeBoundParameters)

			if (($RoleName = $FakeBoundParameters['RoleName'])) {
				[string[]]$list = Get-IAMRolePolicyList -RoleName $RoleName
				if ($list) { $list -like "$WordToComplete*" }
			}
			if (($GroupName = $FakeBoundParameters['GroupName'])) {
				[string[]]$list = Get-IAMGroupPolicyList -GroupName $GroupName
				if ($list) { $list -like "$WordToComplete*" }
			}
		}
	}
	@{
		ParameterName = 'PolicyArn'
		ScriptBlock   = {
			param ($0, $1, $WordToComplete)
			[string[]]$list = Get-IAMPolicyList -OnlyAttached $true -Select Policies.Arn
			if ($list) { $list -like "$WordToComplete*" }
		}
	}
	@{
		ParameterName = 'VersionId'
		ScriptBlock   = {
			param ($0, $1, $WordToComplete, $3, $FakeBoundParameters)
			if (($PolicyArn = $FakeBoundParameters['PolicyArn'])) {
				[string[]]$list = Get-IAMPolicyVersionList -PolicyArn $PolicyArn -Select Versions.VersionId
				if ($list) { $list -like "$WordToComplete*" }
			}
		}
	}
	@{
		ParameterName = 'GroupName'
		ScriptBlock   = {
			param ($0, $1, $WordToComplete)
			[string[]]$list = Get-IAMGroupList -Select Groups.GroupName
			if ($list) { $list -like "$WordToComplete*" }
		}
	}
	@{
		ParameterName = 'InstanceProfileName'
		ScriptBlock   = {
			param ($0, $1, $WordToComplete)
			[string[]]$list = Get-IAMInstanceProfileList -Select InstanceProfiles.InstanceProfileName
			if ($list) { $list -like "$WordToComplete*" }
		}
	}
) | % { Register-ArgumentCompleterByModuleName @_ -ModuleName 'AWS.Tools.IdentityManagement' }
