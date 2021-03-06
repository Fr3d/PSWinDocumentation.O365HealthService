function Get-Office365Health {
    [CmdLetbinding()]
    param(
        [string][alias('ClientID')] $ApplicationID,
        [string][alias('ClientSecret')] $ApplicationKey,
        [string] $TenantDomain,
        [PSWinDocumentation.Office365Health[]] $TypesRequired = [PSWinDocumentation.Office365Health]::All,
        [switch] $ToLocalTime
    )
    $StartTime = Start-TimeLog
    $Script:TimeZoneBias = (Get-CimInstance -ClassName Win32_TimeZone).Bias
    $Script:Today = Get-Date
    if ($null -eq $TypesRequired -or $TypesRequired -contains [PSWinDocumentation.Office365Health]::All) {
        $TypesRequired = Get-Types -Types ([PSWinDocumentation.Office365Health])
    }
    $Authorization = Connect-O365ServiceHealth -ApplicationID $ApplicationID -ApplicationKey $ApplicationKey -TenantDomain $TenantDomain
    if ($null -ne $Authorization) {
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @(
                [PSWinDocumentation.Office365Health]::Services,
                [PSWinDocumentation.Office365Health]::ServicesExteneded)) {
            $Services = Get-Office365ServiceHealthServices -Authorization $Authorization -TenantDomain $TenantDomain
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @(
                [PSWinDocumentation.Office365Health]::CurrentStatus,
                [PSWinDocumentation.Office365Health]::CurrentStatusExteneded
            )) {
            $CurrentStatus = Get-Office365ServiceHealthCurrentStatus -Authorization $Authorization -TenantDomain $TenantDomain -ToLocalTime:$ToLocalTime
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @(
                [PSWinDocumentation.Office365Health]::HistoricalStatus,
                [PSWinDocumentation.Office365Health]::HistoricalStatusExteneded
            )) {
            $HistoricalStatus = Get-Office365ServiceHealthHistoricalStatus -Authorization $Authorization -TenantDomain $TenantDomain -ToLocalTime:$ToLocalTime
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @(
                [PSWinDocumentation.Office365Health]::Incidents,
                [PSWinDocumentation.Office365Health]::IncidentsExteneded,
                [PSWinDocumentation.Office365Health]::MessageCenterInformation,
                [PSWinDocumentation.Office365Health]::MessageCenterInformationExtended,
                [PSWinDocumentation.Office365Health]::PlannedMaintenance,
                [PSWinDocumentation.Office365Health]::PlannedMaintenanceExteneded,
                [PSWinDocumentation.Office365Health]::Messages
            )) {
            $Messages = Get-Office365ServiceHealthMessages -Authorization $Authorization -TenantDomain $TenantDomain -ToLocalTime:$ToLocalTime
        }
        $Output = [ordered] @{}
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @([PSWinDocumentation.Office365Health]::Services)) {
            $Output.Services = $Services.Simple
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @([PSWinDocumentation.Office365Health]::ServicesExteneded)) {
            $Output.ServicesExteneded = $Services.Exteneded
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @([PSWinDocumentation.Office365Health]::CurrentStatus)) {
            $Output.CurrentStatus = $CurrentStatus.Simple
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @([PSWinDocumentation.Office365Health]::CurrentStatusExteneded)) {
            $Output.CurrentStatusExteneded = $CurrentStatus.Exteneded
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @([PSWinDocumentation.Office365Health]::HistoricalStatus)) {
            $Output.HistoricalStatus = $HistoricalStatus.Simple
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @([PSWinDocumentation.Office365Health]::HistoricalStatusExteneded)) {
            $Output.HistoricalStatusExteneded = $HistoricalStatus.Exteneded
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @([PSWinDocumentation.Office365Health]::MessageCenterInformation)) {
            $Output.MessageCenterInformation = $Messages.MessageCenterInformationSimple | Sort-Object -Property LastUpdatedTime -Descending
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @([PSWinDocumentation.Office365Health]::MessageCenterInformationExtended)) {
            $Output.MessageCenterInformationExtended = $Messages.MessageCenterInformation | Sort-Object -Property LastUpdatedTime -Descending
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @([PSWinDocumentation.Office365Health]::Incidents)) {
            $Output.Incidents = $Messages.IncidentsSimple | Sort-Object -Property LastUpdatedTime -Descending
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @([PSWinDocumentation.Office365Health]::Messages)) {
            $Output.IncidentsMessages = $Messages.Messages | Sort-Object -Property PublishedTime -Descending
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @([PSWinDocumentation.Office365Health]::IncidentsExteneded)) {
            $Output.IncidentsExteneded = $Messages.Incidents | Sort-Object -Property LastUpdatedTime -Descending
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @([PSWinDocumentation.Office365Health]::PlannedMaintenance)) {
            $Output.PlannedMaintenance = $Messages.PlannedMaintenanceSimple | Sort-Object -Property LastUpdatedTime -Descending
        }
        if (Find-TypesNeeded -TypesRequired $TypesRequired -TypesNeeded @([PSWinDocumentation.Office365Health]::PlannedMaintenanceExteneded)) {
            $Output.PlannedMaintenanceExteneded = $Messages.PlannedMaintenance | Sort-Object -Property LastUpdatedTime -Descending
        }
        $EndTime = Stop-TimeLog -Time $StartTime -Option OneLiner
        Write-Verbose "Get-Office365Health - Time to process: $EndTime"
        return $Output

    } else {
        return
    }
}