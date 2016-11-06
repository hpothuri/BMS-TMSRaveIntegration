create or replace
PACKAGE BODY tmsint_java_xfer_utils
   AS

--    **************************************************************************
--    ***                                                                    ***
--    *** Procedure:    getClinicalDataFromMedidata                          ***
--    ***                                                                    ***
--    *** Inputs:       pJobID                                               ***
--    ***               pSourceURL                                           ***
--    ***               pUserName                                            ***
--    ***               pPassword                                            ***
--    ***               pXMLResponse  (TMSINT_XFER_HTML_WS_OBJT Array)       ***
--    ***               pErrorMessage                                        ***
--    ***                                                                    ***
--    *** Description:  The Procedure GetClinicalDataFromMedidata is         ***
--    ***               Called From the Function extractClinicalDataFromURL  ***
--    ***               and will Call the Java Process                       ***
--    ***               ExtractClinicalData.getClinicalDataFromMedidata      ***
--    ***               for the Current Input Parameter Values               ***
--    ***                                                                    ***
--    **************************************************************************
      PROCEDURE getClinicalDataFromMedidata
        (pJobID         IN VARCHAR2,
         pSourceURL     IN VARCHAR2,
         pUserName      IN VARCHAR2,
         pPassword      IN VARCHAR2,
         pXMLResponse   OUT tmsint_xfer_html_ws_objt,
         pErrorMessage  OUT VARCHAR2)
      IS LANGUAGE JAVA
         NAME 'com/rave/tmsint/ExtractClinicalData.getClinicalDataFromMedidata
                 (java.lang.String,
                  java.lang.String,
                  java.lang.String,
                  java.lang.String,
                  oracle.sql.ARRAY[],
                  java.lang.String[])';

--    **************************************************************************
--    ***                                                                    ***
--    *** Procedure:    postClinicalDataToMedidata                           ***
--    ***                                                                    ***
--    *** Inputs:       pPostUrl                                             ***
--    ***               pXLMReqBody                                          ***
--    ***               pUserName                                            ***
--    ***               pPassword                                            ***
--    ***                                                                    ***
--    *** Outputs:      pStatusCode                                          ***
--    ***               pResponsebody                                        ***
--    ***               pErrorMessage                                        ***
--    ***                                                                    ***
--    *** Description:  The Procedure PostClinicalDataFromMedidata is        ***
--    ***               Called From the Function ImportClinicalDataFromURL   ***
--    ***               and will Call the Java Process                       ***
--    ***               pistClinicalData.pstClinicalDataToMedidata for       ***
--    ***               the Current Input Parameter Values                   ***
--    ***                                                                    ***
--    **************************************************************************
      PROCEDURE postClinicalDatatoMedidata
        (pPosturl         IN VARCHAR2,
         pXMLReqBody      IN VARCHAR2,
         pUsername        IN VARCHAR2,
         pPassword        IN VARCHAR2,
         pStatusCode     OUT VARCHAR2,
         pResponseBody   OUT VARCHAR2,
         pErrorMessage   OUT VARCHAR2)
      IS LANGUAGE JAVA
         NAME 'com/rave/tmsint/ImportClinicalData.postClinicalDataToMedidata
                (java.lang.String,
                 java.lang.String,
                 java.lang.String,
                 java.lang.String,
                 oracle.sql.String[],
                 java.lang.String[],
                 java.lang.String[])';

--    **************************************************************************
--    ***                                                                    ***
--    *** Function:    extractClinicalDataFromURL                            ***
--    ***                                                                    ***
--    *** Called By:   TMSINT_XFER_UTILS.RUN_JOB_EXTRACT                     ***
--    ***                                                                    ***
--    *** Inputs:      pJobTab (TMSINT_JAVA_JOB_OBJT Object Type)            ***
--    ***              pDCMTab (TMSINT_JAVA_DCM_OBJT Object Type)            ***
--    ***                                                                    ***
--    *** Outputs:     pExtTab (TMSINT_XFER_HTML_WS_OBJT)                    ***
--    ***                                                                    ***
--    *** Return:      NULL Return = Success; Otherwise Error Message        ***
--    ***                                                                    ***
--    *** Description: This Function is Called from the the Procedure        ***
--    ***              TMSINT_XFER_UTILS.RUN_JOB_EXTRACT.  The Function will ***
--    ***              be Provided Specific Information about a Given        ***
--    ***              Job in the Job Queue for the Purpose of Extracting,   ***
--    ***              and Returning Client Data from the Client Source      ***
--    ***              System Applicable to the Job.  The Return Data will   ***
--    ***              be Used to Populate the EXTRACT Table which will be   ***
--    ***              used for Later TMS Integration Processing.            ***
--    ***                                                                    ***
--    **************************************************************************
      FUNCTION extractClinicalDataFromURL (pJobTab  IN tmsint_java_job_objt,
                                           pDCMTab  IN tmsint_java_dcm_objt,
                                           pExtTab  IN OUT tmsint_xfer_html_ws_objt)
      RETURN VARCHAR2
      IS
         rtn         VARCHAR2(4000)      := NULL;
         errm        VARCHAR2(32767)     := NULL;
         source_url  VARCHAR2(1000)      := NULL;
      BEGIN

--       ***********************************************
--       *** Verify pJobTab and pDCMTab Contain Data ***
--       ***********************************************
         IF (pJobTab.COUNT = 0) OR (pDCMTab.COUNT = 0) THEN
             errm := '%%% Job Information Not Provided for Java Processing';
             RETURN errm;
         END IF;

--       *********************************************
--       *** Initialize the XMLResponseTAB Array.  ***
--       *********************************************
         XMLResponseTAB := tmsint_xfer_html_ws_objt();

--       ***********************************************************************
--       *** For Each STUDY Associated to the Current JobID...               ***
--       *** <pJobTab Contains ONLY a Single JobID but One ore More Studies> ***
--       ***********************************************************************
         FOR i IN pJobTab.FIRST .. pJobTab.LAST LOOP

--           **************************************************
--           *** For Each DCM (FormOID) within the STUDY... ***
--           **************************************************
             FOR j IN pDCMTab.FIRST .. pDCMTab.LAST LOOP

--               *********************************************************
--               *** If the DCM is a Associated to the "Current" STUDY ***
--               *********************************************************
                 IF (pJobTab(i).study_name = pDCMTab(j).study_name) THEN

--                   *****************************************************
--                   *** Construct the SOURCE_URL for the Java Process ***
--                   *****************************************************
                     source_url := pJobTab(i).url||'/'||pDCMTab(j).dcm_name;
                     IF (pJobTab(i).extract_type = 'INCREMENTAL') THEN
                         source_url := source_url ||'?start='||
                             TO_CHAR(pJobTab(i).extract_ts,'YYYY-MM-DD')||'T'||
                             TO_CHAR(pJobTab(i).extract_ts,'HH24:MI:SS');
                     END IF;

--                   *********************************************************
--                   *** Call Java Processing getClinicalDataFromMedidata  ***
--                   *** for the Current Study DCM                         ***
--                   *********************************************************
                     tmsint_java_xfer_utils.getClinicalDataFromMedidata
                       (pJobID         => pJobTab(i).job_id,
                        pSourceURL     => source_url,
                        pUserName      => pJobTab(i).url_username,
                        pPassword      => pJobTab(i).url_password,
                        pXMLResponse   => XMLResponseTAB,
                        pErrorMessage  => errm);

--                   ******************************************
--                   *** Return to Caller if Error Occurred ***
--                   ******************************************
                     IF (errm IS NOT NULL) THEN
                         RETURN errm;   -- Abort and Return to Caller
                     END  IF;

--                   **************************************************
--                   *** Copy the Contents of XMLResponseTAB to the ***
--                   *** Output Parameter pExtTab to be Returned to ***
--                   *** the Caller and then Initialize the Array   ***
--                   *** for the Next Call to Obtain DCM Data       ***
--                   *** Within the Study                           ***
--                   **************************************************
                     IF (XMLResponseTAB.COUNT > 0) THEN
                         FOR k IN XMLResponseTAB.FIRST .. XMLResponseTAB.LAST LOOP
                             pExtTab.EXTEND;
                             pExtTab(pExtTab.LAST) := tmsint_xfer_html_ws_objr
                                (pJobTab(i).url,                -- FILE_NAME
                                 XMLResponseTAB(k).html_text,   -- HTML_TEXT
                                 pJobTab(i).job_id);            -- JOB_ID
                         END LOOP;
                         XMLResponseTAB := tmsint_xfer_html_ws_objt();
                     END IF;
                 END IF;
             END LOOP;  -- End DCM
         END LOOP;  -- End Job Study

--       ************************************
--       *** Return Extracted Data Caller ***
--       ************************************
         RETURN NULL;  -- No Errors Occurred

--    *************************
--    *** Exception Handler ***
--    *************************
      EXCEPTION WHEN OTHERS THEN
         errm := '%%% Unhandled Error in Function extractClinicalDataFromURL '||
             SQLERRM;
         RETURN errm;

      END extractClinicalDataFromURL;


--    **************************************************************************
--    ***                                                                    ***
--    *** Function:    importClinicalDataFromURL                             ***
--    ***                                                                    ***
--    *** Called By:   TMSINT_XFER_UTILS.RUN_JOB_IMPORT                      ***
--    ***                                                                    ***
--    *** Inputs:      pJobTab (TMSINT_JAVA_JOB_OBJT Object Type)            ***
--    ***              pDCMTab (TMSINT_JAVA_DCM_OBJT Object Type)            ***
--    ***                                                                    ***
--    *** Outputs:     pImpTab (TMSINT_XFER_HTML_IMPORT_OBJT)                ***
--    ***                                                                    ***
--    *** Return:      NULL Return = Success; Otherwise Error Message        ***
--    ***                                                                    ***
--    *** Description: This Function is Called from the the Procedure        ***
--    ***              TMSINT_XFER_UTILS.RUN_JOB_EXTRACT.  The Function will ***
--    ***              be Provided Specific Information about a Given        ***
--    ***              Job in the Job Queue for the Purpose of Extracting,   ***
--    ***              and Returning Client Data from the Client Source      ***
--    ***              System Applicable to the Job.  The Return Data will   ***
--    ***              be Used to Populate the EXTRACT Table which will be   ***
--    ***              used for Later TMS Integration Processing.            ***
--    ***                                                                    ***
--    **************************************************************************
      FUNCTION importClinicalDataFromURL (pJobTab IN     tmsint_java_job_objt,
                                          pImpTab IN OUT tmsint_xfer_html_import_objt)
      RETURN VARCHAR2
      IS
         status_rtn        VARCHAR2(4000)    := NULL;
         errm              VARCHAR2(32767)   := NULL;
         out_status_code   VARCHAR2(1000)    := NULL;
         out_response_body VARCHAR2(32767)   := NULL;  -- Not used - Not sure what this is
      BEGIN
--       ************************************
--       *** Verify pJobTab Contains Data ***
--       ************************************
         IF (pJobTab.COUNT = 0) THEN
             errm := '%%% Job Information Not Provided for Java Processing';
             RETURN errm;
         END IF;

--       *****************************************************
--       *** For Each Study for the Corresponding JobID... ***
--       *****************************************************
         FOR i IN pJobTab.FIRST .. pJobTab.LAST LOOP

--           *******************************************************
--           *** For Each Patient Record for the Current Study.. ***
--           *******************************************************
             FOR j IN pImpTab.FIRST .. pImpTab.LAST LOOP

                 IF (pJobTab(i).study_name = pImpTab(j).study) THEN

--                   *****************************************************
--                   *** Update Client Source System with HTML Text... ***
--                   *****************************************************
                     BEGIN
                        tmsint_java_xfer_utils.postClinicalDataToMedidata
                          (pPostUrl         => pJobTab(i).url,
                           pXMLReqBody      => pimptab(j).html_text,
                           pUsername        => pjobtab(i).url_username,
                           pPassword        => pjobtab(i).url_password,
                           pStatusCode      => out_status_code,
                           pResponseBody    => out_response_body,
                           pErrorMessage    => errm);
                     EXCEPTION WHEN OTHERS THEN
                        errm := '%%% Unhandled Error in Call to Java '||
                            'Process postClinicalDataToMedidata '||SQLERRM;
                        RETURN errm;
                     END;

--                   *****************************************************
--                   *** Update the IMPORT Table Array Column Based on ***
--                   *** the Successful Update of the Client Record    ***
--                   *** or the Failure to Update the Client Record    ***
--                   *****************************************************
                     IF (out_status_code = 'SUCCESS') then
                         pImpTab(j).process_flag        := 'Y';
                         pimptab(j).process_ts          :=  SYSDATE;
                         pimptab(j).process_status_code :=  NULL;
                         pimptab(j).process_error_msg   :=  SUBSTR(out_response_body,1,4000);
                     ELSE
                         status_rtn := SUBSTR(errm,1,4000);
                         pimptab(j).process_flag        := 'E';
                         pimptab(j).process_ts          :=  SYSDATE;
                         pimptab(j).process_status_code :=  SUBSTR(errm,1,1000);
                         pimptab(j).process_error_msg   :=  SUBSTR(out_response_body,1,4000);
                     END IF;
                 END IF;
             END LOOP;  -- Patient HTML Import Record
         END LOOP;  -- End Job Study

--       *******************************************************************************
--       *** Return Execution Status to Caller                                       ***
--       *** If No Import Errors Occurred, the STATUS_RTN will be NULL (Success)     ***
--       *** If One or More Errors were Encountered, the STATUS_RTN Variable will    ***
--       *** Contain the Error Message of the Last Error Encountered which will be   ***
--       *** Logged for the Job in the Job Queue as the Reason for Failure.          ***
--       *******************************************************************************
         RETURN status_rtn;

--    *************************
--    *** Exception Handler ***
--    *************************
      EXCEPTION WHEN OTHERS THEN
         errm := '%%% Unhandled Error in Function importClinicalDataFromURL '||
             SQLERRM;
         RETURN errm;

      END importClinicalDataFromURL;


   END tmsint_java_xfer_utils;