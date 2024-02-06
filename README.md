	- Download https://github.com/nitinpandey-ms/AzureIaaSVM/blob/main/Pagefile.ps1 in the server where we are changing the Pagefile
	- Open PowerShell as Administrator.
	- Execute this command: Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force
	- If there is a Security Warning as below, press R and proceed
	
	
	
	
	- The first output that this script shows is the total size and free space of all disks.
	- Calculate and chose a drive in which we can accommodate the size of (RAM * 2) + 10 GB
	- For example, if size of RAM is 8 GB, then chose a drive where free space is at least (8 * 2) + 10 GB = 26 GB
	
	
	
	- If we accidentally select a drive which does not have enough free space as per above calculations, this message will be shown:
	
	
	
	- Once you select the drive with right amount of space, it will show how much free space would be left in that drive after PageFile is configured and Memory Dump is captured.
	- Then it will automatically configure Pagefile in chosen drive + change Memory Dump location to chosen drive + configure it to capture a Full Memory Dump + enable NMI in case we need to capture Memory Dump through NMI Interrupt of Serial Console.
	
	
	
	- At the end, it will ask whether you want to restart the server now or later.
	- If you chose No, the server will not restart now and you can chose to restart it later when suitable.
	- This message will be displayed if N is chosen
	
	
	
	- If you need to test whether the Memory Dump is collected successfully
	OR
	If you need to collect the Memory Dump when the issue resurfaces, you can send NMI interrupt to the virtual machine by following below clicks:
	
	

	- Below screen will show suggesting that the Memory Dump is in process of collection. It goes through mentioned three stages. The server will restart automatically after it has collected the Memory Dump file. 
	- The amount of time the dump collection takes depends upon the size of RAM in the virtual machine. The smaller the RAM, the quicker the dump file is generated.

	

![Uploading image.png…]()
