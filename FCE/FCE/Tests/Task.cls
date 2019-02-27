Class FCE.Tests.Task Extends %SYS.Task.Definition
{

Property Verbose As %Integer [ InitialExpression = 0 ];

Method OnTask() As %Status
{
	set st = $$$OK
	try {
		do ##class(FCE.Tests.BasicTests).Run(..Verbose)
	}
	catch ex {
		set st = ex.AsStatus()
	}
	return st
}

}
