/// Bank branch information
Class FCE.Branch Extends (%Persistent, %Populate, %XML.Adaptor)
{

Property Phone As FCE.PhoneNumber [ Required ];

Index PhoneIndex On Phone [ Unique ];

Property Address As FCE.RealEstate;

Index AddressIndex On Address [ Unique ];

ForeignKey RealEstateFK(Address) References FCE.RealEstate() [ OnDelete = setnull ];

/// Time branch opens
Property Opens As %Time(MAXVAL = "$ztimeh(""12:00n"")", MINVAL = "$ztimeh(""6:00am"")");

/// Time branch closes
Property Closes As %Time(MAXVAL = "$ztimeh(""10:00pm"")", MINVAL = "$ztimeh(""1:00pm"")");

/// Currency used by this branch's nation
Property NationalCurrency As FCE.CurrencyName [ InitialExpression = "USD" ];

Property CurrencyBalances As array Of %Numeric(MAXVAL = 100000000, MINVAL = 0, POPSPEC = ":5:##class(FCE.Currency).Currency()") [ SqlFieldName = Balance ];

Index CBIndex On CurrencyBalances(KEYS);

Property DurationOpen As %String [ Calculated, SqlComputeCode = {if ({Closes} = "") || ({Opens} = "")
{set {DurationOpen} = ""}
else {set {DurationOpen} = $ztime({Closes} - {Opens})}}, SqlComputed ];

Relationship ATMs As FCE.ATM [ Cardinality = children, Inverse = Branch ];

/// create a JSON object from Branch properties
Method CopyToObject(object As %DynamicObject) As %Status
{
	set object.ID = ..%Id()
	set object.Phone = ..Phone
	set object.Opens = $ztime(..Opens)
	set object.Closes = $ztime(..Closes)
	return $$$OK
}

/// copy a JSON object into Branch properties
Method CopyFromObject(object As %DynamicObject) As %Status
{
	set ..Phone  = object.Phone
	set ..Opens = $ztimeh(object.Opens)
	set ..Closes = $ztimeh(object.Closes)
	return $$$OK
}

/// Update Branch by crediting currencies
Method Update(currencyIn As FCE.CurrencyName, amountIn As %Numeric) As %Status
{
	// credit incoming currency by incoming amount
	set stockAmountIn = ..CurrencyBalances.GetAt(currencyIn)
	set stockAmountIn = stockAmountIn + amountIn
	do ..CurrencyBalances.SetAt(stockAmountIn, currencyIn)
	return $$$OK
}

Query CurrencySummary() As %SQLQuery [ SqlProc ]
{
 select element_key as Currency, 
        sum(Balance) as Total_Balance
 from FCE.Branch_Balance
 group by element_key
 order by element_key
}

Method %OnValidateObject() As %Status [ Private, ProcedureBlock = 1, ServerOnly = 1 ]
{
	return ##class(FCE.Currency).CurrencyKeysValidate(..CurrencyBalances)
}

ClassMethod CurrencyReport() [ ReturnResultsets, SqlProc ]
{
	set rs1 = ##class(%ResultSet).%New("FCE.Branch:CurrencySummary")
	set rs2 = ##class(%ResultSet).%New("FCE.ATM:CurrencySummary")
	do rs1.%Execute()
	do rs2.%Execute()
	do %sqlcontext.AddResultSet(rs1)
	do %sqlcontext.AddResultSet(rs2)
}

Storage Default
{
<Data name="BranchDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Phone</Value>
</Value>
<Value name="3">
<Value>Address</Value>
</Value>
<Value name="4">
<Value>Opens</Value>
</Value>
<Value name="5">
<Value>Closes</Value>
</Value>
<Value name="6">
<Value>NationalCurrency</Value>
</Value>
</Data>
<Data name="CurrencyBalances">
<Attribute>CurrencyBalances</Attribute>
<Structure>subnode</Structure>
<Subscript>"CurrencyBalances"</Subscript>
</Data>
<DataLocation>^FCE.BranchD</DataLocation>
<DefaultData>BranchDefaultData</DefaultData>
<ExtentSize>5</ExtentSize>
<IdLocation>^FCE.BranchD</IdLocation>
<IndexLocation>^FCE.BranchI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Address">
<AverageFieldSize>1.8</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Closes">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>20.0000%</Selectivity>
</Property>
<Property name="DurationOpen">
<AverageFieldSize>8</AverageFieldSize>
<Selectivity>20.0000%</Selectivity>
</Property>
<Property name="NationalCurrency">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Opens">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>20.0000%</Selectivity>
</Property>
<Property name="Phone">
<AverageFieldSize>12</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<SQLMap name="AddressIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="PhoneIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^FCE.BranchS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
