Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# --- Style Configuration ---
$theme = @{
    BackgroundColor = [System.Drawing.ColorTranslator]::FromHtml("#F0F0F0") # Light Grey
    ButtonColor     = [System.Drawing.ColorTranslator]::FromHtml("#0078D4") # A nice shade of Blue
    TextColor       = [System.Drawing.Color]::White
    FontFamily      = "Segoe UI"
    TitleFontSize   = 24
    ButtonFontSize  = 12
}

# --- Main Form ---
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "Lipa Support Tools"
$mainForm.Size = New-Object System.Drawing.Size(400, 400)
$mainForm.StartPosition = "CenterScreen"
$mainForm.BackColor = $theme.BackgroundColor
$mainForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$mainForm.MaximizeBox = $false
$mainForm.MinimizeBox = $false

# --- Title Label ---
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Lipa"
$titleLabel.Font = New-Object System.Drawing.Font($theme.FontFamily, $theme.TitleFontSize, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = $theme.ButtonColor
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$mainForm.Controls.Add($titleLabel)

# --- Button Creation Function ---
function Create-StyledButton {
    param (
        [string]$Text,
        [int]$Top,
        [System.Windows.Forms.Form]$Form
    )
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Font = New-Object System.Drawing.Font($theme.FontFamily, $theme.ButtonFontSize, [System.Drawing.FontStyle]::Bold)
    $button.BackColor = $theme.ButtonColor
    $button.ForeColor = $theme.TextColor
    $button.Size = New-Object System.Drawing.Size(340, 50)
    $button.Location = New-Object System.Drawing.Point(20, $Top)
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.FlatAppearance.BorderSize = 0
    $Form.Controls.Add($button)
    return $button
}

# --- Create Buttons ---
$installButton = Create-StyledButton -Text "Install Packages" -Top 80 -Form $mainForm
$endpointButton = Create-StyledButton -Text "Endpoint Config" -Top 150 -Form $mainForm
$ticketButton = Create-StyledButton -Text "Create Ticket" -Top 220 -Form $mainForm

# --- Event Handlers ---
$installButton.Add_Click({
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -Command `"irm `"https://raw.githubusercontent.com/CowsSayMoo/Lipa/refs/heads/main/scripts/package-installation.ps1`" | iex`""
})

$endpointButton.Add_Click({
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -Command `"irm `"https://raw.githubusercontent.com/CowsSayMoo/Lipa/refs/heads/main/scripts/endpoint-configuration.ps1`" | iex`""
})

$ticketButton.Add_Click({
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -Command `"irm `"https://raw.githubusercontent.com/CowsSayMoo/Lipa/refs/heads/main/scripts/generate-ticket.ps1`" | iex`""
})

# --- Show Form ---
$mainForm.ShowDialog()