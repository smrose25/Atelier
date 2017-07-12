Class BG.EldritchHorror.Session Extends (BG.Session, %Persistent)
{

Property AncientOne As AncientOne;

Index AncientOneIndex on AncientOne;

Property Won As %Boolean;

Index WonIndex on Won [Type = bitmap ];

Property Doom As %Integer;

Property Gates As %Integer;

Property Monsters As %Integer;

Property MysteriesSolved As %Integer;

ClassMethod GetAllSessionsArray(Output st as %Status) As %DynamicArray
{
	set arr = []

	set rs = ##class(%ResultSet).%New()
	set rs.ClassName = "BG.EldritchHorror.Session"
	set rs.QueryName = "AllSessions"
	
	set st = rs.%Execute()
	
	if st = $$$OK {
		while rs.%Next() {
		
			set obj = {}
			set obj.id = rs.ID
			set obj.ancientOne = rs.AncientOne
			set obj.date = rs.SessionDate
			set obj.won = rs.Won
			
			do arr.%Push(obj)
		}
	}
	
	return arr
}

ClassMethod GetSessionObject(sessionId as %String, Output st as %Status) as %DynamicObject
{
	set obj = {}

	set rs = ##class(%ResultSet).%New()
	set rs.ClassName = "BG.EldritchHorror.Session"
	set rs.QueryName = "SessionById"
	
	set st = rs.%Execute(sessionId)
	
	if st = $$$OK {
		do rs.%Next() 
		
		set obj.ancientOne = rs.AncientOne
		set obj.date = rs.SessionDate
		set obj.won = rs.Won
		set obj.doom = rs.Doom
		set obj.gates = rs.Gates
		set obj.monsters = rs.Monsters
		set obj.mysteriessolved = rs.MysteriesSolved
	}
	
	return obj
}

Query AllSessions() As %SQLQuery [SqlProc]
{
Select %ID, AncientOne->name as AncientOne, %external(SessionDate) as sessiondate, Won
from Session
order by SessionDate
}

Query SessionById(id) As %SQLQuery [SqlProc]
{
	Select AncientOne->name as AncientOne, %external(SessionDate) as sessiondate, Won, Doom, Gates, Monsters, MysteriesSolved
	from Session
	where id = :id
}

Storage Default
{
<Data name="SessionDefaultData1">
<Subscript>"Session"</Subscript>
<Value name="1">
<Value>Won</Value>
</Value>
<Value name="2">
<Value>Doom</Value>
</Value>
<Value name="3">
<Value>AncientOne</Value>
</Value>
<Value name="4">
<Value>Gates</Value>
</Value>
<Value name="5">
<Value>Monsters</Value>
</Value>
<Value name="6">
<Value>MysteriesSolved</Value>
</Value>
</Data>
<DefaultData>SessionDefaultData1</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
