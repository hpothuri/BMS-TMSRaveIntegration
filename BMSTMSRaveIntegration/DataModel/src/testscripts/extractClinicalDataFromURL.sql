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
--     FOR study IN (SELECT * FROM TABLE(tmsint_xfer_utils.query_datafile()))
--     LOOP
         pJobTab.EXTEND;
         pJobTab(pJobTab.LAST) := tmsint_java_job_objr
           (fake_job_id,                    -- JOB_ID
            'BMS',             -- CLIENT_ALIAS
            'TMS CODING STUDY 1(DEV)',               -- STUDY_NAME
            'https://bmsdev.mdsol.com/RaveWebServices/studies/TMS CODING STUDY 1(DEV)/datasets/regular',             -- URL
            'DCaruso',            -- URL_USERNAME
            'QuanYin1',             -- URL_PASSWORD
            'CUMULATIVE',        -- EXTRACT_TYPE
            null);    -- EXRACT_TS
            
           pJobTab.EXTEND;
         pJobTab(pJobTab.LAST) := tmsint_java_job_objr
           (fake_job_id,                    -- JOB_ID
            'BMS',             -- CLIENT_ALIAS
            'TMS CODING STUDY 2(DEV)',               -- STUDY_NAME
            'https://bmsdev.mdsol.com/RaveWebServices/studies/TMS CODING STUDY 2(DEV)/datasets/regular',             -- URL
            'DCaruso',            -- URL_USERNAME
            'QuanYin1',             -- URL_PASSWORD
            'CUMULATIVE',        -- EXTRACT_TYPE
            null);    -- EXRACT_TS
 
--       *********************************************
--       *** Populate pDCMTab for Current Study... ***
--       *********************************************
--         FOR dcm IN (SELECT * FROM TABLE(tmsint_xfer_utils.query_dict_mapping())
--                     WHERE datafile_id = study.datafile_id)
--         LOOP
             pDCMTab.EXTEND;
             pDCMTab(pDCMTab.LAST) := tmsint_java_dcm_objr
               (fake_job_id,                  -- JOB_ID
                'TMS CODING STUDY 1(DEV)',             -- STUDY_NAME
                'CONMED',                 -- DCM_NAME
                'EXTRT_PREMED');                 -- VT_NAME
                
             pDCMTab.EXTEND;
             pDCMTab(pDCMTab.LAST) := tmsint_java_dcm_objr
               (fake_job_id,                  -- JOB_ID
                'TMS CODING STUDY 1(DEV)',             -- STUDY_NAME
                'PREMED',                 -- DCM_NAME
                'EXTRT_PREMED');                 -- VT_NAME
--         END LOOP;
--      END LOOP;

--    **********************************
--    *** Display Array Content...   ***
--    **********************************
--      IF (pJobTab.COUNT > 0) THEN
--          FOR i IN pJobTab.FIRST .. pJobTab.LAST LOOP
--              DBMS_OUTPUT.PUT_LINE(CHR(9));
--              DBMS_OUTPUT.PUT_LINE('JobID:       '||pJobTab(i).job_id);
--              DBMS_OUTPUT.PUT_LINE('Study:       '||pJobTab(i).study_name);
--              DBMS_OUTPUT.PUT_LINE('URL:         '||SUBSTR(pJobTab(i).url,1,50)||'[...]');
--              DBMS_OUTPUT.PUT_LINE('Credentials: '||pJobTab(i).url_username||'/'||pJobTab(i).url_password);
--              DBMS_OUTPUT.PUT_LINE(CHR(9));
--              FOR j IN pDCMTab.FIRST .. pDCMTab.LAST LOOP
--                  IF (pDCMTab(j).study_name = pJobTab(i).study_name) THEN
--                      DBMS_OUTPUT.PUT_LINE(CHR(9)||'DCM => '||pDCMTab(j).dcm_name||'.'||pDCMTab(j).vt_name);
--                  END IF;
--              END LOOP;
--          END LOOP;
--      END IF;
 
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
           FOR i IN pExtTab.FIRST .. pExtTab.LAST LOOP
           DBMS_OUTPUT.PUT_LINE(pExtTab(i).FILE_NAME || ' - '|| pExtTab(i).html_text);
           END LOOP;
         else         
             RAISE_APPLICATION_ERROR(-20101,'%%% Error Returned from Java: '||java_rtn);
         END IF;         
      EXCEPTION WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20101,'%%% Unhandled Error Running Java '||SQLERRM);
      END;

  END;
/