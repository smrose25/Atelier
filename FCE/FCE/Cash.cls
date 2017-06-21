/// Processing for cash payments
Class FCE.Cash Extends FCE.Payment
{

Method Process(order As FCE.CurrencyOrder, Output cashPaymentString As %String = "") As %Status
{
	set status = ##super(order, .paymentString)
	if ($$$ISERR(status)) { return status }
	else {
		set ATM = order.ATM
		// debit and credit ATM only
		set status = ATM.Update(order.CurrencyOut,
								order.AmountOut,
								order.CurrencyIn,
								order.AmountIn)	
		set paymentSaved = ..%Save()								
		set status = $$$ADDSC(status, paymentSaved)
		if $$$ISOK(status) {
			set cashPaymentString = paymentString _ $$$NL
			    _ "Cash payment of "
			    _ order.AmountIn _ " "
			    _ order.CurrencyIn _ " verified."
		}
		return status
	}
}

Storage Default
{
<ExtentSize>44</ExtentSize>
<Property name="%%CLASSNAME">
<AverageFieldSize>10</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>2.41</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="VerificationID">
<AverageFieldSize>4.86</AverageFieldSize>
<Selectivity>2.2727%</Selectivity>
</Property>
<SQLMap name="$Cash">
<BlockCount>-4</BlockCount>
</SQLMap>
<Type>%Library.CacheStorage</Type>
}

}
