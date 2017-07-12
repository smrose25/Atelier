Class BG.EldritchHorror.AncientOne extends %Persistent 
{
Property Name as %String;

Index NameIndex on Name [Unique];

classMethod InsertAncientOne(name as %String) As %Status
{
	set ancientOne = ##class(AncientOne).%New()
	set ancientOne.Name = name
	return ancientOne.%Save()
}

ClassMethod GetAncientOnesArray(Output st as %Status) As %DynamicArray
{
	set arr = []

	set rs = ##class(%ResultSet).%New()
	set rs.ClassName = "BG.EldritchHorror.AncientOne"
	set rs.QueryName = "AncientOnesByName"
	
	set st = rs.%Execute()
	
	if st = $$$OK {
		while rs.%Next() {
			do arr.%Push(rs.Name)
		}
	}
	
	return arr
}

Query AncientOnesByName() As %SQLQuery [SqlProc]
{
Select Name
from AncientOne
order by Name
}

Storage Default
{
<Data name="AncientOneDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
</Data>
<DataLocation>^BG.EldritchHorror.AncientOneD</DataLocation>
<DefaultData>AncientOneDefaultData</DefaultData>
<IdLocation>^BG.EldritchHorror.AncientOneD</IdLocation>
<IndexLocation>^BG.EldritchHorror.AncientOneI</IndexLocation>
<StreamLocation>^BG.EldritchHorror.AncientOneS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}