/// ATMs belonging to a branch
Class FCE.ATM Extends (%Persistent, %Populate, %XML.Adaptor)
{

Parameter EXTENTQUERYSPEC = "SerialNumber";

Property Address As FCE.RealEstate;

ForeignKey RealEstateFK(Address) References FCE.RealEstate() [ OnDelete = setnull ];

Property CurrencyBalances As array Of %Numeric(MAXVAL = 10000, MINVAL = 0, POPSPEC = ":5:##class(FCE.Currency).Currency()") [ SqlFieldName = Balance ];

Index CBIndex On CurrencyBalances(KEYS);

/// External identification for an ATM
Property SerialNumber As %String(POPSPEC = "##class(%PopulateUtils).String(5)_##class(%PopulateUtils).String(5)");

Index SerialNumberIndex On SerialNumber [ Unique ];

Property Notes As %Stream.GlobalCharacter;

Relationship Branch As FCE.Branch [ Cardinality = parent, Inverse = ATMs ];

Relationship Orders As FCE.CurrencyOrder [ Cardinality = many, Inverse = ATM ];

/// Update ATM by debiting/crediting currencies<br>
/// This method can be called with:<br>
/// * all 4 arguments (cash in - cash out). currencyOut and currencyIn <b>must</b> be different<br>
/// * the first 2 arguments (cash out only, paid for by credit card or bank account)<br>
/// * the last 2 arguments (cash in only, to be credited to bank balance)<br>
Method Update(currencyOut As FCE.CurrencyName = "", amountOut As %Numeric = 0, currencyIn As FCE.CurrencyName = "", amountIn As %Numeric = 0) As %Status
{
	try {
		set status = $$$OK
		set (outChanged, inChanged) = 0
		
		// debit stock amount by amount taken out
		if (currencyOut '= "") && (amountOut > 0) {
			set outChanged = 1
			set stockAmountOut = ..CurrencyBalances.GetAt(currencyOut)
			set debitedAmountOut = stockAmountOut - amountOut
			do ..CurrencyBalances.SetAt(debitedAmountOut, currencyOut)
			set status = ..%ValidateObject()
			if $$$ISERR(status) {
				set ex = ##class(%Exception.StatusException).CreateFromStatus(status)
				throw ex
			}
		}
		
		// credit stock amount by amount put in
		if (currencyIn '= "") && (amountIn > 0) {
			set inChanged = 1
			set stockAmountIn = ..CurrencyBalances.GetAt(currencyIn)
			set creditedAmountIn = stockAmountIn + amountIn
			do ..CurrencyBalances.SetAt(creditedAmountIn, currencyIn)
			set status = ..%ValidateObject()
			if $$$ISERR(status) {
				set ex = ##class(%Exception.StatusException).CreateFromStatus(status)
				throw ex
			}
		}
		// create unforseen <DIVIDE> exception 10% of the time
		// if '$r(10) {write 1/0}
	}
	catch ex {
		#dim ex, exCustom as %Exception.StatusException // enable Studio Assist for the exception objects
		// return custom error status and also write it to Application Error Log
		if (ex.Code = $$$ERRORCODE($$$DTMinVal)) {
			set custom = "Not enough stock in ATM " _ ..SerialNumber _ " for " _ currencyOut
			set status = $$$ERROR($$$GeneralError, custom)
			set exCustom = ##class(%Exception.StatusException).CreateFromStatus(status)
			do exCustom.Log()
		}
		elseif (ex.Code = $$$ERRORCODE($$$DTMaxVal)) {
			set custom = "ATM " _ ..SerialNumber _ " has no more room for " _ currencyIn
			set status = $$$ERROR($$$GeneralError, custom)
			set exCustom = ##class(%Exception.StatusException).CreateFromStatus(status)
			do exCustom.Log()
		}
		// or change unforeseen exception back into a status
		else {
			set status = ex.AsStatus()
			do ex.Log()
		}
		// reset currencyIn and currencyOut
		if (outChanged) {
		 	do ..CurrencyBalances.SetAt(stockAmountOut, currencyOut)
	 	}
		if (inChanged) {
		 	do ..CurrencyBalances.SetAt(stockAmountIn, currencyIn)
	 	}
		
		// write to console log, optionally triggering notification
		set consoleMsg = "ATM " _ ..SerialNumber _ " Stock Problem - Check Error Log for details: "
		set portalLink = "http://localhost:57772/csp/sys/op/UtilSysAppErrorNamespaces.csp"
		do ##class(%SYS.System).WriteToConsoleLog(consoleMsg _ portalLink, , 2)
	}
	return status
}

///  Sum currency amounts and count ATMs, by currency
Query CurrencySummary(minimum = 0) As %SQLQuery [ SqlProc ]
{
 select element_key as Currency, count(ATM) as ATM_Count, 
        sum(Balance) as Total_Balance
 from FCE.ATM_Balance
 group by element_key
 having sum(Balance) >= :minimum
 order by element_key
}

/// Return unique list of city/state combinations with ATMs
Query CitiesStates() As %SQLQuery [ SqlProc ]
{
select distinct Address->City, Address->State
from FCE.ATM
order by Address->State, Address->City
}

ClassMethod CitiesStatesList() As %Status
{
	set resultSet = ##class(%ResultSet).%New("FCE.ATM:CitiesStates")
	set status = resultSet.%Execute()
	while resultSet.%Next() {
		write !, resultSet.City, ?25, resultSet.State
	}
	do resultSet.%Close()
	return $$$OK
}

/// Show serial numbers and addresses for ATMs in a given city that have at least one currency
ClassMethod ATMsInACity(city As %String, state As %String) As %Status
{
	&sql(declare ATMS cursor for
	     select SerialNumber, Address->Street, list(ATM_Balance->element_key) as Currencies
	     from FCE.ATM
	     where (Address->City = :city AND Address->State = :state)
	     group by SerialNumber
	     having list(ATM_Balance->element_key) is not null)
	&sql(open ATMS)
	for {
	    &sql(fetch ATMS into :serial, :street, :currencies)
	    quit:(SQLCODE '= 0)
	    write !, serial, ?15, street, ?37, currencies
	}
    if SQLCODE = 100 {
	    write !!, %ROWCOUNT, " row(s) returned."
	    set status = $$$OK
	}
    else { set status = $$$ERROR($$$GeneralError, "SQLCODE: " _ SQLCODE _ " " _ %msg) }
	&sql(close ATMS)
	return status
}

Method %OnValidateObject() As %Status [ Private, ProcedureBlock = 1, ServerOnly = 1 ]
{
	return ##class(FCE.Currency).CurrencyKeysValidate(..CurrencyBalances)
}

Storage Default
{
<Data name="ATMDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Address</Value>
</Value>
<Value name="3">
<Value>SerialNumber</Value>
</Value>
<Value name="4">
<Value>Notes</Value>
</Value>
</Data>
<Data name="CurrencyBalances">
<Attribute>CurrencyBalances</Attribute>
<Structure>subnode</Structure>
<Subscript>"CurrencyBalances"</Subscript>
</Data>
<DataLocation>{%%PARENT}("ATMs")</DataLocation>
<DefaultData>ATMDefaultData</DefaultData>
<ExtentSize>15</ExtentSize>
<IdLocation>^FCE.BranchC("ATMs")</IdLocation>
<IndexLocation>^FCE.ATMI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>6</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Address">
<AverageFieldSize>1.87</AverageFieldSize>
<Selectivity>7.1429%</Selectivity>
</Property>
<Property name="Branch">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>25.0000%</Selectivity>
</Property>
<Property name="Notes">
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="SerialNumber">
<AverageFieldSize>9.73</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="childsub">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>6.6667%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="SerialNumberIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^FCE.ATMS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
