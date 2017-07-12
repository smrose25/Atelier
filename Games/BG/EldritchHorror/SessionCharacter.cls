Class BG.EldritchHorror.SessionCharacter extends %Persistent 
{

Property Session As BG.EldritchHorror.Session;

Index SessionIndex on Session;

Property Character As BG.EldritchHorror.Character;

Index CharacterIndex on Character;

Property Player As BG.Player;

Index PlayerIndex on Player;

ClassMethod GetCharactersArray(sessionId as %String, Output st as %Status) As %DynamicArray
{
	set arr = []

	set rs = ##class(%ResultSet).%New()
	set rs.ClassName = "BG.EldritchHorror.SessionCharacter"
	set rs.QueryName = "CharactersBySession"
	
	set st = rs.%Execute(sessionId)
	
	if st = $$$OK {
		while rs.%Next() {
			set obj = {}
			set obj.player = rs.Player
			set obj.character = rs.Character
			do arr.%Push(obj)
		}
	}
	
	return arr
}

Query CharactersBySession(id) As %SQLQuery [SqlProc]
{
Select "character"->name as "Character", player->name as Player
from SessionCharacter
where session = :id
order by "character"
}

Storage Default
{
<Data name="SessionCharacterDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Session</Value>
</Value>
<Value name="3">
<Value>Character</Value>
</Value>
<Value name="4">
<Value>Player</Value>
</Value>
</Data>
<DataLocation>^BG.EldritcEAAF.SessionChar2E31D</DataLocation>
<DefaultData>SessionCharacterDefaultData</DefaultData>
<IdLocation>^BG.EldritcEAAF.SessionChar2E31D</IdLocation>
<IndexLocation>^BG.EldritcEAAF.SessionChar2E31I</IndexLocation>
<StreamLocation>^BG.EldritcEAAF.SessionChar2E31S</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}