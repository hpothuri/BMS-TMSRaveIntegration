-- *****************************************************************************
-- ***                                                                       ***
-- *** File Name:    tmsint_install_acl_for_smtp                             ***
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
-- ***               in which to allow the UTL_SMTP package to interact with ***
-- ***               an external host. Oracle 11g introduced fine grained    ***
-- ***               access to external services using ACLs in the xml db    ***
-- ***               repository allowing control over which users access     ***
-- ***               which network resources.                                ***
-- ***               This sql scipt will create the acl "smtp_host.xml"      ***
-- ***               with the oracle user TMSINT application's Java owner as ***
-- ***               the "principal".                                        ***
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
PROMPT *** Executing: tmsint_install_acl_for_smtp.sql                ***
PROMPT ***                                                           ***
PROMPT *** The purpose of this script is to create an access control ***
prompt *** list to allow TMSINT_JAVA to connect to SMTP server       ***
PROMPT ***                                                           ***
PROMPT *****************************************************************

ACCEPT CHAR p_tmsint_java_owner PROMPT 'Enter the TMSINT Application Java Owner Username: '
ACCEPT CHAR p_smtp_host PROMPT 'Enter the SMTP server host name: '
ACCEPT NUMBER p_smtp_port PROMPT 'Enter the SMTP server port number: '

-- ************************************************************
-- *** Delete the ACL "smtp_host.xml" (if pre-existing) ***
-- ************************************************************

 BEGIN
      DBMS_NETWORK_ACL_ADMIN.DROP_ACL
         (acl => 'smtp_host.xml');
      COMMIT;
   EXCEPTION
      WHEN DBMS_NETWORK_ACL_ADMIN.ACL_NOT_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20101,SQLERRM);
 END;


BEGIN

-- ******************************************
-- *** Create the ACL "smtp_host.xml"     ***
-- ******************************************

  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (acl           => 'smtp_host.xml'
                                   , description   => 'ACL for SMTP(email) host'
                                   , principal     => '&p_tmsint_java_owner'
                                   , is_grant      => true
                                   , privilege     => 'connect');
								   
-- ************************************************
--    This will allow look up and connect to smtp host
-- ************************************************								   
                                   
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl        => 'smtp_host.xml'
                                      , principal  => '&p_tmsint_java_owner'
                                      , is_grant   => true
                                      , privilege  => 'resolve');
 
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl        => 'smtp_host.xml'
                                      , principal  => '&p_tmsint_java_owner'
                                      , is_grant   => true
                                      , privilege  => 'connect');

-- ************************************************
--  Assign ACL to SMTP host
-- ************************************************	
                                      
   DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL   (acl        => 'smtp_host.xml'
                                      , host       => '&p_smtp_host'
                                      , lower_port => 80
                                      , upper_port => null);
  
   DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL    (acl       => 'smtp_host.xml'
                                      , host       => '&p_smtp_host'
                                      , lower_port => &p_smtp_port
                                      , upper_port => null);

-- ************************************************
--  Provide privelege to access client certificates
-- ************************************************										  
                                      
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl       => 'smtp_host.xml',
                                         principal => '&p_tmsint_java_owner',
                                         is_grant  => true, 
                                         privilege => 'use-client-certificates');

  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(acl         => 'smtp_host.xml',
                                       principal   => '&p_tmsint_java_owner',
                                       is_grant    =>  true,
                                       privilege   => 'use-passwords');
 
  COMMIT;
END;

/
SHOW ERRORS;