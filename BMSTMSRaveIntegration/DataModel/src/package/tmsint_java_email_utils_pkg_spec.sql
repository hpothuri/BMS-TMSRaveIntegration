-- *****************************************************************************
-- ***                                                                       ***
-- *** File Name:     tmsint_java_email_utils_pkg_spec.sql                   ***
-- ***                                                                       ***
-- *** Date Written:  15 November 2016                                       ***
-- ***                                                                       ***
-- *** Written By:    Harish Pothuri / DBMS Consulting Inc.                  ***
-- ***                                                                       ***
-- *** Package Name:  TMSINT_JAVA_EMAIL_UTILS (Package Specification)        ***
-- ***                                                                       ***
-- *** Package Owner: TMS Integration JAVA Admin Owner (TMSINT_JAVA)         ***
-- ***                                                                       ***
-- *** Description:   This SQL Script will Create the Database Package       ***
-- ***                TMSINT_JAVA_EMAIL_UTILS Containing the Application     ***
-- ***                Email Utilities. The Application Owner Account and     ***
-- ***                all XFER and PROC Accounts will be Granted EXECUTE     ***
-- ***                Permission this Package.                               ***
-- ***                                                                       ***
-- *** Modification History:                                                 ***
-- *** --------------------                                                  ***
-- *** 15-NOV-2016 / Harish Pothuri - Initial Creation                       ***
-- ***                                                                       ***
-- *****************************************************************************
   SET ECHO OFF
   SET FEEDBACK OFF
   WHENEVER SQLERROR EXIT FAILURE
   COLUMN date_column NEW_VALUE curr_date NOPRINT
   SELECT TO_CHAR(SYSDATE,'MMDDYY_HHMI') date_column FROM DUAL;
   COLUMN owner_column NEW_VALUE curr_owner NOPRINT
   SELECT property_value owner_column FROM tmsint_adm_properties
   WHERE property_name = 'OWNER';

   SET PAGESIZE 0
   SET VERIFY OFF
   SET TERMOUT OFF
   SET SERVEROUTPUT ON SIZE UNLIMITED
   SET TERMOUT ON
   SET FEEDBACK OFF
   SPOOL ../log/tmsint_java_email_utils_pkg_spec_&curr_date..log

   SELECT 'Process:  '||'tmsint_java_email_utils_pkg_spec.sql'  ||CHR(10)||
          'Package:  '||'TMSINT_JAVA_EMAIL_UTILS Specification' ||CHR(10)||
          'User:     '||USER                                    ||CHR(10)||
          'Date:     '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI AM') ||CHR(10)||
          'Instance: '||global_name
   FROM global_name;
   SET FEEDBACK ON

   PROMPT 
   PROMPT *********************************************************************
   PROMPT ***      Creating TMSINT_JAVA_EMAIL_UTILS Package Specification   ***
   PROMPT *********************************************************************

-- ****************************************************************************
-- ***               TMSINT_JAVA_EMAIL_UTILS Package Specification          ***
-- ****************************************************************************
   CREATE OR REPLACE PACKAGE tmsint_java_email_utils AUTHID DEFINER
   AS
--    **********************************************
--    *** Extract Data from Client Source System ***
--    **********************************************
      PROCEDURE email
        (pEmailToList  IN  VARCHAR2,
         pEmailCCList  IN  VARCHAR2  DEFAULT NULL,
         pEmailSubject IN  VARCHAR2,
         pEmailBody    IN  CLOB,
         pDebugFlag    IN  VARCHAR2 DEFAULT 'N');

   END tmsint_java_email_utils;
/
  SHOW ERRORS
  SET TERMOUT ON

  PROMPT
  PROMPT *******************************************************************
  PROMPT *** Issue Grant to TMSINT Application Owner.  The Application   ***
  PROMPT *** Owner MUST BE Registered in the TMSINT Properties Tables -  *** 
  PROMPT *** If the Statement Below is in Error - Verify the Application ***
  PROMPT *** Owner is Registered and Re-Execute                          ***
  PROMPT *** During the Client Setup - the Application Owner will be     ***
  PROMPT *** Account that Grants Access to this Package to the XFER and  ***
  PROMPT *** PROC Schemas                                                ***
  PROMPT *******************************************************************
  GRANT EXECUTE ON tmsint_java_email_utils TO &curr_owner WITH GRANT OPTION;

  SPOOL OFF
  EXIT

