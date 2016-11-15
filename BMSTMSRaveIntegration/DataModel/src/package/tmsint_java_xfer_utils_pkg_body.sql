-- *****************************************************************************
-- ***                                                                       ***
-- *** File Name:     tmsint_java_xfer_utils_pkg_body.sql                    ***
-- ***                                                                       ***
-- *** Date Written:  15 November 2016                                       ***
-- ***                                                                       ***
-- *** Written By:    Harish Pothuri / DBMS Consulting Inc.                  ***
-- ***                                                                       ***
-- *** Package Name:  TMSINT_JAVA_XFER_UTILS (Package Body)                  ***
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
   COLUMN date_column NEW_VALUE curr_date NOPRINT
   SELECT TO_CHAR(SYSDATE,'MMDDYY_HHMI') date_column FROM DUAL;
   SET PAGESIZE 0
   SET VERIFY OFF
   SET TERMOUT OFF
   SET SERVEROUTPUT ON SIZE UNLIMITED
   SET TERMOUT ON
   SET FEEDBACK OFF
   SPOOL ../log/tmsint_java_xfer_utils_pkg_body_&curr_date..log

   SELECT 'Process:  '||'tmsint_java_xfer_utils_pkg_body.sql'   ||CHR(10)||
          'Package:  '||'TMSINT_JAVA_XFER_UTILS Body'           ||CHR(10)||
          'User:     '||USER                                    ||CHR(10)||
          'Date:     '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI AM') ||CHR(10)||
          'Instance: '||global_name
   FROM global_name;
   SET FEEDBACK ON

   PROMPT 
   PROMPT *********************************************************************
   PROMPT ***      Creating TMSINT_JAVA_XFER_UTILS Package Body             ***
   PROMPT *********************************************************************

-- ****************************************************************************
-- ***               TMSINT_JAVA_XFER_UTILS Package Body                    ***
-- ****************************************************************************
   CREATE OR REPLACE PACKAGE BODY tmsint_java_xfer_utils 
   AS

--    **************************************************************************
--    ***                                                                    ***
--    *** Procedure:    PUT_LOG                                              ***
--    ***                                                                    ***
--    **************************************************************************
      PROCEDURE put_log(p_proc    IN VARCHAR2,
                        p_message IN VARCHAR2)
       IS
       BEGIN
          DBMS_OUTPUT.PUT_LINE(p_proc||'-'||p_message);
       END put_log;

--    **************************************************************************
--    ***                                                                    ***
--    *** Function:    INVOKE_REST_SERVICE                                   ***
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
      PROCEDURE invoke_rest_service
          (p_url             IN VARCHAR2,
           p_input_payload   IN CLOB,
           p_http_method     IN VARCHAR2,
           p_username        IN VARCHAR2,
           p_password        IN VARCHAR2,
           p_response        OUT CLOB,
           p_status_code     OUT VARCHAR2,
           p_error_message   OUT VARCHAR2)
     IS
         l_rest_endpoint    VARCHAR2 (1000);
         l_wallet           VARCHAR2 (100) := NULL;
         l_wallet_pwd       VARCHAR2 (100) := 'orawallet@123';  --Wrap!
         l_req_length       BINARY_INTEGER;
         buffer             VARCHAR2(2000);
         amount             PLS_INTEGER := 2000;
         offset             PLS_INTEGER := 1;
         l_text             VARCHAR2(32767);
         l_http_request     UTL_HTTP.REQ;
         l_http_response    UTL_HTTP.RESP;
     BEGIN
--       ************************************************
--       *** Get Value of "JAVA_WALLET_PATH" Property ***
--       ************************************************
         BEGIN
            SELECT property_value INTO l_wallet
            FROM tmsint_adm_properties
            WHERE property_name = 'JAVA_WALLET_PATH';
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RAISE_APPLICATION_ERROR(-20101,'%%% The Application Property '||
                   '"JAVA_WALLET_PATH" has Not Been Defined - Contact the '||
                   'Application Administrator to Create the Property');
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20101,'%%% Unhandled Error Obtaining '||
                  'the "JAVA_WALLET_PATH" Property '||SQLERRM);
         END;

         put_log('INVOKE_REST_SERVICE', 'p_url =' || p_url);
         put_log('INVOKE_REST_SERVICE', 'p_http_method =' || P_HTTP_METHOD);
         put_log('INVOKE_REST_SERVICE', 'p_username=' || p_username);
         put_log('INVOKE_REST_SERVICE', 'p_password=' || p_password);
         put_log('INVOKE_REST_SERVICE', 'l_wallet=' || l_wallet);
         put_log('INVOKE_REST_SERVICE', 'l_wallet_pwd=' || l_wallet_pwd);

         IF (l_wallet IS NULL) THEN
             RAISE_APPLICATION_ERROR(-20002,'SSL Wallet is not setup. '||
               'Please contact your administrator.');
         END IF;

         IF (l_wallet_pwd IS NULL) THEN
             RAISE_APPLICATION_ERROR (-20003,'SSL Wallet Password is not setup. '||
               'Please contact your administrator.');
         END IF;

         IF (p_url IS NULL) THEN
            RAISE_APPLICATION_ERROR (-20004,'Rest Service Url can not be null.');
         END IF;

         IF (p_username IS NULL) OR (p_password IS NULL) THEN
            RAISE_APPLICATION_ERROR (-20005,'Credentials can not be null.');
         END IF;

--       ****************************************
--       *** Set the Wallet Path and Password ***
--       ****************************************
         UTL_HTTP.SET_WALLET(l_wallet, l_wallet_pwd);

--       **********************
--       *** Encode the URL ***
--       **********************
         l_rest_endpoint := UTL_URL.ESCAPE(p_url);
         put_log('INVOKE_REST_SERVICE','Encoded l_rest_endpoint =' ||l_rest_endpoint);
         l_http_request := UTL_HTTP.BEGIN_REQUEST(l_rest_endpoint,p_http_method,'HTTP/1.1');

--       ***********************
--       *** Set Credentials ***
--       ***********************
         UTL_HTTP.SET_AUTHENTICATION(l_http_request, p_username, p_password);
         DBMS_LOB.CREATETEMPORARY (p_response, false);

         BEGIN
            IF (P_HTTP_METHOD = 'GET') THEN
                put_log ('INVOKE_REST_SERVICE','Processing GET request');

            ELSIF (P_HTTP_METHOD = 'POST') THEN
                put_log('INVOKE_REST_SERVICE', 'Processing POST request');
                IF (P_INPUT_PAYLOAD IS NULL) THEN
                   RAISE_APPLICATION_ERROR (-20006,'Input payload can not be '||
                       'null when the operation is POST.');
                END IF;

                UTL_HTTP.SET_HEADER (L_HTTP_REQUEST,
                                'Content-Type',
                                'text/xml; charset=utf-8');
                put_log ('INVOKE_REST_SERVICE', 'Done setting Content-Type '||
                         'header as text/xml');

                L_REQ_LENGTH := DBMS_LOB.GETLENGTH (P_INPUT_PAYLOAD);
                PUT_LOG ('INVOKE_REST_SERVICE',
                  'input Payload length =' || L_REQ_LENGTH);

--               **********************************************
--               *** read payload and populate http request ***
--               **********************************************
                 IF (L_REQ_LENGTH <= 32767)
                 THEN
                    UTL_HTTP.SET_HEADER (l_http_request, 'Content-Length', l_req_length);
                     put_log ('INVOKE_REST_SERVICE', 'Done setting Content-Length '||
                              'header as '||l_req_length);
                    UTL_HTTP.WRITE_TEXT (l_http_request, p_input_payload);
                 ELSE
                    UTL_HTTP.SET_HEADER (l_http_request, 'Transfer-Encoding', 'chunked');
                    BEGIN
                      LOOP
                         DBMS_LOB.READ (p_input_payload,
                                      amount,
                                      offset,
                                      buffer);
                         UTL_HTTP.WRITE_TEXT (l_http_request, buffer);
                         offset := offset + amount;
                       END LOOP;
                    EXCEPTION WHEN NO_DATA_FOUND THEN    
                      put_log ('INVOKE_REST_SERVICE', 'Done writing P_INPUT_PAYLOAD');
                    END;
                 END IF;                
            ELSE
                RAISE_APPLICATION_ERROR (-20007,'Invalid http method. '||
                   'Only GET and POST are supported.');
            END IF;

--          **********************************************
--          *** process http request and read response ***
--          **********************************************
            l_http_response := UTL_HTTP.get_response(l_http_request);
            put_log ('INVOKE_REST_SERVICE', 'Status code : ' || l_http_response.status_code);
            IF (l_http_response.status_code = UTL_HTTP.HTTP_OK) then
                BEGIN
                   LOOP
                       UTL_HTTP.READ_TEXT (L_HTTP_RESPONSE, L_TEXT, 32766);
                        put_log('INVOKE_REST_SERVICE','Chunk of 32766 chars : ' || L_TEXT);
                        DBMS_LOB.WRITEAPPEND (p_response, LENGTH (L_TEXT), L_TEXT);
                   END LOOP;
                EXCEPTION
                   WHEN UTL_HTTP.END_OF_BODY THEN
                        UTL_HTTP.END_RESPONSE (L_HTTP_RESPONSE);
                   WHEN OTHERS THEN
                        put_log('INVOKE_REST_SERVICE',SQLERRM);
                END;
                   put_log('INVOKE_REST_SERVICE','Response length : ' ||
                            DBMS_LOB.getlength(p_response));
                   p_status_code := 'S';
           ELSE
               p_status_code := 'E';
           END IF;

         EXCEPTION WHEN OTHERS THEN
            put_log('INVOKE_REST_SERVICE','Execption raised');
            p_error_message := UTL_HTTP.GET_DETAILED_SQLCODE||UTL_HTTP.GET_DETAILED_SQLERRM || SQLERRM;
         END;

         put_log('INVOKE_REST_SERVICE','Status : ' ||p_status_code );
         UTL_HTTP.END_REQUEST(l_http_request);

--   *************************
--   *** Exception Handler ***
--   *************************
     EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20101,'%%% Unhandled Error in Procedure '||
            'INVOKE_REST_SERVICE' || SQLERRM);

     END invoke_rest_service;

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
         rtn            VARCHAR2(4000)      := NULL;
         errm           VARCHAR2(32767)     := NULL;
         source_url     VARCHAR2(1000)      := NULL;
         l_status_code  VARCHAR2(1)         := NULL;
         l_xml_line     VARCHAR2(4000)      := NULL;
         l_response     CLOB;
         l_xmlresponse  XMLTYPE;
         l_str          LONG;
         l_resp_header_elem    VARCHAR2(400):= NULL;
         l_resp_footer_elem    VARCHAR2(10) := '</ODM>';
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
                     PUT_LOG('extractClinicalDataFromURL','Calling invoke_rest_service');
                     DBMS_LOB.CREATETEMPORARY (l_response, true);
                     tmsint_java_xfer_utils.invoke_rest_service
                        (p_url           =>  source_url,
                         p_input_payload =>  NULL,
                         p_http_method   => 'GET' ,
                         p_username      =>  pJobTab(i).url_username,
                         p_password      =>  pJobTab(i).url_password,
                         p_response      =>  l_response,
                         p_status_code   =>  l_status_code,
                         p_error_message =>  errm);

                      IF (l_status_code = 'S') THEN
                          put_log('extractClinicalDataFromURL','Rest service call successful' );
                          put_log('extractClinicalDataFromURL','Response length before cleaning: '||
                              DBMS_LOB.GETLENGTH(l_response));
                          l_response := DBMS_LOB.SUBSTR(l_response,
                              DBMS_LOB.GETLENGTH(l_response) -
                              DBMS_LOB.INSTR(l_response,'<')+1,
                              DBMS_LOB.INSTR(l_response,'<'));
                          put_log('extractClinicalDataFromURL','Response length after cleaning: ' ||
                              DBMS_LOB.GETLENGTH(l_response));
                          l_xmlresponse := XMLTYPE.CREATEXML(l_response);

--                        **************************************************************************
--                        *** Copy the Contents of XMLResponseTAB to the Output Parameter pExtTab ***
--                        *** to be Returned to the Caller and then Initialize the Array for the  ***
--                        *** Next Call to Obtain DCM Data Within the Study                       ***
--                        ***************************************************************************
                          l_str := l_xmlresponse.extract('/*').getstringval();
                          LOOP
                              EXIT WHEN l_str IS NULL;
                              put_log('extractClinicalDataFromURL',
                                  'Response line - '||(SUBSTR(l_str,1,INSTR(l_str,CHR(10))-1)));
                              l_xml_line := (SUBSTR(l_str,1,INSTR(l_str,CHR(10))-1));
--                        ***************************************************************************
--                        *** Populate header and footer for the first request and skip them in   ***
--                        *** subsequent calls                                                    ***
--                        *************************************************************************** 
                              IF SUBSTR(l_xml_line,1,4) = '<ODM' THEN
                                IF l_resp_header_elem IS NULL THEN
                                  l_resp_header_elem := l_xml_line;
                              pExtTab.EXTEND;
                              pExtTab(pExtTab.LAST) := tmsint_xfer_html_ws_objr
                                (pJobTab(i).url,                -- FILE_NAME
                                 l_xml_line,                    -- HTML_TEXT
                                 pJobTab(i).job_id);            -- JOB_ID
                                END IF;
                              ELSIF l_xml_line = l_resp_footer_elem THEN
                                put_log('extractClinicalDataFromURL','Skipping footer element');
                              ELSE  
                                 pExtTab.EXTEND;
                                 pExtTab(pExtTab.LAST) := tmsint_xfer_html_ws_objr
                                                            (pJobTab(i).url,                -- FILE_NAME
                                                             l_xml_line,                    -- HTML_TEXT
                                                             pJobTab(i).job_id);            -- JOB_ID                                
                              END IF;
                              l_str := SUBSTR(l_str,INSTR(l_str,CHR(10))+1);
                         END LOOP;
                         
                         XMLResponseTAB := tmsint_xfer_html_ws_objt();
                      ELSE
                         RETURN errm;   -- Abort and Return to Caller
                      END IF;
                 END IF; -- Study DCM
             END LOOP;  -- End DCM
             
--      **************************************************************
--      *** Add the footer at the last element in response         ***
--      **************************************************************
        pExtTab.EXTEND;
        pExtTab(pExtTab.LAST) := tmsint_xfer_html_ws_objr
                                    (pJobTab(i).url,                -- FILE_NAME
                                     l_resp_footer_elem,            -- HTML_TEXT
                                     pJobTab(i).job_id);            -- JOB_ID     

         END LOOP;  -- End Job Study

--       ************************************
--       *** Return Extracted Data Caller ***
--       ************************************
         DBMS_LOB.FREETEMPORARY(l_response);
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
         out_response_body CLOB;
         l_input_payload    CLOB;
         l_payload_length       BINARY_INTEGER;

      BEGIN
--       ************************************
--       *** Verify pJobTab Contains Data ***
--       ************************************
         IF (pJobTab.COUNT = 0) THEN
             errm := '%%% Job Information Not Provided for Java Processing';
             RETURN errm;
         END IF;

         DBMS_LOB.CREATETEMPORARY(out_response_body,FALSE);
         DBMS_LOB.CREATETEMPORARY(l_input_payload,FALSE);

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
                        put_log('importClinicalDataFromURL', '****************************');
                        put_log('importClinicalDataFromURL', 'url - '||  pJobTab(i).url);
                        put_log('importClinicalDataFromURL', 'seqno - '||  pImpTab(j).seqno);
                        put_log('importClinicalDataFromURL', 'html_text - '||  pImpTab(j).html_text);

--                     *****************************************************************
--                     *** Reset l_input_payload CLOB and populate it with html text ***
--                     *****************************************************************
                       l_payload_length := DBMS_LOB.GETLENGTH(l_input_payload);
                       DBMS_LOB.ERASE(l_input_payload,l_payload_length,1);
                       DBMS_LOB.WRITE(l_input_payload, LENGTH(pImpTab(j).html_text),
                          1, pImpTab(j).html_text);

                       tmsint_java_xfer_utils.invoke_rest_service
                         (p_url           =>  pJobTab(i).url,
                          p_input_payload =>  l_input_payload,
                          p_http_method   => 'POST' ,
                          p_username      =>  pJobTab(i).url_username,
                          p_password      =>  pJobTab(i).url_password,
                          p_response      =>  out_response_body,
                          p_status_code   =>  out_status_code,
                          p_error_message =>  errm);
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
                     IF (out_status_code = 'S') then
                         pImpTab(j).process_flag        := 'Y';
                         pImpTab(j).process_ts          :=  SYSDATE;
                         pImpTab(j).process_status_code :=  NULL;
                         pImpTab(j).process_error_msg   :=  DBMS_LOB.SUBSTR(out_response_body,4000,1);
                     ELSE
                         status_rtn                     :=  SUBSTR(errm,1,1000);
                         pImpTab(j).process_flag        := 'E';
                         pImpTab(j).process_ts          :=  SYSDATE;
                         pimptab(j).process_status_code :=  SUBSTR(errm,1,1000);
                         pimptab(j).process_error_msg   :=  DBMS_LOB.SUBSTR(out_response_body,4000,1);
                     END IF;
                 END IF;
             END LOOP;  -- Patient HTML Import Record
         END LOOP;  -- End Job Study

         DBMS_LOB.FREETEMPORARY(out_response_body);
         DBMS_LOB.FREETEMPORARY(l_input_payload);
	
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
/
  SHOW ERRORS

  SPOOL OFF
  EXIT

