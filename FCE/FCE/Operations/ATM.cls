Include (%occStatus, %occConstant)

/// Facade for ATM operations
Class FCE.Operations.ATM
{

Parameter FEERATE = .025;

/// Calculate Exchange Rate
/// generates a random value from .1 to 2
/// will be replaced with a lookup
ClassMethod GetExchangeRate(currencyOut As FCE.Currency, currencyIn As FCE.Currency) As %Decimal [ SqlProc ]
{
	set rate = (($random(20) / 10) + .1)
	return rate
}

/// Perform calculations for a request
ClassMethod GetAmountOutAndFee(amountIn As %Numeric, exchangeRate As %Decimal, Output fee As %Numeric, Output amountOut As %Numeric) As %Status [ SqlProc ]
{
	set fee = amountIn * ..#FEERATE
	set amountOut = (amountIn - fee) * exchangeRate
	return $$$OK
}

/// Process initial request
/// Do calculations, validate request
/// Return order linked to ATM
ClassMethod ProcessRequest(orderATM As FCE.ATM, requestor As %String, requestorEmail As %String, currencyOut As FCE.Currency, currencyIn As FCE.Currency, amountIn As %Numeric) As FCE.CurrencyOrder
{
	set exchangeRate = ..GetExchangeRate(currencyOut, currencyIn)
	do ..GetAmountOutAndFee(amountIn, exchangeRate, .fee, .amountOut) // using pass by reference
	set stockAmountOut = orderATM.CurrencyBalances.GetAt(currencyOut)
	// check stock here, even though Update has the check also
	if (amountOut > stockAmountOut) {
		return $$$NULLOREF
	}
	else {
		set order = ##class(FCE.CurrencyOrder).%New(currencyOut,
		                                            amountOut,
		                                            currencyIn,
		                                            amountIn)
		// if order was created, attach orderATM
		if $IsObject(order) {
			set order.ATM = orderATM
			set order.Requestor = requestor
			set order.RequestorEmail = requestorEmail
			set order.ExchangeRate = exchangeRate
			set order.Fee = fee
		}
		return order
	}
}

/// Process an order, with a payment (optionally made from an account)
/// 1. Link objects
/// 2. Prepare for transaction
/// 3. Tstart, process payment, Tcommit
/// 4. Report errors, set error status
ClassMethod ProcessOrder(order As FCE.CurrencyOrder, payment As FCE.Payment, account As FCE.AccountHolder = "", ByRef message As %String) As %Status
{
	if $IsObject(account) { set order.AccountHolder = account }
	
	set UTCTimeStamp = $system.SYS.TimeStamp()
	set order.DateStamp = $p(UTCTimeStamp, ",", 1)
	set order.TimeStamp = $p(UTCTimeStamp, ",", 2)
	set status = $$$OK, message = "" // initialize
	

	// check that account has valid and sufficient currency
	if $IsObject(account) &&
	       ( (account.Currency '= order.CurrencyIn) ||
	         (account.Balance < order.AmountIn) ) {
		set order.Status = "Rejected"
	}
	else {
		tstart // start a nested transaction
		set status = payment.Process(order, .message)

		if $$$ISERR(status)
		{
			set order.Status = "Problem"
			trollback 1
		}
		else {
			set order.Payment = payment
			set order.Status = "Completed"
			tcommit
		}
	}
	set orderSaved = order.%Save()
	set finalStatus = $$$ADDSC(status, orderSaved)
	if ($$$ISERR(finalStatus)) {return finalStatus}
	else {
		do ##class(FCE.Operations.ATM).SendConfirmation(order)
		return $$$OK
	}
}

/// Send email confirmation for processed order
ClassMethod SendConfirmation(order As FCE.CurrencyOrder) As %Status
{
	//disabled for now; comment following line to enable
	return 1
	// define an smtp server
	set mailServer = ##class(%Net.SMTP).%New()
	set mailServer.smtpserver = "mail.intersystems.com" ; your smtp server
	set mailServer.timezone = "-0500"  ; your timezone
	// define a message
	set message = ##class(%Net.MailMessage).%New()
	set message.Subject = "Confirmation of " _ order.Status _ " currency exchange"
	set message.From = "auto-confirm@fcxbank.com"
	do message.To.Insert(order.RequestorEmail)
	// add text
	set line(1) = "Hello " _ order.Requestor
	set line(2) = $$$NL _ $$$NL _ "Your exchange of " _ order.AmountIn _ " " _ order.CurrencyIn
	set line(3) = $$$NL _ $justify("for ",17) _ order.AmountOut _ " " _ order.CurrencyOut
	set line(4) = $$$NL _ "has been " _ order.Status _ "."
	for i=1:1:4 {
		do message.TextData.Write(line(i))
	}
	// send the email
	set status = mailServer.Send(message)
	return status
}

/// create different kinds of payments
ClassMethod CreatePayment(paymentType As %String, ccType As %String, ccNumber As %String, ccExpiration As %Date) As FCE.Payment
{
	if (paymentType = "Credit Card") {
		set cc = ##class(FCE.CreditCard).%New()
		set cc.Type = ccType,
		    cc.Number = ccNumber,
		    cc.ExpirationDate = ccExpiration
		return cc
	}
	elseif (paymentType = "Cash") {
		return ##class(FCE.Cash).%New()
	}
	elseif (paymentType = "Account") {
		return ##class(FCE.AccountPayment).%New()
	}
	else { return $$$NULLOREF }
}

/// lookup accounts by ID number
ClassMethod GetAccountByID(ID As %Integer) As FCE.AccountHolder
{
	return ##class(FCE.AccountHolder).%OpenId(ID)
}

}
