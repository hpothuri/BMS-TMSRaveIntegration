 SET SERVEROUTPUT ON SIZE UNLIMITED
  DECLARE
     pJobTab      tmsint_java_job_objt     := tmsint_java_job_objt();
     pImpTab      tmsint_xfer_html_import_objt     := tmsint_xfer_html_import_objt();
     l_input_payload VARCHAR2(4000) := '<?xml version="1.0" encoding="utf-8"?>
<ODM FileType="Transactional" FileOID="131e5e07-22b8-4da9-8048-33f4452492a3" CreationDateTime="2016-10-28T17:09:30.100-00:00" ODMVersion="1.3" xmlns:mdsol="http://www.mdsol.com/ns/odm/metadata" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.cdisc.org/ns/odm/v1.3">
<ClinicalData StudyOID="TMS Coding Study 1(DEV)" MetaDataVersionOID="114" >
  <SubjectData SubjectKey="001-00001" TransactionType="Update">
   <SiteRef LocationOID="RKB_001" />
    <StudyEventData StudyEventOID="CONMED" StudyEventRepeatKey="1" TransactionType="Update">
     <FormData FormOID="CONMED" FormRepeatKey="1" TransactionType="Update">
      <ItemGroupData ItemGroupOID="CONMED_LOG_LINE" ItemGroupRepeatKey="3" TransactionType="Upsert">
       <ItemData ItemOID="CONMED.CMTRT" Value="BARACLUDE  (ENTECAVIR)" TransactionType="Context">
        <mdsol:Query Recipient="Site from Dictionary" QueryRepeatKey="54018" Status="Open"/>
       </ItemData>
      </ItemGroupData>
     </FormData>
    </StudyEventData>
   </SubjectData>
</ClinicalData>
</ODM>';
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
 
--       *********************************************
--       *** Populate pDCMTab for Current Study... ***
--       *********************************************
--         FOR dcm IN (SELECT * FROM TABLE(tmsint_xfer_utils.query_dict_mapping())
--                     WHERE datafile_id = study.datafile_id)
--         LOOP
             pImpTab.EXTEND;
             pImpTab(pImpTab.LAST) := tmsint_xfer_html_import_objr
               (1,                  -- seqno
                 'study', -- study
                'patient',             -- patient
                'file_name',                 -- file_name
                'file_type',
                l_input_payload,
                sysdate, --creation_ts
                null, --process_flag
                null,--process_ts
                null,--process_status_code
                null,--process_error_msg
                999);                 -- job_id
       
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
         java_rtn := tmsint_java_xfer_utils.importClinicalDataFromURL
                     (pJobTab => pJobTab,
                      pImpTab => pImpTab);
         IF (java_rtn IS NULL) THEN
             dbms_output.put_line('Java import Completed Successfully');
             DBMS_OUTPUT.PUT_LINE('Number of lines processed : ' || pImpTab.COUNT);
         else         
             RAISE_APPLICATION_ERROR(-20101,'%%% Error Returned from Java: '||java_rtn);
         END IF;         
      EXCEPTION WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20101,'%%% Unhandled Error Running Java '||SQLERRM);
      END;

  END;
/