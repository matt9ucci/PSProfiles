<# npm command aliases
npm i: install
npm i -D: --save-dev
npm i -G: --global
npm i -P: --save-prod
npm i -S: --save
npm run: run-script
#>

${package.json} = @"
{
	"name": "$((Get-Item .).Name)",
	"version": "0.1.0",
	"description": "$((Get-Item .).Name)",
	"main": "index.js",
	"scripts": {
		"start": "node dist/index.js",
		"build": "npm run build:ts",
		"build:ts": "tsc",
		"clean": "npm run clean:js",
		"clean:js": "@pwsh -nop -c Remove-Item dist -Recurse -Force"
	},
	"author": "M",
	"license": "ISC"
}
"@
Set-Content -Path package.json -Value ${package.json}

New-Item -Path src -ItemType Directory
Set-Content -Path src/index.ts -Value 'console.log("Hello, World!")'

npm i -D typescript
npx tsc --init `
	--rootDir src `
	--outDir dist `
	--target ES2019

npm i -D @types/node

<# optional
npm i -D eslint
npx eslint --init

npm i -D jest @types/jest ts-jest
#>
