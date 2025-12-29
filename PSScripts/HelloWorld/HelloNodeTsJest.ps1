<#
.LINK
	Jest - TypeScript Deep Dive https://basarat.gitbook.io/typescript/intro-1/jest
#>
param (
	[string]
	$Path = 'HelloNodeTsJest',

	[uint]
	$Version = 14
)

ni $Path -ItemType Directory -Force

pushd $Path

Set-Content package.json @"
{
	"scripts": {
		"test": "jest"
	}
}
"@
Set-Content tsconfig.json @"
{
	"extends": "@tsconfig/node$Version/tsconfig.json"
}
"@
Set-Content sum.ts @"
export function sum(a: number, b: number) {
	return a + b
}
"@
Set-Content sum.test.ts @"
import { sum } from "./sum"

test('Hello NodeTs Jest', () => {
	expect(sum(1, 2)).toBe(3)
})
"@

npm install --save-dev typescript
npm install --save-dev "@types/node@$Version"
npm install --save-dev "@tsconfig/node$Version"

npm install --save-dev jest
npm install --save-dev @types/jest ts-jest

# Initialize jest.config.js
npx ts-jest config:init

npm test

popd
