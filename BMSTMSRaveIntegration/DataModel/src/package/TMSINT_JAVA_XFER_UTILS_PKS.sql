-- *****************************************************************************
-- ***                                                                       ***
-- *** Package Body :    tmsint_java_xfer_utils                              ***
-- ***                                                                       ***
-- *** Date Written: 14 November 2016                                        ***
-- ***                                                                       ***
-- *** Written By:   DBMS Consulting Inc.                                    ***
-- ***                                                                       ***
-- *** Run as:       SYSTEM                                                  ***
-- ***                                                                       ***
-- *** Prerequisite: Oracle User TMSINT application's Java owner             ***
-- ***               must be pre-existing                                    ***
-- ***                                                                       ***
-- *** Description:  This script will create package tmsint_java_xfer_utils  ***
-- ***               which is used for extracting and importing clinical data***
-- ***               from the Medidata system using RAVE web services.       ***
-- ***               This package is owned by account TMSINT application's   ***
-- ***               Java owner.                                             ***
-- ***                                                                       ***
-- *****************************************************************************

CREATE OR REPLACE 
PACKAGE tmsint_java_xfer_utils AUTHID DEFINER
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

SHOW ERRORS ;
EXIT