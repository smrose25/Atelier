Class BG.Game extends %Persistent 
{
Property Title As %String(MAXLEN=256);

Index TitleIndex on Title [Unique ];

Property Cooperative As %Boolean;


classMethod InsertGame(title as %String, coop as %Boolean) As %Status
{
	set game = ##class(BG.Game).%New()
	set game.Title = title
	set game.Cooperative = coop
	
	return game.%Save()
}

ClassMethod GetGamesArray(Output st as %Status) As %DynamicArray
{
	set arr = []

	set rs = ##class(%ResultSet).%New()
	set rs.ClassName = "BG.Game"
	set rs.QueryName = "GamesByTitle"
	
	set st = rs.%Execute()
	
	if st = $$$OK {
		while rs.%Next() {
			set obj = {}
			set obj.title = rs.Title
			set obj.coop = rs.Cooperative
			do arr.%Push(obj)
		}
	}
	
	return arr
}

Query GamesByTitle() As %SQLQuery [SqlProc]
{
Select Title, Cooperative
from Game
order by Title
}


Storage Default
{
<Data name="GameDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Title</Value>
</Value>
<Value name="3">
<Value>Cooperative</Value>
</Value>
</Data>
<DataLocation>^BG.GameD</DataLocation>
<DefaultData>GameDefaultData</DefaultData>
<IdLocation>^BG.GameD</IdLocation>
<IndexLocation>^BG.GameI</IndexLocation>
<StreamLocation>^BG.GameS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}