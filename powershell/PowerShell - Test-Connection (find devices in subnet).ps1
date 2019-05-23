
Function Test-ComputerConnection
{
	# FUNCTION REQUIREMENTS --> POWERSHELL v6+
	<#	
		.SYNOPSIS
			Test-ComputerConnection sends a ping to the specified computer or IP Address specified in the ComputerName parameter.
		
		.DESCRIPTION
			Test-ComputerConnection sends a ping to the specified computer or IP Address specified in the ComputerName parameter. Leverages the System.Net object for ping
			and measures out multiple seconds faster than Test-Connection -Count 1 -Quiet.
		
		.PARAMETER ComputerName
			The name or IP Address of the computer to ping.

		.EXAMPLE
			Test-ComputerConnection -ComputerName "THATPC"
			
			Tests if THATPC is online and returns a custom object to the pipeline.
			
		.EXAMPLE
			$MachineState = Import-CSV .\computers.csv | Test-ComputerConnection -Verbose
		
			Test each computer listed under a header of ComputerName, MachineName, CN, or Device Name in computers.csv and
			and stores the results in the $MachineState variable.
			
	#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$True,
		ValueFromPipeline=$True, ValueFromPipelinebyPropertyName=$true)]
		[alias("CN","MachineName","Device Name")]
		[string]$ComputerName	
	)
	Begin
	{
		[int]$timeout = 20
		[switch]$resolve = $true
		[int]$TTL = 128
		[switch]$DontFragment = $false
		[int]$buffersize = 32
		$options = new-object system.net.networkinformation.pingoptions
		$options.TTL = $TTL
		$options.DontFragment = $DontFragment
		$buffer=([system.text.encoding]::ASCII).getbytes("a"*$buffersize)	
	}
	Process
	{
		$ping = New-Object system.net.networkinformation.ping;

		Try {
			$reply = $ping.Send($ComputerName,$timeout,$buffer,$options)	
		} Catch {
			$ErrorMessage = $_.Exception.Message
		}
		
		If ($reply.status -eq "Success") {
			$props = @{ComputerName=$ComputerName
						Online=$True
			}
		} Else {
			$props = @{ComputerName=$ComputerName
						Online=$False			
			}
		}
		New-Object -TypeName PSObject -Property $props
	}
	End{};
}

$TotalMilliseconds_TestConn = 0.0;
$TotalMilliseconds_TestComputerConn = 0.0;
$TotalMilliseconds_DnsLookupHostname = 0.0;

$LogFile_IPv4Addresses = ("${HOME}/Desktop/NetworkDevice.IPv4Addresses.$(Get-Date -UFormat '%Y-%m-%d_%H-%M-%S').log");
$LogFile_Hostnames = ("${HOME}/Desktop/NetworkDevice.Hostnames.$(Get-Date -UFormat '%Y-%m-%d_%H-%M-%S').log");

$private_network_cidr = @();
$private_network_cidr += "10.0.0.0/8";
$private_network_cidr += "172.16.0.0/12";
$private_network_cidr += "192.168.0.0/16";

$ipv4_ranges = @();

$ipv4_val1 = 192; $ipv4_val1_subnet2 = 10;
$ipv4_val2 = 168; $ipv4_val2_subnet2 = 2;
$ipv4_val3_start = 1; $ipv4_val3_max = 255;
$ipv4_val4_start = 1; $ipv4_val4_max = 255;


For ($ipv4_val3=$ipv4_val3_start; $ipv4_val3 -Le $ipv4_val3_max; $ipv4_val3++) {

	If (($ipv4_val1 -Eq 192) -And ($ipv4_val3 -Ge ($ipv4_val3_max-1))) {
		$ipv4_val1 = $ipv4_val1_subnet2;
		$ipv4_val2 = $ipv4_val2_subnet2;
		$ipv4_val3 = $ipv4_val3_start;
	}

	Write-Host "";

	For ($ipv4_val4=$ipv4_val4_start; $ipv4_val4 -Le $ipv4_val4_max; $ipv4_val4++) {

		$EachIPv4 = "${ipv4_val1}.${ipv4_val2}.${ipv4_val3}.${ipv4_val4}";

		Write-Host "${EachIPv4}  |  " -NoNewLine;

		# $Measure_TestConn = Measure-Command {
		# 	$TestConn = (Test-Connection -Quiet -Ping -Count (1) -ComputerName ("${EachIPv4}") -ErrorAction ("SilentlyContinue") -InformationAction ("Ignore") 6> $Null);
		# };
		# $TotalMilliseconds_TestConn += $Measure_TestConn.TotalMilliseconds;

		$Measure_TestComputerConn = Measure-Command {
			$TestComputerConn = (Test-ComputerConnection -ComputerName ("${EachIPv4}"));
		};
		$TotalMilliseconds_TestComputerConn += $Measure_TestConn.TotalMilliseconds;

		# If (($TestConn -Eq $True)) {
		If (($TestComputerConn.Online -Eq $True)) {

			Write-Host "Exists" -ForegroundColor ("Green");

			Add-Content -Path ("${LogFile_IPv4Addresses}") -Value ("${EachIPv4}");

			If ($False) {
				
				# $Measure_TestNetConn = Measure-Command {
				# 	$TestNetConn = (Test-NetConnection -InformationLevel ("Detailed") -ComputerName ("${EachIPv4}"));
				# };

				$Revertable_ErrorActionPreference = $ErrorActionPreference; $ErrorActionPreference = ("SilentlyContinue");
				$Measure_DnsLookupHostname = Measure-Command {
					$DnsLookupHostname = ([System.Net.Dns]::GetHostByAddress("${EachIPv4}")); $DnsLookupSuccess = $?;
				};
				$TotalMilliseconds_DnsLookupHostname += $Measure_DnsLookupHostname.TotalMilliseconds;
				$ErrorActionPreference = $Revertable_ErrorActionPreference;

				If (($DnsLookupHostname -Ne $Null) -And ($DnsLookupSuccess -Eq $True)) {
					If ($DnsLookupHostname.HostName -Ne $Null) {
						Add-Content -Path ("${LogFile_Hostnames}") -Value ($DnsLookupHostname.HostName);
					}
				}

			}
		} Else {
			Write-Host "No-Response" -ForegroundColor ("Red");
			If ($ipv4_val4 -Eq 1) {
				Break;
			}
		}

	}
}

# Add-Content -Path ("${LogFile_IPv4Addresses}") -Value ("`nTotalMilliseconds_TestConn = [ ${TotalMilliseconds_TestConn} ]");
# Add-Content -Path ("${LogFile_IPv4Addresses}") -Value ("`nTotalMilliseconds_TestComputerConn = [ ${TotalMilliseconds_TestComputerConn} ]");
# Add-Content -Path ("${LogFile_IPv4Addresses}") -Value ("`nTotalMilliseconds_DnsLookupHostname = [ ${TotalMilliseconds_DnsLookupHostname} ]");

# Add-Content -Path ("${LogFile_Hostnames}") -Value ("`nTotalMilliseconds_TestConn = [ ${TotalMilliseconds_TestConn} ]");
# Add-Content -Path ("${LogFile_Hostnames}") -Value ("`nTotalMilliseconds_TestComputerConn = [ ${TotalMilliseconds_TestComputerConn} ]");
# Add-Content -Path ("${LogFile_Hostnames}") -Value ("`nTotalMilliseconds_DnsLookupHostname = [ ${TotalMilliseconds_DnsLookupHostname} ]");



#
#	Citation(s)
#
#		"Test-ComputerConnection"
#				|--> Original code provided by Reddit user [ Kreloc ] on forum [ https://www.reddit.com/r/PowerShell/comments/3rnrj9 ]
#
#		"Best Current Practice ::: Address Allocation for Private Internets"
#			https://tools.ietf.org/html/rfc1918
#