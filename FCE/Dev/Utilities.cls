Class Dev.Utilities
{

/// Reset all storage definitions for a package
ClassMethod ResetStorage(package As %String)
{
	if ($get(package) = "") {
		write !, "Please supply package or sub-package name as argument." return }
	set resultSet = ##class(%ResultSet).%New()
	set resultSet.ClassName = "%Dictionary.ClassDefinition"
	set resultSet.QueryName = "FormWizard"
	// returns names of persistent classes
	do resultSet.%Execute("persistent")
	write !, "Clearing storage definitions for classes:"
	set pattern = "1""" _ package _ """.e"
	while resultSet.%Next() {
		set className = resultSet.%GetData(1)
		continue:(className'?@pattern)
		set class = ##class(%Dictionary.ClassDefinition).%OpenId(className)
		write !, className
		do class.Storages.Clear()
		do class.%Save()
	}
	do resultSet.%Close()
	write !, "Compiling classes..."
	do $system.OBJ.CompilePackage(package,"k")
}

/// Load Person classes (exercise B-1), and update classes programatically using %Dictionary package
ClassMethod LoadConfigPerson(directory As %String = "c:\Foundations\PersonOnly.xml")
{
	set st = $system.OBJ.Load(directory, "ck")
	quit:$$$ISERR(st)
	set classEmployee = ##class(%Dictionary.ClassDefinition).%OpenId("FCE.Employee")
	set classAccountHolder = ##class(%Dictionary.ClassDefinition).%OpenId("FCE.AccountHolder")
	set classCurrencyOrder = ##class(%Dictionary.ClassDefinition).%OpenId("FCE.CurrencyOrder")
	set propEmptoCO = ##class(%Dictionary.PropertyDefinition).%New()
	set propEmptoCO.Name = "ApprovedOrders",
	    propEmptoCO.Type = "FCE.CurrencyOrder",
	    propEmptoCO.Relationship = 1,
	    propEmptoCO.Cardinality = "many",
	    propEmptoCO.Inverse = "Employee",
	    propEmptoCO.Description = "Exchanges that this employee approved"
	set propAccttoCO = ##class(%Dictionary.PropertyDefinition).%New()
	set propAccttoCO.Name = "CurrencyOrders",
	    propAccttoCO.Type = "FCE.CurrencyOrder",
	    propAccttoCO.Relationship = 1,
	    propAccttoCO.Cardinality = "many",
	    propAccttoCO.Inverse = "AccountHolder",
	    propAccttoCO.Description = "Exchanges that this customer made"
	set propEmptoCO.parent = classEmployee
	set propAccttoCO.parent = classAccountHolder
	
	set propCOtoEmp = ##class(%Dictionary.PropertyDefinition).%New()
	set propCOtoEmp.Name = "Employee",
	    propCOtoEmp.Type = "FCE.Employee",
	    propCOtoEmp.Relationship = 1,
	    propCOtoEmp.Cardinality = "one",
	    propCOtoEmp.Inverse = "ApprovedOrders"
	set propCOtoAcct = ##class(%Dictionary.PropertyDefinition).%New()
	set propCOtoAcct.Name = "AccountHolder",
	    propCOtoAcct.Type = "FCE.AccountHolder",
	    propCOtoAcct.Relationship = 1,
	    propCOtoAcct.Cardinality = "one",
	    propCOtoAcct.Inverse = "CurrencyOrders"
	set propCOtoEmp.parent = classCurrencyOrder
	set propCOtoAcct.parent = classCurrencyOrder
	
	set indexEmp = ##class(%Dictionary.IndexDefinition).%New()
	set indexEmp.Name = "EmployeeIndex", indexEmp.Properties = "Employee"
	set indexEmp.parent = classCurrencyOrder
	set indexAcct = ##class(%Dictionary.IndexDefinition).%New()
	set indexAcct.Name = "AccountHolderIndex", indexAcct.Properties = "AccountHolder"
	set indexAcct.parent = classCurrencyOrder
	
	do classEmployee.%Save(), classAccountHolder.%Save(), classCurrencyOrder.%Save()
	
	set compileList = "FCE.Employee.cls,FCE.AccountHolder.cls,FCE.CurrencyOrder.cls"
	do $system.OBJ.CompileList(compileList, "ck")
}

}
