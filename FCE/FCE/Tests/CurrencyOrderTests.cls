Class FCE.Tests.CurrencyOrderTests Extends FCE.Tests.TestCase
{

/// test FCE.CurrencyOrder.%New()
Method TestCurrencyOrderCreate()
{
	set currencyOut    = "EUR"
	set currencyIn     = "USD"
	set (amountOut, amountIn) = -1 // bad values
	set order = ##class(FCE.CurrencyOrder).%New(currencyOut,
	                                            amountOut,
	                                            currencyIn,
	                                            amountIn,
	                                            .status)
	do $$$AssertStatusNotOK(status, "Amounts must be >= 0")
	
	set (amountOut, amountIn) = 100 // good values
	set order = ##class(FCE.CurrencyOrder).%New(currencyOut,
	                                            amountOut,
	                                            currencyIn,
	                                            amountIn,
	                                            .status)
	do $$$AssertStatusOK(status, "Currency Order created")
}

/// test FCE.Operations.ATM.GetAmountOutAndFee()
Method TestGetAmountOutAndFee()
{
	set amountIn        = 100
	set exchangeRate    = 1
	set targetAmountOut = 97.5
	set targetFee       = 2.5
	do ##class(FCE.Operations.ATM).GetAmountOutAndFee(amountIn, exchangeRate, .fee, .amountOut)
	do $$$AssertEquals(fee, targetFee, "Fee correctly calculated")
	do $$$AssertEquals(amountOut, targetAmountOut, "Outgoing amount correctly calculated")
}

/// test FCE.Operations.ATM.ProcessRequest
Method TestProcessRequest()
{
	set ATM = ##class(FCE.ATM).%New()
	do ATM.CurrencyBalances.SetAt(200,"EUR")
	do ATM.CurrencyBalances.SetAt(50,"USD")
	set requestor      = "Smith,John"
	set requestorEmail = "smith@intersystems.com"
	set currencyOut    = "EUR"
	set currencyIn     = "USD"
	set amountIn       = -1
	set order = ##class(FCE.Operations.ATM).ProcessRequest(ATM,
														   requestor, 
	                                                       requestorEmail,
	                                                       currencyOut,
	                                                       currencyIn,
	                                                       amountIn)
	do $$$AssertNotTrue($IsObject(order), "Incoming amount must be >= 0")
	set amountIn = 100
	set order = ##class(FCE.Operations.ATM).ProcessRequest(ATM,
														   requestor, 
	                                                       requestorEmail,
	                                                       currencyOut,
	                                                       currencyIn,
	                                                       amountIn)
	do $$$AssertTrue($IsObject(order), "Order created")
	do $$$AssertEquals(requestor, order.Requestor, "Requestor assigned")
	do $$$AssertEquals(requestorEmail, order.RequestorEmail, "Requestor email assigned")
	do $$$AssertEquals(ATM, order.ATM, "ATM assigned")
	do $$$AssertEquals(currencyIn, order.CurrencyIn, "Incoming currency assigned")
	do $$$AssertEquals(amountIn, order.AmountIn, "Incoming amount assigned")
	do $$$AssertEquals(currencyOut, order.CurrencyOut, "Outgoing currency assigned")
	do $$$AssertNotEquals(0, order.AmountOut, "Outgoing amount computed")
	do $$$AssertNotEquals(0, order.ExchangeRate, "Exchange rate computed")
}

/// test FCE.Operations.ATM.ProcessOrder()
Method TestProcessOrder()
{
	// create branch
	set branch = ##class(FCE.Branch).%New()
	set phone = "999-999-0000", branch.Phone = phone
	set status = branch.%Save()

	// create order #1
	set order1 = ##class(FCE.Tests.Utilities).CreateOrder()
	set order1.ATM.Branch = branch
	set payment1 = ##class(FCE.Operations.ATM).CreatePayment("Cash")
	set status = ##class(FCE.Operations.ATM).ProcessOrder(order1, payment1, , .message1)
	do $$$AssertStatusOK(status, "Order #1 processed and saved")
	do $$$AssertNotEquals(message1, "", "Message returned")
	do $$$AssertEquals(order1.Status, "Completed", "Order #1 completed")
	set euros = order1.ATM.CurrencyBalances.GetAt("EUR")
	set dollars = order1.ATM.CurrencyBalances.GetAt("USD")
	do $$$AssertEquals(dollars, 150, "Incoming Currency updated in ATM")
	do $$$AssertEquals(euros, 155, "Outgoing Currency updated in ATM")

	// create account for order #2
	set account = ##class(FCE.Tests.Utilities).CreateAccount()
	
	// create order #2
	set order2 = ##class(FCE.Tests.Utilities).CreateOrder()
	set order2.ATM.Branch = branch
	set payment2 = ##class(FCE.Operations.ATM).CreatePayment("Account")
	set order2.AmountIn = 1100 // change incoming amount so it's greater than account balance
	set order2.CurrencyIn = "RUB" // change incoming currency so it doesn't match account
	set status = ##class(FCE.Operations.ATM).ProcessOrder(order2, payment2, account, .message2)
	do $$$AssertStatusOK(status, "Order #2 processed and saved")
	do $$$AssertEquals(message2, "", "Message not returned")
	do $$$AssertEquals(order2.Status, "Rejected", "Order #2 rejected-insufficient funds in account")
	do $$$AssertNotEquals(account.Balance, 900, "Account payment not completed")
	set order2.AmountIn = 100 // change incoming amount back
	set status = ##class(FCE.Operations.ATM).ProcessOrder(order2, payment2, account, .message2)
	do $$$AssertStatusOK(status, "Order #2 processed and saved")
	do $$$AssertEquals(message2, "", "Message not returned")
	do $$$AssertEquals(order2.Status, "Rejected", "Order #2 rejected-account has wrong currency")
	do $$$AssertNotEquals(account.Balance, 900, "Account payment not completed")
	set order2.CurrencyIn = "USD" // correct incoming currency
	set status = ##class(FCE.Operations.ATM).ProcessOrder(order2, payment2, account, .message2)
	do $$$AssertStatusOK(status, "Order #2 processed and saved")
	do $$$AssertEquals(order2.Status, "Completed", "Order #2 completed")
	do $$$AssertNotEquals(message2, "", "Message returned")
	do $$$AssertEquals(account.Balance, 900, "Account payment completed")
	set euros = order2.ATM.CurrencyBalances.GetAt("EUR")
	set dollars = order2.ATM.Branch.CurrencyBalances.GetAt("USD")
	do $$$AssertEquals(dollars, 100, "Incoming Currency updated in Branch")
	do $$$AssertEquals(euros, 155, "Outgoing Currency updated in ATM")

	// create order #3
	set order3 = ##class(FCE.Tests.Utilities).CreateOrder()
	set order3.ATM.Branch = branch
	set payment3 = ##class(FCE.Operations.ATM).CreatePayment("Credit Card","Visa","1234-4444-3333-2222",($h + 1095))
	set status = ##class(FCE.Operations.ATM).ProcessOrder(order3, payment3, , .message3)
	do $$$AssertStatusOK(status, "Order #3 processed and saved")
	do $$$AssertEquals(order3.Status, "Completed", "Order #3 completed")
	do $$$AssertNotEquals(message3, "", "Message returned")
	set euros = order3.ATM.CurrencyBalances.GetAt("EUR")
	do $$$AssertEquals(euros, 155, "Outgoing Currency updated in ATM")

	// create order #4 to test rollback
	set order4 = ##class(FCE.Tests.Utilities).CreateOrder()
	set order4.AmountOut = 10000
	set order4.ATM.Branch = branch
	set payment4 = ##class(FCE.Operations.ATM).CreatePayment("Credit Card","Visa","1234-4444-3333-2222",($h + 1095))
	set status = ##class(FCE.Operations.ATM).ProcessOrder(order4, payment4, , .message4)
	set paymentID = payment4.%Id()
	do $$$AssertNotEquals(paymentID, "", "Order #4 Payment saved")
	do $$$AssertStatusNotOK(status, "Order #4 processed and saved, but has a problem")
	do $$$AssertEquals(order4.Status, "Problem", "Order #4's Status=Problem")
	do $$$AssertEquals(message4, "", "Message not returned")
	&sql(select verificationID from FCE.Payment where ID = :paymentID)
	do $$$AssertEquals(SQLCODE, 100, "Rollback deleted order #4 saved payment")

	// delete orders and payments
	set status = ##class(FCE.CurrencyOrder).%DeleteId(order1.%Id())
	do $$$AssertStatusOK(status, "Order #1 deleted")
	set status = ##class(FCE.CurrencyOrder).%DeleteId(order2.%Id())	
	do $$$AssertStatusOK(status, "Order #2 deleted")
	set status = ##class(FCE.CurrencyOrder).%DeleteId(order3.%Id())	
	do $$$AssertStatusOK(status, "Order #3 deleted")
	set status = ##class(FCE.CurrencyOrder).%DeleteId(order4.%Id())	
	do $$$AssertStatusOK(status, "Order #4 deleted")
	// delete account
	set status = ##class(FCE.AccountHolder).%DeleteId(account.%Id())	
	do $$$AssertStatusOK(status, "Account deleted")
	
	// delete Branch and ATM
	do ##class(FCE.Branch).%DeleteId(branch.%Id())
}

/// test unified trigger FCE.CurrencyOrder.UpdateDeleteInNotes for updates and deletes
Method TestCOTrigger()
{
	// create branch
	set branch = ##class(FCE.Branch).%New()
	set phone = "999-999-0000", branch.Phone = phone
	set status = branch.%Save()

	// create ATM and order
	set ATM = ##class(FCE.ATM).%New()
	set ATM.SerialNumber = "a111"
	do ATM.CurrencyBalances.SetAt(250, "EUR")
	do ATM.CurrencyBalances.SetAt(50, "USD")
	set order = ##class(FCE.CurrencyOrder).%New()
	set order.CurrencyOut = "EUR"
	set order.AmountOut = 95
	set order.CurrencyIn = "USD"
	set order.AmountIn = 100
	set order.Requestor = "Smith,John"
	set order.RequestorEmail = "Smith@abcd.com"
	set order.ATM = ATM
	set order.ATM.Branch = branch
	set status = order.%Save()
	do $$$AssertStatusOK(status, "Order saved")
		
	set order.Fee = 50
	set status = order.%Save()
	do $$$AssertStatusOK(status, "Fee changed, Order saved")
	
	set atmNotes = order.ATM.Notes
	set length1 = atmNotes.Size
	do $$$AssertTrue(length1 > 0, "ATM Notes got longer")
	set found = atmNotes.FindAt(1, "updated")
	do $$$AssertTrue((found '= -1), "ATM notes contain an ""update"" entry")
	
	// delete order
	set orderID = order.%Id()
	&sql(delete fce.currencyorder where ID = :orderID)
	do $$$AssertEquals(SQLCODE, 0, "Order deleted")

	set length2 = atmNotes.Size
	do $$$AssertTrue(length2 > length1, "ATM Notes got longer again")
	set found = atmNotes.FindAt(1, "deleted")
	do $$$AssertTrue((found '= -1), "ATM notes contain a ""delete"" entry")

	// delete Branch and ATM
	do ##class(FCE.Branch).%DeleteId(branch.%Id())
}

}
