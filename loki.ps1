$Global:__loki = @{}
 
function Apply-LokiFile {

  function Get-LokiFile {
    $currentDir = Get-Location
    $lokiFiles = @(Resolve-Path (Join-Path $currentDir ".loki*") -ErrorAction SilentlyContinue)
    if($lokiFiles.Length -eq 0) { return $null }
    return $lokiFiles[0]
  }
  
  $lokiFile = Get-LokiFile
  if(!$lokiFile) { return }

  if($Global:__loki.current -and !($Global:__loki.current -eq $lokiFile)) {
    if($PSCmdlet.MyInvocation.BoundParameters["Debug"].IsPresent) {
      Write-Host "Removing loki config file: $($Global:__loki.current)"
    }
    Remove-Module -Name $Global:__loki.current -Force -ErrorAction SilentlyContinue
    $Global:__loki.current = $null
  }

  $Global:__loki.current = "$lokiFile"
  if($PSCmdlet.MyInvocation.BoundParameters["Debug"].IsPresent) {
    Write-Host "Importing loki config file: $lokiFile"
  }
  $module = New-Module -Name "$lokiFile" -ScriptBlock {}
  . $module $lokiFile
  Import-Module $module
}

<#
 
.ForwardHelpTargetName Set-Location
.ForwardHelpCategory Cmdlet
 
#>
function Set-Location {
  [CmdletBinding(DefaultParameterSetName='Path', SupportsTransactions=$true, HelpUri='http://go.microsoft.com/fwlink/?LinkID=113397')]
  param(
    [Parameter(ParameterSetName='Path', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string]
    ${Path},
 
    [Parameter(ParameterSetName='LiteralPath', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('PSPath')]
    [string]
    ${LiteralPath},
 
    [switch]
    ${PassThru},
 
    [Parameter(ParameterSetName='Stack', ValueFromPipelineByPropertyName=$true)]
    [string]
    ${StackName})
 
  begin
  {
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Set-Location', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
  }
 
  process
  {
    try {
        $steppablePipeline.Process($_)
    } catch {
        throw
    }
 }
 
  end
  {
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
 
    Apply-LokiFile
  }
}