# Enable-vTPMMigration
Enable migration for VTPM enabled VMs on a Hyper-V cluster.


 This script will copy existing default HGS certificates to all cluster nodes in order to enable live migration for VMs where       
 TPM is enabled.                                                                                                                   
 Will not enable shielded VMs                                                                                                       
 VTPM is a feature need to encrypt data and use features like bitlocker.                                                            
 When enabling vTPM on a clustered environment the VMs will need the certificate on each host to allow Live migration between nodes 
                                                                                                                                    
