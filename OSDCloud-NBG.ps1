#Variables to define the Windows OS / Edition etc to be applied during OSDCloud 
$OSName = 'Windows 11 23H2 x64'
$OSEdition = 'Pro'
$OSActivation = 'Retail'
$OSLanguage = 'sv-se'

#Variables Used by DriverPack
$Product = (Get-MyComputerProduct)
$Model = (Get-MyComputerModel)
$Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
$OSVersion = 'Windows 11' #Used to Determine Driver Pack
$OSReleaseID = '23H2' #Used to Determine Driver Pack

$Global:OSDCloud
#Set OSDCloud Vars
$Global:MyOSDCloud = [ordered]@{
    Restart = [bool]$False #Disables OSDCloud automatically restarting
    RecoveryPartition = [bool]$true #Ensures a Recover partition is created, True is default unless on VM
    OEMActivation = [bool]$True #Attempts to look up the Windows Code in UEFI and activate Windows OS (SetupComplete Phase)
    WindowsUpdate = [bool]$true #Runs Windows Updates during Setup Complete
    WindowsUpdateDrivers = [bool]$true #Runs WU for Drivers during Setup Complete
    WindowsDefenderUpdate = [bool]$true #Run Defender Platform and Def updates during Setup Complete
    SetTimeZone = [bool]$true #Set the Timezone based on the IP Address
    ClearDiskConfirm = [bool]$False #Skip the Confirmation for wiping drive before format
    ShutdownSetupComplete = [bool]$false #After Setup Complete, instead of Restarting to OOBE, just Shutdown
    SyncMSUpCatDriverUSB = [bool]$true #Sync any MS Update Drivers during WinPE to Flash Drive, saves time in future run
    CheckSHA1 = [bool]$true
    #SkipAutopilot = [bool]$false
    #SkipAutopilotOOBE = [bool]$false
}

<# Offline Driver Details
If you extract Driver Packs to your Flash Drive, you can DISM them in while in WinPE and it will make the process much faster, plus ensure driver support for first Boot
Extract to: OSDCLoudUSB:\OSDCloud\DriverPacks\DISM\$ComputerManufacturer\$ComputerProduct
Use OSD Module to determine Vars
$ComputerProduct = (Get-MyComputerProduct)
$ComputerManufacturer = (Get-MyComputerManufacturer -Brief)
#>

#Testing MS Update Catalog Driver Sync
#$Global:MyOSDCloud.DriverPackName = 'Microsoft Update Catalog'

#Used to Determine Driver Pack
$DriverPack = Get-OSDCloudDriverPack -Product $Product -OSVersion $OSVersion -OSReleaseID $OSReleaseID

if ($DriverPack){
    $Global:MyOSDCloud.DriverPackName = $DriverPack.Name
}

<#If Drivers are expanded on the USB Drive, disable installing a Driver Pack
if (Test-DISMFromOSDCloudUSB -eq $true){
    Write-Host "Found Driver Pack Extracted on Cloud USB Flash Drive, disabling Driver Download via OSDCloud" -ForegroundColor Green
    if ($Global:MyOSDCloud.SyncMSUpCatDriverUSB -eq $true){
        write-host "Setting DriverPackName to 'Microsoft Update Catalog'"
        $Global:MyOSDCloud.DriverPackName = 'Microsoft Update Catalog'
    }
    else {
        write-host "Setting DriverPackName to 'None'"
        $Global:MyOSDCloud.DriverPackName = "None"
    }
}
#>


#Launch OSDCloud
Write-Host "Starting OSDCloud" -ForegroundColor Green
write-host "Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage"

Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage

Set-WindowsProductKey C9N3Y-9VH6P-BGJFJ-JRY78-MTDGY

#Restart Computer from WInPE into Full OS to continue Process
restart-computer
