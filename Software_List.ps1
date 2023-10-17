#Use WMIC to query list of installed software
$SoftwareList = Get-WmiObject -Class Win32_Product | Select-Object -Property Name, Version, Vendor, InstallDate, InstallLocation, PackageName, IdentifyingNumber | Sort-Object -Property Name

#Create a new Excel workbook
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $True
$Excel = $Excel.Workbooks.Add()

#Add a new worksheet
$Sheet = $Excel.Worksheets.Add()

#Set the column headers
$Sheet.Cells.Item(1,1) = "Name"
$Sheet.Cells.Item(1,2) = "Version"
$Sheet.Cells.Item(1,3) = "Vendor"
$Sheet.Cells.Item(1,4) = "InstallDate"
$Sheet.Cells.Item(1,5) = "InstallLocation"
$Sheet.Cells.Item(1,6) = "PackageName"
$Sheet.Cells.Item(1,7) = "IdentifyingNumber"

#Set the column headers to bold
$Sheet.Rows.Item(1).Font.Bold = $True

#Populate the spreadsheet with the software list
$Row = 2
$Column = 1
ForEach ($Software in $SoftwareList) {
    $Sheet.Cells.Item($Row,$Column) = $Software.Name
    $Sheet.Cells.Item($Row,$Column+1) = $Software.Version
    $Sheet.Cells.Item($Row,$Column+2) = $Software.Vendor
    $Sheet.Cells.Item($Row,$Column+3) = $Software.InstallDate
    $Sheet.Cells.Item($Row,$Column+4) = $Software.InstallLocation
    $Sheet.Cells.Item($Row,$Column+5) = $Software.PackageName
    $Sheet.Cells.Item($Row,$Column+6) = $Software.IdentifyingNumber
    $Row++
}

#Autofit the columns
$Sheet.Columns.Item(1).AutoFit() | Out-Null
$Sheet.Columns.Item(2).AutoFit() | Out-Null
$Sheet.Columns.Item(3).AutoFit() | Out-Null
$Sheet.Columns.Item(4).AutoFit() | Out-Null
$Sheet.Columns.Item(5).AutoFit() | Out-Null
$Sheet.Columns.Item(6).AutoFit() | Out-Null
$Sheet.Columns.Item(7).AutoFit() | Out-Null

#Save the spreadsheet
$Excel.SaveAs("C:\temp\SoftwareList.xlsx")



