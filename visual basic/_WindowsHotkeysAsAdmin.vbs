CreateObject( "WScript.Shell" ).Run "PowerShell -Command ""EnsureProcessIsRunning -Name 'Autohotkey' -Path 'C:\Program Files\AutoHotkey\Autohotkey.exe' -Args ((${HOME})+('\Documents\GitHub\Coding\ahk\_WindowsHotkeys.ahkv2')) -AsAdmin -Quiet;"" ", 0, True

' Program/script:   C:\Windows\System32\wscript.exe
' Add arguments:    "%USERPROFILE%\Documents\GitHub\Coding\visual basic\_WindowsHotkeysAsAdmin.vbs"

' Trigger: At log on
