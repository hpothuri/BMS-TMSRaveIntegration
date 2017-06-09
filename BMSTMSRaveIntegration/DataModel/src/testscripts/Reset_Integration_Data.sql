set echo on
set termout on
set feedback on
spool force_1st_time_run_for_smile_study.log
 
--    **************************************************************
--    *** Delete All Patient Omission Data in TMS_VT_OMISSIONS   ***
--    *** SMILE-002(PFTEST) - This is REQUIRED to Simulate a     ***
--    *** 1st time Execution for this Study to Produce ALL of    ***
--    *** IMPORT Data Needed.                                    ***
--    **************************************************************
      COL ext_value_1 format a45 WRAP
      SELECT def_integration_key, ext_value_1, COUNT(*)
      FROM tms.tms_vt_omissions
      WHERE def_integration_key = 'BMS'
      GROUP BY def_integration_key, ext_value_1;
      DECLARE
         curr_ignore_discard_flag  BOOLEAN  := TRUE;
         rtn                       BOOLEAN  := TRUE;
         curr_instance_id          INTEGER  := NULL;
      BEGIN
         SELECT def_instance_id INTO curr_instance_id
         FROM tms.tms_def_instances WHERE remote_db_flag = 'N';
 
         FOR rec IN (SELECT * FROM tms.tms_vt_omissions
                     WHERE def_integration_key = 'BMS'
                       AND INSTR(ext_value_1,'SMILE-002(PFTEST)|') > 0
                       AND INSTR(ext_value_4,'|') > 0
                       AND INSTR(ext_value_5,'|') > 0
                       AND INSTR(ext_value_6,'|') > 0
                       AND ext_value_7 IS NULL
                       AND ext_value_8 IS NULL)
         LOOP
            rtn:= tms.tms_conflict_res.vt_omissions_del
              (pSourceTermId       => rec.source_term_id,
               pOccurenceId        => rec.occurrence_id,
               pDefInstanceId      => curr_instance_id,
               pDefIntegrationKey  => 'BMS',
               pIgnoreDiscardFlag  => curr_ignore_discard_flag);
         END LOOP;
         COMMIT;
         tms.tms_user_synchronization.synchronize;
      END;
/
      SELECT def_integration_key, ext_value_1, COUNT(*)
      FROM tms.tms_vt_omissions
      WHERE def_integration_key = 'BMS'
      GROUP BY def_integration_key, ext_value_1;
 
 
--    **************************************************************
--    *** Delete All Patient Coding Data in TMS_SOURCE_TERMS for ***
--    *** SMILE-002(PFTEST) - This is REQUIRED to Simulate a     ***
--    *** 1st time Execution for this Study to Produce ALL of    ***
--    *** IMPORT Data Needed.                                    ***
--    *** This Does Not Delete any VTAs in the TMS Repository!   ***
--    **************************************************************
      SELECT def_integration_key, ext_value_1, COUNT(*)
      FROM tms.tms_source_terms
      WHERE def_integration_key = 'BMS'
      GROUP BY def_integration_key, ext_value_1;
      DECLARE
         curr_instance_id          INTEGER        := NULL;
      BEGIN
         SELECT def_instance_id INTO curr_instance_id
         FROM tms.tms_def_instances WHERE remote_db_flag = 'N';
 
         FOR rec IN (SELECT * FROM tms.tms_source_terms
                     WHERE def_integration_key = 'BMS'
                       AND INSTR(ext_value_1,'SMILE-002(PFTEST)|') > 0
                       AND INSTR(ext_value_4,'|') > 0
                       AND INSTR(ext_value_5,'|') > 0
                       AND INSTR(ext_value_6,'|') > 0
                       AND ext_value_7 IS NULL
                       AND ext_value_8 IS NULL)
         LOOP
            tms.tms_user_source_data.deletesourceterm
              (pSourceTermId       => rec.source_term_id,
               pOccurenceId        => rec.occurrence_id,
               pDefIntegrationKey  => 'BMS',
               pDefInstanceId      => curr_instance_id);
        END LOOP;
        COMMIT;
        tms.tms_user_synchronization.synchronize;
     END;
/
      SELECT def_integration_key, ext_value_1, COUNT(*)
      FROM tms.tms_source_terms
      WHERE def_integration_key = 'BMS'
      GROUP BY def_integration_key, ext_value_1;
 
 
-- ***************************************************************************
-- *** Delete all TMSINT SMILE-002(PFTEST) Data to Simulate a 1st time Run ***
-- ***************************************************************************
   connect tmsint_proc_bms/tmsint_proc_bms
 
   DELETE FROM tmsint_proc_coding_derv_jn j
   WHERE EXISTS (SELECT 1 FROM tmsint_proc_coding_jn
                 WHERE study_name = 'SMILE-002(PFTEST)'
                   AND coding_id = j.coding_id);
   DELETE FROM tmsint_proc_coding_dtls_jn j
   WHERE EXISTS (SELECT 1 FROM tmsint_proc_coding_jn
                 WHERE study_name = 'SMILE-002(PFTEST)'
                   AND coding_id = j.coding_id);
   DELETE FROM tmsint_proc_coding_jn WHERE study_name = 'SMILE-002(PFTEST)';
   COMMIT;
 
   DELETE FROM tmsint_proc_coding_derv c
   WHERE EXISTS (SELECT 1 FROM tmsint_proc_coding
                 WHERE study_name = 'SMILE-002(PFTEST)'
                   AND coding_id = c.coding_id);
   DELETE FROM tmsint_proc_coding_dtls c
   WHERE EXISTS (SELECT 1 FROM tmsint_proc_coding
                 WHERE study_name = 'SMILE-002(PFTEST)'
                   AND coding_id = c.coding_id);
   DELETE FROM tmsint_proc_coding WHERE study_name = 'SMILE-002(PFTEST)';
   COMMIT;
 
   connect tmsint_xfer_bms/tmsint_xfer_bms
   DELETE FROM tmsint_xfer_xml_import WHERE study = 'SMILE-002(PFTEST)';
   COMMIT;
 
SPOOL OFF
EXIT