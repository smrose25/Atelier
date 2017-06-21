/// Tests for AccountHolders and Employees
Class FCE.Tests.PersonTests Extends FCE.Tests.TestCase
{

/// Basic tests for FCE.AccountHolder
Method TestAccountHolder()
{
	// assertion 1
	set accountHolder = ##class(FCE.AccountHolder).%New()
	do $$$AssertTrue($isobject(accountHolder), "Create new account holder")
	// assertion 2
	set status = accountHolder.%Save()
	do $$$AssertStatusNotOK(status, "Name is required")
	set accountHolder.Name = "Smith,John"
	// assertion 3
	set status = accountHolder.%Save()
	do $$$AssertStatusNotOK(status, "Email is required")
	set accountHolder.Email = "Smith@zzz.com"
	// assertion 4
	set status = accountHolder.%Save()
	do $$$AssertStatusNotOK(status, "Home/work address is required")
	set accountHolder.Home.Street = "10 High St."
	set accountHolder.Home.City = "Cambridge"
	set accountHolder.Home.State = "MA"
	set accountHolder.Home.Zip = "02142"
	set work = accountHolder.Home.%ConstructClone()
	set accountHolder.Work = work
	// assertion 5
	set accountHolder.DOB = $zdh("01/01/2100")
	set status = accountHolder.%Save()
	do $$$AssertStatusNotOK(status, "DOB must be in past")
	set accountHolder.DOB = $zdh("01/01/1980")
	// assertion 6
	set accountHolder.Currency = "DKK"
	set status = accountHolder.%Save()
	do $$$AssertStatusNotOK(status, "Invalid currency type")
	set accountHolder.Currency = "INR"
	// assertion 7
	set accountHolder.Balance = -5
	set status = accountHolder.%Save()
	do $$$AssertStatusNotOK(status, "Balance must be >= 0")
	set accountHolder.Balance = 1000
	// assertion 8
	set status = accountHolder.%Save()
	do $$$AssertStatusOK(status, "New account holder saved")
	// assertion 9
	set status = ##class(FCE.AccountHolder).%DeleteId(accountHolder.%Id())
	do $$$AssertStatusOK(status, "New account holder deleted")
}

/// SQL tests for FCE.AccountHolder
Method TestAccountHolderSQL()
{
	&sql(insert into FCE.AccountHolder (Name) values ('Smith,John'))
	do $$$AssertNotEquals(SQLCODE, 0, "Email is required")
	&sql(insert into FCE.AccountHolder (Name, Email)
	     values ('Smith,John', 'Smith@zzz.com'))
	do $$$AssertNotEquals(SQLCODE, 0, "Home/work addresses required")
	&sql(insert into FCE.AccountHolder (Name, Email, DOB,
		 Home_Street, Home_City, Home_State, Home_Zip,
		 Work_Street, Work_City, Work_State, Work_Zip)
		 values ('Smith,John', 'Smith@zzz.com', {d '2100-01-01'},
		 '10 High St.', 'Cambridge', 'MA', '02142',
		 '10 High St.', 'Cambridge', 'MA', '02142'))
	do $$$AssertNotEquals(SQLCODE, 0, "DOB must be in past")
	&sql(insert into FCE.AccountHolder (Name, Email, DOB, Currency,
		 Home_Street, Home_City, Home_State, Home_Zip,
		 Work_Street, Work_City, Work_State, Work_Zip)
		 values ('Smith,John', 'Smith@zzz.com', {d '1980-01-01'}, 'DKK',
		 '10 High St.', 'Cambridge', 'MA', '02142',
		 '10 High St.', 'Cambridge', 'MA', '02142'))
	do $$$AssertNotEquals(SQLCODE, 0, "Invalid currency type")
	&sql(insert into FCE.AccountHolder (Name, Email, DOB, Currency, Balance,
		 Home_Street, Home_City, Home_State, Home_Zip,
		 Work_Street, Work_City, Work_State, Work_Zip)
		 values ('Smith,John', 'Smith@zzz.com', {d '1980-01-01'}, 'INR', -5,
		 '10 High St.', 'Cambridge', 'MA', '02142',
		 '10 High St.', 'Cambridge', 'MA', '02142'))
	do $$$AssertNotEquals(SQLCODE, 0, "Balance must be >= 0")
	&sql(insert into FCE.AccountHolder (Name, Email, DOB, Currency, Balance,
		 Home_Street, Home_City, Home_State, Home_Zip,
		 Work_Street, Work_City, Work_State, Work_Zip)
		 values ('Smith,John', 'Smith@zzz.com', {d '1980-01-01'}, 'INR', 100,
		 '10 High St.', 'Cambridge', 'MA', '02142',
		 '10 High St.', 'Cambridge', 'MA', '02142'))
	do $$$AssertEquals(SQLCODE, 0, "New account holder saved:")
	&sql(delete from FCE.AccountHolder where ID = :%ROWID)
	do $$$AssertEquals(SQLCODE, 0, "New account holder deleted")
}

/// Basic tests for FCE.Employee
Method TestEmployee()
{
	// assertion 1
	set employee = ##class(FCE.Employee).%New()
	do $$$AssertTrue($isobject(employee), "Create new employee")
	// assertion 2
	set status = employee.%Save()
	do $$$AssertStatusNotOK(status, "Name is required")
	set employee.Name = "Smith,John"
	// assertion 3
	set status = employee.%Save()
	do $$$AssertStatusNotOK(status, "Home/work address is required")
	set employee.Home.Street = "10 High St."
	set employee.Home.City = "Cambridge"
	set employee.Home.State = "MA"
	set employee.Home.Zip = "02142"
	set work = employee.Home.%ConstructClone()
	set employee.Work = work
	// assertion 4
	set status = employee.%Save()
	do $$$AssertStatusNotOK(status, "Email is required")
	set employee.Email = "Smith@zzz.com"
	// assertion 5
	set status = employee.%Save()
	do $$$AssertStatusNotOK(status, "Email must end with @fcxbank.com")
	set employee.Email = "Smith@fcxbank.com"
	// assertion 6
	set employee.DOB = $zdh("01/01/2100")
	set status = employee.%Save()
	do $$$AssertStatusNotOK(status, "DOB must be in past")
	set employee.DOB = $zdh("01/01/1980")
	// assertion 7
	set status = employee.%Save()
	do $$$AssertStatusOK(status, "New employee saved")
	// assertion 8
	set status = ##class(FCE.Employee).%DeleteId(employee.%Id())
	do $$$AssertStatusOK(status, "New employee deleted")
}

/// SQL tests for FCE.Employee
Method TestEmployeeSQL()
{
	&sql(insert into FCE.Employee (Name) values ('Smith,John'))
	do $$$AssertNotEquals(SQLCODE, 0, "Email is required")
	&sql(insert into FCE.Employee (Name, Email)
	     values ('Smith,John', 'Smith@zzz.com'))
	do $$$AssertNotEquals(SQLCODE, 0, "Email must end with @fcxbank.com")
	&sql(insert into FCE.Employee (Name, Email)
	     values ('Smith,John', 'Smith@fcxbank.com'))
	do $$$AssertNotEquals(SQLCODE, 0, "Home/work addresses required")
	&sql(insert into FCE.Employee (Name, Email, DOB,
		 Home_Street, Home_City, Home_State, Home_Zip,
		 Work_Street, Work_City, Work_State, Work_Zip)
		 values ('Smith,John', 'Smith@fcxbank.com', {d '2100-01-01'},
		 '10 High St.', 'Cambridge', 'MA', '02142',
		 '10 High St.', 'Cambridge', 'MA', '02142'))
	do $$$AssertNotEquals(SQLCODE, 0, "DOB must be in past")
	&sql(insert into FCE.Employee (Name, Email, DOB,
		 Home_Street, Home_City, Home_State, Home_Zip,
		 Work_Street, Work_City, Work_State, Work_Zip)
		 values ('Smith,John', 'Smith@fcxbank.com', {d '1980-01-01'},
		 '10 High St.', 'Cambridge', 'MA', '02142',
		 '10 High St.', 'Cambridge', 'MA', '02142'))
	do $$$AssertEquals(SQLCODE, 0, "New employee saved")
	&sql(delete from FCE.Employee where ID = :%ROWID)
	do $$$AssertEquals(SQLCODE, 0, "New employee deleted")
}

}
