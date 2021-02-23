B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=4.2
@EndOfDesignText@

Sub Class_Globals
	Dim App As AWTRIX
	
	'###### nötige Variablen deklarieren ######
	Dim temp As String = 0	
	Dim iconID As Int = 487
End Sub

' ignore
Public Sub Initialize() As String
	
	App.Initialize(Me,"App")
	
	'change plugin name (must be unique, avoid spaces)
	App.Name="WeatherCN"
	
	'Version of the App
	App.Version="1.0"
	
	'Description of the App. You can use HTML to format it
	App.Description=$"
	查询天气<br/>
	"$
		
	App.author="Rick"	
		
	'SetupInstructions. You can use HTML to format it
	App.setupDescription= $"
	<b>城市名和心知天气Key<br/>
	"$
	
	App.coverIcon=473
	
	'How many downloadhandlers should be generated
	App.Downloads=1
	
	'IconIDs from AWTRIXER.
	App.Icons=Array(487)
	
	'Tickinterval in ms (should be 65 by default)
	App.tick=65
	
	'needed Settings for this App (Wich can be configurate from user via webinterface)
	App.Settings=CreateMap("CityName":"", "Key":"")
	
	App.MakeSettings
	Return "AWTRIX20"
End Sub

' ignore
public Sub GetNiceName() As String
	Return App.name
End Sub

' ignore
public Sub Run(Tag As String, Params As Map) As Object
	Return App.interface(Tag,Params)
End Sub

Sub App_iconRequest
	App.Icons=Array As Int(iconID)
End Sub

'Called with every update from Awtrix
'return one URL for each downloadhandler
'https://api.seniverse.com/v3/weather/now.json?key=SbzmxqkLlOzNp0vt_&location=jiujiang
Sub App_startDownload(jobNr As Int)
	Select jobNr
		Case 1
			App.Download("https://api.seniverse.com/v3/weather/now.json?key=" & App.get("Key") & "&location=" & App.get("CityName"))
	End Select
End Sub

'process the response from each download handler
'if youre working with JSONs you can use this online parser
'to generate the code automaticly
'https://json.blueforcer.de/ 
Sub App_evalJobResponse(Resp As JobResponse)
	Try
		If Resp.success Then
			Select Resp.jobNr
				Case 1
					Dim parser As JSONParser
					parser.Initialize(Resp.ResponseString)
					Dim one As Map = parser.NextObject
					Dim res As List = one.get("results")
					Dim ress As Map = res.Get(0)
					Dim now As Map = ress.Get("now")
					Dim tem As String = now.Get("temperature")
					temp = tem & "°C"
					Dim colweather As String = now.Get("text")
					iconID=getIconID(colweather)
			End Select
		End If
	Catch
		Log("Error in: "& App.Name & CRLF & LastException)
		Log("API response: " & CRLF & Resp.ResponseString)
	End Try
End Sub


Sub App_genFrame
	App.genText(temp,True,1,Null,False)
	App.drawBMP(0,0,App.getIcon(iconID),8,8)
End Sub

Sub getIconID (ico As String)As Int
	Select ico
	'Day
		Case "晴"
			Return 349 'sunny
		Case "云"
			Return 486 'cloudy
		Case "雷"
			Return 346 'rainy
		Case "雨"
			Return 346 'rainy
		Case Else
			Log("Error from weatherApp:")
			Log("Icon " & ico & " not found!")
			Return 487
	End Select
	
	
End Sub
