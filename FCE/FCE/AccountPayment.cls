/// Processing for Account payments
Class FCE.AccountPayment Extends FCE.Payment
{

Method Process(order As FCE.CurrencyOrder, Output accountPaymentString As %String = "") As %Status
{
	set status = ##super(order, .paymentString)
	if ($$$ISERR(status)) { return status }
	else {
		#dim ATM as FCE.ATM
		set ATM = order.ATM
		#dim branch as FCE.Branch
		set branch = ATM.Branch
		#dim account as FCE.AccountHolder
		set account = order.AccountHolder
		// debit ATM
		set ATMStatus = ATM.Update(order.CurrencyOut, order.AmountOut)
		// credit branch					       
		set branchStatus = branch.Update(order.CurrencyIn, order.AmountIn)
		// debit account							         
		set accountStatus = account.Update(order.AmountIn)
		
		set paymentSaved = ..%Save()								
		set status = $$$ADDSC(ATMStatus, branchStatus)
		set status = $$$ADDSC(status, accountStatus)
		set status = $$$ADDSC(status, paymentSaved)
		if $$$ISOK(status) {
			set accountPaymentString = paymentString _ $$$NL
		    	_ "Thank you, " _ account.PrintName
		    	_ ", for your account payment of "
		    	_ order.AmountIn _ " "
		    	_ order.CurrencyIn _ "."
		}
		return status
	}
}

Storage Default
{
<ExtentSize>10</ExtentSize>
<Property name="%%CLASSNAME">
<AverageFieldSize>20</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="VerificationID">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>10.0000%</Selectivity>
</Property>
<SQLMap name="$AccountPayment">
<BlockCount>-4</BlockCount>
</SQLMap>
<Type>%Storage.Persistent</Type>
}

}
