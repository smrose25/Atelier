Class BG.EldritchHorror.RESTService extends BG.RESTService {
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
	
	set players = ##class(BG.SessionPlayer).GetPlayersArray(id,.st)
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
	
	return $$$OK
}

}