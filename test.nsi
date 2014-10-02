!include "MUI2.nsh"
!include "DotNetChecker.nsh"
!include "CheckDotNet.nsh"
!include "DotNetSearch.nsh"

Name "DotNetChecker Example"
OutFile "Example.exe"

InstallDir "$LOCALAPPDATA\DotNetChecker Example" 
InstallDirRegKey HKCU "Software\DotNetChecker Example" ""

RequestExecutionLevel admin

!define MUI_ABORTWARNING

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
 
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
  
!insertmacro MUI_LANGUAGE "English"

;--------------------------------


Function CheckSQLVersion
 
	ClearErrors

	ReadRegStr $4 HKLM "SOFTWARE\Microsoft\Microsoft SQL Server\SQLEXPRESS\MSSQLServer\CurrentVersion" "CurrentVersion"
	IfErrors SQLServerNotFound SQLServerFound

	SQLServerFound:
		;Check the first digit of the version; must be 11
		StrCpy $0 $4
		StrCpy $1 $0 2
		StrCmp $1 "11" SQLServer2012Found SQLServerVersionError
		Goto ExitCheckSQLVersion

	SQLServer2012Found:
		DetailPrint "SQLServer version 2012 was found"
		Goto ExitCheckSQLVersion

	SQLServerVersionError:
		MessageBox MB_OK|MB_ICONEXCLAMATION "This product requires a minimum SQLServer 2012; detected version not satisfied. Setup will abort."
		Push 0
		Goto ExitCheckSQLVersion

	SQLServerNotFound:
		MessageBox MB_OK|MB_ICONEXCLAMATION "SQLServer was not detected; this is required for installation. Setup will abort."
		Push 0
		Goto ExitCheckSQLVersion

	ExitCheckSQLVersion:

FunctionEnd

;Installer Sections

Section "Dummy Section" SecDummy

  SetOutPath "$INSTDIR"

  !insertmacro DotNetSearch 4 0 "" "INSTALL_NOABORT" "$INSTDIR"
  Call CheckSQLVersion
  
  ;Store installation folder
  WriteRegStr HKCU "Software\DotNetChecker Example" "" $INSTDIR
  
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

Section "Uninstall"

  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  DeleteRegKey /ifempty HKCU "Software\DotNetChecker Example"
SectionEnd