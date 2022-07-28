
######################################################################################################################################
#                                                                                                                                    #
# This script will copy existing default HGS certificates to all cluster nodes in order to enable live migration for VMs where       #
# TPM is enabled.                                                                                                                    #
# Will not enable shielded VMs                                                                                                       #
# VTPM is a feature need to encrypt data and use features like bitlocker.                                                            #
# When enabling vTPM on a clustered environment the VMs will need the certificate on each host to allow Live migration between nodes #
#                                                                                                                                    #
######################################################################################################################################

Function Enable-vTPMMigration
{

      <#
        .SYNOPSIS
        Enable migration for VTPM enabled virtual machines on a Hyper-V cluster.

        .DESCRIPTION
        This script will copy existing default HGS certificates to all cluster nodes in order to enable live migration for VMs where       
        TPM is enabled.    
        
        !!IMPORTANT!! 
        Make sure you create a VM on all nodes and enable TPM, that will create the default guardian and its certificates.
        Without that step, the script will not work!

        The script will prompt for a password to secure the exported certificates.
                                                                                                                        
                                                                                         
        VTPM is a feature need to encrypt data and use features like bitlocker.                                                            
        When enabling vTPM on a clustered environment the VMs will need the certificate on each host to allow Live migration between nodes

        .PARAMETER ClusterName
        Name of the cluster

        .PARAMETER CertPath
        Working path where the certificates will be exported (C:\CLHGSCerts by default)

        .EXAMPLE 
        PS> Enable-SecuredVMMigration -ClusterName Cluster01

    #>

        Param
        (
         [Parameter(Mandatory=$true)]
            
            [string]$ClusterName = (Read-host -Prompt "Cluster's name"),
            
                       
        [Parameter(Mandatory=$false)]
            $CertPath = ("C:\CLHGSCERTS\")
         )    
#Reading password for certs


#Gathering nodes
$Nodes = Get-ClusterNode -cluster $clustername
If ($Nodes -ne $null)
    {
    $CertificatePassword = (Read-Host -Prompt 'Please enter a password to secure the certificate files' -AsSecureString)
    If ((get-item $certpath) -eq $null)
        {
        Write-Host "Setting up Certificate export directory"
        new-item -type directory $CertPath
        }


    $workpath = (Get-Item -Path $CertPath).FullName

    foreach ($Node in $Nodes)
        {
        Write-Host "Checking if default guardian exists on $Node"
        If ((Get-HgsGuardian -Name "UntrustedGuardian" -CimSession $Node.name -ErrorAction SilentlyContinue) -ne $null)
            {
            [array]$guardians += $node.name
            }
        Else 
            {
            [array]$missing += $node.name
            }

        }
    If ($Guardians.count -eq $Nodes.count)
        {
        ForEach ($Node in $Nodes) 
            {
            Write-Host "$Node exports certs"

#Creating remote session to $node
            $session = New-PSSession -ComputerName $Node.Name

#Exporting certs to local workfolder    
            Invoke-Command -Session $session -ScriptBlock { 
                $guardian = Get-HgsGuardian -Name "UntrustedGuardian"
                $encryptionCertificate = Get-Item -Path "Cert:\LocalMachine\Shielded VM Local Certificates\$($guardian.EncryptionCertificate.Thumbprint)";
                $signingCertificate = Get-Item -Path "Cert:\LocalMachine\Shielded VM Local Certificates\$($guardian.SigningCertificate.Thumbprint)";
                New-Item -ItemType Directory -Path C:\ -Name HGSCerts;
                Export-PfxCertificate -Cert $encryptionCertificate -FilePath "C:\HGSCerts\$Using:Node-encryption.pfx" -Password $Using:CertificatePassword;
                Export-PfxCertificate -Cert $signingCertificate -FilePath "C:\HGSCerts\$Using:Node-signing.pfx" -Password $Using:CertificatePassword
                }
    #Exporting certs to global workfolder    
            Write-Host "copy cert from $name"
    
            Copy-Item C:\HgsCerts\* -Include *.pfx -Destination $workpath -Recurse -Verbose -FromSession $session
            Remove-PSSession $session
            }
    
#Importing certs to each nodes

        ForEach ($Node in $Nodes)
            {
            Write-Host "$Node imports certs"
            $session = New-PSSession -ComputerName $Node.Name
                Copy-Item -Path "$workpath\*" -Include *.pfx  -ToSession $session -Destination c:\hgscerts\ -Recurse 
                Invoke-Command -Session $session -ScriptBlock {
                $certs = Get-Childitem -Path c:\HGSCerts\ "*pfx";
                
                ForEach ($cert in $certs)
                    {
                    If ($cert.fullname -notlike "*$using:Node*")
                        {
                        write-host "$cert";
                        Import-PfxCertificate -FilePath $cert.fullname -CertStoreLocation "Cert:\LocalMachine\Shielded VM Local Certificates\" -Password $using:CertificatePassword;
                        }
                   };
                Get-Item -Path "Cert:\LocalMachine\Shielded VM Local Certificates\*" ;
                Remove-Item -Path c:\HGSCerts -Recurse -Force;
                }
            Remove-PSSession $session
            }
        }
    Else 
        {
        Write-Host -ForegroundColor Yellow "Not all nodes have default guardian enabled, the following node(s) needs it:"
        $missing
        Write-Host -ForegroundColor Yellow "Please deploy a VM on the node(s) listed above and enable vTPM on them via Hyper-V manager (MMC)"
        }
    Remove-Item $workpath -Recurse
    }
Else
    {
    Write-Host -ForegroundColor Red "!!!$Clustername not found/cannot be connected, exiting..."
    }
}        
         
            
        
        
    
