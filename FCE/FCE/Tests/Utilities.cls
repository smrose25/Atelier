/// Utilities for development
Class FCE.Tests.Utilities [ CompileAfter = FCE.Currency ]
{

/// Delete all data and run tests
ClassMethod DestroyAll()
{
	// if there's no data in FCE.Currency run FetchRates()
	&sql(select count(*) into :count from FCE.Currency)
	do:(count '= 10) ##class(FCE.Currency).FetchRates()

	do ##class(FCE.CurrencyOrder).%KillExtent()
	do ##class(FCE.Branch).%DeleteExtent()  // also deletes FCE.ATM Notes stream data
	do ##class(FCE.RealEstate).%KillExtent()
	do ##class(FCE.AccountHolder).%KillExtent()
	do ##class(FCE.Employee).%KillExtent()
	do ##class(FCE.Payment).%KillExtent()
	read !, "Data deleted. Press <Enter> to run tests.", x
	do ##class(FCE.Tests.BasicTests).Run()
	read !, "Press <Enter> to continue.", x
	do ##class(FCE.Tests.CurrencyOrderTests).Run()
	read !, "Press <Enter> to continue.", x
	do ##class(FCE.Tests.PersonTests).Run()
	read !, "Press <Enter> to continue.", x
	do ##class(FCE.Tests.PaymentTests).Run()
	read !, "Press <Enter> to continue.", x
}

/// Create data and run tests
ClassMethod CreateAll(base As %Integer = 5)
{
	// if there's no data in FCE.Currency run FetchRates()
	&sql(select count(*) into :count from FCE.Currency)
	do:(count '= 10) ##class(FCE.Currency).FetchRates()

	do ##class(FCE.RealEstate).Populate(base * 10)
	// assigns real estate objects to new branches and ATMs
	do ##class(FCE.Branch).Populate(base)
	do ##class(FCE.ATM).Populate(base * 3)
	do ##class(FCE.AccountHolder).Populate(base * 3)
	do ##class(FCE.Employee).Populate(base * 3)
	// assigns account holders and employees to new currency orders
	do ##class(FCE.CurrencyOrder).Populate(base * 6)
	read !, "Data added. Press <Enter> to run tests.", x
	do ##class(FCE.Tests.BasicTests).Run()
	read !, "Press <Enter> to continue.", x
	do ##class(FCE.Tests.CurrencyOrderTests).Run()
	read !, "Press <Enter> to continue.", x
	do ##class(FCE.Tests.PersonTests).Run()
	read !, "Press <Enter> to continue.", x
	do ##class(FCE.Tests.PaymentTests).Run()
	read !, "Press <Enter> to continue.", x
}

/// helper method for tests
ClassMethod CreateOrder() As FCE.CurrencyOrder
{
	set currencyOut           = "EUR"
	set amountOut			  = 95
	set currencyIn            = "USD"
	set amountIn              = 100
	set ATM = ##class(FCE.ATM).%New()
	set ATM.SerialNumber = ##class(%PopulateUtils).String(5)_##class(%PopulateUtils).String(5)
	do ATM.CurrencyBalances.SetAt(250,"EUR")
	do ATM.CurrencyBalances.SetAt(50,"USD")
	set order = ##class(FCE.CurrencyOrder).%New(currencyOut,
								                amountOut,
	                                            currencyIn,
	                                            amountIn)
	set order.Requestor = "Smith,John"
	set order.RequestorEmail = "Smith@abcd.com"
	set order.ATM = ATM
	return order
}

/// helper method for tests
ClassMethod CreateAccount() As FCE.AccountHolder
{
	
	set account = ##class(FCE.AccountHolder).%New()
	set account.Name = "Smith,John"
	set account.Email = "Smith@zzz.com"
	set account.Home.Street = "10 High St."
	set account.Home.City = "Cambridge"
	set account.Home.State = "MA"
	set account.Home.Zip = "02142"
	set work = account.Home.%ConstructClone()
	set account.Work = work
	set account.DOB = $zdh("01/01/1980")
	set account.Balance = 1000
	set account.Currency = "USD"
	return account
}

}
