-- *****************************************************************************
-- ***                                                                       ***
-- *** File Name:      test_call_to_extract.sql                              ***
-- ***                                                                       ***
-- *** Required User:  Must Run as a Valid TMSINT XFER Oracle Account        ***
-- ***                                                                       ***
-- *** Calls:          TMSINT_XFER_UTILS.QUERY_DATAFILE()                    ***
-- ***                 TMSINT_XFER_UTILS.QUERY_DICT_MAPPING()                ***
-- ***                 TMSINT_JAVA_UTILS.ExtractClinicalData                 ***
-- ***                                                                       ***
-- *** Description:    This SQL Program is Simply a Means to Populate the    ***
-- ***                 pJobTab and pDCMTab Object Arrays which are Inputs    ***
-- ***                 to the Java EXTRACT Process.  This Allows Testing of  ***
-- ***                 the Extract Procedure to be Isolated and Run Outside  ***
-- ***                 the Scope of the TMSINT Application Batch Queue.      ***
-- ***                 This Process will use an Abitrary JobID and will      ***
-- ***                 NOT Actually Create data in the EXTRACT Table.        ***
-- ***                 Only the Input Parameter Arrays will be Populated     ***
-- ***                 for the Call to the Java Extract so that the Java     ***
-- ***                 Program may Test Functionality and Populate the       ***
-- ***                 EXTRACT object array.                                 ***
-- ***                                                                       ***
-- *****************************************************************************
--  SET ECHO ON
--  SET TERMOUT ON
  SET SERVEROUTPUT ON SIZE UNLIMITED
  DECLARE
     pJobTab      tmsint_java_job_objt     := tmsint_java_job_objt();
     pDCMTab      tmsint_java_dcm_objt     := tmsint_java_dcm_objt();
     pExtTab      tmsint_xfer_html_ws_objt := tmsint_xfer_html_ws_objt();
     java_rtn     VARCHAR2(32767)          := NULL;
     fake_job_id  INTEGER                  := 999;
  BEGIN

--   *************************************************************************
--   *** Populate pJobTab for Test all to Java Processing...               ***
--   *** ------------------------------------------------                  ***
--   *** If running as Oracle User TMSINT_XFER_BMS,  data will be for BMS  ***
--   *** If running as Oracle User TMSINT_XFER_BMS2, data will be for BMS2 ***
--   *** If running as Oracle User TMSINT_XFER_INV,  data will be for INV  ***  
--   *************************************************************************
     FOR study IN (SELECT * FROM TABLE(tmsint_xfer_utils.query_datafile()))
     LOOP
         pJobTab.EXTEND;
         pJobTab(pJobTab.LAST) := tmsint_java_job_objr
           (fake_job_id,                    -- JOB_ID
            study.client_alias,             -- CLIENT_ALIAS
            study.study_name,               -- STUDY_NAME
            study.datafile_url,             -- URL
            study.url_user_name,            -- URL_USERNAME
            study.url_password,             -- URL_PASSWORD
            study.data_extract_type,        -- EXTRACT_TYPE
            study.next_incr_extract_ts);    -- EXRACT_TS
 
--       *********************************************
--       *** Populate pDCMTab for Current Study... ***
--       *********************************************
         FOR dcm IN (SELECT * FROM TABLE(tmsint_xfer_utils.query_dict_mapping())
                     WHERE datafile_id = study.datafile_id)
         LOOP
             pDCMTab.EXTEND;
             pDCMTab(pDCMTab.LAST) := tmsint_java_dcm_objr
               (fake_job_id,                  -- JOB_ID
                study.study_name,             -- STUDY_NAME
                dcm.dcm_name,                 -- DCM_NAME
                dcm.vt_name);                 -- VT_NAME
         END LOOP;
      END LOOP;

--    **********************************
--    *** Display Array Content...   ***
--    **********************************
      IF (pJobTab.COUNT > 0) THEN
          FOR i IN pJobTab.FIRST .. pJobTab.LAST LOOP
              DBMS_OUTPUT.PUT_LINE(CHR(9));
              DBMS_OUTPUT.PUT_LINE('JobID:       '||pJobTab(i).job_id);
              DBMS_OUTPUT.PUT_LINE('Study:       '||pJobTab(i).study_name);
              DBMS_OUTPUT.PUT_LINE('URL:         '||pJobTab(i).url);
              DBMS_OUTPUT.PUT_LINE('Credentials: '||pJobTab(i).url_username||'/'||pJobTab(i).url_password);
              DBMS_OUTPUT.PUT_LINE(CHR(9));
              FOR j IN pDCMTab.FIRST .. pDCMTab.LAST LOOP
                  IF (pDCMTab(j).study_name = pJobTab(i).study_name) THEN
                      DBMS_OUTPUT.PUT_LINE(CHR(9)||'DCM => '||pDCMTab(j).dcm_name||'.'||pDCMTab(j).vt_name);
                  END IF;
              END LOOP;
          END LOOP;
      END IF;
 
--    ******************************************************************
--    *** Call Java extractClinicalDataFromURL for the Current JobID ***
--    ******************************************************************
      DBMS_OUTPUT.PUT_LINE(CHR(9));
      DBMS_OUTPUT.PUT_LINE('Calling Java Extract Process...');
      BEGIN
         java_rtn := tmsint_java_xfer_utils.extractClinicalDataFromURL
                     (pJobTab => pJobTab,
                      pDCMTab => pDCMTab,
                      pExtTab => pExtTab);
         IF (java_rtn IS NULL) THEN
             dbms_output.put_line('Java Extract Completed Successfully');
             DBMS_OUTPUT.PUT_LINE('Number of lines extracted : ' || pExtTab.COUNT);
         else         
             RAISE_APPLICATION_ERROR(-20101,'%%% Error Returned from Java: '||java_rtn);
         END IF;
      EXCEPTION WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20101,'%%% Unhandled Error Running Java '||SQLERRM);
      END;

  END;
/