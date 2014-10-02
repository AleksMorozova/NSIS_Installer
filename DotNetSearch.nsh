!macro DotNetSearch DOTNETVMAJOR DOTNETVMINOR DOTNETVMINORMINOR DOTNETLASTFUNCTION DOTNETPATH
	Var /GLOBAL DOTNET1
	Var /GLOBAL DOTNET2
	Var /GLOBAL DOTNET4
	Var /GLOBAL DOTNET5
	Var /GLOBAL DOTNET6
		Push $DOTNET1
		Push $DOTNET2
		Push $DOTNET3
		Push $DOTNET4
		Push $DOTNET5
		Push $DOTNET6
 
			StrCpy $DOTNET1 "0"
			StrCpy $DOTNET2 "SOFTWARE\Microsoft\.NETFramework"
			StrCpy $DOTNET3 "0"
 
	DotNetStartEnum:
		EnumRegKey $DOTNET4 HKLM $DOTNET2 $DOTNET3
			StrCmp $DOTNET4 "" noDotNet dotNetFound
 
	dotNetFound:
		StrCpy $DOTNET5 $DOTNET4 1 0
		StrCmp $DOTNET5 "v" +1 goNextDotNet
		StrCpy $DOTNET5 $DOTNET4 1 1
 
	IntCmp $DOTNET5 ${DOTNETVMAJOR} +1 goNextDotNet yesDotNet
    StrCpy $DOTNET5 $DOTNET4 1 3
    IntCmp $DOTNET5 ${DOTNETVMINOR} +1 goNextDotNet yesDotNet
 
		StrCmp ${DOTNETVMINORMINOR} "" yesDotNet +1 yesDotNet
		;StrCmp ${DOTNETVMINORMINOR} "" yesDotNet +1
 		;Changed this line (otherwise it would not work with my setup!) - Vinz0r
 
	IntCmpU $DOTNET5 ${DOTNETVMINORMINOR} yesDotNet goNextDotNet yesDotNet
 
		goNextDotNet:
			IntOp $DOTNET3 $DOTNET3 + 1
			Goto DotNetStartEnum
 
	noDotNet:
		StrCmp ${DOTNETLASTFUNCTION} "INSTALL_ABORT" +1 nDN2
			MessageBox MB_YESNO|MB_ICONQUESTION \
			"You must have Microsoft .NET Framework version ${DOTNETVMAJOR}.${DOTNETVMINOR}.${DOTNETVMINORMINOR}$\nor higher installed. Install now?" \
			IDYES +2 IDNO +1
			Abort
			ExecWait '${DOTNETPATH}'
			Goto DotNetStartEnum
	nDN2:
		StrCmp ${DOTNETLASTFUNCTION} "INSTALL_NOABORT" +1 nDN3
			MessageBox MB_YESNO|MB_ICONQUESTION \
			"Microsoft .NET Framework version ${DOTNETVMAJOR}.${DOTNETVMINOR}.${DOTNETVMINORMINOR} is not installed.$\nDo so now?" \
			IDYES +1 IDNO +3
			ExecWait '${DOTNETPATH}'
			Goto DotNetStartEnum
			StrCpy $DOTNET1 0
			Goto DotNetFinish
	nDN3:
		StrCmp ${DOTNETLASTFUNCTION} "WARNING" +1 nDN4
			MessageBox MB_OK|MB_ICONEXCLAMATION \
			"Warning:$\n$\n$\t$\tMicrosoft .NET Framework version$\n$\t$\t${DOTNETVMAJOR}.${DOTNETVMINOR}.${DOTNETVMINORMINOR} is not installed!" \
			IDOK 0
			StrCpy $DOTNET1 0
			Goto DotNetFinish
	nDN4:
		StrCmp ${DOTNETLASTFUNCTION} "ABORT" +1 nDN5
			MessageBox MB_OK|MB_ICONEXCLAMATION \
			"Error:$\n$\n$\t$\tMicrosoft .NET Framework version$\n$\t$\t${DOTNETVMAJOR}.${DOTNETVMINOR}.${DOTNETVMINORMINOR} is not installed, aborting!" \
			IDOK 0
			Abort
	nDN5:
		StrCmp ${DOTNETLASTFUNCTION} "IGNORE" +1 nDN6
			StrCpy $DOTNET1 0
			Goto DotNetFinish
	nDN6:
		MessageBox MB_OK \
		"$(^Name) Setup internal error.$\nMacro 'DotNetSearch', parameter '4'(${DOTNETLASTFUNCTION})invalid.$\nValue must be INSTALL_ABORT|INSTALL_NOABORT|WARNING|ABORT|IGNORE$\nSorry for the inconvenience.$\n$\tAborting..." \
		IDOK 0
		Abort
 
	yesDotNet:
		DetailPrint ".NET Framework  ${DOTNETVMAJOR}.${DOTNETVMINOR} found, no need to install."
		StrCpy $DOTNET1 1
 
	DotNetFinish:
		Pop $DOTNET6
		Pop $DOTNET5
		Pop $DOTNET4
		Pop $DOTNET3
		Pop $DOTNET2
		!define ${DOTNETOUTCOME} $DOTNET1
		Exch $DOTNET1
!macroend