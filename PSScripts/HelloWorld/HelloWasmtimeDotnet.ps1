<#
.LINK
	https://github.com/bytecodealliance/wasmtime-dotnet/blob/main/docs/articles/intro.md
#>
param (
	[string]
	$Name = 'HelloWasmtimeDotnet'
)

dotnet new console --output $Name
dotnet add $Name package --version 0.32.0-preview1 wasmtime
dotnet new globaljson --output $Name
dotnet new gitignore --output $Name

Set-Content (Join-Path $Name Program.cs) @'
namespace HelloWasmtimeDotnet {
	class Program {
		static void Main(string[] args) {
			using var engine = new Wasmtime.Engine();

			using var module = Wasmtime.Module.FromTextFile(engine, args[0]);

			using var store = new Wasmtime.Store(engine);

			using var linker = new Wasmtime.Linker(engine);
			linker.Define(
				"HostModule",
				"HostFunction",
				Wasmtime.Function.FromCallback(store, (() => System.Console.WriteLine("Hello wasmtime-dotnet!")))
			);

			var instance = linker.Instantiate(store, module);
			instance.GetFunction(store, "run")?.Invoke(store);
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
