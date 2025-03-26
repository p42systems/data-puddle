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

# Rest of script remains unchanged from previous version...