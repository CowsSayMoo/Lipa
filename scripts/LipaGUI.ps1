Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# --- Style Configuration ---
$theme = @{
    BackgroundColor = [System.Drawing.ColorTranslator]::FromHtml("#5DBADF") # Lipa Light Blue
    TitleBarColor = [System.Drawing.ColorTranslator]::FromHtml("#F5F5F5") # Light grey title bar
    TabActiveColor = [System.Drawing.ColorTranslator]::FromHtml("#5DBADF") # Blue for active tab
    TabInactiveColor = [System.Drawing.ColorTranslator]::FromHtml("#E0E0E0") # Grey for inactive
    ButtonColor     = [System.Drawing.ColorTranslator]::FromHtml("#FFFFFF") # White buttons
    ButtonHoverColor = [System.Drawing.ColorTranslator]::FromHtml("#F0F0F0") # Light grey on hover
    ButtonTextColor = [System.Drawing.ColorTranslator]::FromHtml("#5DBADF") # Blue text on buttons
    TitleColor      = [System.Drawing.Color]::White
    DarkTextColor   = [System.Drawing.ColorTranslator]::FromHtml("#333333") # Dark text
    FontFamily      = "Segoe UI"
    TitleFontSize   = 28
    SubtitleFontSize = 9
    ButtonFontSize  = 11
    ChecklistFontSize = 10
}

# --- Main Form (Borderless) ---
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$mainForm.Size = New-Object System.Drawing.Size(500, 550)
$mainForm.StartPosition = "CenterScreen"
$mainForm.BackColor = $theme.BackgroundColor

# Enable dragging the form
$isDragging = $false
$dragStartPoint = New-Object System.Drawing.Point(0, 0)

# --- Custom Title Bar ---
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Location = New-Object System.Drawing.Point(0, 0)
$titleBar.Size = New-Object System.Drawing.Size(500, 40)
$titleBar.BackColor = $theme.TitleBarColor
$mainForm.Controls.Add($titleBar)

# Make title bar draggable
$titleBar.Add_MouseDown({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:isDragging = $true
        $script:dragStartPoint = $e.Location
    }
})

$titleBar.Add_MouseMove({
    param($sender, $e)
    if ($script:isDragging) {
        $currentPos = $mainForm.PointToScreen($e.Location)
        $newPos = New-Object System.Drawing.Point(
            ($currentPos.X - $script:dragStartPoint.X),
            ($currentPos.Y - $script:dragStartPoint.Y)
        )
        $mainForm.Location = $newPos
    }
})

$titleBar.Add_MouseUp({
    param($sender, $e)
    $script:isDragging = $false
})

# --- Window Icon/Title ---
$windowTitle = New-Object System.Windows.Forms.Label
$windowTitle.Text = "⬜ Lipa Support Tools"
$windowTitle.Font = New-Object System.Drawing.Font($theme.FontFamily, 9, [System.Drawing.FontStyle]::Regular)
$windowTitle.ForeColor = $theme.DarkTextColor
$windowTitle.AutoSize = $true
$windowTitle.Location = New-Object System.Drawing.Point(10, 12)
$titleBar.Controls.Add($windowTitle)

# Make title draggable too
$windowTitle.Add_MouseDown({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:isDragging = $true
        $script:dragStartPoint = $e.Location
    }
})

$windowTitle.Add_MouseMove({
    param($sender, $e)
    if ($script:isDragging) {
        $currentPos = $mainForm.PointToScreen($e.Location)
        $newPos = New-Object System.Drawing.Point(
            ($currentPos.X - $script:dragStartPoint.X),
            ($currentPos.Y - $script:dragStartPoint.Y)
        )
        $mainForm.Location = $newPos
    }
})

$windowTitle.Add_MouseUp({
    param($sender, $e)
    $script:isDragging = $false
})

# --- Tab Buttons in Title Bar ---
function New-TitleBarTab {
    param (
        [string]$Text,
        [int]$Left,
        [bool]$IsActive = $false
    )
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Font = New-Object System.Drawing.Font($theme.FontFamily, 9, [System.Drawing.FontStyle]::Regular)
    $button.ForeColor = if ($IsActive) { [System.Drawing.Color]::White } else { $theme.DarkTextColor }
    $button.Size = New-Object System.Drawing.Size(90, 30)
    $button.Location = New-Object System.Drawing.Point($Left, 5)
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.FlatAppearance.BorderSize = 0
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $button.BackColor = if ($IsActive) { $theme.TabActiveColor } else { $theme.TabInactiveColor }
    
    $titleBar.Controls.Add($button)
    return $button
}

$scriptsTabButton = New-TitleBarTab -Text "Scripts" -Left 220 -IsActive $true
$checklistTabButton = New-TitleBarTab -Text "Checklist" -Left 315 -IsActive $false

# --- Window Control Buttons ---
# Minimize Button
$minimizeBtn = New-Object System.Windows.Forms.Button
$minimizeBtn.Text = "─"
$minimizeBtn.Size = New-Object System.Drawing.Size(35, 30)
$minimizeBtn.Location = New-Object System.Drawing.Point(410, 5)
$minimizeBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$minimizeBtn.FlatAppearance.BorderSize = 0
$minimizeBtn.BackColor = $theme.TitleBarColor
$minimizeBtn.ForeColor = $theme.DarkTextColor
$minimizeBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$minimizeBtn.Add_Click({ $mainForm.WindowState = [System.Windows.Forms.FormWindowState]::Minimized })
$minimizeBtn.Add_MouseEnter({ $minimizeBtn.BackColor = [System.Drawing.Color]::LightGray })
$minimizeBtn.Add_MouseLeave({ $minimizeBtn.BackColor = $theme.TitleBarColor })
$titleBar.Controls.Add($minimizeBtn)

# Close Button
$closeBtn = New-Object System.Windows.Forms.Button
$closeBtn.Text = "✕"
$closeBtn.Size = New-Object System.Drawing.Size(35, 30)
$closeBtn.Location = New-Object System.Drawing.Point(455, 5)
$closeBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$closeBtn.FlatAppearance.BorderSize = 0
$closeBtn.BackColor = $theme.TitleBarColor
$closeBtn.ForeColor = $theme.DarkTextColor
$closeBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$closeBtn.Add_Click({ $mainForm.Close() })
$closeBtn.Add_MouseEnter({ 
    $closeBtn.BackColor = [System.Drawing.Color]::Red
    $closeBtn.ForeColor = [System.Drawing.Color]::White
})
$closeBtn.Add_MouseLeave({ 
    $closeBtn.BackColor = $theme.TitleBarColor
    $closeBtn.ForeColor = $theme.DarkTextColor
})
$titleBar.Controls.Add($closeBtn)

# --- Content Area ---
$contentArea = New-Object System.Windows.Forms.Panel
$contentArea.Location = New-Object System.Drawing.Point(0, 40)
$contentArea.Size = New-Object System.Drawing.Size(500, 510)
$contentArea.BackColor = $theme.BackgroundColor
$mainForm.Controls.Add($contentArea)

# --- Lipa Title in Content ---
$lipaTitle = New-Object System.Windows.Forms.Label
$lipaTitle.Text = "lipa"
$lipaTitle.Font = New-Object System.Drawing.Font($theme.FontFamily, $theme.TitleFontSize, [System.Drawing.FontStyle]::Regular)
$lipaTitle.ForeColor = $theme.TitleColor
$lipaTitle.AutoSize = $true
$lipaTitle.Location = New-Object System.Drawing.Point(30, 20)
$contentArea.Controls.Add($lipaTitle)

# --- Subtitle ---
$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "ICT support geklopt"
$subtitleLabel.Font = New-Object System.Drawing.Font($theme.FontFamily, $theme.SubtitleFontSize, [System.Drawing.FontStyle]::Regular)
$subtitleLabel.ForeColor = $theme.TitleColor
$subtitleLabel.AutoSize = $true
$subtitleLabel.Location = New-Object System.Drawing.Point(30, 60)
$contentArea.Controls.Add($subtitleLabel)

# --- Scripts Content Panel ---
$scriptsContent = New-Object System.Windows.Forms.Panel
$scriptsContent.Location = New-Object System.Drawing.Point(0, 90)
$scriptsContent.Size = New-Object System.Drawing.Size(500, 370)
$scriptsContent.BackColor = $theme.BackgroundColor
$scriptsContent.Visible = $true
$contentArea.Controls.Add($scriptsContent)

# --- Checklist Content Panel ---
$checklistContent = New-Object System.Windows.Forms.Panel
$checklistContent.Location = New-Object System.Drawing.Point(0, 90)
$checklistContent.Size = New-Object System.Drawing.Size(500, 370)
$checklistContent.BackColor = [System.Drawing.Color]::White
$checklistContent.Visible = $false
$contentArea.Controls.Add($checklistContent)

# --- Tab Button Click Handlers ---
$scriptsTabButton.Add_Click({
    $scriptsTabButton.BackColor = $theme.TabActiveColor
    $scriptsTabButton.ForeColor = [System.Drawing.Color]::White
    $checklistTabButton.BackColor = $theme.TabInactiveColor
    $checklistTabButton.ForeColor = $theme.DarkTextColor
    $scriptsContent.Visible = $true
    $checklistContent.Visible = $false
    $scriptsContent.BringToFront()
    $lipaTitle.Visible = $true
    $subtitleLabel.Visible = $true
})

$checklistTabButton.Add_Click({
    $checklistTabButton.BackColor = $theme.TabActiveColor
    $checklistTabButton.ForeColor = [System.Drawing.Color]::White
    $scriptsTabButton.BackColor = $theme.TabInactiveColor
    $scriptsTabButton.ForeColor = $theme.DarkTextColor
    $checklistContent.Visible = $true
    $scriptsContent.Visible = $false
    $checklistContent.BringToFront()
    $lipaTitle.Visible = $false
    $subtitleLabel.Visible = $false
})

# --- Button Creation Function ---
function New-StyledButton {
    param (
        [string]$Text,
        [int]$Top,
        [System.Windows.Forms.Control]$Parent
    )
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Font = New-Object System.Drawing.Font($theme.FontFamily, $theme.ButtonFontSize, [System.Drawing.FontStyle]::Regular)
    $button.BackColor = $theme.ButtonColor
    $button.ForeColor = $theme.ButtonTextColor
    $button.Size = New-Object System.Drawing.Size(430, 55)
    $button.Location = New-Object System.Drawing.Point(30, $Top)
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.FlatAppearance.BorderSize = 0
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    $button.Add_MouseEnter({ $this.BackColor = $theme.ButtonHoverColor })
    $button.Add_MouseLeave({ $this.BackColor = $theme.ButtonColor })
    
    $Parent.Controls.Add($button)
    return $button
}

# --- Create Buttons in Scripts Tab ---
$installButton = New-StyledButton -Text "Install Packages" -Top 0 -Parent $scriptsContent
$endpointButton = New-StyledButton -Text "Endpoint Config" -Top 70 -Parent $scriptsContent
$ticketButton = New-StyledButton -Text "Create Ticket" -Top 140 -Parent $scriptsContent

# --- Checklist Title ---
$checklistTitle = New-Object System.Windows.Forms.Label
$checklistTitle.Text = "Endpoint Configuration Checklist"
$checklistTitle.Font = New-Object System.Drawing.Font($theme.FontFamily, 14, [System.Drawing.FontStyle]::Bold)
$checklistTitle.ForeColor = $theme.ButtonTextColor
$checklistTitle.AutoSize = $true
$checklistTitle.Location = New-Object System.Drawing.Point(30, 15)
$checklistContent.Controls.Add($checklistTitle)

# --- Checklist Items ---
$checklistItems = @(
    "Verify network connectivity",
    "Check Windows updates status",
    "Confirm antivirus is active and updated",
    "Test domain connection",
    "Verify user permissions",
    "Check disk space availability",
    "Confirm backup configuration",
    "Test printer connectivity",
    "Verify email configuration",
    "Check system event logs",
    "Confirm software installations",
    "Test remote access capabilities"
)

$checkedListBox = New-Object System.Windows.Forms.CheckedListBox
$checkedListBox.Location = New-Object System.Drawing.Point(30, 55)
$checkedListBox.Size = New-Object System.Drawing.Size(430, 300)
$checkedListBox.Font = New-Object System.Drawing.Font($theme.FontFamily, $theme.ChecklistFontSize, [System.Drawing.FontStyle]::Regular)
$checkedListBox.CheckOnClick = $true
$checkedListBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

foreach ($item in $checklistItems) {
    [void]$checkedListBox.Items.Add($item)
}

$checklistContent.Controls.Add($checkedListBox)

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

# --- Footer Label ---
$footerLabel = New-Object System.Windows.Forms.Label
$footerLabel.Text = "Made with ♥ by CowsSayMoo"
$footerLabel.Font = New-Object System.Drawing.Font($theme.FontFamily, 9, [System.Drawing.FontStyle]::Regular)
$footerLabel.ForeColor = $theme.TitleColor
$footerLabel.AutoSize = $true
$footerLabel.Location = New-Object System.Drawing.Point(30, 470)
$contentArea.Controls.Add($footerLabel)

# --- Show Form ---
$mainForm.ShowDialog()