Class BG.SessionPlayer Extends %Persistent [Abstract]
{

Property Session As BG.Session;

Index SessionIndex On Session;

Property Player As BG.Player;

Index PlayerIndex On Player;

Query PlayersBySession(id) As %SQLQuery [ SqlProc ]
{
Select Player->Name
from BG.SessionPlayer
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
