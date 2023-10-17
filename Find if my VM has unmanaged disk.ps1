#Find if my VM has unmanaged disk
$vm = Get-AzureRmVM -ResourceGroupName "myResourceGroup" -Name "myVM"
$vm.StorageProfile.OsDisk.ManagedDisk
$vm.StorageProfile.DataDisks.ManagedDisk
```
If the output is null, then the VM has unmanaged disk. If the output is not null, then the VM has managed disk.
For more details, please refer to the article.

Update:
If you want to get the VMs which have unmanaged disk, you can use the following script:
```
$vm = Get-AzVM -ResourceGroupName "myResourceGroup" -Name "myVM"
if($vm.StorageProfile.OsDisk.ManagedDisk -eq $null -or $vm.StorageProfile.DataDisks.ManagedDisk -eq $null)
{
    Write-Host "The VM has unmanaged disk"
}
else
{
    Write-Host "The VM has managed disk"
}
```


