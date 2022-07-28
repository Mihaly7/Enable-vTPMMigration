# Enable-vTPMMigration
Enable migration for VTPM enabled VMs on a Hyper-V cluster.


 This script will copy existing default HGS certificates to all cluster nodes in order to enable live migration for VMs where       
 TPM is enabled.                                                                                                                   
 Will not enable shielded VMs-                                                                                                       
 VTPM is a feature needed to encrypt data and use features like bitlocker.                                                            
 When enabling vTPM on a clustered environment the VMs will need the certificate on each host to allow Live migration between nodes.
                                                                                                                                    
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
