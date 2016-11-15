#!/bin/sh

# ****************************************************************************
# ***                                                                      ***
# *** File Name:    tmsint_create_oracle_wallet.sh                         ***
# ***                                                                      ***
# *** Date Written: 14 November 2016                                       ***
# ***                                                                      ***
# *** Written By:   DBMS Consulting Inc.                                   ***
# ***                                                                      ***
# *** Invoke As:    SYSTEM                                                 ***
# ***                                                                      ***
# *** prerequisite: 1) ORACLE_HOME environment variable pointing to oracle ***
# ***                  installation path is already set.                   ***
# ***               2) Wallet directory($ORACLE_HOME/wallets/tmsint)       ***
# ***                  has been created prior to executing this script.    ***
# ***               3) In addition, the certificates have been already     *** 
# ***                  copied over to the wallet directory.                ***
# ***                                                                      ***
# ***                                                                      ***
# *** Description:  Create an Oracle Wallet and Import the Applicable      ***
# ***               Certificates to the Wallet.                            ***
# ***               A Wallet is a Oracle object that keeps the record of   ***
# ***               Digital Certificates used by the Database for          ***
# ***               encryption purpose. The Walled kept outside the        ***
# ***               Database and has a different password than the DBA     ***
# ***               System Password                                        ***
# ***                                                                      ***
# ****************************************************************************

# Remove existing wallet if there exists one
orapki wallet remove -wallet $ORACLE_HOME/wallets/tmsint -trusted_cert_all -pwd orawallet@123
 
# Create wallet
orapki wallet create -wallet $ORACLE_HOME/wallets/tmsint -pwd orawallet@123 -auto_login

# Import Go-Daddy Root Certificate
orapki wallet add -wallet $ORACLE_HOME/wallets/tmsint -trusted_cert -cert $ORACLE_HOME/wallets/tmsint/go_daddy_root_cert.cer -pwd orawallet@123

# Import Go-Daddy Intermediate Certificate
orapki wallet add -wallet $ORACLE_HOME/wallets/tmsint -trusted_cert -cert $ORACLE_HOME/wallets/tmsint/go_daddy_intermediate_cert.cer -pwd orawallet@123

# Display the wallet information
orapki wallet display -wallet $ORACLE_HOME/wallets/tmsint