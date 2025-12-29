<#
.LINK
	[OpenID Connect Discovery 1.0]: https://openid.net/specs/openid-connect-discovery-1_0.html
#>
function Get-OidcProviderConfiguration {
	param (
		[Parameter(Mandatory)]
		[ArgumentCompletions('token.actions.githubusercontent.com')]
		$Issuer
	)

	$params = @{
		Uri    = 'https://{0}/.well-known/openid-configuration' -f $Issuer
		Method = 'Get'
	}
	Invoke-RestMethod @params
}
