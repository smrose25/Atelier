/// Tests for all Payments
Class FCE.Tests.PaymentTests Extends FCE.Tests.TestCase
{

/// OREF of an order that all the tests use
Property Order As FCE.CurrencyOrder;

Method OnAfterAllTests() As %Status
{
	set id = ..Order.%Id()
	&sql(delete from FCE.CurrencyOrder where ID = :id)
	&sql(delete from FCE.AccountHolder where Name = 'Smith,John')
	&sql(delete from FCE.Branch where Phone = '999-999-0000')
	set ..Order = ""
	return $$$OK
}

Method OnBeforeAllTests() As %Status
{
	// create branch
	set branch = ##class(FCE.Branch).%New()
	set phone = "999-999-0000", branch.Phone = phone
	set status = branch.%Save()

	set order = ##class(FCE.Tests.Utilities).CreateOrder()
	set order.ATM.Branch = branch
	set status = order.%Save()
	set ..Order = order
	return $$$OK
}

Method OnBeforeOneTest() As %Status
{
	do ..Order.ATM.CurrencyBalances.SetAt(250, "EUR") // reset
	return $$$OK
}

/// Basic tests for FCE.Cash
Method TestCashPayment()
{
	set order = ..Order
	set cashPayment = ##class(FCE.Cash).%New()
	do $$$AssertTrue($isobject(cashPayment), "Create new cash payment")
	set order.Payment = cashPayment 
	set status = cashPayment.Process(order, .cashPaymentMessage)
	do $$$AssertNotEquals(cashPayment.%Id(), "", "New cash payment saved by Process() method")
	do $$$AssertNotEquals(cashPaymentMessage, "", "Message Generated: """ _ cashPaymentMessage _ """")
	set status = order.%Save()
	do $$$AssertStatusOK(status, "Order saved")
	set status = ##class(FCE.Cash).%DeleteId(cashPayment.%Id())
	do $$$AssertStatusNotOK(status, "Foreign key constraint prevents cash payment deletion")
	set order.Payment = ""
	set status = order.%Save()
	do $$$AssertStatusOK(status, "Payment removed from order")
	set status = ##class(FCE.Cash).%DeleteId(cashPayment.%Id())
	do $$$AssertStatusOK(status, "New cash payment deleted")
}

/// Basic tests for FCE.CreditCard
Method TestCCPayment()
{
	set order = ..Order
	set CCPayment = ##class(FCE.CreditCard).%New()
	do $$$AssertTrue($isobject(CCPayment), "Create new credit card payment")
	set CCPayment.Type = "XYZ"
	set status = CCPayment.%ValidateObject()
	do $$$AssertStatusNotOK(status, "Type must be Visa,MC,etc.")
	set CCPayment.Type = "Visa"
	set CCPayment.Number = "1234"
	set status = CCPayment.%ValidateObject()
	do $$$AssertStatusNotOK(status, "Number must match pattern")
	set CCPayment.Number = "1234-1234-1234-1234"
	set status = CCPayment.%ValidateObject()
	do $$$AssertStatusOK(status, "New credit card payment valid")
	set order.Payment = CCPayment
	set status = CCPayment.Process(order, .CCPaymentMessage)
	do $$$AssertNotEquals(CCPayment.%Id(), "", "New credit card payment saved by Process() method")
	do $$$AssertNotEquals(CCPaymentMessage, "", "Message Generated: """ _ CCPaymentMessage _ """")
	set status = order.%Save()
	do $$$AssertStatusOK(status, "Order saved")
	set status = ##class(FCE.CreditCard).%DeleteId(CCPayment.%Id())
	do $$$AssertStatusNotOK(status, "Foreign key constraint prevents credit card payment deletion")
	set order.Payment = ""
	set status = order.%Save()
	do $$$AssertStatusOK(status, "Payment removed from order")
	set status = ##class(FCE.CreditCard).%DeleteId(CCPayment.%Id())
	do $$$AssertStatusOK(status, "New credit card payment deleted")
}

/// Basic tests for FCE.AccountPayment
Method TestAccountPayment()
{
	set order = ..Order
	set accountPayment = ##class(FCE.AccountPayment).%New()
	do $$$AssertTrue($isobject(accountPayment), "Create new account payment")
	set order.Payment =  accountPayment
	set accountHolder = ##class(FCE.Tests.Utilities).CreateAccount()
	set order.AccountHolder = accountHolder
	set status = accountPayment.Process(order, .accountPaymentMessage)
	do $$$AssertNotEquals(accountPayment.%Id(), "", "New account payment saved by Process() method")
	do $$$AssertNotEquals(accountPaymentMessage, "", "Message Generated: """ _ accountPaymentMessage _ """")
	set status = order.%Save()
	do $$$AssertStatusOK(status, "Order saved")
	set status = ##class(FCE.AccountPayment).%DeleteId(accountPayment.%Id())
	do $$$AssertStatusNotOK(status, "Foreign key constraint prevents account payment deletion")
	set order.Payment = ""
	set status = order.%Save()
	do $$$AssertStatusOK(status, "Payment removed from order")
	set status = ##class(FCE.AccountPayment).%DeleteId(accountPayment.%Id())
	do $$$AssertStatusOK(status, "New account payment deleted")
}

}
