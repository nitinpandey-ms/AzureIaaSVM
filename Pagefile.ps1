<#

This script is created to configure Pagefile and Memory Dump in a chosen drive. 
The script will check if the chosen drive has enough free space to configure Pagefile and Memory Dump. 
If the drive has enough free space, then the script will configure Pagefile and Memory Dump in the chosen drive. 
If the drive does not have enough free space, then the script will ask the user to select another drive.


Note that both the Pagefile and Memory Dump are INTENTIONALLY configured in the same drive to avoid the Dump corruption issue.

User input and script progress logs are saved in C:\PagefileMemoryDumpConfiguration.log

#>

#Creaet a Function and call it
function Get-ChosenDrive {

    #Record all input and output to a log file
    Start-Transcript -Path C:\PagefileMemoryDumpConfiguration.log -Verbose

    #Select the drive where you want to configure the Pagefile and Memory Dump
    $drive = Read-Host "Enter the drive letter where you want to configure the Pagefile and Memory Dump (Example: D): "
    $chosendrive = $drive + ":"
    mkdir $drive\MemoryDump -Force
    Write-Host "The drive selected is $chosendrive" -ForegroundColor Red -BackgroundColor White
    
    #Check if the drive selected has enough free space to configure Pagefile and Memory Dump
    if ($drives | Where-Object {$_.DeviceID -eq $chosendrive -and $_.'FreeSpace(GB)' -ge $freeSpaceNeeded})
    {
        $chosendrivefreeSpace = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$chosendrive'" | Select-Object -ExpandProperty FreeSpace
        $chosendrivefreeSpaceGB = [math]::Round($chosendrivefreeSpace / 1GB, 2)
        $chosendrivetotalSpace = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$chosendrive'" | Select-Object -ExpandProperty Size
        $chosendrivetotalSpaceGB = [math]::Round($chosendrivetotalSpace / 1GB, 2)
        $chosendriveafterPagefileMemoryDumpfreeSpace = $chosendrivefreeSpaceGB - $freeSpaceNeeded
        $chosendriveafterPagefileMemoryDumpfreeSpacepercentage = [math]::Round(($chosendriveafterPagefileMemoryDumpfreeSpace / $chosendrivetotalSpaceGB) * 100, 2)
        Write-Host "$chosendrive drive has $chosendrivefreeSpaceGB GB free space out of $chosendrivetotalSpaceGB GB total space.`r`nAfter configuring Pagefile and Memory Dump, the drive will have $chosendriveafterPagefileMemoryDumpfreeSpace GB free space which is $chosendriveafterPagefileMemoryDumpfreeSpacepercentage% of the total space. `r`n" -ForegroundColor red -BackgroundColor white
        sleep 5

        #Set the Pagefile in chosen drive with 1.2 times size of RAM
        Write-Host "Configuring Pagefile..." -ForegroundColor red -BackgroundColor white
        sleep 5
        $pfdrive = $drive + ":" + "\pagefile.sys"
        wmic computersystem set AutomaticManagedPagefile=False
        wmic pagefileset set InitialSize=0,MaximumSize=0
        wmic pagefileset delete
        wmic pagefileset create name=$pfdrive
        wmic pagefileset set InitialSize=$pagefilesizeMB,MaximumSize=$pagefilesizeMB
        Write-Host "Pagefile configured successfully. `n" -ForegroundColor red -BackgroundColor white
        sleep 5

        <#Set the Memory Dump in chosen drive
        $drive = $drive + ":"
        Write-Host "`nSetting Memory Dump location to be $drive\MemoryDump\Memory.dmp..." -ForegroundColor red -BackgroundColor white
        sleep 5
        mkdir $drive\MemoryDump -Force
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl" /v DumpFile /t REG_EXPAND_SZ /d "$chosendrive\MemoryDump\Memory.dmp" /f
        Write-Host "Memory Dump location set successfully to $chosendrive\MemoryDump\Memory.dmp." -ForegroundColor red -BackgroundColor white
        sleep 5 #>

        #Setting Memory Dump location, to be a Full Memory Dump and enable NMI (Non-Maskable Interrupt) to capture the Memory Dump
        Write-Host "Setting Memory Dump location as $chosendrive\MemoryDump\Memory.dmp, to be a Full Memory Dump and enable NMI (Non-Maskable Interrupt)..." -ForegroundColor red -BackgroundColor white
        sleep 5
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl" /v CrashDumpEnabled /t REG_DWORD /d 1 /f 
        Write-Host "Memory Dump is successfully set to be Full Memory Dump." -ForegroundColor red -BackgroundColor white
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl" /v DumpFile /t REG_EXPAND_SZ /d  "$chosendrive\MemoryDump\Memory.dmp" /f
        Write-Host "Memory Dump location set successfully to $chosendrive\MemoryDump\Memory.dmp." -ForegroundColor red -BackgroundColor white
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl" /v NMICrashDump /t REG_DWORD /d 1 /f
        Write-Host "NMI (Non-Maskable Interrupt) is successfully enabled to capture the Memory Dump.`n" -ForegroundColor red -BackgroundColor white
        sleep 5
        
        #Popup a message box asking user if they want to restart the server now or later. If Yes, then restart the server. If No, then exit the script with a message suggesting to restart the server for the changes to take effect.
        $result = Read-Host "Do you want to restart the server now? (Y/N): "
        if ($result -eq "Y" -or $result -eq "y")
        {
            Write-Host "You have chosen to restart the server now. The server will restart in few seconds" -ForegroundColor red -BackgroundColor white
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show("The server will restart in few seconds", "Restart Server")
            sleep 5
            Restart-Computer -Force
        }
        else
        {
            Write-Host "You have chosen to restart the server later. Please restart the server at your earliest convenience for the changes to take effect." -ForegroundColor red -BackgroundColor white
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show("Please restart the server at your earliest convenience for the changes to take effect.", "Restart Server")
        }
    }
    else
    {
        #Send message to user that the drive selected does not have enough free space to configure Pagefile and Memory Dump
        Write-Host "The drive selected does not have enough free space to configure Pagefile and Memory Dump. Please select another drive." -ForegroundColor red -BackgroundColor white
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("The drive selected does not have enough free space to configure Pagefile and Memory Dump. Please select another drive.", "Pagefile and Memory Dump Configuration", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

        Get-ChosenDrive

    }
Stop-Transcript
}

#Get size of RAM in GB
$ram = Get-WmiObject -Class Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | Select-Object -ExpandProperty Sum
$ramGB = [math]::Round($ram / 1GB, 2)

#Recommended Pagefile size
$pagefilesize = $ramGB * 1.2
$pagefilesizeMB = [math]::Round($pagefilesize * 1024, 2)

#Free space needed to capture memory dump (Pagefile X 1.2 + size of RAM in GB)
$freeSpaceNeeded = [math]::Round($ramGB * 1.2, 2) + $ramGB

#Get Total space, Free space and Percentage free space of all the drives except the drive labelled as "Temporary Drive"
$drives = Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.VolumeName -ne "Temporary Storage"} | Select-Object DeviceID, @{Name="TotalSize(GB)";Expression={[math]::Round($_.Size / 1GB, 2)}}, @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace / 1GB, 2)}}, @{Name="PercentFree";Expression={[math]::Round(($_.FreeSpace / $_.Size) * 100, 2)}}
$drives | Format-Table -AutoSize


Get-ChosenDrive

