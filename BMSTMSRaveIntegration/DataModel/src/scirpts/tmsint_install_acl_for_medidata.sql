-- *****************************************************************************
-- ***                                                                       ***
-- *** File Name:    tmsint_install_acl_for_medidata                         ***
-- ***                                                                       ***
-- *** Date Written: 14 November 2016                                        ***
-- ***                                                                       ***
-- *** Written By:   DBMS Consulting Inc.                                    ***
-- ***                                                                       ***
-- *** Run as:       SYSTEM                                                  ***
-- ***                                                                       ***
-- *** Prerequisite: The Oracle User TMSINT_JAVA must be pre-existing        ***
-- ***                                                                       ***
-- *** description:  This sql script will create an access control list (ACL)***
-- ***               in which to allow the UTL_HTTP package to interact with ***
-- ***               an external host. Oracle 11g introduced fine grained    ***
-- ***               access to external services using ACLs in the xml db    ***
-- ***               repository allowing control over which users access     ***
-- ***               which network resources.                                ***
-- ***               This sql scipt will create the acl "medidata_host.xml"  ***
-- ***               with the TMSINT application's Java owner as "principal".***
-- ***                                                                       ***
-- *****************************************************************************
SET ECHO OFF
SET FEEDBACK OFF
COLUMN date_column NEW_VALUE curr_date NOPRINT
SELECT TO_CHAR(SYSDATE,'MMDDYY_HHMI') date_column FROM DUAL;
SET PAGESIZE 0
SET LINESIZE 200
SET ARRAYSIZE 1
SET ECHO OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET TERMOUT ON
SET SERVEROUTPUT ON SIZE 1000000

PROMPT
PROMPT *****************************************************************
PROMPT ***                                                           ***
PROMPT *** Executing: tmsint_install_acl_for_medidata.sql            ***
PROMPT ***                                                           ***
PROMPT *** The purpose of this script is to create an access control ***
prompt *** list to allow TMSINT_JAVA to connect to Medidata system   ***
PROMPT ***                                                           ***
PROMPT *****************************************************************

ACCEPT CHAR p_tmsint_java_owner PROMPT 'Enter the TMSINT Application Java Owner Username: '
ACCEPT CHAR p_mediata_host PROMPT 'Enter the Medidata host name(Ex: xyz.mdsol.com): '

-- ************************************************************
-- *** Delete the ACL "medidata_host.xml" (if pre-existing) ***
-- ************************************************************

 BEGIN
      DBMS_NETWORK_ACL_ADMIN.DROP_ACL
         (acl => 'medidata_host.xml');
      COMMIT;
   EXCEPTION
      WHEN DBMS_NETWORK_ACL_ADMIN.ACL_NOT_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20101,SQLERRM);
 END;


BEGIN

-- ******************************************
-- *** Create the ACL "medidata_host.xml" ***
-- ******************************************

  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (acl           => 'medidata_host.xml'
                                   , description   => 'ACL for Medidata system'
                                   , principal     => '&p_tmsint_java_owner'
                                   , is_grant      => true
                                   , privilege     => 'connect');
								   
-- ************************************************
--    This will allow look up and connect to smtp host
-- ************************************************								   
                                   
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl        => 'medidata_host.xml'
                                      , principal  => '&p_tmsint_java_owner'
                                      , is_grant   => true
                                      , privilege  => 'resolve');
 
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl        => 'medidata_host.xml'
                                      , principal  => '&p_tmsint_java_owner'
                                      , is_grant   => true
                                      , privilege  => 'connect');

-- ************************************************
--  Assign ACL to Medidata host
-- ************************************************	
                                      
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL  ( acl         => 'medidata_host.xml',
                                       host        => '&p_mediata_host');

-- ************************************************
--  Provide privelege to access client certificates
-- ************************************************										  
                                      
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl       => 'medidata_host.xml',
                                         principal => '&p_tmsint_java_owner',
                                         is_grant  => true, 
                                         privilege => 'use-client-certificates');

  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(acl         => 'medidata_host.xml',
                                       principal   => '&p_tmsint_java_owner',
                                       is_grant    =>  true,
                                       privilege   => 'use-passwords');
 
  commit;
END;

/
SHOW ERRORS;