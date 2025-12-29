Install-Module -Name AWS.Tools.Installer -Repository PSGallery -Force
Install-AWSToolsModule -Name @(
	'EC2'
	'S3'
	'CloudFormation'
	'IdentityManagement'
	'SimpleSystemsManagement'
	'CloudWatch'
	'CloudWatchLogs'
) -CleanUp -Force
