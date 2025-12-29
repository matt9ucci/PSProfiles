param (
	[string]
	$Path = 'HelloNodeJs'
)

ni $Path -ItemType Directory -Force

pushd $Path

Set-Content package.json '{}'
Set-Content server.js 'console.log("Hello NodeJs")'

npm run # Show default `npm start` script: `node server.js`
npm start

popd
