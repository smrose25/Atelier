/// Processing for cash payments
Class FCE.Cash Extends FCE.Payment
{

Method Process(order As FCE.CurrencyOrder, Output cashPaymentString As %String = "") As %Status
{
	set status = ##super(order, .paymentString)
	if ($$$ISERR(status)) { return status }
	else {
		#dim ATM as FCE.ATM
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
<ExtentSize>6</ExtentSize>
<Property name="%%CLASSNAME">
<AverageFieldSize>10</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>1.83</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="VerificationID">
<AverageFieldSize>4.83</AverageFieldSize>
<Selectivity>16.6667%</Selectivity>
</Property>
<SQLMap name="$Cash">
<BlockCount>-4</BlockCount>
</SQLMap>
<Type>%Storage.Persistent</Type>
}

}
