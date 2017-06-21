/// Addresses for branches and ATMs
Class FCE.RealEstate Extends (%Persistent, FCE.Address)
{

ClassMethod ByZip(state As %String = "", Output status As %Status) As %SQL.StatementResult [ ReturnResultsets, SqlProc ]
{
	set resultSet = $$$NULLOREF
	set statement = ##class(%SQL.Statement).%New()
	set sql = "select zip, street, city, state from fce.realestate"
	if (state '= "") {
		set sql = sql _ " where state = ?"
	}
	set sql = sql _ " order by zip"
	set status = statement.%Prepare(sql)
	if $$$ISOK(status) {
		if (state '= "") {
			set resultSet = statement.%Execute(state)
		}
		else {
			set resultSet = statement.%Execute()
		}
		if (resultSet.%SQLCODE = 0) {
			// successful %Execute
			// do resultSet.%Display()  // for testing
			do %sqlcontext.AddResultSet(resultSet)  // for xDBC
		}
		else {
			// error during %Execute
			set %sqlcontext.%SQLCODE = resultSet.%SQLCODE
			set %sqlcontext.%Message = resultSet.%Message
		}
	}
	else {
		// error during %Prepare: bad SQL
		do $system.Status.DecomposeStatus(status, .err)
		set %sqlcontext.%SQLCODE = err(1,"param",1)
		set %sqlcontext.%Message = err(1,"param",2)
	}
	return resultSet  // return results to other server-side code
}

Storage Default
{
<Data name="RealEstateDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Street</Value>
</Value>
<Value name="3">
<Value>City</Value>
</Value>
<Value name="4">
<Value>State</Value>
</Value>
<Value name="5">
<Value>Zip</Value>
</Value>
</Data>
<DataLocation>^FCE.RealEstateD</DataLocation>
<DefaultData>RealEstateDefaultData</DefaultData>
<ExtentSize>50</ExtentSize>
<IdLocation>^FCE.RealEstateD</IdLocation>
<IndexLocation>^FCE.RealEstateI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>1.9</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="City">
<AverageFieldSize>6.96</AverageFieldSize>
<Selectivity>4.3478%</Selectivity>
</Property>
<Property name="State">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="Street">
<AverageFieldSize>16.76</AverageFieldSize>
<Selectivity>2.0000%</Selectivity>
</Property>
<Property name="Zip">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>2.0000%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^FCE.RealEstateS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
