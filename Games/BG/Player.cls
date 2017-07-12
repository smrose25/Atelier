Class BG.Player extends %Persistent 
{
Property Name As %String;

Index NameIndex on Name [Unique];

classMethod InsertPlayer(name as %String) As %Status
{
	set player = ##class(Player).%New()
	set player.Name = name
	return player.%Save()
}

ClassMethod GetPlayersArray(Output st as %Status) As %DynamicArray
{
	set arr = []

	set rs = ##class(%ResultSet).%New()
	set rs.ClassName = "BG.Player"
	set rs.QueryName = "PlayersByName"
	
	set st = rs.%Execute()
	
	if st = $$$OK {
		while rs.%Next() {
			do arr.%Push(rs.Name)
		}
	}
	
	return arr
}

Query PlayersByName() As %SQLQuery [SqlProc]
{
Select Name
from Player
order by Name
}

Storage Default
{
<Data name="PlayerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
</Data>
<DataLocation>^BG.PlayerD</DataLocation>
<DefaultData>PlayerDefaultData</DefaultData>
<IdLocation>^BG.PlayerD</IdLocation>
<IndexLocation>^BG.PlayerI</IndexLocation>
<StreamLocation>^BG.PlayerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}