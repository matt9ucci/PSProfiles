param (
	[string]$ProfileName = $env:AWS_PROFILE,
	[string]$Region = $env:AWS_REGION
)

if (Test-Path $PROFILEDIR\PwshProxy.xml) {
	$pwshProxy = Import-Clixml $PROFILEDIR\PwshProxy.xml
	$proxy = $pwshProxy.Proxy

	Set-AWSProxy -Hostname $proxy.Host -Port $proxy.Port -Credential $pwshProxy.ProxyCredential
}

Set-AWSCredential -ProfileName $ProfileName
Set-DefaultAWSRegion $Region

$PSDefaultParameterValues['Get-EC2ConsoleOutput:Select'] = 'Output'

Import-Module -Name @(
	'AWS.Tools.AccessAnalyzer'
	'AWS.Tools.ACMPCA'
	'AWS.Tools.AlexaForBusiness'
	'AWS.Tools.Amplify'
	'AWS.Tools.APIGateway'
	'AWS.Tools.ApiGatewayManagementApi'
	'AWS.Tools.ApiGatewayV2'
	'AWS.Tools.AppConfig'
	'AWS.Tools.ApplicationAutoScaling'
	'AWS.Tools.ApplicationDiscoveryService'
	'AWS.Tools.ApplicationInsights'
	'AWS.Tools.AppMesh'
	'AWS.Tools.AppStream'
	'AWS.Tools.AppSync'
	'AWS.Tools.Athena'
	'AWS.Tools.AugmentedAIRuntime'
	'AWS.Tools.AutoScaling'
	'AWS.Tools.AutoScalingPlans'
	'AWS.Tools.AWSHealth'
	'AWS.Tools.AWSMarketplaceCommerceAnalytics'
	'AWS.Tools.AWSMarketplaceMetering'
	'AWS.Tools.AWSSupport'
	'AWS.Tools.Backup'
	'AWS.Tools.Batch'
	'AWS.Tools.Budgets'
	'AWS.Tools.CertificateManager'
	'AWS.Tools.Chime'
	'AWS.Tools.Cloud9'
	'AWS.Tools.CloudDirectory'
	'AWS.Tools.CloudFormation'
	'AWS.Tools.CloudFront'
	'AWS.Tools.CloudHSMV2'
	'AWS.Tools.CloudSearch'
	'AWS.Tools.CloudSearchDomain'
	'AWS.Tools.CloudTrail'
	'AWS.Tools.CloudWatch'
	'AWS.Tools.CloudWatchLogs'
	'AWS.Tools.CodeBuild'
	'AWS.Tools.CodeCommit'
	'AWS.Tools.CodeDeploy'
	'AWS.Tools.CodeGuruProfiler'
	'AWS.Tools.CodeGuruReviewer'
	'AWS.Tools.CodePipeline'
	'AWS.Tools.CodeStar'
	'AWS.Tools.CodeStarNotifications'
	'AWS.Tools.CognitoIdentity'
	'AWS.Tools.CognitoIdentityProvider'
	'AWS.Tools.CognitoSync'
	'AWS.Tools.Common'
	'AWS.Tools.Comprehend'
	'AWS.Tools.ComprehendMedical'
	'AWS.Tools.ComputeOptimizer'
	'AWS.Tools.ConfigService'
	'AWS.Tools.Connect'
	'AWS.Tools.ConnectParticipant'
	'AWS.Tools.CostAndUsageReport'
	'AWS.Tools.CostExplorer'
	'AWS.Tools.DatabaseMigrationService'
	'AWS.Tools.DataExchange'
	'AWS.Tools.DataPipeline'
	'AWS.Tools.DataSync'
	'AWS.Tools.DAX'
	'AWS.Tools.DeviceFarm'
	'AWS.Tools.DirectConnect'
	'AWS.Tools.DirectoryService'
	'AWS.Tools.DLM'
	'AWS.Tools.DocDB'
	'AWS.Tools.DynamoDBv2'
	'AWS.Tools.EBS'
	'AWS.Tools.EC2'
	'AWS.Tools.ECR'
	'AWS.Tools.ECS'
	'AWS.Tools.EKS'
	'AWS.Tools.ElastiCache'
	'AWS.Tools.ElasticBeanstalk'
	'AWS.Tools.ElasticFileSystem'
	'AWS.Tools.ElasticInference'
	'AWS.Tools.ElasticLoadBalancing'
	'AWS.Tools.ElasticLoadBalancingV2'
	'AWS.Tools.ElasticMapReduce'
	'AWS.Tools.Elasticsearch'
	'AWS.Tools.ElasticTranscoder'
	'AWS.Tools.EventBridge'
	'AWS.Tools.FMS'
	'AWS.Tools.ForecastQueryService'
	'AWS.Tools.ForecastService'
	'AWS.Tools.FraudDetector'
	'AWS.Tools.FSx'
	'AWS.Tools.GameLift'
	'AWS.Tools.Glacier'
	'AWS.Tools.GlobalAccelerator'
	'AWS.Tools.Glue'
	'AWS.Tools.Greengrass'
	'AWS.Tools.GroundStation'
	'AWS.Tools.GuardDuty'
	'AWS.Tools.IdentityManagement'
	'AWS.Tools.Imagebuilder'
	'AWS.Tools.ImportExport'
	'AWS.Tools.Inspector'
	'AWS.Tools.IoT'
	'AWS.Tools.IoTEvents'
	'AWS.Tools.IoTEventsData'
	'AWS.Tools.IoTJobsDataPlane'
	'AWS.Tools.IoTSecureTunneling'
	'AWS.Tools.IoTThingsGraph'
	'AWS.Tools.Kafka'
	'AWS.Tools.Kendra'
	'AWS.Tools.KeyManagementService'
	'AWS.Tools.Kinesis'
	'AWS.Tools.KinesisAnalyticsV2'
	'AWS.Tools.KinesisFirehose'
	'AWS.Tools.KinesisVideo'
	'AWS.Tools.KinesisVideoMedia'
	'AWS.Tools.KinesisVideoSignalingChannels'
	'AWS.Tools.LakeFormation'
	'AWS.Tools.Lambda'
	'AWS.Tools.Lex'
	'AWS.Tools.LexModelBuildingService'
	'AWS.Tools.LicenseManager'
	'AWS.Tools.Lightsail'
	'AWS.Tools.MachineLearning'
	'AWS.Tools.Macie'
	'AWS.Tools.ManagedBlockchain'
	'AWS.Tools.MarketplaceCatalog'
	'AWS.Tools.MarketplaceEntitlementService'
	'AWS.Tools.MediaConnect'
	'AWS.Tools.MediaConvert'
	'AWS.Tools.MediaLive'
	'AWS.Tools.MediaPackage'
	'AWS.Tools.MediaPackageVod'
	'AWS.Tools.MediaStore'
	'AWS.Tools.MediaStoreData'
	'AWS.Tools.MediaTailor'
	'AWS.Tools.MigrationHub'
	'AWS.Tools.MigrationHubConfig'
	'AWS.Tools.Mobile'
	'AWS.Tools.MQ'
	'AWS.Tools.MTurk'
	'AWS.Tools.Neptune'
	'AWS.Tools.NetworkManager'
	'AWS.Tools.OpsWorks'
	'AWS.Tools.OpsWorksCM'
	'AWS.Tools.Organizations'
	'AWS.Tools.Outposts'
	'AWS.Tools.Personalize'
	'AWS.Tools.PersonalizeEvents'
	'AWS.Tools.PersonalizeRuntime'
	'AWS.Tools.PI'
	'AWS.Tools.Pinpoint'
	'AWS.Tools.PinpointEmail'
	'AWS.Tools.Polly'
	'AWS.Tools.Pricing'
	'AWS.Tools.QLDB'
	'AWS.Tools.QLDBSession'
	'AWS.Tools.QuickSight'
	'AWS.Tools.RAM'
	'AWS.Tools.RDS'
	'AWS.Tools.RDSDataService'
	'AWS.Tools.Redshift'
	'AWS.Tools.Rekognition'
	'AWS.Tools.ResourceGroups'
	'AWS.Tools.ResourceGroupsTaggingAPI'
	'AWS.Tools.RoboMaker'
	'AWS.Tools.Route53'
	'AWS.Tools.Route53Domains'
	'AWS.Tools.Route53Resolver'
	'AWS.Tools.S3'
	'AWS.Tools.S3Control'
	'AWS.Tools.SageMaker'
	'AWS.Tools.SageMakerRuntime'
	'AWS.Tools.SavingsPlans'
	'AWS.Tools.SecretsManager'
	'AWS.Tools.SecurityHub'
	'AWS.Tools.SecurityToken'
	'AWS.Tools.ServerlessApplicationRepository'
	'AWS.Tools.ServerMigrationService'
	'AWS.Tools.ServiceCatalog'
	'AWS.Tools.ServiceDiscovery'
	'AWS.Tools.ServiceQuotas'
	'AWS.Tools.Shield'
	'AWS.Tools.SimpleEmail'
	'AWS.Tools.SimpleEmailV2'
	'AWS.Tools.SimpleNotificationService'
	'AWS.Tools.SimpleSystemsManagement'
	'AWS.Tools.SimpleWorkflow'
	'AWS.Tools.Snowball'
	'AWS.Tools.SQS'
	'AWS.Tools.SSO'
	'AWS.Tools.SSOOIDC'
	'AWS.Tools.StepFunctions'
	'AWS.Tools.StorageGateway'
	'AWS.Tools.Textract'
	'AWS.Tools.TranscribeService'
	'AWS.Tools.Transfer'
	'AWS.Tools.Translate'
	'AWS.Tools.WAF'
	'AWS.Tools.WAFRegional'
	'AWS.Tools.WAFV2'
	'AWS.Tools.WorkDocs'
	'AWS.Tools.WorkLink'
	'AWS.Tools.WorkMail'
	'AWS.Tools.WorkMailMessageFlow'
	'AWS.Tools.WorkSpaces'
	'AWS.Tools.XRay'
)
