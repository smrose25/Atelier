Class BG.EldritchHorror.SessionPlayer Extends BG.SessionPlayer
{
Property Session As BG.EldritchHorror.Session;


ClassMethod InsertSessionPlayer(sessionId, name) As %Status
{
	set player = ..%New()
	
	set player.Player = ##class(BG.Player).NameIndexOpen(name)
	
	set player.Session = ##class(BG.EldritchHorror.Session).%OpenId(sessionId)
	
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
from BG_EldritchHorror.SessionPlayer
where Session = :id
order by Name
}
Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}