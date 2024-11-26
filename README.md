# on-demo-vdi

Demo for KASM Workspaces. 

## Development KASM

- License: Community
- URL: https://vdi.dev.ontracon.cloud

## Production KASM

- License: Enterprise
- URL: https://vdi.ontracon.cloud



# Used Windows 11 Images

```json
{
  "id": "/subscriptions/da733702-a697-4e22-bb0b-8c3e60bb51db/resourceGroups/on-vdi-images-rg/providers/Microsoft.Compute/galleries/VDI/images/Base/versions/1.0.1"
}
```

Germany:
```json
{
"architecture": "x64",
"offer": "windows-ent-cpc",
"publisher": "MicrosoftWindowsDesktop",
"sku": "win11-23h2-ent-cpc-os",
"urn": "MicrosoftWindowsDesktop:windows-ent-cpc:win11-23h2-ent-cpc-os:22631.3296.240312",
"version": "22631.3296.240312"
}
```

EastUS:
```json
{
"architecture": "x64",
"offer": "windows-ent-cpc",
"publisher": "MicrosoftWindowsDesktop",
"sku": "win11-23h2-ent-cpc",
"urn": "MicrosoftWindowsDesktop:windows-ent-cpc:win11-23h2-ent-cpc:22631.4169.240910",
"version": "22631.4169.240910"
}
```

```powershell
#ps1_sysnative
net stop kasm
cd "C:\Program Files\Kasm"
.\agent.exe --register-host {upstream_auth_address} --register-port 443 --server-id  {server_id} --register-token {checkin_jwt}
net start kasm
```

Firewall:
New-NetFirewallRule -DisplayName 'KASM' -LocalPort 4902 -Action Allow -Profile 'Any' -Protocol TCP -Direction 
Inbound -EdgeTraversalPolicy Allow

Current Startup script:
```powershell
#ps1_sysnative

New-EventLog -LogName Application -Source kasm_startup_script
Write-EventLog -LogName "Application" -Source "kasm_startup_script" -EventID 1000 -EntryType Information -Message "Startup script has started."

Function Install-Winfsp {{
Write-EventLog -LogName "Application" -Source "kasm_startup_script" -EventID 1000 -EntryType Information -Message "Installing Winsfp"
Invoke-WebRequest -Uri $winfsp_url -OutFile $Env:temp\$winfsp_msi
Write-Host "Installing WinFSP"
Start-Process -FilePath $Env:temp\$winfsp_msi -ArgumentList '/q' -WorkingDirectory "C:\Windows\Temp\" -Wait
Remove-Item $Env:temp\$winfsp_msi -Force
}}

$user_home = "$profile_dir\$username"
$ProgressPreference = 'SilentlyContinue'
$winfsp_url = "https://github.com/winfsp/winfsp/releases/download/v2.0/winfsp-2.0.23075.msi"
$winfsp_msi = "winfsp-2.0.23075.msi"
$rclone_url = "https://github.com/rclone/rclone/releases/download/v1.68.0/rclone-v1.68.0-windows-amd64.zip"
$rclone_zip = "rclone-v1.68.0-windows-amd64.zip"
$rclone_bin = "C:\Program Files\Kasm\bin\rclone.exe"

# Download and install the Kasm Service
Write-EventLog -LogName "Application" -Source "kasm_startup_script" -EventID 1000 -EntryType Information -Message "Downloading Windows Service"
Invoke-Webrequest -URI https://kasm-static-content.s3.us-east-1.amazonaws.com/kasm_windows_service_installer_x86_64_1.5_5972ac21d.exe -OutFile C:\Users\Public\Downloads\kasm_service_installer.exe

Write-EventLog -LogName "Application" -Source "kasm_startup_script" -EventID 1000 -EntryType Information -Message "Installing Windows Service"
C:\Users\Public\Downloads\kasm_service_installer.exe /S

# Optionally download and install Winfsp, required for Cloud Storage Mapping to work
Install-Winfsp

for ($i = 1; $i -le 20; $i++) {{
Start-Sleep -s 3
$service = Get-Service -Name W32Time -ErrorAction SilentlyContinue

    if ($service.Length -gt 0 -And (Test-Path -Path "C:\Users\Public\Downloads\kasm_service_installer.exe" -PathType Leaf)) {{
        # Register the Kasm Service with the deployment
        Write-EventLog -LogName "Application" -Source "kasm_startup_script" -EventID 1000 -EntryType Information -Message "Registering the Windows Service with the Kasm deployment at {upstream_auth_address}"
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
        net stop kasm
        cd "C:\Program Files\Kasm"
        .\agent.exe --register-host {upstream_auth_address} --register-port 443 --server-id  {server_id} --register-token {checkin_jwt}
        
        if ($LastExitCode -eq 0) {{
            net start kasm
            Start-Service -Name "Audiosrv"
            Write-EventLog -LogName "Application" -Source "kasm_startup_script" -EventID 1000 -EntryType Information -Message "Successfully installed and registered agent"
            Exit 0
        }} else {{
            Write-EventLog -LogName "Application" -Source "kasm_startup_script" -EventID 1000 -EntryType Error -Message "Registration of Agent failed: Check log output of kasm_service in EventViewer"
            
            Exit 1
        }}
    }} else {{
        Write-EventLog -LogName "Application" -Source "kasm_startup_script" -EventID 1000 -EntryType Information -Message "Service not found, trying again..."
    }}
}}

Write-EventLog -LogName "Application" -Source "kasm_startup_script" -EventID 1000 -EntryType Error -Message "Timed out waiting for Kasm Windows Service to be registered."
Exit 1
```