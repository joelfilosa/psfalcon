function Edit-FalconReconAction {
<#
.SYNOPSIS
Modify a Falcon Intelligence Recon action
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Write'.
.PARAMETER Frequency
Action frequency
.PARAMETER Recipient
Email address
.PARAMETER Status
Action status
.PARAMETER ContentFormat
Email format
.PARAMETER TriggerMatchless
Send email when no matches are found
.PARAMETER Id
Action identifier
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Edit-FalconReconAction
#>
    [CmdletBinding(DefaultParameterSetName='/recon/entities/actions/v1:patch',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/entities/actions/v1:patch',Mandatory,ValueFromPipelineByPropertyName,
            Position=1)]
        [ValidateSet('asap','daily','weekly',IgnoreCase=$false)]
        [string]$Frequency,
        [Parameter(ParameterSetName='/recon/entities/actions/v1:patch',Mandatory,ValueFromPipelineByPropertyName,
            Position=2)]
        [ValidateScript({
            if ((Test-RegexValue $_) -eq 'email') { $true } else { throw "'$_' is not a valid email address." }
        })]
        [Alias('Recipients')]
        [string[]]$Recipient,
        [Parameter(ParameterSetName='/recon/entities/actions/v1:patch',Mandatory,ValueFromPipelineByPropertyName,
            Position=3)]
        [ValidateSet('enabled','muted',IgnoreCase=$false)]
        [string]$Status,
        [Parameter(ParameterSetName='/recon/entities/actions/v1:patch',Mandatory,ValueFromPipelineByPropertyName,
            Position=4)]
        [ValidateSet('standard','enhanced',IgnoreCase=$false)]
        [Alias('content_format')]
        [string]$ContentFormat,
        [Parameter(ParameterSetName='/recon/entities/actions/v1:patch',Mandatory,ValueFromPipelineByPropertyName,
            Position=5)]
        [Alias('trigger_matchless')]
        [boolean]$TriggerMatchless,
        [Parameter(ParameterSetName='/recon/entities/actions/v1:patch',Mandatory,ValueFromPipelineByPropertyName,
            Position=6)]
        [ValidatePattern('^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')]
        [string]$Id
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{
                Body = @{ root = @('id','frequency','trigger_matchless','recipients','status','content_format') }
            }
        }
        [System.Collections.Generic.List[string]] $List = @()
    }
    process {
        if ($Recipient) {
            @($Recipient).foreach{ $List.Add($_) }
        } else {
            Invoke-Falcon @Param -Inputs $PSBoundParameters
        }
    }
    end {
        if ($List) {
            $PSBoundParameters['Recipient'] = @($List | Select-Object -Unique)
            Invoke-Falcon @Param -Inputs $PSBoundParameters
        }
    }
}
function Edit-FalconReconNotification {
<#
.SYNOPSIS
Modify a Falcon Intelligence Recon notification
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Write'.
.PARAMETER Array
An array of notifications to modify in a single request
.PARAMETER Id
Notification identifier
.PARAMETER Status
Notification status
.PARAMETER AssignedToUuid
User identifier
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Edit-FalconReconNotification
#>
    [CmdletBinding(DefaultParameterSetName='/recon/entities/notifications/v1:patch',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='array',Mandatory,ValueFromPipeline)]
        [ValidateScript({
            foreach ($Object in $_) {
                $Param = @{
                    Object = $Object
                    Command = 'Edit-FalconReconNotification'
                    Endpoint = '/recon/entities/notifications/v1:patch'
                    Required = @('id','assigned_to_uuid','status')
                    Pattern = @('id','assigned_to_uuid')
                    Format = @{ assigned_to_uuid = 'AssignedToUuid' }
                }
                Confirm-Parameter @Param
            }
        })]
        [Alias('resources')]
        [object[]]$Array,
        [Parameter(ParameterSetName='/recon/entities/notifications/v1:patch',Mandatory,Position=1)]
        [ValidatePattern('^\w{76}$')]
        [string]$Id,
        [Parameter(ParameterSetName='/recon/entities/notifications/v1:patch',Mandatory,Position=2)]
        [string]$Status,
        [Parameter(ParameterSetName='/recon/entities/notifications/v1:patch',Mandatory,Position=3)]
        [ValidatePattern('^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')]
        [Alias('assigned_to_uuid')]
        [string]$AssignedToUuid
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = '/recon/entities/notifications/v1:patch'
            Format = @{ Body = @{ root = @('assigned_to_uuid','id','status','raw_array') }}
        }
        [System.Collections.Generic.List[object]]$List = @()
    }
    process {
        if ($Array) {
            foreach ($i in $Array) {
                # Select allowed fields, when populated
                [string[]]$Select = @('id','assigned_to_uuid','status').foreach{ if ($i.$_) { $_ }}
                $List.Add(($i | Select-Object $Select))
            }
        } else {
            Invoke-Falcon @Param -Inputs $PSBoundParameters
        }
    }
    end {
        if ($List) {
            for ($i = 0; $i -lt $List.Count; $i += 100) {
                $PSBoundParameters['raw_array'] = @($List[$i..($i + 99)])
                Invoke-Falcon @Param -Inputs $PSBoundParameters
            }
        }
    }
}
function Edit-FalconReconRule {
<#
.SYNOPSIS
Modify a Falcon Intelligence Recon monitoring rule
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Write'.
.PARAMETER Array
An array of monitoring rules to modify in a single request
.PARAMETER Id
Monitoring rule identifier
.PARAMETER Name
Monitoring rule name
.PARAMETER Filter
Monitoring rule filter
.PARAMETER Priority
Monitoring rule priority
.PARAMETER Permission
Permission level [public: 'All Intel users', private: 'Recon Admins']
.PARAMETER BreachMonitoring
Monitor for breach data
.PARAMETER SubstringMatching
Monitor for substring matches
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Edit-FalconReconRule
#>
    [CmdletBinding(DefaultParameterSetName='/recon/entities/rules/v1:patch',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='array',Mandatory,ValueFromPipeline)]
        [ValidateScript({
            foreach ($Object in $_) {
                $Param = @{
                    Object = $Object
                    Command = 'Edit-FalconReconRule'
                    Endpoint = '/recon/entities/rules/v1:patch'
                    Required = @('id','name','filter','priority','permissions')
                    Content = @('permissions','priority')
                    Pattern = @('id')
                }
                Confirm-Parameter @Param
            }
        })]
        [Alias('resources')]
        [object[]]$Array,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:patch',Mandatory,Position=1)]
        [ValidatePattern('^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')]
        [string]$Id,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:patch',Mandatory,Position=2)]
        [string]$Name,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:patch',Mandatory,Position=3)]
        [ValidateScript({ Test-FqlStatement $_ })]
        [string]$Filter,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:patch',Mandatory,Position=4)]
        [ValidateSet('high','medium','low',IgnoreCase=$false)]
        [string]$Priority,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:patch',Mandatory,Position=5)]
        [ValidateSet('private','public',IgnoreCase=$false)]
        [Alias('permissions')]
        [string]$Permission,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:patch',Position=6)]
        [Alias('breach_monitoring_enabled')]
        [boolean]$BreachMonitoring,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:patch',Position=7)]
        [Alias('substring_matching_enabled')]
        [boolean]$SubstringMatching
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = '/recon/entities/rules/v1:patch'
            Format = @{
                Body = @{
                    root = @('permissions','priority','name','id','filter','raw_array','breach_monitoring_enabled',
                        'substring_matching_enabled')
                }
            }
        }
        [System.Collections.Generic.List[object]]$List = @()
    }
    process {
        if ($Array) {
            foreach ($i in $Array) {
                # Select allowed fields, when populated
                [string[]]$Select = @('permissions','priority','name','filter','breach_monitoring_enabled',
                'substring_match_enabled','id').foreach{
                    if ($null -ne $i.$_) { $_ }
                }
                $List.Add(($i | Select-Object $Select))
            }
        } else {
            Invoke-Falcon @Param -Inputs $PSBoundParameters
        }
    }
    end {
        if ($List) {
            for ($i = 0; $i -lt $List.Count; $i += 100) {
                $PSBoundParameters['raw_array'] = @($List[$i..($i + 99)])
                Invoke-Falcon @Param -Inputs $PSBoundParameters
            }
        }
    }
}
function Get-FalconReconAction {
<#
.SYNOPSIS
Search for Falcon Intelligence Recon actions
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Read'.
.PARAMETER Id
Action identifier
.PARAMETER Filter
Falcon Query Language expression to limit results
.PARAMETER Query
Perform a generic substring search across available fields
.PARAMETER Sort
Property and direction to sort results
.PARAMETER Limit
Maximum number of results per request
.PARAMETER Offset
Position to begin retrieving results
.PARAMETER Detailed
Retrieve detailed information
.PARAMETER All
Repeat requests until all available results are retrieved
.PARAMETER Total
Display total result count instead of results
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Get-FalconReconAction
#>
    [CmdletBinding(DefaultParameterSetName='/recon/queries/actions/v1:get',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/entities/actions/v1:get',Mandatory,ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [ValidatePattern('^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')]
        [Alias('Ids')]
        [string[]]$Id,
        [Parameter(ParameterSetName='/recon/queries/actions/v1:get',Position=1)]
        [ValidateScript({ Test-FqlStatement $_ })]
        [string]$Filter,
        [Parameter(ParameterSetName='/recon/queries/actions/v1:get',Position=2)]
        [Alias('q')]
        [string]$Query,
        [Parameter(ParameterSetName='/recon/queries/actions/v1:get',Position=3)]
        [string]$Sort,
        [Parameter(ParameterSetName='/recon/queries/actions/v1:get',Position=4)]
        [int32]$Limit,
        [Parameter(ParameterSetName='/recon/queries/actions/v1:get')]
        [int32]$Offset,
        [Parameter(ParameterSetName='/recon/queries/actions/v1:get')]
        [switch]$Detailed,
        [Parameter(ParameterSetName='/recon/queries/actions/v1:get')]
        [switch]$All,
        [Parameter(ParameterSetName='/recon/queries/actions/v1:get')]
        [switch]$Total
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{ Query = @('limit','ids','sort','q','offset','filter') }
        }
        [System.Collections.Generic.List[string]]$List = @()
    }
    process { if ($Id) { @($Id).foreach{ $List.Add($_) }}}
    end {
        if ($List) { $PSBoundParameters['Id'] = @($List | Select-Object -Unique) }
        Invoke-Falcon @Param -Inputs $PSBoundParameters
    }
}
function Get-FalconReconExport {
<#
.SYNOPSIS
Return status of Falcon Intelligence Recon export jobs
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Read'.
.PARAMETER Id
Recon export job identifier
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Get-FalconReconExport
#>
    [CmdletBinding(DefaultParameterSetName='/recon/entities/exports/v1:get',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/entities/exports/v1:get',Mandatory,ValueFromPipelineByPropertyName,
            ValueFromPipeline,Position=1)]
        [Alias('ids')]
        [string[]]$Id
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{ Query = @('ids') }
        }
        [System.Collections.Generic.List[string]]$List = @()
    }
    process { if ($Id) { @($Id).foreach{ $List.Add($_) }}}
    end {
        if ($List) {
            $PSBoundParameters['Id'] = @($List | Select-Object -Unique)
            Invoke-Falcon @Param -Inputs $PSBoundParameters
        }
    }
}
function Get-FalconReconNotification {
<#
.SYNOPSIS
Search for Falcon Intelligence Recon notifications
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Read'.
.PARAMETER Id
Notification identifier
.PARAMETER Filter
Falcon Query Language expression to limit results
.PARAMETER Query
Perform a generic substring search across available fields
.PARAMETER Sort
Property and direction to sort results
.PARAMETER Limit
Maximum number of results per request
.PARAMETER Offset
Position to begin retrieving results
.PARAMETER Detailed
Retrieve detailed information
.PARAMETER All
Repeat requests until all available results are retrieved
.PARAMETER Total
Display total result count instead of results
.PARAMETER Intel
Include raw intelligence content
.PARAMETER Translate
Translate to English
.PARAMETER Combined
Include raw intelligence content and translate to English
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Get-FalconReconNotification
#>
    [CmdletBinding(DefaultParameterSetName='/recon/queries/notifications/v1:get',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/entities/notifications/v1:get',Mandatory,
            ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [Parameter(ParameterSetName='/recon/entities/notifications-detailed/v1:get',Mandatory,
            ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [Parameter(ParameterSetName='/recon/entities/notifications-translated/v1:get',Mandatory,
            ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [Parameter(ParameterSetName='/recon/entities/notifications-detailed-translated/v1:get',Mandatory,
            ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [ValidatePattern('^\w{76}$')]
        [Alias('Ids')]
        [string[]]$Id,
        [Parameter(ParameterSetName='/recon/queries/notifications/v1:get',Position=1)]
        [ValidateScript({ Test-FqlStatement $_ })]
        [string]$Filter,
        [Parameter(ParameterSetName='/recon/queries/notifications/v1:get',Position=2)]
        [Alias('q')]
        [string]$Query,
        [Parameter(ParameterSetName='/recon/queries/notifications/v1:get',Position=3)]
        [ValidateSet('created_date|asc','created_date|desc','updated_date|asc','updated_date|desc',
            IgnoreCase=$false)]
        [string]$Sort,
        [Parameter(ParameterSetName='/recon/queries/notifications/v1:get',Position=4)]
        [ValidateRange(1,500)]
        [int32]$Limit,
        [Parameter(ParameterSetName='/recon/queries/notifications/v1:get')]
        [int32]$Offset,
        [Parameter(ParameterSetName='/recon/queries/notifications/v1:get')]
        [switch]$Detailed,
        [Parameter(ParameterSetName='/recon/queries/notifications/v1:get')]
        [switch]$All,
        [Parameter(ParameterSetName='/recon/queries/notifications/v1:get')]
        [switch]$Total,
        [Parameter(ParameterSetName='/recon/entities/notifications-detailed/v1:get',Mandatory)]
        [switch]$Intel,
        [Parameter(ParameterSetName='/recon/entities/notifications-translated/v1:get',Mandatory)]
        [switch]$Translate,
        [Parameter(ParameterSetName='/recon/entities/notifications-detailed-translated/v1:get',Mandatory)]
        [switch]$Combined
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{ Query = @('limit','ids','sort','q','offset','filter') }
        }
        [System.Collections.Generic.List[string]]$List = @()
    }
    process { if ($Id) { @($Id).foreach{ $List.Add($_) }}}
    end {
        if ($List) { $PSBoundParameters['Id'] = @($List | Select-Object -Unique) }
        Invoke-Falcon @Param -Inputs $PSBoundParameters
    }
}
function Get-FalconReconRecord {
<#
.SYNOPSIS
Search for Falcon Intelligence Recon exposed data record notifications
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Read'.
.PARAMETER Id
Exposed data record identifier
.PARAMETER Filter
Falcon Query Language expression to limit results
.PARAMETER Query
Perform a generic substring search across available fields
.PARAMETER Sort
Property and direction to sort results
.PARAMETER Limit
Maximum number of results per request
.PARAMETER Offset
Position to begin retrieving results
.PARAMETER Detailed
Retrieve detailed information
.PARAMETER All
Repeat requests until all available results are retrieved
.PARAMETER Total
Display total result count instead of results
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Get-FalconReconRecord
#>
    [CmdletBinding(DefaultParameterSetName='/recon/queries/notifications-exposed-data-records/v1:get',
        SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/entities/notifications-exposed-data-records/v1:get',Mandatory,
            ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [ValidatePattern('^\w{76}$')]
        [Alias('ids')]
        [string[]]$Id,
        [Parameter(ParameterSetName='/recon/queries/notifications-exposed-data-records/v1:get',Position=1)]
        [ValidateScript({ Test-FqlStatement $_ })]
        [string]$Filter,
        [Parameter(ParameterSetName='/recon/queries/notifications-exposed-data-records/v1:get',Position=2)]
        [Alias('q')]
        [string]$Query,
        [Parameter(ParameterSetName='/recon/queries/notifications-exposed-data-records/v1:get',Position=3)]
        [string]$Sort,
        [Parameter(ParameterSetName='/recon/queries/notifications-exposed-data-records/v1:get',Position=4)]
        [int]$Limit,
        [Parameter(ParameterSetName='/recon/queries/notifications-exposed-data-records/v1:get')]
        [int]$Offset,
        [Parameter(ParameterSetName='/recon/queries/notifications-exposed-data-records/v1:get')]
        [switch]$Detailed,
        [Parameter(ParameterSetName='/recon/queries/notifications-exposed-data-records/v1:get')]
        [switch]$All,
        [Parameter(ParameterSetName='/recon/queries/notifications-exposed-data-records/v1:get')]
        [switch]$Total
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{ Query = @('q','offset','sort','limit','filter','ids') }
        }
        [System.Collections.Generic.List[string]]$List = @()
    }
    process { if ($Id) { @($Id).foreach{ $List.Add($_) }}}
    end {
        if ($List) { $PSBoundParameters['Id'] = @($List | Select-Object -Unique) }
        Invoke-Falcon @Param -Inputs $PSBoundParameters
    }
}
function Get-FalconReconRule {
<#
.SYNOPSIS
Search for Falcon Intelligence Recon monitoring rules
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Read'.
.PARAMETER Id
Monitoring rule identifier
.PARAMETER Filter
Falcon Query Language expression to limit results
.PARAMETER Query
Perform a generic substring search across available fields
.PARAMETER Sort
Property and direction to sort results
.PARAMETER Limit
Maximum number of results per request
.PARAMETER Offset
Position to begin retrieving results
.PARAMETER Detailed
Retrieve detailed information
.PARAMETER All
Repeat requests until all available results are retrieved
.PARAMETER Total
Display total result count instead of results
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Get-FalconReconRule
#>
    [CmdletBinding(DefaultParameterSetName='/recon/queries/rules/v1:get',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/entities/rules/v1:get',Mandatory,ValueFromPipelineByPropertyName,
            ValueFromPipeline)]
        [ValidatePattern('^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')]
        [Alias('Ids')]
        [string[]]$Id,
        [Parameter(ParameterSetName='/recon/queries/rules/v1:get',Position=1)]
        [ValidateScript({ Test-FqlStatement $_ })]
        [string]$Filter,
        [Parameter(ParameterSetName='/recon/queries/rules/v1:get',Position=2)]
        [Alias('q')]
        [string]$Query,
        [Parameter(ParameterSetName='/recon/queries/rules/v1:get',Position=3)]
        [ValidateSet('created_timestamp|asc','created_timestamp|desc','last_updated_timestamp|asc',
            'last_updated_timestamp|desc',IgnoreCase=$false)]
        [string]$Sort,
        [Parameter(ParameterSetName='/recon/queries/rules/v1:get',Position=4)]
        [ValidateRange(1,500)]
        [int32]$Limit,
        [Parameter(ParameterSetName='/recon/queries/rules/v1:get')]
        [int32]$Offset,
        [Parameter(ParameterSetName='/recon/queries/rules/v1:get')]
        [switch]$Detailed,
        [Parameter(ParameterSetName='/recon/queries/rules/v1:get')]
        [switch]$All,
        [Parameter(ParameterSetName='/recon/queries/rules/v1:get')]
        [switch]$Total
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{ Query = @('limit','ids','q','sort','offset','filter') }
        }
        [System.Collections.Generic.List[string]]$List = @()
    }
    process { if ($Id) { @($Id).foreach{ $List.Add($_) }}}
    end {
        if ($List) { $PSBoundParameters['Id'] = @($List | Select-Object -Unique) }
        Invoke-Falcon @Param -Inputs $PSBoundParameters
    }
}
function Get-FalconReconRulePreview {
<#
.SYNOPSIS
Preview Falcon Intelligence Recon monitoring rule notification count and distribution
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Read'.
.PARAMETER Topic
Monitoring rule topic
.PARAMETER Filter
Monitoring rule filter
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Get-FalconReconRulePreview
#>
    [CmdletBinding(DefaultParameterSetName='/recon/aggregates/rules-preview/GET/v1:post',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/aggregates/rules-preview/GET/v1:post',Mandatory,Position=1)]
        [string]$Topic,
        [Parameter(ParameterSetName='/recon/aggregates/rules-preview/GET/v1:post',Mandatory,Position=2)]
        [ValidateScript({ Test-FqlStatement $_ })]
        [string]$Filter
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{ Body = @{ root = @('filter','topic') }}
        }
    }
    process { Invoke-Falcon @Param -Inputs $PSBoundParameters }
}
function Invoke-FalconReconExport {
<#
.SYNOPSIS
Initiate a Falcon Intelligence Recon export job
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Write'.
.PARAMETER Array
An array of jobs to submit in a single request
.PARAMETER Entity
Entity type
.PARAMETER Filter
Falcon Query Language expression to limit results
.PARAMETER Sort
Property and direction to sort results
.PARAMETER ExportType
Export file format
.PARAMETER HumanReadable
Use property names that match the Falcon UI
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Invoke-FalconReconExport
#>
    [CmdletBinding(DefaultParameterSetName='/recon/entities/exports/v1:post',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/entities/exports/v1:post',Mandatory,Position=1)]
        [ValidateSet('notification-exposed-data-record',IgnoreCase=$false)]
        [string]$Entity,
        [Parameter(ParameterSetName='/recon/entities/exports/v1:post',Mandatory,Position=2)]
        [ValidateScript({ Test-FqlStatement $_ })]
        [string]$Filter,
        [Parameter(ParameterSetName='/recon/entities/exports/v1:post',Mandatory,Position=3)]
        [ValidateSet('author|asc','author|desc','author_id|asc','author_id|desc','cid|asc','cid|desc',
            'created_date|asc','created_date|desc','credentials_domain|asc','credentials_domain|desc',
            'credentials_ip|asc','credentials_ip|desc','display_name|asc','display_name|desc','domain|asc',
            'domain|desc','email|asc','email|desc','email_domain|asc','email_domain|desc','exposure_date|asc',
            'exposure_date|desc','file.complete_data_set|asc','file.complete_data_set|desc',
            'financial.bank_account|asc','financial.bank_account|desc','financial.credit_card|asc',
            'financial.credit_card|desc','financial.crypto_currency_addresses|asc',
            'financial.crypto_currency_addresses|desc','hash_type|asc','hash_type|desc','id|asc','id|desc',
            'impacted_domain|asc','impacted_domain|desc','impacted_ip|asc','impacted_ip|desc',
            'location.country_code|asc','location.country_code|desc','location.postal_code|asc',
            'location.postal_code|desc','login_id|asc','login_id|desc','notification_id|asc',
            'notification_id|desc','phone_number|asc','phone_number|desc','rule.id|asc','rule.id|desc',
            'rule.topic|asc','rule.topic|desc','site|asc','site|desc','site_id|asc','site_id|desc',
            'social.aim_id|asc','social.aim_id|desc','social.facebook_id|asc','social.facebook_id|desc',
            'social.icq_id|asc','social.icq_id|desc','social.instagram_id|asc','social.instagram_id|desc',
            'social.msn_id|asc','social.msn_id|desc','social.skype_id|asc','social.skype_id|desc',
            'social.twitter_id|asc','social.twitter_id|desc','social.vk_id|asc','social.vk_id|desc',
            'social.vk_token|asc','social.vk_token|desc','source_category|asc','source_category|desc',
            'user_id|asc','user_id|desc','user_ip|asc','user_ip|desc','user_name|asc','user_name|desc',
            'user_uuid|asc','user_uuid|desc',IgnoreCase=$false)]
        [string]$Sort,
        [Parameter(ParameterSetName='/recon/entities/exports/v1:post',Mandatory,Position=4)]
        [ValidateSet('csv','json',IgnoreCase=$false)]
        [Alias('export_type')]
        [string]$ExportType,
        [Parameter(ParameterSetName='/recon/entities/exports/v1:post',Mandatory,Position=5)]
        [Alias('human_readable')]
        [boolean]$HumanReadable
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{ Body = @{ root = @('filter','sort','entity','human_readable','export_type') }}
            BodyArray = $true
        }
    }
    process { Invoke-Falcon @Param -Inputs $PSBoundParameters }
}
function New-FalconReconAction {
<#
.SYNOPSIS
Create Falcon Intelligence Recon monitoring rule actions
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Write'.
.PARAMETER RuleId
Monitoring rule identifier
.PARAMETER Type
Notification type
.PARAMETER Frequency
Notification frequency
.PARAMETER Recipient
Notification recipient
.PARAMETER ContentFormat
Email format
.PARAMETER TriggerMatchless
Send email when no matches are found
.LINK
https://github.com/crowdstrike/psfalcon/wiki/New-FalconReconAction
#>
    [CmdletBinding(DefaultParameterSetName='/recon/entities/actions/v1:post',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/entities/actions/v1:post',Mandatory,ValueFromPipelineByPropertyName,
            Position=1)]
        [ValidatePattern('^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')]
        [Alias('rule_id')]
        [string]$RuleId,
        [Parameter(ParameterSetName='/recon/entities/actions/v1:post',Mandatory,ValueFromPipelineByPropertyName,
            Position=2)]
        [ValidateSet('email',IgnoreCase=$false)]
        [string]$Type,
        [Parameter(ParameterSetName='/recon/entities/actions/v1:post',Mandatory,ValueFromPipelineByPropertyName,
            Position=3)]
        [ValidateSet('asap','daily','weekly',IgnoreCase=$false)]
        [string]$Frequency,
        [Parameter(ParameterSetName='/recon/entities/actions/v1:post',Mandatory,ValueFromPipelineByPropertyName,
            Position=4)]
        [ValidateScript({
            if ((Test-RegexValue $_) -eq 'email') { $true } else { throw "'$_' is not a valid email address." }
        })]
        [Alias('Recipients','uid')]
        [string[]]$Recipient,
        [Parameter(ParameterSetName='/recon/entities/actions/v1:post',ValueFromPipelineByPropertyName,
            Position=5)]
        [ValidateSet('standard','enhanced',IgnoreCase=$false)]
        [Alias('content_format')]
        [string]$ContentFormat,
        [Parameter(ParameterSetName='/recon/entities/actions/v1:post',ValueFromPipelineByPropertyName,
            Position=6)]
        [Alias('trigger_matchless')]
        [boolean]$TriggerMatchless

    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{
                Body = @{
                    root = @('rule_id')
                    actions = @('type','trigger_matchless','recipients','frequency','content_format')
                }
            }
        }
        [System.Collections.Generic.List[string]]$List = @()
    }
    process {
        if ($Recipient) { @($Recipient).foreach{ $List.Add($_) }}
    }
    end {
        if ($List) {
            $PSBoundParameters['Recipient'] = @($List | Select-Object -Unique)
            Invoke-Falcon @Param -Inputs $PSBoundParameters
        }
    }
}
function New-FalconReconRule {
<#
.SYNOPSIS
Create Falcon Intelligence Recon monitoring rules
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Write'.
.PARAMETER Array
An array of monitoring rules to create in a single request
.PARAMETER Name
Monitoring rule name
.PARAMETER Topic
Monitoring rule topic
.PARAMETER Filter
Falcon Query Language expression to limit results
.PARAMETER Priority
Monitoring rule priority
.PARAMETER Permission
Permission level [public: 'All Intel users', private: 'Recon Admins']
.PARAMETER BreachMonitoring
Monitor for breach data
.PARAMETER SubstringMatching
Monitor for substring matches
.LINK
https://github.com/crowdstrike/psfalcon/wiki/New-FalconReconRule
#>
    [CmdletBinding(DefaultParameterSetName='/recon/entities/rules/v1:post',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='array',Mandatory,ValueFromPipeline)]
        [ValidateScript({
            foreach ($Object in $_) {
                $Param = @{
                    Object = $Object
                    Command = 'New-FalconReconRule'
                    Endpoint = '/recon/entities/rules/v1:post'
                    Required = @('name','topic','filter','priority','permissions')
                    Content = @('permissions','priority','topic')
                    Format = @{}
                }
                Confirm-Parameter @Param
            }
        })]
        [object[]]$Array,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:post',Mandatory,Position=1)]
        [string]$Name,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:post',Mandatory,Position=2)]
        [ValidateSet('SA_ALIAS','SA_AUTHOR','SA_BIN','SA_BRAND_PRODUCT','SA_CUSTOM','SA_CVE','SA_DOMAIN',
            'SA_EMAIL','SA_IP','SA_THIRD_PARTY','SA_VIP',IgnoreCase=$false)]
        [string]$Topic,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:post',Mandatory,Position=3)]
        [ValidateScript({ Test-FqlStatement $_ })]
        [string]$Filter,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:post',Mandatory,Position=4)]
        [ValidateSet('high','medium','low',IgnoreCase=$false)]
        [string]$Priority,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:post',Mandatory,Position=5)]
        [ValidateSet('private','public',IgnoreCase=$false)]
        [Alias('permissions')]
        [string]$Permission,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:post',Position=6)]
        [Alias('breach_monitoring_enabled')]
        [boolean]$BreachMonitoring,
        [Parameter(ParameterSetName='/recon/entities/rules/v1:post',Position=7)]
        [Alias('substring_matching_enabled')]
        [boolean]$SubstringMatching
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = '/recon/entities/rules/v1:post'
            Format = @{
                Body = @{
                    root = @('filter','permissions','topic','name','breach_monitoring_enabled',
                        'substring_matching_enabled','priority','raw_array')
                }
            }
        }
        [System.Collections.Generic.List[object]]$List = @()
    }
    process {
        if ($Array) {
            foreach ($i in $Array) {
                # Select allowed fields, when populated
                [string[]]$Select = @('permissions','priority','name','filter','topic',
                'breach_monitoring_enabled','substring_match_enabled').foreach{
                    if ($null -ne $i.$_) { $_ }
                }
                $List.Add(($i | Select-Object $Select))
            }
        } else {
            Invoke-Falcon @Param -Inputs $PSBoundParameters
        }
    }
    end {
        if ($List) {
            for ($i = 0; $i -lt $List.Count; $i += 100) {
                $PSBoundParameters['raw_array'] = @($List[$i..($i + 99)])
                Invoke-Falcon @Param -Inputs $PSBoundParameters
            }
        }
    }
}
function Receive-FalconReconExport {
<#
.SYNOPSIS
Download a Falcon Intelligence Recon export
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Read'.
.PARAMETER Path
Destination path
.PARAMETER Id
Recon export job identifier
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Receive-FalconReconExport
#>
    [CmdletBinding(DefaultParameterSetName='/recon/entities/export-files/v1:get',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/entities/export-files/v1:get',Mandatory,Position=1)]
        [string]$Path,
        [Parameter(ParameterSetName='/recon/entities/export-files/v1:get',Mandatory,
            ValueFromPipelineByPropertyName,ValueFromPipeline,Position=2)]
        [string]$Id
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{
                Outfile = 'path'
                Query = @('id')
            }
            Headers = @{ Accept = 'application/octet-stream' }
        }
    }
    process {
        $OutPath = Test-OutFile $PSBoundParameters.Path
        if ($OutPath.Category -eq 'ObjectNotFound') {
            Write-Error @OutPath
        } elseif ($PSBoundParameters.Path) {
            if ($OutPath.Category -eq 'WriteError' -and !$Force) {
                Write-Error @OutPath
            } else {
                Invoke-Falcon @Param -Inputs $PSBoundParameters
            }
        }
    }
}
function Remove-FalconReconAction {
<#
.SYNOPSIS
Remove an action from a Falcon Intelligence Recon monitoring rule
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Write'.
.PARAMETER Id
Action identifier
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Remove-FalconReconAction
#>
    [CmdletBinding(DefaultParameterSetName='/recon/entities/actions/v1:delete',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/entities/actions/v1:delete',Mandatory,ValueFromPipelineByPropertyName,
            ValueFromPipeline,Position=1)]
        [ValidatePattern('^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')]
        [string]$Id
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{ Query = @('id') }
        }
    }
    process { Invoke-Falcon @Param -Inputs $PSBoundParameters }
}
function Remove-FalconReconExport {
<#
.SYNOPSIS
Remove a Falcon Intelligence Recon export job
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Write'.
.PARAMETER Id
Recon export job identifier
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Remove-FalconReconExport
#>
    [CmdletBinding(DefaultParameterSetName='/recon/entities/exports/v1:delete',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/entities/exports/v1:delete',Mandatory,ValueFromPipelineByPropertyName,
            ValueFromPipeline,Position=1)]
        [Alias('ids')]
        [string[]]$Id
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{ Query = @('ids') }
        }
        [System.Collections.Generic.List[string]]$List = @()
    }
    process { if ($Id) { @($Id).foreach{ $List.Add($_) }}}
    end {
        if ($List) {
            $PSBoundParameters['Id'] = @($List | Select-Object -Unique)
            Invoke-Falcon @Param -Inputs $PSBoundParameters
        }
    }
}
function Remove-FalconReconNotification {
<#
.SYNOPSIS
Remove Falcon Intelligence Recon notifications
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Write'.
.PARAMETER Id
Notification identifier
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Remove-FalconReconNotification
#>
    [CmdletBinding(DefaultParameterSetName='/recon/entities/notifications/v1:delete',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/entities/notifications/v1:delete',Mandatory,
            ValueFromPipelineByPropertyName,ValueFromPipeline,Position=1)]
        [ValidatePattern('^\w{76}$')]
        [Alias('Ids')]
        [string[]]$Id
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{ Query = @('ids') }
        }
        [System.Collections.Generic.List[string]]$List = @()
    }
    process { if ($Id) { @($Id).foreach{ $List.Add($_) }}}
    end {
        if ($List) {
            $PSBoundParameters['Id'] = @($List | Select-Object -Unique)
            Invoke-Falcon @Param -Inputs $PSBoundParameters
        }
    }
}
function Remove-FalconReconRule {
<#
.SYNOPSIS
Remove Falcon Intelligence Recon monitoring rules
.DESCRIPTION
Requires 'Monitoring rules (Falcon Intelligence Recon): Write'.
.PARAMETER Id
Monitoring rule identifier
.LINK
https://github.com/crowdstrike/psfalcon/wiki/Remove-FalconReconRule
#>
    [CmdletBinding(DefaultParameterSetName='/recon/entities/rules/v1:delete',SupportsShouldProcess)]
    param(
        [Parameter(ParameterSetName='/recon/entities/rules/v1:delete',Mandatory,ValueFromPipelineByPropertyName,
            ValueFromPipeline,Position=1)]
        [ValidatePattern('^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')]
        [Alias('Ids')]
        [string[]]$Id
    )
    begin {
        $Param = @{
            Command = $MyInvocation.MyCommand.Name
            Endpoint = $PSCmdlet.ParameterSetName
            Format = @{ Query = @('ids') }
        }
        [System.Collections.Generic.List[string]]$List = @()
    }
    process { if ($Id) { @($Id).foreach{ $List.Add($_) }}}
    end {
        if ($List) {
            $PSBoundParameters['Id'] = @($List | Select-Object -Unique)
            Invoke-Falcon @Param -Inputs $PSBoundParameters
        }
    }
}