#Open a pop up box to chose the file

Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{InitialDirectory = [Environment]::GetFolderPath('Desktop')}
$null = $FileBrowser.ShowDialog()
$FileBrowser.FileName
$folder = Split-Path -Path $FileBrowser.FileName

#Get the file path
$File = $FileBrowser.FileName

#Get the key words
$KeyWords = Read-Host "Enter the key words that you want to search for: "

#Get the event log
$EventLog = Get-WinEvent -Path $File

#Search for the key words
$EventLog | Where-Object {$_.Message -like "*$KeyWords*"} | Format-List

#Save the results to a file
$EventLog | Where-Object {$_.Message -like "*$KeyWords*"} | Format-List | Out-File $Folder\$KeyWords"_Results.txt"

#Open the results file
Invoke-Item $Folder\$KeyWords_Results.txt

#Clear the screen
Clear-Host

#Exit the script
