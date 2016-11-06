create or replace
PACKAGE tmsint_java_xfer_utils AUTHID DEFINER
   AS
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