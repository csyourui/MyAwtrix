B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=4.2
@EndOfDesignText@

Sub Class_Globals
	Dim App As AWTRIX
	Dim Index As Int = 0
	Dim MasNumber As Int = 0
	Dim iconID As Int = 442
	Dim ResultList As List
	Dim NameList As List
	Dim PriceList As List
	Dim DifList As List
	Dim tempList As List
	Dim Red() As Int = Array As Int(255,0,0)
	Dim Green() As Int = Array As Int(0,255,0)
End Sub

' ignore
public Sub GetNiceName() As String
	Return App.name
End Sub

' ignore
public Sub Run(Tag As String, Params As Map) As Object
	Return App.interface(Tag,Params)
End Sub

' Config your App
Public Sub Initialize() As String
	NameList.Initialize
	ResultList.Initialize
	PriceList.Initialize
	DifList.Initialize
	tempList.Initialize
	'initialize the AWTRIX class and parse the instance; dont touch this
	App.Initialize(Me,"App")
	
	'App name (must be unique, no spaces)
	App.name = "Stock"
	
	'Version of the App
	App.version = "1.0"
	
	'Description of the App. You can use HTML to format it
	App.description = $"
	This is just a Stock
	"$
	
	'The developer if this App
	App.author = "Rickyou"

	'Icon (ID) to be displayed in the Appstore and MyApps
	App.coverIcon = 6
	
	'needed Settings for this App wich can be configurate from user via webinterface. Dont use spaces here!
	App.settings = CreateMap("list":"s_sh000001,s_sz399001")
		
	'Setup Instructions. You can use HTML to format it
	App.setupDescription = $"
	<b>CustomText:</b>Text wich will be shown<br/>
	"$
	
	'define some tags to simplify the search in the Appstore
	App.tags = Array As String("Template", "Awesome")
	
	'How many downloadhandlers should be generated
	App.downloads = 1
	
	'IconIDs from AWTRIXER. You can add multiple if you need more
	App.Icons=Array(442)
	
	'Tickinterval in ms (should be 65 by default, for smooth scrolling))
	App.tick = 65
	
	'If set to true AWTRIX will wait for the "finish" command before switch to the next app.
	App.lock = False
	
	'This tolds AWTRIX that this App is an Game.
	App.isGame = False
	
	'If set to true, AWTRIX will download new data before each start.
	App.forceDownload = True

	'ignore
	App.makeSettings
	Return "AWTRIX20"
End Sub

'this sub is called right before AWTRIX will display your App
Sub App_Started
	tempList.Clear
	Dim liststr As String = App.get("list")
	If liststr.Contains(",")  Then
		Dim l() As String = Regex.Split(",",liststr)
		For i=0 To l.Length-1
			tempList.Add(l(i))
		Next
	End If
	MasNumber = tempList.Size
	tempList.Clear
	Log("MasNumber: " & MasNumber)
End Sub
	
'this sub is called if AWTRIX switch to thee next app and pause this one
Sub App_Exited
	
End Sub	

'This sub is called right before AWTRIX will display your App.
'If you need to another Icon you can set your Iconlist here again.
Sub App_iconRequest
	'App.Icons = Array As Int(4)
End Sub

'If the user change any Settings in the webinterface, this sub will be called
Sub App_settingsChanged
	
End Sub

'If you create an Game, use this sub to get the button presses from the Weeebinterface or Controller
'button defines the buttonID of thee controller, dir is true if it is pressed
Sub App_controllerButton(button As Int,dir As Boolean)
	
End Sub

'If you create an Game, use this sub to get the Analog Values of thee connected Controller
Sub App_controllerAxis(axis As Int, dir As Float)

End Sub

'This sub is called when the user presses the middle touchbutton while the app is running
Sub App_buttonPush
	Index = (Index + 1) Mod MasNumber
	Log("current index: " & Index)
End Sub

'It possible to create your own setupscreen in HTML.
'This is a very dirty workaround, but its works:)
'Every input must contains an ID with the corresponding settingskey in lowercase 
Sub App_CustomSetupScreen As String
	Return ""
End Sub

'Called with every update from Awtrix
'return one URL for each downloadhandler
Sub App_startDownload(jobNr As Int)
	Select jobNr
		Case 1
			App.Download("http://hq.sinajs.cn/list="&App.get("list"))
	End Select
End Sub

'process the response from each download handler
'if youre working with JSONs you can use this online parser
'to generate the code automaticly
'https://json.blueforcer.de/ 
Sub App_evalJobResponse(Resp As JobResponse)
	ResultList.Clear
	PriceList.Clear
	DifList.Clear
	NameList.Clear
	Try
		If Resp.Success Then
			Dim restr As String = Resp.ResponseString
			If restr.Contains(CRLF)  Then
				Dim l() As String = Regex.Split(CRLF,restr)
				For i=0 To l.Length-1
					ResultList.Add(l(i))
					getPriceFromResult(l(i))
				Next
			End If
		End If
	Catch
		Log("Error in " & App.Name)
		Log("API response: " & CRLF & Resp.ResponseString)
		Log(LastException)
	End Try
End Sub

Sub getPriceFromResult (result As String)
	tempList.Clear
	If result.Contains(",")  Then
		Dim l() As String = Regex.Split(",",result)
		For i=0 To l.Length-1
			tempList.Add(l(i))
		Next
	End If
	Dim name As String = tempList.Get(0)
	NameList.Add(name.SubString2(13,name.IndexOf("=")))
	PriceList.Add(HandleStringNumbers(tempList.Get(1)))
	DifList.Add(HandleStringNumbers(tempList.Get(2)))
End Sub
'With this sub you build your frame wtih eveery Tick.
Sub App_genFrame
	Dim tempDif As String = DifList.Get(Index)
	If tempDif.CharAt(0) = "-" Then
		App.genText(PriceList.Get(Index),True,1,Green,False)
	Else
		App.genText(PriceList.Get(Index),True,1,Red,False)
	End If
	App.drawBMP(0,0,App.getIcon(442),8,8)
End Sub

Sub HandleStringNumbers(strValue As String)  As String
	Dim doubleValue As Double = strValue
	doubleValue = Round2(doubleValue, 2)
	Return doubleValue
End Sub