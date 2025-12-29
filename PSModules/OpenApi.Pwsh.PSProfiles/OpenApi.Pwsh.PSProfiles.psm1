#Requires -Modules OpenApi.Pwsh

function New-OpenApiModel {
	param (
		[Parameter(Mandatory)]
		[ValidateSet(
			'Callback',
			'Components',
			'Constants',
			'Contact',
			'Discriminator',
			'Document',
			'Encoding',
			'Error',
			'Example',
			'ExternalDocs',
			'Header',
			'Info',
			'License',
			'Link',
			'MediaType',
			'OAuthFlow',
			'OAuthFlows',
			'Operation',
			'Parameter',
			'PathItem',
			'Paths',
			'Reference',
			'RequestBody',
			'Response',
			'Responses',
			'Schema',
			'SecurityRequirement',
			'SecurityScheme',
			'Server',
			'ServerVariable',
			'Tag',
			'Xml'
		)]
		[string]
		$Name,

		[hashtable]
		$Property = @{}
	)

	New-Object -TypeName "Microsoft.OpenApi.Models.OpenApi$Name" -Property $Property
}

function Search-Operation {
	param (
		[Microsoft.OpenApi.Models.OpenApiDocument]
		$Doc,

		[string]
		$Path = '*',

		[Microsoft.OpenApi.Models.OperationType]
		$OperationType,

		[string]
		$OperationId = '*'
	)

	$search = [Microsoft.OpenApi.Services.OperationSearch]::new(
		{
			param ($pathString, $type, [Microsoft.OpenApi.Models.OpenApiOperation]$operation)
			($Path -eq $null -or $pathString -like $Path) -and
			($OperationType -eq $null -or $type -eq $OperationType) -and
			$operation.OperationId -like $OperationId
		}
	)

	[Microsoft.OpenApi.Services.OpenApiWalker]::new($search).Walk($Doc);

	$search.SearchResults.CurrentKeys
	$search.SearchResults.Operation
}
