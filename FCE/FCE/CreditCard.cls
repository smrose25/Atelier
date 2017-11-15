/// Processing for credit card payments
Class FCE.CreditCard Extends FCE.Payment
{

Property Number As %String(PATTERN = "3(4n1""-"")4n", POPSPEC = ".CreditCardNumber()");

Property Type As %String(VALUELIST = "-Visa-MC-AmEx-Discover-Diners");

///  expires within next 5 years 
Property ExpirationDate As %Date(MAXVAL = "$zdh(""t+1825"",5)", MINVAL = "$zdh(""t"",5)");

Method Process(order As FCE.CurrencyOrder, Output creditCardString As %String = "") As %Status
{
	set status = ##super(order, .paymentString)
	if ($$$ISERR(status)) { return status }
	else {
		set ATM = order.ATM
		// debit ATM
		set status = ATM.Update(order.CurrencyOut, order.AmountOut)
		set paymentSaved = ..%Save()								
		set status = $$$ADDSC(status, paymentSaved)
		if $$$ISOK(status) {
			set creditCardString = paymentString _ $$$NL
		        _ ..Type _ " transaction for "
		        _ order.AmountIn _ " "
		        _ order.CurrencyIn _ " completed"
		    	_ " (card ending in " _ $piece(..Number, "-", 4) _ ")."
		}
		return status
	}
}

/// Generate credit card numbers
ClassMethod CreditCardNumber() As %String
{
	return ($Random(9000) + 1000) _ "-"
		 _ ($Random(9000) + 1000) _ "-"
		 _ ($Random(9000) + 1000) _ "-"
		 _ ($Random(9000) + 1000)
}

Storage Default
{
<Data name="CreditCardDefaultData">
<Subscript>"CreditCard"</Subscript>
<Value name="1">
<Value>Number</Value>
</Value>
<Value name="2">
<Value>Type</Value>
</Value>
<Value name="3">
<Value>ExpirationDate</Value>
</Value>
</Data>
<DefaultData>CreditCardDefaultData</DefaultData>
<ExtentSize>11</ExtentSize>
<Property name="%%CLASSNAME">
<AverageFieldSize>16</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>1.91</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="ExpirationDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>9.0909%</Selectivity>
</Property>
<Property name="Number">
<AverageFieldSize>19</AverageFieldSize>
<Selectivity>9.0909%</Selectivity>
</Property>
<Property name="Type">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>20.0000%</Selectivity>
</Property>
<Property name="VerificationID">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>9.0909%</Selectivity>
</Property>
<SQLMap name="$CreditCard">
<BlockCount>-4</BlockCount>
</SQLMap>
<Type>%Library.CacheStorage</Type>
}

}
