Class BG.EldritchHorror.SessionCharacter extends %Persistent 
{

Property Session As BG.EldritchHorror.Session;

Index SessionIndex on Session;

Property Character As BG.EldritchHorror.Character;

Index CharacterIndex on Character;

Property Player As BG.Player;

Index PlayerIndex on Player;


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