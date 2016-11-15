-- *****************************************************************************
-- ***                                                                       ***
-- *** File Name:     tmsint_java_xfer_utils_pkg_spec.sql                    ***
-- ***                                                                       ***
-- *** Date Written:  15 November 2016                                       ***
-- ***                                                                       ***
-- *** Written By:    Harish Pothuri / DBMS Consulting Inc.                  ***
-- ***                                                                       ***
-- *** Package Name:  TMSINT_JAVA_XFER_UTILS (Package Specification)         ***
-- ***                                                                       ***
-- *** Package Owner: TMS Integration JAVA Admin Owner (TMSINT_JAVA)         ***
-- ***                                                                       ***
-- *** Description:   This SQL Script will create the TMSINT_JAVA_XFER_UTILS ***
-- ***                Database Package Containing the APIs Associated with   ***
-- ***                TMSINT Application Java Functionality for Client       ***
-- ***                EXTRACT and IMPORT Functionality.                      ***
-- ***                This Database Package is Created and Owned by the      ***
-- ***                TMSINT JAVA Application Owner, but is Callable ONLY    ***
-- ***                by the Application XFER Accounts from within the       ***
-- ***                the TMSINT_XFER_UTILS Package.                         ***
-- ***                When a Client XFER Oracle Account is Created,          ***
-- ***                EXECUTE Privilge will be GRANTED to the XFER           ***
-- ***                Account and a Private SYNONYM Created.                 ***
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
   SPOOL ../log/tmsint_java_xfer_utils_pkg_spec_&curr_date..log

   SELECT 'Process:  '||'tmsint_java_xfer_utils_pkg_spec.sql'   ||CHR(10)||
          'Package:  '||'TMSINT_JAVA_XFER_UTILS Specification'  ||CHR(10)||
          'User:     '||USER                                    ||CHR(10)||
          'Date:     '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI AM') ||CHR(10)||
          'Instance: '||global_name
   FROM global_name;
   SET FEEDBACK ON

   PROMPT 
   PROMPT *********************************************************************
   PROMPT ***      Creating TMSINT_JAVA_XFER_UTILS Package Specification    ***
   PROMPT *********************************************************************

-- ****************************************************************************
-- ***               TMSINT_JAVA_XFER_UTILS Package Specification           ***
-- ****************************************************************************
   CREATE OR REPLACE PACKAGE tmsint_java_xfer_utils AUTHID DEFINER
   AS
--    ************************************
--    *** Global Variable Declaration  ***
--    ************************************
      xmlresponseTAB  tmsint_xfer_html_ws_objt := tmsint_xfer_html_ws_objt();

--    **********************************
--    *** Web-Service Call Procedure ***
--    ********************************** 
      PROCEDURE invoke_rest_service
        (p_url              IN VARCHAR2,
         p_input_payload    IN CLOB,
         p_http_method      IN VARCHAR2,
         p_username         IN VARCHAR2,
         p_password         IN VARCHAR2,
         p_response         OUT CLOB,
         p_status_code      OUT VARCHAR2,
         p_error_message    OUT VARCHAR2);

--    **********************************************
--    *** Extract Data from Client Source System ***
--    **********************************************
      FUNCTION extractClinicalDataFromURL
        (pJobTab  IN     tmsint_java_job_objt,
         pDCMTab  IN     tmsint_java_dcm_objt,
         pExtTab  IN OUT tmsint_xfer_html_ws_objt)
      RETURN VARCHAR2;

--    **********************************************
--    *** Import Data to Client Source System    ***
--    **********************************************
      FUNCTION importClinicalDataFromURL 
        (pJobTab IN     tmsint_java_job_objt,
         pImpTab IN OUT tmsint_xfer_html_import_objt)
      RETURN VARCHAR2;

   END tmsint_java_xfer_utils;
/
  SHOW ERRORS
  SET TERMOUT ON

  PROMPT
  PROMPT *******************************************************************
  PROMPT *** Issue Grant to TMSINT Application Owner.  The Application   ***
  PROMPT *** Owner MUST BE Registered in the TMSINT Properties Tables -  *** 
  PROMPT *** If the Statement Below is in Error - Verify the Application ***
  PROMPT *** Owner is Registered and Re-Execute                          ***
  PROMPT *******************************************************************
  GRANT EXECUTE ON tmsint_java_xfer_utils TO &curr_owner WITH GRANT OPTION;

  SPOOL OFF
  EXIT

