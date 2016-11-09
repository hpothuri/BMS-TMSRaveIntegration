create or replace
PACKAGE tmsint_java_xfer_utils AUTHID DEFINER
   AS
   
   XMLResponseTAB tmsint_xfer_html_ws_objt;
   
   procedure invoke_rest_service(
    p_url           IN VARCHAR2,
    p_input_payload IN CLOB,
    p_http_method   IN VARCHAR2,
    p_username      IN VARCHAR2,
    p_password      IN VARCHAR2,
    p_response      OUT CLOB,
    p_status_code   OUT VARCHAR2,
    p_error_message OUT VARCHAR2
  );
  
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