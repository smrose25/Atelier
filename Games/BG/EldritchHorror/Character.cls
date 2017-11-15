Class BG.EldritchHorror.Character Extends %Persistent
{

Property Name As %String;

Index NameIndex On Name [ Unique ];

ClassMethod InsertCharacter(name As %String) As %Status
{
	set char = ##class(Character).%New()
	set char.Name = name
	return char.%Save()
}

ClassMethod UpdateCharacter(oldName, newName) As %Status
{
	&sql(update "character" set name = :newName where name = :oldName)
	
	if SQLCODE = 0 {
		return $$$OK
	}
	else {
		return $$$ERROR($$$GeneralError, %msg)
	}
}

ClassMethod GetCharactersArray(Output st As %Status) As %DynamicArray
{
	set arr = []

	set rs = ##class(%ResultSet).%New()
	set rs.ClassName = "BG.EldritchHorror.Character"
	set rs.QueryName = "CharactersByName"
	
	set st = rs.%Execute()
	
	if st = $$$OK {
		while rs.%Next() {
			do arr.%Push(rs.Name)
		}
	}
	
	return arr
}

Query CharactersByName() As %SQLQuery [ SqlProc ]
{
Select Name
from "Character"
order by Name
}

Storage Default
{
<Data name="CharacterDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
</Data>
<DataLocation>^BG.EldritchHorror.CharacterD</DataLocation>
<DefaultData>CharacterDefaultData</DefaultData>
<IdLocation>^BG.EldritchHorror.CharacterD</IdLocation>
<IndexLocation>^BG.EldritchHorror.CharacterI</IndexLocation>
<StreamLocation>^BG.EldritchHorror.CharacterS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
