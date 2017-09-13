/// Customer with accounts
Class FCE.AccountHolder Extends FCE.PersistentPerson
{

/// Current account balance
Property Balance As %Numeric(MINVAL = 0);

/// Type of currency that this account holds
Property Currency As FCE.CurrencyName [ Required ];

/// Exchanges that this customer made
Relationship CurrencyOrders As FCE.CurrencyOrder [ Cardinality = many, Inverse = AccountHolder ];

/// Debit account balance and save account
Method Update(paymentAmount As %Numeric) As %Status
{
	set ..Balance = ..Balance - paymentAmount
	return $$$OK
}

Storage Default
{
<Data name="AccountHolderDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Balance</Value>
</Value>
<Value name="3">
<Value>Currency</Value>
</Value>
<Value name="4">
<Value>Email</Value>
</Value>
<Value name="5">
<Value>DOB</Value>
</Value>
<Value name="6">
<Value>Home</Value>
</Value>
<Value name="7">
<Value>Work</Value>
</Value>
<Value name="8">
<Value>Name</Value>
</Value>
</Data>
<DataLocation>^FCE.AccountHolderD</DataLocation>
<DefaultData>AccountHolderDefaultData</DefaultData>
<ExtentSize>15</ExtentSize>
<IdLocation>^FCE.AccountHolderD</IdLocation>
<IndexLocation>^FCE.AccountHolderI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>1.67</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Balance">
<AverageFieldSize>6.8</AverageFieldSize>
<Selectivity>6.6667%</Selectivity>
</Property>
<Property name="Currency">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>16.6667%</Selectivity>
</Property>
<Property name="DOB">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>6.6667%</Selectivity>
</Property>
<Property name="Email">
<AverageFieldSize>4.73</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Home">
<AverageFieldSize>37,City:7.27,Street:17.47</AverageFieldSize>
<Selectivity>6.6667%,City:8.3333%,Street:6.6667%</Selectivity>
</Property>
<Property name="Name">
<AverageFieldSize>16.4</AverageFieldSize>
<Selectivity>6.6667%</Selectivity>
</Property>
<Property name="PrintName">
<AverageFieldSize>16.4</AverageFieldSize>
<Selectivity>6.6667%</Selectivity>
</Property>
<Property name="Work">
<AverageFieldSize>36.53,City:8,Street:16.13</AverageFieldSize>
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
<StreamLocation>^FCE.AccountHolderS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
