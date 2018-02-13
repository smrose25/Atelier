Class BG.EldritchHorror.Session Extends BG.Session
{

Property AncientOne As AncientOne;

Index AncientOneIndex On AncientOne;

Property Won As %Boolean;

Index WonIndex On Won [ Type = bitmap ];

Property Doom As %Integer;

Property Gates As %Integer;

Property Monsters As %Integer;

Property MysteriesSolved As %Integer;

Property RumoursSolved as %Integer;

ClassMethod GetAllSessionsArray(Output st As %Status) As %DynamicArray
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
			if rs.Won = 1 {
				set obj.won = "Yes"
			}
			else {
				set obj.won = "No"
			}
			do arr.%Push(obj)
		}
	}
	
	return arr
}

ClassMethod GetSessionObject(sessionId As %String, Output st As %Status) As %DynamicObject
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
		if rs.Won = 1 {
				set obj.won = "Yes"
			}
			else {
				set obj.won = "No"
			}
		set obj.doom = rs.Doom
		set obj.gates = rs.Gates
		set obj.monsters = rs.Monsters
		set obj.mysteriessolved = rs.MysteriesSolved
		set obj.rumourssolved = rs.RumoursSolved
	}
	
	return obj
}

ClassMethod InsertSession(aOne, won, doom, gates, monsters, mysteries, rumours,date, Output Id) As %Status
{
	set session = ##class(BG.EldritchHorror.Session).%New()
	
	set session.AncientOne = ##class(BG.EldritchHorror.AncientOne).NameIndexOpen(aOne)
	
	set session.Won = won
	if session.Won = "" { 
		set session.Won = 0 
	}
	
	set session.Doom = doom
	set session.Gates = gates
	set session.Monsters = monsters
	set session.MysteriesSolved = mysteries
	set session.RumoursSolved = rumours
	
	set session.SessionDate = date
	set session.Game = ##class(BG.Game).TitleIndexOpen("Eldritch Horror")
	
	set st = session.%Save()
	
	set Id = session.%Id()
	
	return st
}

Query AllSessions() As %SQLQuery [ SqlProc ]
{
Select %ID, AncientOne->name as AncientOne, %external(SessionDate) as sessiondate, Won
from Session
order by SessionDate
}

Query SessionById(id) As %SQLQuery [ SqlProc ]
{
	Select AncientOne->name as AncientOne, %external(SessionDate) as sessiondate, Won, Doom, Gates, Monsters, MysteriesSolved, RumoursSolved
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
<Value name="7">
<Value>RumoursSolved</Value>
</Value>
</Data>
<DefaultData>SessionDefaultData1</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
