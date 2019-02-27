Class Dev.Utilities
{

/// Reset all storage definitions for a package
ClassMethod ResetStorage(package As %String)
{
	if ($get(package) = "") {
		write !, "Please supply package or sub-package name as argument." return }
	#dim resultSet as %ResultSet
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
		#dim class as %Dictionary.ClassDefinition
		set class = ##class(%Dictionary.ClassDefinition).%OpenId(className)
		write !, className
		do class.Storages.Clear()
		do class.%Save()
	}
	do resultSet.Close()
	write !, "Compiling classes..."
	do $system.OBJ.CompilePackage(package,"k")
}

/// Remove all Population code from classes (call with commit=1 to actually save/recompile the classes)
ClassMethod RemovePopulation(package As %String, commit As %Boolean = 0) As %Status
{
	if ($get(package) = "") {
		write !, "Please supply package or sub-package name as argument." return $$$OK }
	if commit {
		read !, "Changes will be saved and classes recompiled. Continue? No=>", cont
		return:($case($extract(cont), "Y":0, "y":0, :1)) $$$OK
	} 
	
	set status = $$$OK
	
	&sql(declare rempop cursor for
		 select parent, name from %Dictionary.PropertyDefinition
		 where parent %STARTSWITH :package and parameters like '%POPSPEC%'
		 union
		 select name, null from %Dictionary.ClassDefinition
		 where name %STARTSWITH :package and super like '%Populate%'
		 order by parent)
	&sql(open rempop)
	for {
		&sql(fetch rempop into :classname, :propertyname)
		quit:(SQLCODE '= 0)
		write !, classname, ?20, propertyname
		
		// process superclass list (extends)
		#dim class as %Dictionary.ClassDefinition
		set class = ##class(%Dictionary.ClassDefinition).%OpenId(classname)
		set classes(classname) = ""
		set super = class.Super
		if (super [ "%Populate") || (super [ "%Library.Populate") {
			set superList = $listfromstring(super, ",")
			set loc1 = $listfind(superList, "%Populate")
			set loc2 = $listfind(superList, "%Library.Populate")
			set j = 1, superNew = ""
			for i=1:1:$listlength(superList) {
				if (i = loc1) || (i = loc2) {  } // skip, do nothing
				else {
					set $piece(superNew, ",", j) = $list(superList, i)
					set j = j + 1
				}
			}
			write ?40, superNew
			if 'class.SuperIsModified() { set class.Super = superNew }
		}
		
		// process POPSPEC
		if propertyname '= "" {
			#dim property as %Dictionary.PropertyDefinition
			set property = ##class(%Dictionary.PropertyDefinition).IDKEYOpen(classname,propertyname)
			do property.Parameters.RemoveAt("POPSPEC") 
		}
		
		// save changes or not?
		if commit {
			set stClass = class.%Save()
			set stProp = property.%Save()
		}			
	}
	&sql(close rempop)
	
	// comment in if really ready to recompile classes
	/* if commit { do $system.OBJ.Compile(.classes, "ck") }
	else { write ! zw classes } */
	write ! zw classes
	quit status
}

/// Load Person classes (exercise B-1), and update classes programatically using %Dictionary package
ClassMethod LoadConfigPerson(directory As %String = "c:\Development\Studio\PersonOnly.xml")
{
	set st = $system.OBJ.Load(directory, "ck")
	quit:$$$ISERR(st)
	#dim classEmployee, classAccountHolder, classCurrencyOrder as %Dictionary.ClassDefinition
	set classEmployee = ##class(%Dictionary.ClassDefinition).%OpenId("FCE.Employee")
	set classAccountHolder = ##class(%Dictionary.ClassDefinition).%OpenId("FCE.AccountHolder")
	set classCurrencyOrder = ##class(%Dictionary.ClassDefinition).%OpenId("FCE.CurrencyOrder")
	#dim propEmptoCO as %Dictionary.PropertyDefinition
	set propEmptoCO = ##class(%Dictionary.PropertyDefinition).%New()
	set propEmptoCO.Name = "ApprovedOrders",
	    propEmptoCO.Type = "FCE.CurrencyOrder",
	    propEmptoCO.Relationship = 1,
	    propEmptoCO.Cardinality = "many",
	    propEmptoCO.Inverse = "Employee",
	    propEmptoCO.Description = "Exchanges that this employee approved"
	#dim propAccttoCO as %Dictionary.PropertyDefinition
	set propAccttoCO = ##class(%Dictionary.PropertyDefinition).%New()
	set propAccttoCO.Name = "CurrencyOrders",
	    propAccttoCO.Type = "FCE.CurrencyOrder",
	    propAccttoCO.Relationship = 1,
	    propAccttoCO.Cardinality = "many",
	    propAccttoCO.Inverse = "AccountHolder",
	    propAccttoCO.Description = "Exchanges that this customer made"
	set propEmptoCO.parent = classEmployee
	set propAccttoCO.parent = classAccountHolder
	
	#dim propCOtoEmp as %Dictionary.PropertyDefinition
	set propCOtoEmp = ##class(%Dictionary.PropertyDefinition).%New()
	set propCOtoEmp.Name = "Employee",
	    propCOtoEmp.Type = "FCE.Employee",
	    propCOtoEmp.Relationship = 1,
	    propCOtoEmp.Cardinality = "one",
	    propCOtoEmp.Inverse = "ApprovedOrders"
	#dim propCOtoAcct as %Dictionary.PropertyDefinition
	set propCOtoAcct = ##class(%Dictionary.PropertyDefinition).%New()
	set propCOtoAcct.Name = "AccountHolder",
	    propCOtoAcct.Type = "FCE.AccountHolder",
	    propCOtoAcct.Relationship = 1,
	    propCOtoAcct.Cardinality = "one",
	    propCOtoAcct.Inverse = "CurrencyOrders"
	set propCOtoEmp.parent = classCurrencyOrder
	set propCOtoAcct.parent = classCurrencyOrder
	
	#dim indexEmp, indexAcct as %Dictionary.IndexDefinition
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
