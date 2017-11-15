Class BG.SessionPlayer Extends %Persistent
{

Property Session As BG.Session;

Index SessionIndex On Session;

Property Player As BG.Player;

Index PlayerIndex On Player;

ClassMethod InsertSessionPlayer(sessionId, name) As %Status
{
	set player = ##class(BG.SessionPlayer).%New()
	
	set player.Player = ##class(BG.Player).NameIndexOpen(name)
	
	set player.Session = ##class(BG.Session).%OpenId(sessionId)
	
	set st = player.%Save()
	
	return st
}

ClassMethod GetPlayersArray(id As %String, Output st As %Status) As %DynamicArray
{
	set arr = []

	set rs = ##class(%ResultSet).%New()
	set rs.ClassName = "BG.SessionPlayer"
	set rs.QueryName = "PlayersBySession"
	
	set st = rs.%Execute(id)
	
	if st = $$$OK {
		while rs.%Next() {
			do arr.%Push(rs.Name)
		}
	}
	
	return arr
}

Query PlayersBySession(id) As %SQLQuery [ SqlProc ]
{
Select Player->Name
from SessionPlayer
where Session = :id
order by Name
}

Storage Default
{
<Data name="SessionPlayerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Session</Value>
</Value>
<Value name="3">
<Value>Player</Value>
</Value>
</Data>
<DataLocation>^BG.SessionPlayerD</DataLocation>
<DefaultData>SessionPlayerDefaultData</DefaultData>
<IdLocation>^BG.SessionPlayerD</IdLocation>
<IndexLocation>^BG.SessionPlayerI</IndexLocation>
<StreamLocation>^BG.SessionPlayerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
