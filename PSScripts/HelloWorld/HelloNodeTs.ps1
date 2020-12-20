param (
	[string]
	$Path = 'HelloNodeTs'
)

$nodeVersion = (gcm node -ErrorAction Stop).Version.Major

ni $Path -ItemType Directory -Force

pushd $Path

Set-Content package.json '{}'
Set-Content tsconfig.json @"
{
	"extends": "@tsconfig/node${nodeVersion}/tsconfig.json"
}
"@
Set-Content server.ts 'console.log("Hello TypeScript")'

npm install --save-dev typescript
npm install --save-dev "@types/node@${nodeVersion}"
npm install --save-dev "@tsconfig/node${nodeVersion}"

npx tsc && npm start

popd
