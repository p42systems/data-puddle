<#
.SYNOPSIS
Creates and configures a Power BI workspace with automated dataset connections
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$WorkspaceName,
    
    [Parameter(Mandatory=$true)]
    [ValidatePattern("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")]
    [string]$AdminEmail,
    
    [Parameter(Mandatory=$true)]
    [string]$SqlConnectionString
)

# Clean up existing modules
$modules = @(
    'MicrosoftPowerBIMgmt.Profile',
    'MicrosoftPowerBIMgmt.Workspaces',
    'MicrosoftPowerBIMgmt.Data'
)

foreach ($module in $modules) {
    if (Get-Module -Name $module) {
        Remove-Module $module -Force -ErrorAction SilentlyContinue
    }
}

# Install latest modules without version constraints
try {
    Install-Module -Name MicrosoftPowerBIMgmt -Force -AllowClobber -Scope CurrentUser
    Import-Module MicrosoftPowerBIMgmt -DisableNameChecking -Force
}
catch {
    Write-Error "Power BI module installation failed: $_"
    exit 1
}

# Modern authentication
try {
    Connect-PowerBIServiceAccount -Environment Public -Verbose
}
catch {
    Write-Error "Power BI authentication failed: $_"
    exit 1
}

# Create workspace with validation
try {
    $workspace = New-PowerBIWorkspace -Name $WorkspaceName -Verbose
    if (-not $workspace.Id) {
        throw "Workspace creation succeeded but returned invalid ID"
    }
    Write-Host "Workspace created: $($workspace.Id)"
}
catch {
    Write-Error "Workspace creation failed: $_"
    exit 1
}

# Add admin user with workspace ID validation
$retryCount = 0
do {
    try {
        Add-PowerBIWorkspaceUser -WorkspaceId $workspace.Id -UserEmail $AdminEmail -AccessRight Admin -Verbose
        Write-Host "Admin permissions added for $AdminEmail"
        break
    }
    catch {
        $retryCount++
        if ($retryCount -lt 3) {
            Write-Warning "Retrying permission assignment... (Attempt $retryCount)"
            Start-Sleep -Seconds 5
        }
        else {
            Write-Error "Failed to add user permissions after 3 attempts: $_"
            exit 1
        }
    }
} while ($true)

# Create dataset with connection validation
try {
    $datasetParams = @{
        Name = "AdventureWorks_Connection"
        DatasourceConnectionString = $SqlConnectionString
        Verbose = $true
    }

    $dataset = New-PowerBIDataset @datasetParams -WorkspaceId $workspace.Id
    Write-Host "Dataset created: $($dataset.Id)"
}
catch {
    Write-Error "Dataset creation failed: $_"
    exit 1
}

Write-Host "`n=== Deployment Successful ==="
Write-Host "Workspace Name: $WorkspaceName"
Write-Host "Workspace ID:   $($workspace.Id)"
Write-Host "Dataset ID:     $($dataset.Id)"
Write-Host "Admin Email:    $AdminEmail`n"