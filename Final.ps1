[CmdletBinding()]
param (
  [Parameter(Mandatory=$True)]   
  $computername = 'localhost'
)
$logfile="C:\Final\"+$computername+"-"+$date+".txt"
$date=get-date -format "MM-dd-yyyy"

#1.	Gather IP Address and DHCP if available of remote computer.

Write-Output 'IP Address and DHCP' | out-file $logfile  

invoke-command -computername $computername -scriptblock {get-netipaddress -addressfamily ipv4 | select IPAddress,prefixorigin} | out-file $logfile -append

#2.	Gather DNS client server address used by remote computer.

Write-Output 'DNS Server Address' | out-file $logfile  -Append

invoke-command -computername $computername -scriptblock {Get-DnsClientServerAddress | Select ServerAddresses} | Out-file $logfile -append

#3.	Determine OS name, build, and version number of remote computer.

Write-Output 'OS name, build, Version' | out-file $logfile  -Append

Get-ciminstance -computername $computername win32_operatingsystem | select Name,BuildType,Version | Out-file $logfile -append

#4.	System memory in GB of remote computer.

Write-Output 'System Memory (GB)' | out-file $logfile  -Append

Get-CimInstance Win32_PhysicalMemory -computername $computername | Measure-Object -Property capacity -Sum | Foreach {"{0:N2}" -f ([math]::round(($_.Sum / 1GB),2))} | Out-File $logfile -Append

#5.	Processor name for remote computer.

Write-Output 'Processor Name' | out-file $logfile  -Append

Get-CimInstance Win32_processor -computername $computername | Select Name | Out-File $logfile -Append

#6.	Free space in GB for C: on each remote computer.

Write-Output 'Amount of Free Space on C: Drive' | out-file $logfile  -Append

get-ciminstance win32_logicaldisk -computername $computername -filter "deviceid='C:'" | select @{n="FreeSpace (GB)";e={$_.size/1GB}} | Out-File $logfile -Append

#7.	Last reboot performed by remote system.

Write-Output 'Last Reboot' | out-file $logfile  -Append

get-ciminstance win32_operatingsystem -computername $computername | select LastBootUpTime | Out-File $logfile -Append