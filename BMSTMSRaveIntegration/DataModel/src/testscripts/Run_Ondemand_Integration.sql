-- ********************************
-- *** Create JOB in Job Queue  ***
-- ********************************
   connect tmsint_xfer_bms/tmsint_xfer_bms
   EXEC tmsint_job_queue_utils.create_demand_job_one_study('BMS','SMILE-002(PFTEST)');
 
-- ****************************************************************************
-- ***  Run EXTRACT  (FYI - Takes 3 min 57 sec to complete for 1st time Run) ***
-- ****************************************************************************
   SET TIMING ON ECHO ON TERMOUT ON FEEDBACK ON SERVEROUTPUT ON SIZE UNLIMITED
   CONNECT tmsint_xfer_bms/tmsint_xfer_bms
   SPOOL run_extract.log
      EXEC tmsint_xfer_utils.run_job_extract('Y');
   SPOOL OFF
 
-- *******************************************************************************
-- *** Run INTEGRATION  (FYI - Takes 5 min 40 sec to complete for 1st time Run) ***
-- *******************************************************************************
   SET TIMING ON ECHO ON TERMOUT ON FEEDBACK ON SERVEROUTPUT ON SIZE UNLIMITED
   CONNECT tmsint_proc_bms/tmsint_proc_bms
   SPOOL run_integration.log
      EXEC tmsint_proc_utils.run_job_integration;
   SPOOL OFF
 
-- ********************
-- *** Run IMPORT   ***
-- ********************
   SET TIMING ON ECHO ON TERMOUT ON FEEDBACK ON SERVEROUTPUT ON SIZE UNLIMITED
   CONNECT tmsint_xfer_bms/tmsint_xfer_bms
   SPOOL run_import.log
      EXEC tmsint_xfer_utils.run_job_import('Y');
   SPOOL OFF