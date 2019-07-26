# Ercan Polat 
# erjan123@yahoo.com
# LinkedIn: https://www.linkedin.com/in/ercan-polat/
# 07/26/2019
#################################################################################################
<#
.SYNOPSIS
    Uninstalls Solr on your machine. 
.DESCRIPTION
    Script remove solr folder and service from your machine.
.PARAMETER solrExtractLocationcd.
    The Path where Solr was installed. The entire folder will be deleted
.PARAMETER serviceName
    The name the service running solr has, it will be removed
.EXAMPLE
    C:\PS> uninstall-solr-all.ps1 
.NOTES
    Author: Diego Saavedra San Juan
    Date:   Many
#>

param(
    [string]$solrExtractLocation = "C:\solr\solr-7.5.0", 
    [string]$solrServiceName="solr-7.5.0")

$nssmName="nssm.exe"
$nssmLocalPath=".\$nssmName"

if ($solrExtractLocation -eq $null -or $solrExtractLocation -eq "")
{
    Write-Host "Parameter solrExtractLocation is mandatory, but it is null or empty" -ForegroundColor Red
    exit 1
}

if ($solrServiceName -eq $null -or $solrServiceName -eq "")
{
    Write-Host "Parameter serviceName is mandatory, but it is null or empty" -ForegroundColor Red
    exit 1
}


# Uninstall Service
Write-Host "Checking if Solr service is installed"
$isSolrServiceInstalled = Get-Service | Where-Object {$_.Name -like "*$solrServiceName*"}
if ( -not ($isSolrServiceInstalled -eq $null)) 
{
    Write-Host "Removing Solr service $solrServiceName" -ForegroundColor Cyan

    # Stop the service 
    sc.exe stop $solrServiceName

    # Nssm doesn't really delete, it just disables autostart
    #$res = Start-Process $nssmLocalPath -ArgumentList " remove $solrServiceName confirm " -Wait -NoNewWindow -PassThru
    sc.exe delete $solrServiceName 
    Start-Sleep 2
    #$isSolrServiceInstalled = Get-Service | Where-Object {$_.Name -like "*$solrServiceName*"}
    $isSolrServiceInstalled = sc.exe query $solrServiceName
    if ( $isSolrServiceInstalled[0].Contains("1060") )
    {
        Write-Host "Removal of Solr service completed sucessfully" -ForegroundColor Green
    }
    else 
    { 
        Write-Host "Something went wrong removing Solr service named $solrServiceName" -ForegroundColor Red
        exit 1
    }

}
else 
{ 
    Write-Host "Solr service already removed, good" -ForegroundColor Green
}


# Remove folder
if ( Test-Path $solrExtractLocation )
{
    rmdir -recurse $solrExtractLocation
    if ( -Not ( Test-Path $solrExtractLocation ))
    {
        Write-Host "Correctly removed Solr directory at $solrExtractLocation" -ForegroundColor Green
    }
    else 
    { 
        Write-Host "Something went wrong trying to remove the solr directory" -ForegroundColor Red
        exit 1
    }
}
else { Write-Host "Solr location $solrExtractLocation already removed, good" -ForegroundColor Green }

Write-Host "Completed uninstallation of Solr" -ForegroundColor Green

Write-Host ""
Write-Host ""
Write-Host "If you want to be happy then be happy!" -ForegroundColor Green