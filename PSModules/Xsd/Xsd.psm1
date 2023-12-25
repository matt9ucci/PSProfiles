Register-ArgumentCompleter -CommandName xsd -ScriptBlock {
	param ([string]$WordToComplete, $CommandAst, $CursorPosition)

	if ($WordToComplete.StartsWith('/')) {

		function CR ([string]$CompletionText, [string]$ToolTip = $CompletionText) {
			New-Object System.Management.Automation.CompletionResult $CompletionText, $CompletionText, ParameterName, $ToolTip
		}

		CR '/classes' 'Generate classes for this schema. Short form is ''/c''.'
		CR '/dataset' 'Generate sub-classed DataSet for this schema. Short form is ''/d''.'
		CR '/enableLinqDataSet' 'Generate LINQ-enabled sub-classed Dataset for the schemas provided.  Short form is ''/eld''.'
		CR '/element:' 'Element from schema to process. Short form is ''/e:''.'
		CR '/fields' 'Generate fields instead of properties. Short form is ''/f''.'
		CR '/order' 'Generate explicit order identifiers on all particle members.'
		CR '/enableDataBinding' 'Implement INotifyPropertyChanged interface on all generated types to enable data binding. Short form is ''/edb''.'
		CR '/language:' 'The language to use for the generated code. Choose from ''CS'', ''VB'', ''JS'', ''VJS'', ''CPP'' or provide a fully-qualified name for a class implementing System.CodeDom.Compiler.CodeDomProvider. The default language is ''CS'' (CSharp). Short form is ''/l:''.'
		CR '/namespace:' 'The namespace for generated class files. The default namespace is the global namespace. Short form is ''/n:''.'
		CR '/nologo' 'Suppresses the banner.'
		CR '/out:' 'The output directory to create files in. The default is the current directory. Short form is ''/o:''.'
		CR '/type:' 'Type from assembly to generate schema for. Multiple types may be provided. If no types are provided, then schemas for all types in an assembly are generated. Short form is ''/t:''.'
		CR '/uri:' 'Uri of elements from schema to process. Short form is ''/u:''.'
		CR '/parameters:' 'Read command-line options from the specified xml file. Short form is ''/p:''.'
	}
}
