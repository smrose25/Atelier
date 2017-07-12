Class BG.RESTService extends %CSP.REST 
{
XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/titles" Method="GET" Call="GetGames" />
<Route Url="/titles/:title/:coop" Method="POST" Call="InsertGame" />

<Route Url="/players" Method="GET" Call="GetPlayers" />
<Route Url="/players/:name" Method="POST" Call="InsertPlayer" />

</Routes>
}

ClassMethod SetHeaders()
{
	#Dim %response as %CSP.Response
    do %response.SetHeader("ContentType", "application/json")
    do %response.SetHeader("Access-Control-Allow-Origin", "null")
}

ClassMethod GetGames() As %Status
{
	do ..SetHeaders()
	
	set arr = ##class(BG.Game).GetGamesArray(.st)
	if st = $$$OK {
		write arr.%ToJSON()
		
	}
	return st
}

ClassMethod InsertGame(title as %String, coop as %Boolean) As %Status
{
	return ##class(BG.Game).InsertGame(title,coop)
}

ClassMethod GetPlayers() As %Status
{
	do ..SetHeaders()
	
	set arr = ##class(BG.Player).GetPlayersArray(.st)
	if st = $$$OK {
		write arr.%ToJSON()
		
	}
	return st
}

ClassMethod InsertPlayer(name) As %Status
{
	return ##class(BG.Player).InsertPlayer(name)
}

}