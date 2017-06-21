/// Employees that might approve exchanges
Class FCE.Employee Extends FCE.PersistentPerson
{

/// Exchanges that this employee approved
Relationship ApprovedOrders As FCE.CurrencyOrder [ Cardinality = many, Inverse = Employee ];

Property Email As %String(PATTERN = ".e1""@fcxbank.com""", POPSPEC = "String(5)_""@fcxbank.com""") [ Required ];

Storage Default
{
<Data name="EmployeeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Email</Value>
</Value>
<Value name="4">
<Value>DOB</Value>
</Value>
<Value name="5">
<Value>Home</Value>
</Value>
<Value name="6">
<Value>Work</Value>
</Value>
</Data>
<DataLocation>^FCE.EmployeeD</DataLocation>
<DefaultData>EmployeeDefaultData</DefaultData>
<ExtentSize>15</ExtentSize>
<IdLocation>^FCE.EmployeeD</IdLocation>
<IndexLocation>^FCE.EmployeeI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>1.53</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="DOB">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>6.6667%</Selectivity>
</Property>
<Property name="Email">
<AverageFieldSize>17</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Home">
<AverageFieldSize>37.73,City:7.2,Street:18.07</AverageFieldSize>
<Selectivity>6.6667%,City:8.3333%,Street:6.6667%</Selectivity>
</Property>
<Property name="Name">
<AverageFieldSize>17.6</AverageFieldSize>
<Selectivity>6.6667%</Selectivity>
</Property>
<Property name="PrintName">
<AverageFieldSize>17.6</AverageFieldSize>
<Selectivity>6.6667%</Selectivity>
</Property>
<Property name="Work">
<AverageFieldSize>36.8,City:7,Street:17.67</AverageFieldSize>
<Selectivity>6.6667%,City:9.0909%,Street:6.6667%</Selectivity>
</Property>
<SQLMap name="EmailIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="NameIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^FCE.EmployeeS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
