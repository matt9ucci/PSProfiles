<#
.LINK
	https://github.com/bytecodealliance/wasmtime-dotnet/blob/main/docs/articles/intro.md
#>
param (
	[string]
	$Name = 'HelloWasmtimeDotnet'
)

dotnet new console --output $Name
dotnet add $Name package --version 0.23.0-preview1 wasmtime

Set-Content (Join-Path $Name Program.cs) @'
namespace HelloWasmtimeDotnet {
	class Program {
		static void Main(string[] args) {
			using var engine = new Wasmtime.Engine();
			using var host = new Wasmtime.Host(engine);
			using var function = host.DefineFunction(
				"HostModule",
				"HostFunction",
				() => System.Console.WriteLine("Hello wasmtime-dotnet!")
			);

			using var module = Wasmtime.Module.FromTextFile(engine, args[0]);

			using dynamic instance = host.Instantiate(module);
			instance.run();
		}
	}
}
'@

$wasmName = 'module.wat'

Set-Content (Join-Path $Name $wasmName) @'
(module
	(func $hello (import "HostModule" "HostFunction"))
	(func (export "run") (call $hello))
)
'@

dotnet run --project $Name (Join-Path $Name $wasmName)
