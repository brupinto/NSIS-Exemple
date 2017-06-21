!include MUI.nsh
!include LogicLib.nsh
!include WinMessages.nsh
!include FileFunc.nsh
!include nsDialogs.nsh

!define VERSION "1.0.0"

Name "Installer - v${VERSION}"
OutFile "ExempleInstall.exe"

Page custom nsDialogsWelcome 
Page custom nugetSetup

!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_LANGUAGE English


Var NODE
Var NUGET
Var DOTNETCORE

Var DIALOG
Var HEADLINE
Var TEXT
Var IMAGECTL
Var IMAGE

Var DIALOG_NUGET
Var HEADLINE_NUGET
Var Label_user
Var Text_user
Var Label_pwd
Var Text_pwd
var bt_validade

Var EXIT_CODE

Var HEADLINE_FONT

Function .onInit

	CreateFont $HEADLINE_FONT "$(^Font)" "14" "700"

	InitPluginsDir

	File /oname=$PLUGINSDIR\img.bmp "img.bmp"

	StrCpy $NODE "https://nodejs.org/dist/v6.11.0/node-v6.11.0-x64.msi"
	StrCpy $NUGET "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
	StrCpy $DOTNETCORE "https://download.microsoft.com/download/B/9/F/B9F1AF57-C14A-4670-9973-CDF47209B5BF/dotnet-dev-win-x64.1.0.4.exe"

FunctionEnd

Function nsDialogsWelcome
	nsDialogs::Create 1044
	Pop $DIALOG

	nsDialogs::CreateControl STATIC ${WS_VISIBLE}|${WS_CHILD}|${WS_CLIPSIBLINGS}|${SS_BITMAP} 0 0 0 109u 193u ""
	Pop $IMAGECTL

	StrCpy $0 $PLUGINSDIR\img.bmp
	System::Call 'user32::LoadImage(i 0, t r0, i ${IMAGE_BITMAP}, i 0, i 0, i ${LR_LOADFROMFILE}) i.s'
	Pop $IMAGE
	
	SendMessage $IMAGECTL ${STM_SETIMAGE} ${IMAGE_BITMAP} $IMAGE

	nsDialogs::CreateControl STATIC ${WS_VISIBLE}|${WS_CHILD}|${WS_CLIPSIBLINGS} 0 120u 10u -130u 20u "Bem vindo!"
	Pop $HEADLINE

	SendMessage $HEADLINE ${WM_SETFONT} $HEADLINE_FONT 0

	nsDialogs::CreateControl STATIC ${WS_VISIBLE}|${WS_CHILD}|${WS_CLIPSIBLINGS} 0 120u 32u -130u -32u "Mussum Ipsum, cacilds vidis litro abertis. Si num tem leite então bota uma pinga aí cumpadi! Quem num gosta di mim que vai caçá sua turmis! Suco de cevadiss, é um leite divinis, qui tem lupuliz, matis, aguis e fermentis. Cevadis im ampola pa arma uma pindureta. Posuere libero varius. Nullam a nisl ut ante blandit hendrerit. Aenean sit amet nisi. Praesent malesuada urna nisi, quis volutpat erat hendrerit non. Nam vulputate dapibus. A ordem dos tratores não altera o pão duris. Todo mundo vê os porris que eu tomo, mas ninguém vê os tombis que eu levo! Atirei o pau no gatis, per gatis num morreus. Detraxit consequat et quo num tendi nada. Admodum accumsan disputationi eu sit. Vide electram sadipscing et per. Viva Forevis aptent taciti sociosqu ad litora torquent."
	Pop $TEXT

	SetCtlColors $DIALOG "" 0xffffff
	SetCtlColors $HEADLINE "" 0xffffff
	SetCtlColors $TEXT "" 0xffffff

	Call HideControls

	nsDialogs::Show

	Call ShowControls

	System::Call gdi32::DeleteObject(i$IMAGE)
FunctionEnd

Function nugetSetup
	nsDialogs::Create 1018
	Pop $DIALOG_NUGET

	nsDialogs::CreateControl STATIC ${WS_VISIBLE}|${WS_CHILD}|${WS_CLIPSIBLINGS} 0 80u 10u -130u 20u "MyGet Authentication"
	Pop $HEADLINE_NUGET

	SendMessage $HEADLINE_NUGET ${WM_SETFONT} $HEADLINE_FONT 0

	${NSD_CreateLabel} 10u 40u 75% -130u  "User:"
	Pop $Label_user
	
	${NSD_CreateText} 10u 52u 75% -130u "MyGet user here..."
	Pop $Text_user

	${NSD_CreateLabel} 10u 70u 75% -130u "Password:"
	Pop $Label_pwd
	
	${NSD_CreatePassword} 10u 82u 75% -130u "myGet password here..."
	Pop $Text_pwd

	${NSD_CreateButton} 140u 100u 95u -120u "Validade"
	Pop $bt_validade
	GetFunctionAddress $0 OnClick
	nsDialogs::OnClick $bt_validade $0

	SetCtlColors $DIALOG_NUGET "" 0xffffff
	SetCtlColors $HEADLINE_NUGET "" 0xffffff
	SetCtlColors $Label_user "" 0xffffff
	SetCtlColors $Label_pwd "" 0xffffff

	LockWindow on
	GetDlgItem $0 $HWNDPARENT 1
	ShowWindow $0 ${SW_HIDE}

	GetDlgItem $0 $HWNDPARENT 3
	ShowWindow $0 ${SW_HIDE}
	LockWindow off

	nsDialogs::Show

	System::Call gdi32::DeleteObject(i$IMAGE)
	
FunctionEnd

Function OnClick
	Pop $0 # HWND

	NSISdl::download $NUGET ".\nuget.exe" 
	IfErrors 0 +4
		ClearErrors
		MessageBox MB_OK|MB_ICONEXCLAMATION "Something not work while try download do nuget agent. try again!"
		return

	${NSD_GetText} $Text_user $1
	${NSD_GetText} $Text_pwd $2

	ExecWait '".\nuget.exe" sources add -name Unio -source https://www.myget.org/index.json -UserName $1 -Password $2 -StorePasswordInClearText -Verbosity quiet' $EXIT_CODE
	${If} $EXIT_CODE = 1
		ClearErrors
		MessageBox MB_OK|MB_ICONEXCLAMATION "Something not worked when tried register the credentials on nuget. try again!"
		return
	${EndIf}

	ExecWait '".\nuget.exe" install ApiChecker -NonInteractive' $EXIT_CODE
	${If} $EXIT_CODE = 1
		ClearErrors
		MessageBox MB_OK|MB_ICONEXCLAMATION "Something not worked maybe your credentials is not correct. Verifier if you inserted correct user and password!"
		return
	${EndIf}

	LockWindow on
	GetDlgItem $0 $HWNDPARENT 1
	ShowWindow $0 ${SW_NORMAL}
	LockWindow off
FunctionEnd

Function HideControls

    LockWindow on
    GetDlgItem $0 $HWNDPARENT 1028
    ShowWindow $0 ${SW_HIDE}

    GetDlgItem $0 $HWNDPARENT 1256
    ShowWindow $0 ${SW_HIDE}

    GetDlgItem $0 $HWNDPARENT 1035
    ShowWindow $0 ${SW_HIDE}

    GetDlgItem $0 $HWNDPARENT 1037
    ShowWindow $0 ${SW_HIDE}

    GetDlgItem $0 $HWNDPARENT 1038
    ShowWindow $0 ${SW_HIDE}

    GetDlgItem $0 $HWNDPARENT 1039
    ShowWindow $0 ${SW_HIDE}

    GetDlgItem $0 $HWNDPARENT 1045
    ShowWindow $0 ${SW_NORMAL}
    LockWindow off
FunctionEnd

Function ShowControls

    LockWindow on
    GetDlgItem $0 $HWNDPARENT 1028
    ShowWindow $0 ${SW_NORMAL}

    GetDlgItem $0 $HWNDPARENT 1256
    ShowWindow $0 ${SW_NORMAL}

    GetDlgItem $0 $HWNDPARENT 1035
    ShowWindow $0 ${SW_NORMAL}

    GetDlgItem $0 $HWNDPARENT 1037
    ShowWindow $0 ${SW_NORMAL}

    GetDlgItem $0 $HWNDPARENT 1038
    ShowWindow $0 ${SW_NORMAL}

    GetDlgItem $0 $HWNDPARENT 1039
    ShowWindow $0 ${SW_NORMAL}

    GetDlgItem $0 $HWNDPARENT 1045
    ShowWindow $0 ${SW_HIDE}
    LockWindow off

FunctionEnd

Section "INSTALLSECTION"

	NSISdl::download $NODE ".\node.exe" 
	NSISdl::download $DOTNETCORE ".\dotnet.exe" 

	IfErrors 0 +4
		ClearErrors
		MessageBox MB_OK|MB_ICONEXCLAMATION "Something is wrong! Need Internet access to do download of required files. Check the internet issues and try again!"
		return

SectionEnd
