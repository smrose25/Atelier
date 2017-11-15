Class BG.Session Extends %Persistent [ Abstract ]
{

Property Game As BG.Game;

Index GameIndex On Game;

Property SessionDate As %Date;

Storage Default
{
<Data name="SessionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Game</Value>
</Value>
<Value name="3">
<Value>SessionDate</Value>
</Value>
</Data>
<DataLocation>^BG.SessionD</DataLocation>
<DefaultData>SessionDefaultData</DefaultData>
<IdLocation>^BG.SessionD</IdLocation>
<IndexLocation>^BG.SessionI</IndexLocation>
<StreamLocation>^BG.SessionS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
