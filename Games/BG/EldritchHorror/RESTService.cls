Class BG.EldritchHorror.RESTService Extends BG.RESTService
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/ancientones" Method="GET" Call="GetAncientOnes" />
<Route Url="/ancientones/:name" Method="POST" Call="InsertAncientOne" />

<Route Url="/characters" Method="GET" Call="GetCharacters" />
<Route Url="/characters/:name" Method="POST" Call="InsertCharacter" />

<Route Url="/sessions" Method="GET" Call="GetAllSessions" />
<Route Url="/sessions/:id" Method="GET" Call="GetSession" />
<Route Url="/sessions" Method="POST" Call="InsertSession" />

</Routes>
}

ClassMethod GetAncientOnes() As %Status
{
	do ..SetHeaders()
	
	set arr = ##class(BG.EldritchHorror.AncientOne).GetAncientOnesArray(.st)
	if st = $$$OK {
		write arr.%ToJSON()
		
	}
	return st
}

ClassMethod InsertAncientOne(name) As %Status
{
	return ##class(BG.EldritchHorror.AncientOne).InsertAncientOne(name)
}

ClassMethod GetCharacters() As %Status
{
	do ..SetHeaders()
	
	set arr = ##class(BG.EldritchHorror.Character).GetCharactersArray(.st)
	if st = $$$OK {
		write arr.%ToJSON()
		
	}
	return st
}

ClassMethod InsertCharacter(name) As %Status
{
	return ##class(BG.EldritchHorror.Character).InsertCharacter(name)
}

ClassMethod GetAllSessions() As %Status
{
	do ..SetHeaders()
	
	set arr = ##class(BG.EldritchHorror.Session).GetAllSessionsArray(.st)
	if $$$ISOK(st) {
		write arr.%ToJSON()
		
	}
	return st
}

ClassMethod GetSession(id) As %Status
{
	do ..SetHeaders()
	
	set sessionObj = ##class(BG.EldritchHorror.Session).GetSessionObject(id, .st)
	if $$$ISERR(st) {
		return st
	}
	
	set characters = ##class(BG.EldritchHorror.SessionCharacter).GetCharactersArray(id,.st)
	if $$$ISERR(st) {
		return st
	}
	
	set players = ##class(BG.EldritchHorror.SessionPlayer).GetPlayersArray(id,.st)
	if $$$ISERR(st) {
		return st
	}
	
	set sessionObj.players = players
	set sessionObj.characters = characters
	
	write sessionObj.%ToJSON()
	
	return st
}

ClassMethod InsertSession() As %Status
{
	#Dim %request as %CSP.Request
	
	set st = $$$OK
	try {

		set json = %request.Content.Read()
		
		set data = {}.%FromJSON(json)
		
		tstart
		
		set aOne = data.ancientone
		
		set aOne = $replace(aOne, "\n","")
		set aOne = $zstrip(aOne, ">W")
		set aOne = $zstrip(aOne, "*C")
		
		set ^test("aOne") = aOne
		set won = data.won
		set doom = data.doom
		set gates = data.gates
		set monsters = data.monsters
		set mysteries = data.mysteries
		set rumours = data.rumours
		set date = $zdateh(data.date)
		
		set st = ##class(BG.EldritchHorror.Session).InsertSession(aOne,won,doom,gates,monsters,mysteries,rumours,date,.Id)
		$$$ThrowOnError(st)
		
		set pIter = data.players.%GetIterator()
		
		while pIter.%GetNext(.pKey, .player) {
			set player = $replace(player, "\n","")
			set player = $zstrip(player, ">W")
			set player = $zstrip(player, "*C")
			
			set st = ##class(BG.EldritchHorror.SessionPlayer).InsertSessionPlayer(Id,player)
			
			$$$ThrowOnError(st)
			
		}
		
		set cIter = data.characters.%GetIterator()
		
		while cIter.%GetNext(.cKey, .character) {
			set char = character.character
			set player = character.player
			set survived = character.survived
			
			set char = $replace(char, "\n","")
			set char = $zstrip(char, ">W")
			set char = $zstrip(char, "*C")
			set player = $replace(player, "\n","")
			set player = $zstrip(player, ">W")
			set player = $zstrip(player, "*C")
			set ^test("char") = char
			
			set st = ##class(BG.EldritchHorror.SessionCharacter).InsertSessionCharacter(Id,char,player,survived)
			$$$ThrowOnError(st)
		}
		
		tcommit
   }
   catch ex {
   		trollback
   		set st = ex.AsStatus()
   }
	
   return st
}

}
