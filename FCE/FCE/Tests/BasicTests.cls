Class FCE.Tests.BasicTests Extends FCE.Tests.TestCase
{

/// holds the ID of a referenced FCE.RealEstate object, assigned in OnBeforeAllTests()
Property RefdRealEstateID As %Integer [ Private ];

/// holds the ID of an unreferenced FCE.RealEstate object, assigned in OnBeforeAllTests()
Property UnrefdRealEstateID As %Integer [ Private ];

/// Set up test environment
Method OnBeforeAllTests() As %Status
{
 	// create a Branch with this phone #
	set branch = ##class(FCE.Branch).%New()
	set branch.Phone = "999-999-9999"
 
 	/* create a dummy RealEstate object, link it to the Branch above
       and save the id in the "global" RefdRealEstateID property */
	set realestate = ##class(FCE.RealEstate).%New()
	set realestate.Street = "10 Main Street"
	set realestate.City = "New York"
	set realestate.State = "NY"
	set realestate.Zip = "99999"
	set status = realestate.%Save()
	set branch.Address = realestate
	set status = branch.%Save()
	set ..RefdRealEstateID = realestate.%Id()
	
	/* create a dummy RealEstate object that *isn't* referenced by a Branch
	   save the id in the "global" UnrefdRealEstateID property */
	set realestate = ##class(FCE.RealEstate).%New()
	set realestate.Street = "20 Oak Street"
	set realestate.City = "Boston"
	set realestate.State = "MA"
	set realestate.Zip = "99999"
	set status = realestate.%Save()
	set ..UnrefdRealEstateID = realestate.%Id()
 	return $$$OK
}

/// Clean up test environment
Method OnAfterAllTests() As %Status
{
	/// in case any tests fail to *complete*
	/// remove the leftover branch and the initial branch
	&sql(delete from FCE.Branch
	     where (Phone = '999-999-9999' or Phone = '999-999-0000'))
	set id1 = ..RefdRealEstateID, id2 = ..UnrefdRealEstateID
	&sql(delete from FCE.RealEstate where ID in (:id1, :id2))
	return $$$OK
}

/// Basic tests for FCE.Branch
Method TestBranch()
{
	// assertion 1
	set branch = ##class(FCE.Branch).%New()
	do $$$AssertTrue($isobject(branch),"Created New Branch")
	
	// assertion 2
	set status = branch.%Save()
	do $$$AssertStatusNotOK(status, "Phone is required")
	
	// assertion 3
	set branch.Phone = "9999999999" // bad pattern
	set status = branch.%Save()
	do $$$AssertStatusNotOK(status, "Phone doesn't match pattern: ###-###-####")

	// assertion 4
	set branch.Phone = "999-999-9999" // pre-existing number
	set status = branch.%Save()
	do $$$AssertStatusNotOK(status, "Phone must be unique")

	// assertion 5
	set branch.Phone = "999-999-0000"
	set realestateid = ..RefdRealEstateID
	set branch.Address = ##class(FCE.RealEstate).%OpenId(realestateid)
	set status = branch.%Save()
	do $$$AssertStatusNotOK(status, "Another Branch already has this address")

	// assertion 6
	set realestateid = ..UnrefdRealEstateID
	set branch.Address = ##class(FCE.RealEstate).%OpenId(realestateid)
	set branch.Opens = 18000 // open at 5am
	set status = branch.%Save()
	do $$$AssertStatusNotOK(status, "Opening at 5am too early")
	
	// assertion 7
	set branch.Opens = 28800 // open at 8am
	set branch.Closes = 82800 // close at 11pm
	set status = branch.%Save()
	do $$$AssertStatusNotOK(status, "Closing at 11pm too late")

	// assertion 8
	set branch.Closes = 64800 // close at 6pm
	set branch.NationalCurrency = "ABC" // invalid currency
	set status = branch.%Save()
	do $$$AssertStatusNotOK(status, "ABC is invalid currency")

	// assertion 9
	set branch.NationalCurrency = "USD" // valid currency
	set status = branch.%Save()
	do $$$AssertStatusOK(status, "Branch saved")

	// assertion 10
	set id = branch.%Id()
	do $$$AssertNotEquals(id, "", "ID assigned")

	// assertion 11
	set status = ##class(FCE.Branch).%DeleteId(id)
	do $$$AssertStatusOK(status, "Branch deleted")
}

/// SQL tests for FCE.Branch table
Method TestBranchSQL()
{
	set realestateid = ..UnrefdRealEstateID

	&sql(insert into FCE.Branch (Address)
	     VALUES (:realestateid))
	do $$$AssertNotEquals(SQLCODE, 0, "Phone is required")
	&sql(insert into FCE.Branch (Phone, Address)
	     VALUES ('9999999999',:realestateid))
	do $$$AssertNotEquals(SQLCODE, 0, "Phone doesn't match pattern: ###-###-####")
	&sql(insert into FCE.Branch (Phone, Address)
	     VALUES ('999-999-9999',:realestateid))
	do $$$AssertNotEquals(SQLCODE, 0, "Phone must be unique")
	&sql(insert into FCE.Branch (Phone, Address, Opens)
	     VALUES ('999-999-0000',:realestateid,18000))
	do $$$AssertNotEquals(SQLCODE, 0, "Opening at 5am too early")
	&sql(insert into FCE.Branch (Phone, Address, Opens, Closes)
	     VALUES ('999-999-0000',:realestateid,28800,82800))
	do $$$AssertNotEquals(SQLCODE, 0, "Closing at 11pm too late")
	&sql(insert into FCE.Branch (Phone, Address, Opens, Closes, NationalCurrency)
	     VALUES ('999-999-0000',:realestateid,28800,64800,'ABC'))
	do $$$AssertNotEquals(SQLCODE, 0, "ABC is invalid currency")
	&sql(insert into FCE.Branch (Phone, Address, Opens, Closes, NationalCurrency)
	     VALUES ('999-999-0000',:realestateid,28800,64800,'USD'))
	do $$$AssertEquals(SQLCODE, 0, "Branch saved")
	set branchid = %ROWID
	do $$$AssertNotEquals(branchid, "", "ID assigned")
	&sql(delete from FCE.Branch where ID = :branchid)
	do $$$AssertEquals(SQLCODE, 0, "Branch deleted")
}

/// Basic tests for FCE.ATM
Method TestATM()
{
	// assertion 1
	set branch = ##class(FCE.Branch).%New()
	set branch.Phone = "999-999-0000"
	set status = branch.%Save()
	do $$$AssertStatusOK(status, "Branch saved")
	set id = branch.%Id()
	// assertion 2
	set countOfATMs = branch.ATMs.Count()
	do $$$AssertEquals(countOfATMs, 0, "No ATMs yet")
	// assertion 3
	set ATMOne = ##class(FCE.ATM).%New()
	do $$$AssertTrue($isobject(ATMOne), "Create ATMOne")
	// assertion 4
	set status = ATMOne.%Save()
	do $$$AssertStatusNotOK(status, "ATMOne requires a branch")
	// assertion 5
	set ATMOne.Branch = branch
	set countOfATMs = branch.ATMs.Count()
	do $$$AssertEquals(countOfATMs, 1, "Branch has 1 ATM")
	// assertion 6
	set status = ATMOne.%Save()
	do $$$AssertStatusOK(status, "ATMOne saved")
	// assertion 7
	set ATMOneid = ATMOne.%Id()
	do $$$AssertNotEquals(ATMOneid, "", "ATMOne ID assigned")
	// assertion 8
	set ATMTwo = ##class(FCE.ATM).%New()
	do $$$AssertTrue($isobject(ATMTwo), "Create ATMTwo")
	// assertion 9
	do branch.ATMs.Insert(ATMTwo)
	set countOfATMs = branch.ATMs.Count()
	do $$$AssertEquals(countOfATMs, 2, "Branch has 2 ATMs")
	// assertion 10
	set status = branch.%Save()
	do $$$AssertStatusOK(status, "Branch and ATMTwo saved")
	// assertion 11
	set ATMTwoid = ATMTwo.%Id()
	do $$$AssertNotEquals(ATMTwoid, "", "ATMTwo ID assigned")
	// assertion 12
	set (branch, ATMOne, ATMTwo) = ""
	do $$$LogMessage("All objects closed")
	// assertion 13
	set ATMTwo = ##class(FCE.ATM).%OpenId(ATMTwoid)
	do $$$AssertTrue($isobject(ATMTwo), "ATMTwo retrieved")
	// assertion 14
	set branch = ATMTwo.Branch
	do $$$AssertEquals(branch.Phone, "999-999-0000", "Branch retrieved")
	// assertion 15
	set countOfATMs = branch.ATMs.Count()
	do $$$AssertEquals(countOfATMs, 2, "Branch has 2 ATMs")
	// assertion 16
	set (branch, ATMOne, ATMTwo) = ""
	do $$$LogMessage("All objects closed")
	// assertion 17
	set status = ##class(FCE.Branch).%DeleteId(id)
	do $$$AssertStatusOK(status, "Branch deleted")
	// assertion 18
	set ATMOne = ##class(FCE.ATM).%OpenId(ATMOneid)
	do $$$AssertNotTrue($isobject(ATMOne), "ATMOne deleted also")
	// assertion 19
	set ATMTwo = ##class(FCE.ATM).%OpenId(ATMTwoid)
	do $$$AssertNotTrue($isobject(ATMTwo), "ATMTwo deleted also")
}

/// SQL tests for FCE.ATM table
Method TestATMSQL()
{
	set realestateid = ..RefdRealEstateID

	&sql(insert into FCE.Branch (Phone) VALUES ('999-999-0000'))
	do $$$AssertEquals(SQLCODE, 0, "Branch saved")
	set branchid = %ROWID
	do $$$AssertNotEquals(branchid, "", "Branch ID assigned")
	&sql(insert into FCE.ATM (Address)
	     VALUES (:realestateid))
	do $$$AssertNotEquals(SQLCODE, 0, "Branch is required to save ATM")
	&sql(insert into FCE.ATM (Branch, Address)
	     VALUES (:branchid, :realestateid))
	do $$$AssertEquals(SQLCODE, 0, "ATM saved")
	set ATMid = %ROWID
	do $$$AssertNotEquals(ATMid, "", "ATM ID assigned")
	&sql(delete from FCE.Branch where ID = :branchid)
	do $$$AssertEquals(SQLCODE, 0, "Branch deleted")
	&sql(select ID into :ATMid from FCE.ATM where Branch = :branchid)
	do $$$AssertEquals(SQLCODE, 100, "ATM deleted also")
}

/// Basic tests for FCE.RealEstate
Method TestRealEstate()
{
 	// assertion 1
	set realestate = ##class(FCE.RealEstate).%New()
	set status = realestate.%Save()
	do $$$AssertStatusNotOK(status, "Real Estate requires all 4 properties")
	// assertion 2
	set realestate.Street = "10 Main St."
	set status = realestate.%Save()
	do $$$AssertStatusNotOK(status, "Real Estate requires all 4 properties")
	// assertion 3
	set realestate.City = "New York"
	set status = realestate.%Save()
	do $$$AssertStatusNotOK(status, "Real Estate requires all 4 properties")
	// assertion 4
	set realestate.State = "ny"
	set status = realestate.%Save()
	do $$$AssertStatusNotOK(status, "State must be on VALUELIST and must match case")
	// assertion 5
	set realestate.State = "NY"
	set status = realestate.%Save()
	do $$$AssertStatusNotOK(status, "Real Estate requires all 4 properties")
	// assertion 6
	set realestate.Zip = "123"
	set status = realestate.%Save()
	do $$$AssertStatusNotOK(status, "ZipCode must be ##### or #####-####")
	// assertion 7
	set realestate.Zip = "12345-1"
	set status = realestate.%Save()
	do $$$AssertStatusNotOK(status, "ZipCode must be ##### or #####-####")
	// assertion 8
	set realestate.Zip = "99999-4567"
	set status = realestate.%Save()
	set realestateid = realestate.%Id()
	do $$$AssertStatusOK(status, "Real Estate saved")
	// assertion 9
	set branch = ##class(FCE.Branch).%New()
	set branch.Phone = "999-999-0000"
	set branch.Address = realestate
	set status = branch.%Save()
	set branchid = branch.%Id()
	do $$$AssertStatusOK(status, "Branch saved")
	// assertion 10
	set (branch, realestate) = ""
	do $$$LogMessage("All objects closed")
	// assertion 11
	set branch = ##class(FCE.Branch).%OpenId(branchid)
	set realestate = ##class(FCE.RealEstate).%OpenId(realestateid)
	do $$$AssertEquals(branch.Address.City, realestate.City, "Branch references Real Estate")
	// assertion 12
	set (branch, realestate) = ""
	do $$$LogMessage("All objects closed")
	// assertion 13
	set status = ##class(FCE.RealEstate).%DeleteId(realestateid)
	do $$$AssertStatusOK(status, "Real Estate deleted")
	// assertion 14
	set realestateid = ##class(FCE.Branch).AddressGetStored(branchid)
	do $$$AssertEquals(realestateid, "", "Branch not linked to Real Estate")
	// assertion 15
	set status = ##class(FCE.Branch).%DeleteId(branchid)
	do $$$AssertStatusOK(status, "Branch deleted")
}

/// SQL tests for FCE.RealEstate table
Method TestRealEstateSQL()
{
	&sql(insert into FCE.RealEstate (Street) VALUES ('10 Main St.'))
	do $$$AssertNotEquals(SQLCODE, 0, "Real Estate requires all 4 properties")
	&sql(insert into FCE.RealEstate (Street,City) VALUES ('10 Main St.','New York'))
	do $$$AssertNotEquals(SQLCODE, 0, "Real Estate requires all 4 properties")
	&sql(insert into FCE.RealEstate (Street,City,State)
             VALUES ('10 Main St.','New York','ny'))
	do $$$AssertNotEquals(SQLCODE, 0, "State must be on VALUELIST and must match case")
	&sql(insert into FCE.RealEstate (Street,City,State)
             VALUES ('10 Main St.','New York','NY'))
	do $$$AssertNotEquals(SQLCODE, 0, "Real Estate requires all 4 properties")
	&sql(insert into FCE.RealEstate (Street,City,State,Zip) 
             VALUES ('10 Main St.','New York','NY','123'))
	do $$$AssertNotEquals(SQLCODE, 0, "ZipCode must be ##### or #####-####")
	&sql(insert into FCE.RealEstate (Street,City,State,Zip) 
             VALUES ('10 Main St.','New York','NY','12345-1'))
	do $$$AssertNotEquals(SQLCODE, 0, "ZipCode must be ##### or #####-####")
	&sql(insert into FCE.RealEstate (Street,City,State,Zip)
             VALUES ('10 Main St.','New York','NY','99999-4567'))
	do $$$AssertEquals(SQLCODE, 0, "Real Estate saved")
	set realestateid = %ROWID
	do $$$AssertNotEquals(realestateid, "", "Real Estate ID assigned")
	&sql(insert into FCE.Branch (Phone,Address) VALUES ('999-999-0000',:realestateid))
	do $$$AssertEquals(SQLCODE, 0, "Branch saved")
	set branchid = %ROWID
	&sql(select Address->City into :city from FCE.Branch where ID = :branchid)
	do $$$AssertEquals(SQLCODE, 0, "City retrieved")

	do $$$AssertEquals(city, "New York", "Branch references Real Estate")
	&sql(delete from FCE.RealEstate where ID = :realestateid)
	do $$$AssertEquals(SQLCODE, 0, "Real Estate deleted")
	&sql(select Address into :realestateid from FCE.Branch where ID = :branchid)
	do $$$AssertEquals(SQLCODE, 0, "Real Estate ID retrieved")

	do $$$AssertEquals(realestateid, "", "Branch not linked to Real Estate")
	&sql(delete from FCE.Branch where ID = :branchid)
	do $$$AssertEquals(SQLCODE, 0, "Branch deleted")
}

/// Basic tests for FCE.ATM.CurrencyBalances
Method TestCurrencies()
{
	// assertion 1
	set ATMOne = ##class(FCE.ATM).%New()
	do ATMOne.CurrencyBalances.SetAt(100000,"USD")
	set branch = ##class(FCE.Branch).%New()
	set branch.Phone = "999-999-0000"
	set ATMOne.Branch = branch
	set status = ATMOne.%Save()
	do $$$AssertStatusNotOK(status, "Currency Balance must be <= 10000")
	do ATMOne.CurrencyBalances.SetAt(1000,"USD")
	// assertion 2
	set status = ATMOne.%Save()
	set ATMOneid = ATMOne.%Id()
	do $$$AssertStatusOK(status, "ATM with Currency Balance saved")
	// assertion 3
	set count = ATMOne.CurrencyBalances.Count()
	do $$$AssertEquals(count, 1, "ATM has one Currency Balance")
	// assertion 4
	do ATMOne.CurrencyBalances.RemoveAt("US")
	set count = ATMOne.CurrencyBalances.Count()
	do $$$AssertNotEquals(count, 0, "RemoveAt() requires exact key")
	// assertion 5
	do ATMOne.CurrencyBalances.RemoveAt("USD")
	set count = ATMOne.CurrencyBalances.Count()
	do $$$AssertEquals(count, 0, "Currency Balance Removed")
	// assertion 6
	set status = ##class(FCE.Branch).%DeleteId(ATMOne.Branch.%Id())
	do $$$AssertStatusOK(status, "Branch and ATM deleted")
}

/// SQL tests for FCE.ATM.CurrencyBalances
Method TestCurrenciesSQL()
{
	set realestateid = ..RefdRealEstateID	
	
	&sql(insert into FCE.Branch (Phone) VALUES ('999-999-0000'))
	set branchid = %ROWID
	&sql(insert into FCE.ATM (Branch, Address) VALUES (:branchid, :realestateid))
	set ATMid = %ROWID
	&sql(insert into FCE.ATM_Balance (ATM, element_key, Balance)
             VALUES (:ATMid, 'USD', '100000'))
	do $$$AssertNotEquals(SQLCODE, 0, "Currency Balance must be <= 10000")
	&sql(insert into FCE.ATM_Balance (ATM, element_key, Balance)
             VALUES (:ATMid, 'USD', '10000'))
	do $$$AssertEquals(SQLCODE, 0, "ATM with Currency Balance saved")
	&sql(select count(*) into :count from FCE.ATM_Balance where ATM = :ATMid)
	do $$$AssertEquals(SQLCODE, 0, "Currency Balance count retrieved")

	do $$$AssertEquals(count, 1, "ATM has one Currency Balance")
	&sql(delete from FCE.ATM_Balance where element_key = 'USD' and ATM = :ATMid)
	do $$$AssertEquals(SQLCODE, 0, "Currency Balance removed")
	&sql(delete from FCE.Branch where ID = :branchid)
	do $$$AssertEquals(SQLCODE, 0, "Branch and ATM deleted")
}

/// test FCE.ATM.Update()
Method TestUpdateATM()
{
	// create branch and ATM
	set branch = ##class(FCE.Branch).%New()
	set ATM = ##class(FCE.ATM).%New()
	set oldEuros = 150, oldDollars = 50
	do ATM.CurrencyBalances.SetAt(oldEuros, "EUR")
	do ATM.CurrencyBalances.SetAt(oldDollars, "USD")
	set ATM.Branch = branch // must do this so that ATM is valid (Saveable) at this point
	
	set currencyOut = "EUR", amountOut   = 1000
	set currencyIn  = "USD", amountIn    = 100
	set status = ATM.Update(currencyOut, amountOut, currencyIn, amountIn)
	do $$$AssertStatusNotOK(status, $system.Status.GetErrorText(status))
	set euros = ATM.CurrencyBalances.GetAt("EUR")
	set dollars = ATM.CurrencyBalances.GetAt("USD")
	do $$$AssertEquals(euros, oldEuros, "Outgoing currency remains the same")
	do $$$AssertEquals(dollars, oldDollars, "Incoming currency remains the same")

	set amountIn  = 100000, amountOut = 100
	set status = ATM.Update(currencyOut, amountOut, currencyIn, amountIn)
	do $$$AssertStatusNotOK(status, $system.Status.GetErrorText(status))
	set euros = ATM.CurrencyBalances.GetAt("EUR")
	set dollars = ATM.CurrencyBalances.GetAt("USD")
	do $$$AssertEquals(euros, oldEuros, "Outgoing currency remains the same")
	do $$$AssertEquals(dollars, oldDollars, "Incoming currency remains the same")

	set amountIn = 100
	set status = ATM.Update(currencyOut, amountOut, currencyIn, amountIn)
	do $$$AssertStatusOK(status, "ATM updated")
	set euros = ATM.CurrencyBalances.GetAt("EUR")
	set dollars = ATM.CurrencyBalances.GetAt("USD")
	set oldEuros = oldEuros - amountOut, oldDollars = oldDollars + amountIn
	do $$$AssertEquals(euros, oldEuros, "Outgoing currency updated correctly")
	do $$$AssertEquals(dollars, oldDollars, "Incoming currency updated correctly")

	set amountOut = 20
	set status = ATM.Update(currencyOut, amountOut)
	do $$$AssertStatusOK(status, "Outgoing-only currency allowed (credit card or account payment)")
	set euros = ATM.CurrencyBalances.GetAt("EUR")
	set dollars = ATM.CurrencyBalances.GetAt("USD")
	set oldEuros = oldEuros - amountOut
	do $$$AssertEquals(euros, oldEuros, "Outgoing currency updated correctly")
	do $$$AssertEquals(dollars, oldDollars, "Incoming currency remains the same")

	set amountIn = 20
	set status = ATM.Update(,,currencyIn, amountIn)
	do $$$AssertStatusOK(status, "Incoming-only currency allowed (crediting account balance)")
	set euros = ATM.CurrencyBalances.GetAt("EUR")
	set dollars = ATM.CurrencyBalances.GetAt("USD")
	set oldDollars = oldDollars + amountIn
	do $$$AssertEquals(euros, oldEuros, "Outgoing currency remains the same")
	do $$$AssertEquals(dollars, oldDollars, "Incoming currency updated correctly")
}

/// test FCE.Branch.Update()
Method TestUpdateBranch()
{
	// create branch
	set branch = ##class(FCE.Branch).%New()
	set oldDollars = 50
	do branch.CurrencyBalances.SetAt(oldDollars,"USD")
	set currencyIn  = "USD", amountIn    = 100
	set status = branch.Update(currencyIn, amountIn)
	do $$$AssertStatusOK(status, "Branch updated")
	set dollars = branch.CurrencyBalances.GetAt("USD")
	set oldDollars = oldDollars + amountIn
	do $$$AssertEquals(dollars, oldDollars, "Incoming currency updated")
}

}
