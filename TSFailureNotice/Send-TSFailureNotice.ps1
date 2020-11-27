<#
    Show a custom UI that the current task sequence has failed. 
    User can fill out the form to receive assistance with the error received. 
    The form sends an email with the log files as an attachment. 
#>

$ErrorActionPreference = "SilentlyContinue"

function Start-Form {
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    
    $TSProgressUI = New-Object -ComObject Microsoft.SMS.TSProgressUI
    $TSProgressUI.CloseProgressDialog()
    $TSProgressUI = $null 
     
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $FailNotice                      = New-Object system.Windows.Forms.Form
    $FailNotice.ClientSize           = '482,361'
    $FailNotice.text                 = "Failure Notice*"
    $FailNotice.BackColor            = "#ffffff"
    $FailNotice.TopMost              = $false
    $FailNotice.FormBorderStyle      = "FixedDialog"

    $Title                           = New-Object system.Windows.Forms.Label
    $Title.text                      = "This task sequence has failed!"
    $Title.AutoSize                  = $true
    $Title.width                     = 25
    $Title.height                    = 10
    $Title.location                  = New-Object System.Drawing.Point(62,33)
    $Title.Font                      = 'Consolas,14,style=Bold'
    $Title.ForeColor                 = "#f50909"

    $GetAssistance                   = New-Object system.Windows.Forms.Label
    $GetAssistance.text              = "Fill out the form below to get assistance with this error. "
    $GetAssistance.AutoSize          = $true
    $GetAssistance.width             = 25
    $GetAssistance.height            = 10
    $GetAssistance.location          = New-Object System.Drawing.Point(21,65)
    $GetAssistance.Font              = 'Consolas,10'

    $Name                            = New-Object system.Windows.Forms.Label
    $Name.text                       = "Name*"
    $Name.AutoSize                   = $true
    $Name.width                      = 25
    $Name.height                     = 10
    $Name.location                   = New-Object System.Drawing.Point(20,101)
    $Name.Font                       = 'Consolas,10'

    $TxtName                         = New-Object system.Windows.Forms.TextBox
    $TxtName.multiline               = $false
    $TxtName.width                   = 144
    $TxtName.height                  = 20
    $TxtName.location                = New-Object System.Drawing.Point(67,101)
    $TxtName.Font                    = 'Consolas,10'
    $TxtName.TabIndex                = 1

    $TsName                          = New-Object system.Windows.Forms.Label
    $TsName.text                     = "TS Name*"
    $TsName.AutoSize                 = $true
    $TsName.width                    = 25
    $TsName.height                   = 10
    $TsName.location                 = New-Object System.Drawing.Point(227,101)
    $TsName.Font                     = 'Consolas,10'

    $TxtTsName                       = New-Object system.Windows.Forms.TextBox
    $TxtTsName.multiline             = $false
    $TxtTsName.width                 = 159
    $TxtTsName.height                = 20
    $TxtTsName.location              = New-Object System.Drawing.Point(295,101)
    $TxtTsName.Font                  = 'Consolas,10'
    $TxtTsName.TabIndex              = 2

    $Description                     = New-Object system.Windows.Forms.Label
    $Description.text                = "Additional Comments"
    $Description.AutoSize            = $true
    $Description.width               = 25
    $Description.height              = 10
    $Description.location            = New-Object System.Drawing.Point(22,194)
    $Description.Font                = 'Consolas,10'

    $TxtDescription                  = New-Object system.Windows.Forms.TextBox
    $TxtDescription.multiline        = $false
    $TxtDescription.width            = 451
    $TxtDescription.height           = 21
    $TxtDescription.location         = New-Object System.Drawing.Point(21,218)
    $TxtDescription.Font             = 'Consolas,10'
    $TxtDescription.TabIndex         = 4

    $Send                            = New-Object system.Windows.Forms.Button
    $Send.text                       = "Send"
    $Send.width                      = 60
    $Send.height                     = 30
    $Send.location                   = New-Object System.Drawing.Point(412,310)
    $Send.Font                       = 'Consolas,10'

    $Cancel                          = New-Object system.Windows.Forms.Button
    $Cancel.text                     = "Cancel"
    $Cancel.width                    = 60
    $Cancel.height                   = 30
    $Cancel.location                 = New-Object System.Drawing.Point(343,310)
    $Cancel.Font                     = 'Consolas,10'

    $Validation                      = New-Object system.Windows.Forms.Label
    $Validation.text                 = "*Denotes required field"
    $Validation.AutoSize             = $true
    $Validation.width                = 25
    $Validation.height               = 10
    $Validation.location             = New-Object System.Drawing.Point(22,269)
    $Validation.Font                 = 'Consolas,10'

    $Email                           = New-Object system.Windows.Forms.Label
    $Email.text                      = "Email Address*"
    $Email.AutoSize                  = $true
    $Email.width                     = 25
    $Email.height                    = 10
    $Email.location                  = New-Object System.Drawing.Point(21,149)
    $Email.Font                      = 'Consolas,10'

    $TxtEmail                        = New-Object system.Windows.Forms.TextBox
    $TxtEmail.multiline              = $false
    $TxtEmail.width                  = 255
    $TxtEmail.height                 = 20
    $TxtEmail.location               = New-Object System.Drawing.Point(142,149)
    $TxtEmail.Font                   = 'Consolas,10'
    $TxtEmail.TabIndex               = 3

    $FailNotice.controls.AddRange(@($Title,$GetAssistance,$Name,$TxtName,$TsName,$TxtTsName,$Description,$TxtDescription,$Send,$Cancel,$Validation,$Email,$TxtEmail))


    $Send.Add_Click({ Send_OnClick })
    $Cancel.Add_Click({ Cancel_OnClick })
    $TxtName.Add_TextChanged({ ValidateTextboxes })
    $TxtTsName.Add_TextChanged({ ValidateTextboxes })
    $TxtEmail.Add_TextChanged({ ValidateTextboxes })


    function Cancel_OnClick {
        $FailNotice.Close()
    }

    function Validate-IsEmail {
        param([string]$Email)
        return $Email -match "^(?("")("".+?""@)|(([0-9a-zA-Z]((\.(?!\.))|"+`
                        "[-!#\$%&'\*\+/=\?\^`\{\}\|~\w])*)(?<=[0-9a-zA-Z])@))"+`
                        "(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|(([0-9a-zA-Z][-\w]*"+`
                        "[0-9a-zA-Z]\.)+[a-zA-Z]{2,6}))$"
    }
    
    function ValidateTextboxes {
       
        if([string]::IsNullOrEmpty($TxtName.Text)) {
            $Validation.ForeColor = "#e74c3c"
            $Validation.Font = 'Consolas,10,style=Bold'
            $Validation.Text = "Your name is required!"
            $Send.Enabled = $false
        } elseif([string]::IsNullOrEmpty($TxtTsName.Text)) {
            $Validation.ForeColor = "#e74c3c"
            $Validation.Font = 'Consolas,10,style=Bold'
            $Validation.Text = "What TS did you use!"
            $Send.Enabled = $false
        } elseif([string]::IsNullOrEmpty($TxtEmail.Text)) {
            $Validation.ForeColor = "#e74c3c"
            $Validation.Font = 'Consolas,10,style=Bold'
            $Validation.Text = "What is your email address!"
            $Send.Enabled = $false
        } elseif(!(Validate-IsEmail -Email $TxtEmail.Text)) {
            $Validation.ForeColor = "#e74c3c"
            $Validation.Font = 'Consolas,10,style=Bold'
            $Validation.Text = "A valid email is required!"
            $Send.Enabled = $false
        } else {
            $Validation.ForeColor = "#2ecc71"
            $Validation.Font = 'Consolas,10,style=Bold'
            $Validation.Text = "You can now submit the form."
            $Send.Enabled = $true
        }
    }          

    function Send-Mail {
        Param (
            [string]$TSName = "No TS name was provided",
            [string]$Name = "No name was provided",
            [string]$Email, 
            [String[]]$Attachments, 
            [string]$Description
        )

        $Subject = "Task Sequence Failure Notice"

        $Body =  "Task Sequence $TSName Failed! Technician: $Name Email: $Email Description: $Description"

        $SMTPServer = "SMTP_SERVER" # ADD YOUR SMTP SERVER HERE

        # Add or remove members from Security Group for email notifications. 
        $EmailAddress = "ADD_SECURITY_GROUP_HERE" # ADD_SECURITY_GROUP_OR_EMAILADDRESS

        Send-MailMessage -Subject $Subject -Body $Body -From $Email -To $EmailAddress -SmtpServer $SMTPServer -Attachments $Attachments
    }


     function Send_OnClick {
        
        $WinPeBc = "x:\windows\temp\smstslog\smsts.log"
        $WinPeAd = "c:\_SMSTaskSequence\Logs\Smstslog\smsts.log"
        $OsAd = "c:\windows\ccm\logs\Smstslog\smsts.log"
        $OS = "c:\windows\ccm\logs\smsts.log"
        $Attach = @()

        if((Test-Path -Path $WinPeBc)) {
            New-Item -Path "x:\Windows\temp\smstslog\templog" -ItemType Directory -Force
            Copy-Item -Path "x:\windows\temp\smstslog\*.log" -Destination "x:\windows\temp\smstslog\templog\" -Force
            $Attachment = Get-ChildItem -Path "x:\windows\temp\smstslog\templog" -Recurse | ForEach-Object { $Attach += $_.FullName }
        }

        if((Test-Path -Path $WinPeAd)) {
            New-Item -Path "c:\_SMSTaskSequence\Logs\Smstslog\templog" -ItemType Directory -Force
            Copy-Item -Path "c:\_SMSTaskSequence\Logs\Smstslog\*.log" -Destination "c:\_SMSTaskSequence\Logs\Smstslog\templog\" -Force
            $Attachment = Get-ChildItem -Path "c:\_SMSTaskSequence\Logs\Smstslog\templog" -Recurse | ForEach-Object { $Attach += $_.FullName }
        }

        if((Test-Path -Path $OsAd)) {
            New-Item -Path "c:\windows\ccm\logs\Smstslog\templog" -ItemType Directory -Force
            Copy-Item -Path "c:\windows\ccm\logs\Smstslog\*.log" -Destination "c:\windows\ccm\logs\Smstslog\templog\" -Force
            $Attachment = Get-ChildItem -Path "c:\windows\ccm\logs\Smstslog\templog" -Recurse | ForEach-Object { $Attach += $_.FullName }
        }

        if((Test-Path -Path $OS)) {
            New-Item -Path "c:\windows\ccm\logs\templog" -ItemType Directory -Force
            Copy-Item -Path "c:\windows\ccm\logs\*.log" -Destination "c:\windows\ccm\logs\templog\" -Force
            $Attachment = Get-ChildItem -Path "c:\windows\ccm\logs\templog" -Recurse | ForEach-Object { $Attach += $_.FullName }
        }

        try {
            Send-Mail -TSName $TxtTsName.Text -Name $TxtName.Text -Email $TxtEmail.Text -Attachment $Attach -Description $TxtDescription.Text
            [System.Windows.Forms.MessageBox]::Show("The form was successfully submitted.")
            $FailNotice.Close()
        }catch{
            [System.Windows.Forms.MessageBox]::Show("Failed. Please submit a service ticket and include the SMSTS.log file. Details, $_")
            $Send.Enabled = $false
        }
    } 

    [void]$FailNotice.ShowDialog() #Show the form.
    [void]$FailNotice.Activate()   #Make form window active.

} #End Start-Form

Start-Form