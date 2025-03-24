param(
    [string]$WorkspaceName,
    [string]$AdminEmail
)

Install-Module -Name MicrosoftPowerBIMgmt -Force
Connect-PowerBIServiceAccount

# Create workspace
$workspace = New-PowerBIWorkspace -Name $WorkspaceName

# Configure access
Add-PowerBIWorkspaceUser -Id $workspace.Id -UserEmail $AdminEmail -AccessRight Admin

# Data source configuration
$datasetParams = @{
    Name = "AdventureWorks"
    ConnectionString = "Server=localhost;Database=AdventureWorks;User ID=analyst;Password=P@ssw0rd123"
}

New-PowerBIDataset @datasetParams