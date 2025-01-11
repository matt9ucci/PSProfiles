$WORKFLOW_DIRECTORY = '.github/workflows/'

function New-GithubActionsWorkflowDirectory {
	New-Item -Path $WORKFLOW_DIRECTORY -ItemType Directory -Force
	New-GithubActionsWorkflowFile
}

function New-GithubActionsWorkflowFile {
	param (
		[string]
		$Directory = $WORKFLOW_DIRECTORY,

		[string]
		$Name = 'file.yaml'
	)

	if (!(Test-Path $Directory -PathType Container)) {
		throw "Directory not found: $Directory"
	}
	Set-Content -Path (Join-Path $Directory $Name) -Value @'
# https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
name: Workflow
on:
  workflow_dispatch:
    inputs:
'@
}
