param (
	[string]
	$Path = 'HelloJar'
)

New-Item $Path -ItemType Directory

Push-Location $Path

Add-Content -Path Hello.java -Value @"
public class Hello {
	public static void main(String[] args) {
		System.out.println("Hello, jar!!");
	}
}
"@

javac Hello.java

jar --verbose --create --file hello.jar --main-class Hello *.class

java -jar hello.jar

Pop-Location
