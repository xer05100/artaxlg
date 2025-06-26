                        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;    _________________                         ;;;;;;;;;;;;;
      ;;;;;;;;;;;;;;;   |_______________  \ Community Patch v1.3   ;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;      __    _____  \  \_____________     __   ;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;    / _ \  |  __ \  |  _________   _|   ) /   ;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;   | | \ \ | |  \ \ | |    __   \ \    / /    ;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;   | \_| | | |  | | | |  / _ \   \ \  / /     ;;;;;;;;;;;;;;;;;;;
   ;;;;;;;;;;;;;;;;;;   |  _  | | \_/ /  | | | | \ \   \ \/ /      ;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;   | | \ | |    (   | | | \_| |    )  (       ;;;;;;;;;;;;;;;;;
     ;;;;;;;;;;;;;;;;   | | | | | |\ \   | | |  _  |   / /\ \      ;;;;;;;;;;;;;;;;
      ;;;;;;;;;;;;;;;   | | | | | | \ \  | | | | \ |  / /  \ \     ;;;;;;;;;;;;;;;
       ;;;;;;;;;;;;;;   \_| | | \_|  \ \ | | \_| | | |_/    \ \    ;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;       \_|       \_)\_|     \_|         \_)   ;;;;;;;;;;;;;
         ;;;;;;;;;;;;                                              ;;;;;;;;;;;;
        ;;;;;;;;;;;;;             -={ ALWAYS FREE }=-              ;;;;;;;;;;;;;
       ;;;;;;;;;;;;;;    If you paid for this, YOU GOT SCAMMED     ;;;;;;;;;;;;;;
      ;;;;;;;;;;;;;;;                                              ;;;;;;;;;;;;;;;
     ;;;;;;;;;;;;;;;;  ==========================================  ;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;  Emulator launcher for community multi v1.3  ;;;;;;;;;;;;;;;;;
   ;;;;;;;;;;;;;;;;;;  ==========================================  ;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;                                              ;;;;;;;;;;;;;;;;;;;
 ;;;;;;;;;;;;;;;;;;;;               Version 230318a                ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;                                              ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                                                                                ;;;;
;;;;               Currently handles Atomiswave, Laserdisk, Lindbergh,              ;;;;
;;;;                  Naomi, MAME, Sega Model 2/3, and Pinball FX3.                 ;;;;
;;;;                                                                                ;;;;
;;;;                                                                                ;;;;
;;;;                                   HOW TO USE                                   ;;;;
;;;;                             ----------------------                             ;;;;
;;;; * Make a copy of this script and rename it to match any ROM or table name.     ;;;;
;;;;                                                                                ;;;;
;;;; * Compile it to .a3x using Aut2Exe found at the following path:                ;;;;
;;;;     C:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2exe.exe                         ;;;;
;;;;                                                                                ;;;;
;;;; * Move it to the desired ROM or Script folder.                                 ;;;;
;;;;                                                                                ;;;;
;;;; * If required, add an entry to the romlist at E:\SYSTEM\AM\romlists\menu.txt   ;;;;
;;;;   and artwork in the appropriate subfolders of E:\SYSTEM\ARTWORK\.             ;;;;
;;;;                                                                                ;;;;
;;;;                                                                                ;;;;
;;;; NOTE: When adding new GAMES subfolders, remember to add them to attract.cfg    ;;;;
;;;;       and mame.ini, and to add a new config file to E:\SYSTEM\AM\emulators\.   ;;;;
;;;;                                                                                ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>

;; Where are we?
Local $sdrive = "", $sdir = "", $sfilename = "", $sextension = ""
Local $apathsplit = _PathSplit(@ScriptFullPath, $sdrive, $sdir, $sfilename, $sextension)

;; Initialize launch variables
Local $preLaunch = "", $launch = "", $mqOn = "", $mqOff = "", $postLaunch = ""

;; In-game marquee setup
;;
;; To enable this feature, create a text file called EnableMarquee.txt
;; and place it in E:\SYSTEM\AM\. Set your Marquee Width and Height
;; in two locations: Tab->Displays->'Displays Menu' Options->Layout Options
;; for the main menu view, and Tab->Screen Saver for the screen saver view.
;;
;; The marquee artwork collection is incomplete, so this script will
;; fall back to wheel art if no mp4 or png marquee file is available.

$mqOff = "ProcessClose('mpc-hc.exe')"

If FileExists("E:\SYSTEM\AM\EnableMarquee.txt") Then
   Local $picFile
   Local $artDir = StringReplace($sdir, "\GAMES\", "E:\SYSTEM\ARTWORK\")

   If FileExists($artDir & "VMARQUEE\" & $sfilename & ".mp4") Then
	  $picFile = $artDir & "VMARQUEE\" & $sfilename & ".mp4"
   Elseif FileExists($artDir & "MARQUEE\" & $sfilename & ".png") Then
	  $picFile = $artDir & "MARQUEE\" & $sfilename & ".png"
   Else
	  $picFile = $artDir & "WHEEL\" & $sfilename & ".png"
   EndIf

   ;; Open Game Marquee command
   $mqOn = "Run('E:\SYSTEM\MPC-HCPortable\MPC-HCPortable.exe """ & $picFile & """ /monitor 2 /play')"
EndIf
#include <Misc.au3>
#include <ProcessConstants.au3>

If ProcessExists('$CmdLine[1] & ".a3x"') Then
   ProcessClose('$CmdLine[1] & ".a3x"')
EndIf




; ==== CONFIGURATION ====
Global $interactive = True; Set to False when testing with command line
Global $testInput = "Aliens Extermination" ; Manually test a game name or ROM here

; ==== OPEN LOG ====
Global $file = FileOpen("log.txt", 1)
If $file = -1 Then
    MsgBox(16, "Error", "Failed to open log file.")
    Exit
EndIf

; ==== INI PATH ====
Global $iniFile = "E:\SYSTEM\DS\games.ini"
If Not FileExists($iniFile) Then
    FileWriteLine($file, "Error: INI file not found.")
    FileClose($file)
    Exit
EndIf

; ==== GET INPUT ====
Global $input = ""
If $interactive Then
    $input = $testInput
Else
    If $CmdLine[0] < 1 Then
        FileWriteLine($file, "Error: No game name or ROM provided.")
        FileClose($file)
        Exit
    EndIf
    $input = $CmdLine[1]
EndIf
FileWriteLine($file, "Input Argument: " & $input)

; ==== READ INI SECTIONS ====
Global $sections = IniReadSectionNames($iniFile)
If @error Then
    FileWriteLine($file, "Error: Unable to read sections from INI file.")
    FileClose($file)
    Exit
EndIf

; ==== SEARCH FOR MATCH ====
Global $gameName = "", $target = "", $rom = "", $options = ""
For $i = 1 To $sections[0]
    Local $section = $sections[$i]
    Local $sectionRom = IniRead($iniFile, $section, "rom", "")
	If StringLower($input) = "aliens extermination" Then
    $gameName = "Aliens Extermination Dehasped (2nd dump, x86 and x64, no need for VM)"
    $target = "globalvr"
    $rom = "aliens"
    $options = IniRead($iniFile, $gameName, "options", "")
    FileWriteLine($file, "Override: Aliens Extermination matched. Set target to 'globalvr' and rom to 'aliens'")
    ExitLoop
EndIf

; ==== LOOP OVER INI SECTIONS ====
For $i = 1 To $sectionCount
    $section = IniReadSectionNames($iniFile)[$i]
    $sectionRom = IniRead($iniFile, $section, "rom", "")
    ; ==== HANDLE MANUAL ALIAS FOR ALIENS EXTERMINATION ====
If StringLower($input) = "aliens extermination" Then
    $gameName = "Aliens Extermination Dehasped (2nd dump, x86 and x64, no need for VM)"
    $target = "globalvr"
    $rom = "aliens"
    $options = IniRead($iniFile, $gameName, "options", "")
    FileWriteLine($file, "Override: Aliens Extermination matched. Set target to 'globalvr' and rom to 'aliens'")
Else
    ; ==== LOOP OVER INI SECTIONS ====
    For $i = 1 To $sectionCount
        $section = IniReadSectionNames($iniFile)[$i]
        $sectionRom = IniRead($iniFile, $section, "rom", "")

        If StringLower($input) = StringLower($section) Or StringLower($input) = StringLower($sectionRom) Then
            $gameName = $section
            $target = IniRead($iniFile, $gameName, "target", "")
            $rom = IniRead($iniFile, $gameName, "rom", "")
            $options = IniRead($iniFile, $gameName, "options", "")

            ; ==== OVERRIDE FOR NINJASLT ====
            If StringLower($target) = "demul" And StringLower($rom) = "ninjaslt" Then
                FileWriteLine($file, "Override: Changing target from 'demul' to 'flycast' for ninjaslt")
                $target = "flycast"
            EndIf

            ; ==== OVERRIDE FOR RINGSYSTEM ====
            If StringLower($target) = "ringsystem" Then
                FileWriteLine($file, "Override: Changing target from 'ringsystem' to 'ringwide'")
                $target = "ringwide"
            EndIf

            ExitLoop
        EndIf
    Next
EndIf


; ==== CHECK IF FOUND ====
If $gameName = "" Then
    FileWriteLine($file, "Error: No matching game found for input: " & $input)
    FileClose($file)
    Exit
EndIf

; ==== LOG VALUES ====
FileWriteLine($file, "Game Name: " & $gameName)
FileWriteLine($file, "Target: " & $target)
FileWriteLine($file, "ROM: " & $rom)
FileWriteLine($file, "Options: " & $options)

If $target = "" Or $rom = "" Then
    FileWriteLine($file, "Error: Missing required values for " & $gameName)
    FileClose($file)
    Exit
EndIf

; ==== SETUP DEMULSHOOTER COMMANDS ====
Global $DS32 = "E:\SYSTEM\DS\DemulShooter.exe"
Global $DS64 = "E:\SYSTEM\DS\DemulShooterX64.exe"
Global $cmd32 = '"' & $DS32 & '" -target=' & $target & ' -rom=' & $rom & ' ' & $options
Global $cmd64 = '"' & $DS64 & '" -target=' & $target & ' -rom=' & $rom & ' ' & $options

		If ProcessClose($CmdLine[1] & ".a3x") Then
        ProcessClose($CmdLine[1] & ".a3x")
	EndIf


; ==== HANDLE TARGET CASES ====
Switch StringLower($target)
    Case "flycast"
    FileWriteLine($file, "Launching Flycast with ROM: " & $rom)

    ; Check if the .a3x process exists for the specific ROM and close it if found
    If ProcessExists($rom & ".a3x") Then
        FileWriteLine($file, "Closing existing " & $rom & ".a3x process.")
        ProcessClose($rom & ".a3x")
    EndIf

    ; Launch Flycast with the ROM
    FileChangeDir("E:\SYSTEM\FLYCAST")
    Run('E:\SYSTEM\FLYCAST\flycast.exe E:\GAMES\NAOMI\' & $rom & '.zip', "", @SW_SHOW)
    Run(@ComSpec & " /c " & $cmd64, "", @SW_HIDE)
    Run('E:\SYSTEM\AUTOHOTKEY\esc2altf4.exe', '', @SW_HIDE)
	ProcessWaitClose("flycast.exe")
    ProcessWaitClose("DemulshooterX64.exe")
    FileChangeDir("E:\SYSTEM\AM")
    Run("E:\SYSTEM\AM\Multi.exe", "", @SW_SHOW)
    Exit


    Case Else
        FileWriteLine($file, "Launching DemulShooter 32-bit and 64-bit")
        Run(@ComSpec & " /c " & $cmd32, "", @SW_HIDE)
        Run(@ComSpec & " /c " & $cmd64, "", @SW_HIDE)
        FileWriteLine($file, "Executed 32-bit Command: " & $cmd32)
        FileWriteLine($file, "Executed 64-bit Command: " & $cmd64)
        FileClose($file)

        ConsoleWrite("Script exit for non-flycast game" & @CRLF)
        Exit
	EndSwitch
	
	
	
	    FileWriteLine($file, "Executed 64-bit Command: " & $cmd64)
    FileClose($file)




ProcessWaitClose("fastio.exe")

Run("E:\SYSTEM\AM\fastio.exe", "", @SW_HIDE) ;; Launch standard fastio.exe

If ProcessExists("fastio.exe") Then
   ProcessClose("fastio.exe")
EndIf