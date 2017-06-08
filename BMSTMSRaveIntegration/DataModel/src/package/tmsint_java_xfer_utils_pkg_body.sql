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
--    *** Procedure:    GENERATE_LOG                                         ***
--    ***                                                                    ***
--    *** Input:        pText => User Defined Informational Text String      ***
--    ***                                                                    ***
--    *** Description:  This Procedure May Optionally be Called to Populate  ***
--    ***               the Global CLOB Variable INFO_LOG with User-Defined  ***
--    ***               Execution Details that may Aid is Troubleshooting    ***
--    ***               Errors in the ExtractClinicalDataFromURL Procedure   ***
--    ***               OR the ImportClinicalDataFromURL Procedure.          ***
--    ***                                                                    ***
--    ***               The INFO_LOG Variable may then be Passed Back to the ***
--    ***               Calling Batch Processes Respectively,                ***
--    ***               TMSINT_XFER_UTILS.RUN_JOB_EXTRACT or                 ***
--    ***               TMSINT_XFER_UTILS.RUN_JOB_IMPORT which may then      ***
--    ***               Send an Email (in the Event of Failure)              ***
--    ***                                                                    ***
--    **************************************************************************
      PROCEDURE generate_log (pText IN VARCHAR2) 
      IS
      BEGIN
         info_log := info_log || pText || CHR(10);
      EXCEPTION WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20101,'%%% Error in Procedure GENERATE_LOG '||
           SQLERRM);    
      END generate_log;


--    **************************************************************************
--    ***                                                                    ***
--    *** Procedure:    PRINT_LOG                                            ***
--    ***                                                                    ***
--    *** Description:  Display the Content of the INFO_LOG CLOB Variable to ***
--    ***               Screen.  Lines will be Delimited on the <NL>         ***
--    ***               Character Embedded within the Variable.              ***
--    ***               This Procedure is Called from the Extract/Import     ***
--    ***               Processes when the pDebugFlag Input Parameter is "Y" ***
--    ***               which will Only be for Interactive Executions.       ***
--    ***               If the Extract/Import Processing is Running via      ***
--    ***               Batch (DBMS_SCHEDULER), the Calling Process will     ***
--    ***               Send and Email of the INFO_LOG Clob Value in the     ***
--    ***               Event of Error.  This Procedure was Created for      ***
--    ***               Interactive Manually Processing During Development   ***
--    ***               and Testing.                                         ***
--    ***                                                                    ***
--    **************************************************************************
      PROCEDURE print_log 
      IS
         curr_line VARCHAR2(4000) := NULL;
      BEGIN
         FOR i IN 1..LENGTH(info_log) LOOP
             IF (ASCII(SUBSTR(info_log,i,1)) = 10) THEN
                 DBMS_OUTPUT.PUT_LINE(curr_line);
                 curr_line := NULL;
             ELSE
                curr_line := curr_line || SUBSTR(info_log,i,1);
             END IF;
         END LOOP;
         IF (LENGTH(curr_line) > 0) THEN
             DBMS_OUTPUT.PUT_LINE(curr_line);
         END IF;
         
      END print_log;


--    **************************************************************************
--    ***                                                                    ***
--    *** Function:    GET_PROPERTY_VALUE                                    ***
--    ***                                                                    ***
--    *** Input:       pPropertyName                                         ***
--    ***                                                                    ***
--    *** Return:      pPropertyValue (Single Value)                         ***
--    ***                                                                    ***
--    *** Description: This Function will be Called to Obtain the Property   ***
--    ***              Value Corresponding to the Caller Specified Property  ***
--    ***              Name.  All Java Related Properties will have ONLY     ***
--    ***              a Single Value!!!                                     ***
--    ***                                                                    ***
--    **************************************************************************
      FUNCTION get_property_value (pPropertyName IN VARCHAR2)
      RETURN VARCHAR2
      IS
         out_property_value VARCHAR2(100)  := NULL;
         errm               VARCHAR2(4000) := NULL;
      BEGIN
         SELECT property_value INTO out_property_value
         FROM TABLE(tmsint_adm_utils.query_java_property())
         WHERE property_name = UPPER(TRIM(pPropertyName));
         RETURN out_property_value;
 
--    *************************
--    *** Exception Handler ***
--    *************************
      EXCEPTION WHEN OTHERS THEN
        errm := '%%% Unhandled Error Retrieving Property Value for "'||
           UPPER(TRIM(pPropertyName))||'" from the Properties Table '||
           SQLERRM;
        RAISE_APPLICATION_ERROR(-20101,errm);

      END get_property_value;


--    **************************************************************************
--    ***                                                                    ***
--    *** Function:     FORMAT_PROC_STATUS                                   ***
--    ***                                                                    ***
--    *** Input:        pStatusCode (E=Error, S=Success)                     ***
--    ***               pRecType    (CODE or ERROR)                          ***
--    ***               pResponse    Response from Client System             ***
--    ***                                                                    ***
--    *** Description:  This Function will Be Called by the Function         ***
--    ***               ImportClientDatafromURL Once for Each Patient Record ***
--    ***               Updated in the Client System.  This Function will    ***
--    ***               Accept the OutputResponseBody (pResponse) Returned   ***
--    ***               by the Source System and Break the Text into         ***
--    ***               Either a "Code" Value or an "Error Message" Value.   ***
--    ***               The Return Value will Written to PROCESS_ERROR_CODE  ***
--    ***               when pRecType is "CODE" and to PROCESS_ERROR_MSG     ***
--    ***               when pRecType is "ERROR" within the IMPORT Table     ***
--    ***               TMSINT_XFER_XML_IMPORT.                              ***
--    ***               The PROCESS_ERROR_CODE Should Contain the Text Value ***
--    ***               "ERROR" or "SUCCESS" Followed by Additional Info     ***
--    ***               Provided by the Source System Regardless of Success  ***
--    ***               or Failure.  The PROCESS_ERROR_MSG is Reserved for   ***
--    ***               Errors ONLY and will be NULL when the Transaction    ***
--    ***               was Successful. The Response Text (pResponse) will   ***
--    ***               be Formatted and "Split" into the CODE and ERROR     ***
--    ***               Values and Returned to the Caller.                   ***
--    ***                                                                    ***
--    **************************************************************************
      FUNCTION format_proc_status (pStatusCode IN VARCHAR2,
                                   pRecType    IN VARCHAR2,
                                   pResponse   IN CLOB)
      RETURN VARCHAR2
      IS
         rtn_value VARCHAR2(4000) := NULL;
         tmp_value VARCHAR2(4000) := NULL;
         errm      VARCHAR2(4000) := NULL;
      BEGIN
         IF (pStatusCode NOT IN ('S','E')) THEN
             errm := '%%% Invalid pStatusCode - Values Must be "S" or "E"';
             RAISE_APPLICATION_ERROR(-20101,errm);
         END IF;

         IF (pRecType NOT IN ('CODE','ERROR')) THEN
             errm := '%%% Invalid pRecType - Values Must be "CODE" '||
               'or "ERROR"';
             RAISE_APPLICATION_ERROR(-20101,errm);
         END IF;

         tmp_value := TRIM(REPLACE(TRIM(REPLACE(RTRIM(LTRIM(pResponse,
                        '<Repsonse '),'</Repsonse>'),'  ','')),
                        CHR(9),' '));

         IF (pStatusCode = 'S') THEN
             IF (pRecType = 'CODE') THEN
                 rtn_value := 'SUCCESS'||CHR(10)||tmp_value;
                 RETURN SUBSTR(rtn_value,1,1000);
             ELSIF (pRecType = 'ERROR') THEN
                 rtn_value := NULL;
             END IF;

         ELSIF (pStatusCode = 'E') THEN
             IF (pRecType = 'CODE') THEN
                 rtn_value := 'ERROR'||CHR(10)||SUBSTR(tmp_value,1,
                               INSTR(tmp_value,'ErrorClientResponseMessage')-1);
                 RETURN SUBSTR(rtn_value,1,1000);
             ELSIF (pRecType = 'ERROR') THEN
                 rtn_value :=  SUBSTR(tmp_value,
                               INSTR(tmp_value,'ErrorClientResponseMessage'));
                 RETURN SUBSTR(rtn_value,1,4000);
             END IF;
         END IF;
         
      EXCEPTION WHEN OTHERS THEN
         errm := '%%% Unhandled Error in Function FORMAT_PROC_STATUS '||SQLERRM;
         generate_log(pText => errm);
         RAISE_APPLICATION_ERROR(-20101,errm);

      END format_proc_status;


--    **************************************************************************
--    ***                                                                    ***
--    *** Procedure:   WEBSVC_SETUP                                          ***
--    ***                                                                    ***
--    *** Description: This Procedure will Perform the Following:            ***
--    ***                                                                    ***
--    ***              1.) Obtain the Application Property Values for the    ***
--    ***                  Following Properties:                             ***
--    ***                  1.1.) WEBSVC_WALLET_PATH                          ***
--    ***                  1.2.) WEBSVC_WALLET_PASSWORD                      *** 
--    ***                  1.3.) WEBSVC_PROXY_SERVER                         ***
--    ***                  1.4.) WEBSVC_PROXY_TIMEOUT                        ***
--    ***              2.) Set the Oracle Wallet Used for all HTTP Requests  ***
--    ***                  Over SSL (HTTPS)                                  ***
--    ***              3.) Set the Proxy when the Property Value for         ***
--    ***                  WEBSVC_PROXY_SERVER is Not "NOPROXY"              ***
--    ***              4.) Set Webservice Timeout Based on the Property      ***
--    ***                  Value for WEBSVC_PROXY_TIMEOUT                    ***
--    ***                                                                    ***
--    **************************************************************************
      PROCEDURE websvc_setup 
      IS
         errm VARCHAR2(4000) := NULL;
      BEGIN
--       ***********************************************
--       *** Initialize Global Web Service Variables ***
--       ***********************************************
         wallet_path   := NULL;
         wallet_psw    := NULL;
         proxy_server  := NULL;
         proxy_timeout := NULL;

--       *******************************************************
--       *** Select the Required Web Service Property Values ***
--       *******************************************************
         FOR rec IN (SELECT property_name, property_value 
                     FROM TABLE(tmsint_adm_utils.query_java_property())
                     WHERE property_name IN 
                       ('WEBSVC_WALLET_PATH',
                        'WEBSVC_WALLET_PASSWORD',
                        'WEBSVC_PROXY_SERVER',
                        'WEBSVC_PROXY_TIMEOUT'))
         LOOP
            IF (rec.property_name = 'WEBSVC_WALLET_PATH') THEN
                wallet_path := rec.property_value;
            ELSIF (rec.property_name = 'WEBSVC_WALLET_PASSWORD') THEN
                wallet_psw := rec.property_value;
            ELSIF (rec.property_name = 'WEBSVC_PROXY_SERVER') THEN
                proxy_server := rec.property_value; 
            ELSIF (rec.property_name = 'WEBSVC_PROXY_TIMEOUT') THEN
                proxy_timeout := rec.property_value;
            END IF;
         END LOOP;

--       ******************************************************************
--       *** Verify All Required Web Serivce Properties Contain a Value ***
--       ******************************************************************
         IF (wallet_path IS NULL) THEN
            errm := '%%% Error Retrieving the WEBSVC_WALLET_PATH '||
                 'Property. Ensure the Property had been Created with '||
                 'the Appropriate Value';
            RAISE_APPLICATION_ERROR(-20101,errm);
         ELSIF (wallet_psw IS NULL) THEN
            errm := '%%% Error Retrieving the WEBSVC_WALLET_PASSWORD '||
                 'Property. Ensure the Property had been Created with '||
                 'the Appropriate Value';
            RAISE_APPLICATION_ERROR(-20101,errm);
         ELSIF (proxy_server IS NULL) THEN
            errm := '%%% Error Retrieving the WEBSVC_PROXY_SERVER '||
                 'Property. Ensure the Property had been Created with '||
                 'the Appropriate Value';
            RAISE_APPLICATION_ERROR(-20101,errm);
         ELSIF (proxy_timeout IS NULL) THEN
            errm := '%%% Error Retrieving the WEBSVC_PROXY_TIMEOUT '||
                 'Property. Ensure the Property had been Created with '||
                 'the Appropriate Value';
            RAISE_APPLICATION_ERROR(-20101,errm);
         END IF;

--       *************************************************************************
--       *** Set the Oracle Wallet Used for all HTTP Requests Over SSL (HTTPS) ***
--       *************************************************************************
         BEGIN
            UTL_HTTP.SET_WALLET(wallet_path, wallet_psw);
         EXCEPTION WHEN OTHERS THEN
            errm := '%%% Error Setting Oracle Wallet '||wallet_path||' '||
               SQLERRM;
            RAISE_APPLICATION_ERROR(-20101,errm);
         END;

--       ***************************************
--       *** Set the Proxy (When Applicable) ***
--       ***************************************
         IF (UPPER(TRIM(proxy_server)) <> 'NOPROXY') THEN
             BEGIN
                UTL_HTTP.SET_PROXY(proxy => proxy_server);
             EXCEPTION WHEN OTHERS THEN
                 errm := '%%% Error Setting Proxy. Proxy Server: '|| 
                   proxy_server||' '||SQLERRM;
                 RAISE_APPLICATION_ERROR(-20101,errm);
             END;
         END IF;

--       ******************************
--       *** Set Webservice Timeout ***
--       ******************************
         BEGIN
            UTL_HTTP.SET_TRANSFER_TIMEOUT(proxy_timeout);
         EXCEPTION WHEN OTHERS THEN
            errm := '%%% Error Setting Transfer Timeout ('||
               proxy_timeout||') '||SQLERRM;
            RAISE_APPLICATION_ERROR(-20101,errm);
         END;

--    *************************
--    *** Exception Handler ***
--    *************************
      EXCEPTION WHEN OTHERS THEN
        errm := '%%% Unhandled Error in Procedure WEBSVC_SETUP: '||SQLERRM;
        RAISE_APPLICATION_ERROR(-20101,errm);

      END websvc_setup;


--    **************************************************************************
--    ***                                                                    ***
--    *** Procedure:   INVOKE_REST_SERVICE                                   ***
--    ***                                                                    ***
--    *** Inputs:      pURL                                                  ***
--    ***              pURLUserName                                          ***
--    ***              pURLPassword                                          ***
--    ***              pHTTPMethod    {GET,POST}                             ***
--    ***              pInputPayLoad  {NULL for GET Operations}              ***
--    ***                                                                    ***
--    *** Outputs:     pOutResponse                                          ***
--    ***              pOutStatusCode {S=Success, E=Error}                   ***
--    ***              pOutErrorMsg   {NULL=Success, Non-NULL=Error}         ***
--    ***                                                                    ***
--    *** Description: This Procedure is Called from the the Procedure       ***
--    ***              ExtractClinicalDataFromURL and the Procedure          ***
--    ***              ImportClinicalDataFromURL for the Purpose of Creating ***
--    ***              a Web-Service According to the Representational State ***
--    ***              Transfer (REES) Architectural Pattern.                ***
--    ***              This API will Connect to the Specified URL Based on   ***
--    ***              the Provided Input Credentials and will Perform the   ***
--    ***              Requested HTTP Get/Post Operations.  This Procedure   ***
--    ***              will Return a Status Code and Error Message           ***
--    ***              (if applicable) to the Caller to Indicate of the      ***
--    ***              Requested Operation was Successful.                   ***
--    ***                                                                    ***
--    **************************************************************************
      PROCEDURE invoke_rest_service 
          (pURL             IN  VARCHAR2,
           pURLUsername     IN  VARCHAR2,
           pURLPassword     IN  VARCHAR2,
           pHTTPMethod      IN  VARCHAR2,
           pInputPayload    IN  CLOB,
           pOutResponse     OUT CLOB,
           pOutStatusCode   OUT VARCHAR2,
           pOutErrorMsg     OUT VARCHAR2)
      IS
         rest_endpoint    VARCHAR2(1000)  := NULL;
         req_length       BINARY_INTEGER  := NULL;
         buffer           VARCHAR2(2000)  := NULL;
         amount           PLS_INTEGER     := 2000;
         offset           PLS_INTEGER     := 1;
         text             VARCHAR2(32767) := NULL;
         http_request     UTL_HTTP.REQ;
         http_response    UTL_HTTP.RESP;
     BEGIN      
--       ***********************************
--       *** Verify the pURL is Not Null ***
--       ***********************************
         IF (pURL IS NULL) THEN
             pOutStatusCode := 'E';
             pOutErrorMsg := '%%% The URL Parameter Provided is NULL';
             generate_log(pText => pOutErrorMsg);
             RETURN;
         END IF;

--       ***************************************
--       *** Verify the pHTTPMethod is Valid ***
--       ***************************************
         IF (NVL(pHTTPMethod,'x') NOT IN ('GET','POST')) THEN
             pOutStatusCode := 'E';
             pOutErrorMsg := '%%% Invalid pHTTPMethod Parameter - '||
                'Value Must be "GET" or "POST"';
             generate_log(pText => pOutErrorMsg);
             RETURN;
         END IF;

--       ******************************************************************
--       *** Verify the pInputPayload is Not Null for "POST" Operations ***
--       ******************************************************************
         IF (pHTTPMethod = 'POST') THEN
             IF (TRIM(pInputPayload) IS NULL) THEN 
                 pOutStatusCode := 'E';
                 pOutErrorMsg := '%%% The pInputPayLoad Parameter may '||
                    'Not be Null When the pHTTPMethod is "POST"';
                 generate_log(pText => pOutErrorMsg);
                 RETURN;
             END IF;
         END IF;

--       ****************************************
--       *** Verify the pUserName is Not Null ***
--       ****************************************
         IF (pURLUsername IS NULL) THEN
             pOutStatusCode := 'E';
             pOutErrorMsg := '%%% The pUserName Parameter Provided is NULL';
             generate_log(pText => pOutErrorMsg);
             RETURN;
         END IF;

--       ****************************************
--       *** Verify the pPassword is Not Null ***
--       ****************************************
         IF (pURLPassword IS NULL) THEN
             pOutStatusCode := 'E';
             pOutErrorMsg := '%%% The pPassword Parameter Provided is NULL';
             generate_log(pText => pOutErrorMsg);
             RETURN;
         END IF;

--       **********************************************************************
--       *** Return the URL with Illegal Characters and Reserved Characters ***
--       *** Escaped Using the %2-digit-hex-code Format                     *** 
--       **********************************************************************
         BEGIN
            rest_endpoint := UTL_URL.ESCAPE(url => pURL);
         EXCEPTION WHEN OTHERS THEN
            pOutStatusCode := 'E';
            pOutErrorMsg := '%%% Error Removing Escape Characters from URL '||
               SQLERRM;
            generate_log(pText => pOutErrorMsg);
            RETURN;
         END;

--       *********************************************************************
--       *** Establish the Network Connection to the Target Web Server or  ***
--       *** the Proxy Server and Sends the HTTP Request Line              ***
--       *********************************************************************
         BEGIN
            http_request := UTL_HTTP.BEGIN_REQUEST 
              (url          => rest_endpoint,
               method       => pHTTPMethod,
               http_version => 'HTTP/1.1');
         EXCEPTION WHEN OTHERS THEN
            pOutStatusCode := 'E';
            pOutErrorMsg := '%%% Error Establishing Network Connection '||
               'to Target WebServer/Proxy '||SQLERRM;
            generate_log(pText => pOutErrorMsg);
            RETURN;
         END;

--       ***********************
--       *** Set Credentials ***
--       ***********************
         BEGIN
            UTL_HTTP.SET_AUTHENTICATION(http_request, pURLUsername, pURLPassword);
         EXCEPTION WHEN OTHERS THEN
            pOutStatusCode := 'E';
            pOutErrorMsg := '%%% Error Setting URL WebServer/Proxy '||
               'Authentication '||SQLERRM;
            generate_log(pText => pOutErrorMsg);
            RETURN;
         END;
         DBMS_LOB.CREATETEMPORARY (pOutResponse, FALSE);

--       ******************************************************************
--       *** Populate HTTP Request Based on pInputPayLoad ("POST" Only) ***
--       ******************************************************************
         IF (pHTTPMethod = 'POST') THEN
             BEGIN
                UTL_HTTP.SET_HEADER 
                  (http_request,
                  'Content-Type',
                  'text/xml; charset=utf-8');
                req_length := DBMS_LOB.GETLENGTH (pInputPayload);
                IF (req_length <= 32767) THEN
                    UTL_HTTP.SET_HEADER (http_request, 'Content-Length', req_length);
                    UTL_HTTP.WRITE_TEXT (http_request, pInputPayload);
                ELSE
                    UTL_HTTP.SET_HEADER (http_request, 'Transfer-Encoding', 'chunked');
                    BEGIN
                       LOOP
                          DBMS_LOB.READ(pInputPayload, amount, offset, buffer);
                          UTL_HTTP.WRITE_TEXT(http_request, buffer);
                          offset := offset + amount;
                       END LOOP;
                    EXCEPTION WHEN NO_DATA_FOUND THEN 
                      NULL;  
                    END;
                END IF;                
             EXCEPTION WHEN OTHERS THEN
                UTL_HTTP.END_REQUEST(http_request);
                pOutStatusCode := 'E';
                pOutErrorMsg := '%%% Error Populating HTTP Request During '||
                  'POST Operation: '||
                   UTL_HTTP.GET_DETAILED_SQLCODE||
                   UTL_HTTP.GET_DETAILED_SQLERRM || SQLERRM; 
                generate_log(pText => pOutErrorMsg);
                RETURN;
             END;
         END IF;

--       *****************************
--       *** Get the HTTP Response ***
--       *****************************
         BEGIN
            http_response := UTL_HTTP.GET_RESPONSE(http_request);
         EXCEPTION WHEN OTHERS THEN
            UTL_HTTP.END_REQUEST(http_request);
            pOutStatusCode := 'E';
            pOutErrorMsg := '%%% Error Getting HTTP Response: '||
               UTL_HTTP.GET_DETAILED_SQLCODE||' '||
               UTL_HTTP.GET_DETAILED_SQLERRM||' '||
               SQLERRM;
            generate_log(pText => pOutErrorMsg);
            RETURN;
         END;

--       **************************
--       *** Read HTTP Response ***
--       **************************
         BEGIN
            LOOP
               UTL_HTTP.READ_TEXT(http_response, text, 32766);
               DBMS_LOB.WRITEAPPEND(pOutResponse, LENGTH(text), text);
            END LOOP;
         EXCEPTION
            WHEN UTL_HTTP.END_OF_BODY THEN
                 UTL_HTTP.END_RESPONSE (http_response);
            WHEN OTHERS THEN                    
                 UTL_HTTP.END_REQUEST(http_request);
                 pOutStatusCode := 'E';
                 pOutErrorMsg := '%%% Error in Read/Write HTTP Response: '||
                    UTL_HTTP.GET_DETAILED_SQLCODE||' '||
                    UTL_HTTP.GET_DETAILED_SQLERRM||' '||
                    SQLERRM;
                 generate_log(pText => pOutErrorMsg);
                 RETURN;
         END;

--       ***************************************
--       *** Check HTTP Response Status Code ***
--       ***************************************
         IF (http_response.status_code = UTL_HTTP.HTTP_OK) THEN               
             pOutStatusCode := 'S';
             pOutErrorMsg := NULL;
        ELSE              
             pOutStatusCode := 'E';
             pOutErrorMsg := http_response.status_code||': '||
                 http_response.reason_phrase;
             IF (UPPER(http_response.reason_phrase) = 'UNAUTHORIZED') THEN
                 generate_log(pText => '%%% Error: '||pOutErrorMsg);
                 generate_log(pText => '%%% Check for Change in URL Credentials');
                 generate_log(pText => '%%% Current Credentials: '||pURLUsername||'/'||pURLPassword);
             ELSIF (http_response.status_code = '404') THEN
                 pOutStatusCode := 'W';  -- Error Override to Warning only
                 pOutErrorMsg := '%%% Specified URL Not Found - 404 Warning in HTTP GET Request';
                 generate_log(pText => '%%% Error: '||pOutErrorMsg);
                 generate_log(pText => '%%% (1) Verify Availability in Source System');
                 generate_log(pText => '%%% (2) Check for Typo in Study Definition Metadata DCM Name/URL');
             ELSE
                 generate_log(pText => '%%% Error HTTP Status Check: Failure');
                 generate_log(pText => pOutErrorMsg);
             END IF;
        END IF;
        UTL_HTTP.END_REQUEST(http_request);
        RETURN;

--   *************************
--   *** Exception Handler ***
--   *************************
     EXCEPTION WHEN OTHERS THEN
        UTL_HTTP.END_REQUEST(http_request);
        pOutStatusCode := 'E';
        pOutErrorMsg := '%%% Unhandled Error in Procedure '||
            'InvokeRestService: '||SQLERRM;
        generate_log(pText => pOutErrorMsg);
        RETURN;

     END invoke_rest_service;


--    **************************************************************************
--    ***                                                                    ***
--    *** Function:    extractClinicalDataFromURL                            ***
--    ***                                                                    ***
--    *** Called By:   TMSINT_XFER_UTILS.RUN_JOB_EXTRACT                     ***
--    ***                                                                    ***
--    *** Inputs:      pJobTab    (TMSINT_JAVA_JOB_OBJT Object Type)         ***
--    ***              pDCMTab    (TMSINT_JAVA_DCM_OBJT Object Type)         ***
--    ***              pDebugFlag (Display to Screen when Interactive)       ***
--    ***                                                                    ***
--    *** Outputs:     pExtTab     (TMSINT_XFER_XML_EXTRACT_OBJT)            ***
--    ***              pInfoLog    (Execution LOG Email Body for Caller )    ***
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
--    ***              If Processing is Successful a NULL Return Status will ***
--    ***              be Returned to the Caller.                            ***
--    ***              If an Error Occurs During Processing the RETURN Value ***
--    ***              will be a Non-Null Error Message.  When this Occurs,  ***
--    ***              the Caller may Optionally Send an EMAIL of the        ***
--    ***              Execution Results with the Error Based on the Return  ***
--    ***              Value of pInfoLOG.  No EMAIL will be Needed for       ***
--    ***              Successful Executions                                 ***
--    ***                                                                    ***
--    **************************************************************************
      FUNCTION extractClinicalDataFromURL 
        (pJobTab         IN     tmsint_java_job_objt,
         pDCMTab         IN OUT tmsint_java_dcm_objt,
         pExtTab         IN OUT tmsint_xfer_xml_extract_objt,
         pInfoLog        OUT    CLOB,
         pDCMWarningFlag OUT    VARCHAR2,
         pDebugFlag      IN     VARCHAR2 DEFAULT 'N')
      RETURN VARCHAR2
      IS
         job_id                INTEGER          := NULL;
         source_url            VARCHAR2(1000)   := NULL;
         buffer                VARCHAR2(4000)   := NULL;
         amount                PLS_INTEGER      := 2000;
         offset                PLS_INTEGER      := 1;
         xml_original          CLOB             := NULL;
         xml_cleaned           CLOB             := NULL;
         xml_temp              CLOB             := NULL;
         xml_line              VARCHAR2(4000)   := NULL;
         xml_final             XMLTYPE;
         xml_header            VARCHAR2(2000)   := NULL;
         xml_comment           VARCHAR2(300)    := NULL;
         rtn_status_code       VARCHAR2(1)      := NULL;
         rtn_error_msg         VARCHAR2(32767)  := NULL;
      BEGIN
--       ***************************************************
--       *** Write to LOG (Process LOG Emailed on Error) ***
--       ***************************************************
         pDCMWarningFlag := 'N';
         info_log := NULL;
         generate_log(pText => CHR(9));
         generate_log(pText => 'Executing Function TMSINT_JAVA_XFER_UTILS.'||
            'ExtractClinicalDataFromURL');
         generate_log(pText => 'Processing Time: '||
            TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS AM'));

--       ***********************************************
--       *** Verify pJobTab and pDCMTab Contain Data ***
--       ***********************************************
         IF (pJobTab.COUNT = 0) OR (pDCMTab.COUNT = 0) THEN
             rtn_error_msg := '%%% Job Information Not Provided by Caller';
             generate_log(pText => rtn_error_msg);
             pInfoLog := info_log;
             IF (pDebugFlag = 'Y') THEN
                 print_log;
             END IF;
             RETURN rtn_error_msg;
         END IF;

--       **********************************************
--       *** Perform Initial Web Service Setup...   ***
--       **********************************************
         BEGIN
             tmsint_java_xfer_utils.websvc_setup;
         EXCEPTION WHEN OTHERS THEN
            rtn_error_msg := SQLERRM; 
            generate_log(pText => rtn_error_msg);
            pInfoLog := info_log;
            IF (pDebugFlag = 'Y') THEN
                print_log;
            END IF;
            RETURN rtn_error_msg;
         END;

--       ***********************************************************************
--       *** For Each STUDY Associated to the Current JobID...               ***
--       *** <pJobTab Contains ONLY a Single JobID but One ore More Studies> ***
--       ***********************************************************************
         FOR i IN pJobTab.FIRST .. pJobTab.LAST LOOP

--           ********************************
--           *** Write Study/JobID to LOG ***
--           ********************************
             generate_log(pText => CHR(9));
             generate_log(pText => '************************************************');
             generate_log(pText => '*** JobID: '||pJobTab(i).job_id);
             generate_log(pText => '*** Study: '||pJobTab(i).study_name);
             generate_log(pText => '************************************************');
             job_id := pJobTab(i).job_id;

--           **************************************************
--           *** For Each DCM (FormOID) within the STUDY... ***
--           **************************************************
             FOR j IN pDCMTab.FIRST .. pDCMTab.LAST LOOP

--               *********************************************************
--               *** If the DCM is a Associated to the "Current" STUDY ***
--               *********************************************************
                 IF (pJobTab(i).study_name = pDCMTab(j).study_name) THEN

--                   ********************************
--                   *** Write DCM/VT Name to LOG ***
--                   ********************************
                     generate_log(pText => 'Extracting Data for '||
                        pDCMTab(j).dcm_name||'.'||pDCMTab(j).vt_name);

--                   ****************************************
--                   *** Construct the URL for Processing ***
--                   ****************************************
                     source_url := pJobTab(i).url||'/'||pDCMTab(j).dcm_name;

--                   ************************************************
--                   *** Append to URL for INCREMENTAL Processing ***
--                   ************************************************
                     IF (pJobTab(i).extract_type = 'INCREMENTAL') THEN
                         BEGIN
                            source_url := source_url ||'?start='||
                                TO_CHAR(pJobTab(i).extract_ts,'YYYY-MM-DD')||'T'||
                                TO_CHAR(pJobTab(i).extract_ts,'HH24:MI:SS');
                         EXCEPTION WHEN OTHERS THEN
                            rtn_error_msg := '%%% Unhandled Error Populating SOURCE_URL '||
                               SQLERRM; 
                            generate_log(pText => rtn_error_msg);
                            pInfoLog := info_log;
                            IF (pDebugFlag = 'Y') THEN
                                print_log;
                            END IF;
                            RETURN rtn_error_msg;
                         END;
                     END IF;

--                   ***************************************
--                   *** Execute Web-Service GET Request ***
--                   ***************************************
                     DBMS_LOB.CREATETEMPORARY (xml_original, TRUE);
                     BEGIN
                         tmsint_java_xfer_utils.invoke_rest_service
                            (pURL           =>  source_url,
                             pURLUsername   =>  pJobTab(i).url_username,
                             pURLPassword   =>  pJobTab(i).url_password,
                             pHTTPMethod    => 'GET' ,
                             pInputPayload  =>  NULL,
                             pOutResponse   =>  xml_original,
                             pOutStatusCode =>  rtn_status_code,
                             pOutErrorMsg   =>  rtn_error_msg); 

--                       ************************************************************
--                       *** If the Specific DCM Returned a 404 Error, then the   ***
--                       *** DCM is Either NOT Accessible in the Source System or ***
--                       *** there is a Typo in the DCM Name within the TMSINT    ***
--                       *** Study Definition Metadata.  In this Case, the DCM    ***
--                       *** will NOT be Processed and will Generate a WARNING    ***
--                       *** instead of a ERROR.                                  ***
--                       ************************************************************
                         IF (rtn_status_code = 'W') THEN
                             pDCMWarningFlag := 'Y'; -- Return Warning indicator to Caller
                             pDCMTab(j).dcm_warning := '%%% '||pDCMTab(j).dcm_name||'.'||
                                pDCMTab(j).vt_name||CHR(10)||'%%% '||rtn_error_msg||CHR(10)||
                               '%%% (1) Verify Availibility in Source System'||CHR(10)||
                               '%%% (2) Check for Typo in Study Definition Metadata DCM Name/URL';
                         END IF;

--                   *************************
--                   *** Exception Handler ***
--                   *************************
                     EXCEPTION WHEN OTHERS THEN
                         rtn_error_msg := '%%% Unahandled Error WebService Procedure '||
                            'for GET Request: '||SQLERRM;
                         generate_log(pText => rtn_error_msg);
                         pInfoLog := info_log;
                         IF (pDebugFlag = 'Y') THEN
                             print_log;
                         END IF;
                         RETURN rtn_error_msg;
                     END;

--                   *******************************************************
--                   *** When INVOKE_REST_SERVICE Completed Successfully ***
--                   *******************************************************
                     IF (rtn_status_code = 'S') THEN  

--                       **************************************************************
--                       *** Remove Garbage Characters from the HTTP Response Value ***
--                       *** Move the "Cleaned" Value from Variable XML_ORIGINAL    ***
--                       *** to the Variable XML_CLEANED                            ***
--                       **************************************************************
                         offset  := 1;
                         buffer  := NULL;
                         amount  := 2000;
                         xml_cleaned := NULL;
                         DBMS_LOB.CREATETEMPORARY (xml_cleaned, TRUE);
                         BEGIN
                            LOOP
                               DBMS_LOB.READ (xml_original, amount, offset, buffer);
                               IF (offset=1) THEN    
                                   DBMS_LOB.WRITEAPPEND 
                                     (xml_cleaned, 
                                      LENGTH(SUBSTR(buffer,INSTR(buffer,'<'))),
                                      SUBSTR(buffer,INSTR(buffer,'<')));
                               ELSE
                                   DBMS_LOB.WRITEAPPEND(xml_cleaned, amount, buffer);
                               END IF;
                               offset := offset + amount;
                            END LOOP;
                         EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                              NULL;
                            WHEN OTHERS THEN
                              rtn_error_msg := '%%% Error Removing Junk Characters from '||
                                 'HTTP Response: '||SQLERRM;
                              generate_log(pText => rtn_error_msg);
                              pInfoLog := info_log;
                              IF (pDebugFlag = 'Y') THEN
                                  print_log;
                              END IF;
                              RETURN rtn_error_msg; 
                         END;                 

--                       **************************************************************
--                       *** Remove <?xml version="1.0" encoding="utf-8"?> From XML ***
--                       ************************************************************** 
                         IF (INSTR(xml_cleaned,'<?xml version="1.0" encoding="utf-8"?>',1,1) > 0)
                         THEN
                             xml_cleaned := SUBSTR(xml_cleaned,39);
                         END IF;

--                       *****************************************************************
--                       *** Extract XML_HEADER for Posting File Updated During IMPORT ***
--                       *** Replace the XML_HEADER with <ODM> in the XML Response     ***
--                       *****************************************************************
                         xml_header := SUBSTR(xml_cleaned,1,INSTR(xml_cleaned,'>',1,1));
                         xml_cleaned := REPLACE(xml_cleaned,xml_header,'<ODM>');
                         IF (xml_cleaned = '<ODM>') THEN
                             xml_cleaned := NULL;
                             xml_comment := '%%% No Data Extracted for '||pDCMTab(j).dcm_name;
                         ELSE
                             xml_comment := NULL;
                         END IF;

--                       **************************************************************
--                       *** Convert the CLOB (xml_cleaned) to XMLTYPE (xml_final)  ***
--                       **************************************************************
                         BEGIN
                             xml_final := NULL;
                             IF (xml_cleaned IS NOT NULL) THEN
                                xml_final := XMLTYPE.CREATEXML(xml_cleaned);
                             END IF;
                         EXCEPTION WHEN OTHERS THEN
                             rtn_error_msg := '%%% Unhandled Error Converting Response Value to XML '||
                               CHR(10)||SQLERRM;
                             generate_log(pText => rtn_error_msg);
                             pInfoLog := info_log;
                             IF (pDebugFlag = 'Y') THEN
                                 print_log;
                             END IF;
                             RETURN rtn_error_msg;
                         END;

--                       ****************************************************************
--                       *** Populate the TMSINT_XFER_XML_EXTRACT Return Object Array ***
--                       ****************************************************************
                         BEGIN
                           pExtTab.EXTEND;
                           pExtTab(pExtTab.LAST) := tmsint_xfer_xml_extract_objr
                              (pJobTab(i).job_id,           -- JOB_ID
                               0,                           -- SEQNO,
                               pJobTab(i).datafile_id,      -- DATAFILE_ID
                               pJobTab(i).study_name,       -- STUDY_NAME
                               pDCMTab(j).dcm_name,         -- DCM_NAME
                               xml_final,                   -- XML_DATA
                               xml_header,                  -- XML_HEADER
                               xml_comment,                 -- XML_COMMENT
                               SYSDATE,                     -- ENTRY_TS
                              'N',                          -- PROCESS_FLAG
                               NULL);                       -- PROCESS_TS
                         EXCEPTION WHEN OTHERS THEN
                             rtn_error_msg := '%%% Unhandled Errpr Creating Extract '||
                                'Object Array Entry '||CHR(10)||SQLERRM;
                             generate_log(pText => rtn_error_msg);
                             pInfoLog := info_log;
                             IF (pDebugFlag = 'Y') THEN
                                 print_log;
                             END IF;
                             RETURN rtn_error_msg;
                         END;
                                      
--                   *****************************************************************
--                   *** When Procedure INVOKE_REST_SERVICE Completes with Error   ***
--                   *****************************************************************
                     ELSIF (rtn_status_code = 'E') THEN
                          generate_log(pText => 'Failed Execution of Java "RESTful Web Service"');
                          pInfoLog := info_log;
                          IF (pDebugFlag = 'Y') THEN
                              print_log;
                          END IF;
                          RETURN rtn_error_msg;   -- Abort and Return to Caller
                      END IF;

--                   *****************************************************************
--                   *** When Procedure INVOKE_REST_SERVICE Completes with a 404   ***
--                   *****************************************************************
                     ELSIF (rtn_status_code = 'W') THEN
                         CONTINUE;
                 END IF; -- Study DCM
             END LOOP;  -- End DCM
         END LOOP;  -- End Job Study

--       ************************************
--       *** Return Extracted Data Caller ***
--       ************************************
         BEGIN
            DBMS_LOB.FREETEMPORARY(xml_original);
            DBMS_LOB.FREETEMPORARY(xml_cleaned);
         EXCEPTION WHEN OTHERS THEN
            NULL;
         END;
         generate_log(pText => CHR(9));
         generate_log(pText => 'Extract Processing Successfully '||
             'Completed for JobID '||job_id);
         pInfoLog := info_log;
         IF (pDebugFlag = 'Y') THEN
             print_log;
         END IF;
         RETURN NULL;  -- No Errors Occurred

--    *************************
--    *** Exception Handler ***
--    *************************
      EXCEPTION WHEN OTHERS THEN
         rtn_error_msg := '%%% Unhandled Error in Function '||
             'ExtractClinicalDataFromURL '||SQLERRM;
         generate_log(pText => rtn_error_msg);
         pInfoLog := info_log;
         IF (pDebugFlag = 'Y') THEN
             print_log;
         END IF;
         RETURN rtn_error_msg;

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
--    *** Outputs:     pImpTab (TMSINT_XFER_XML_IMPORT_OBJT)                 ***
--    ***                                                                    ***
--    *** Return:      NULL Return = Success; Otherwise Error Message        ***
--    ***                                                                    ***
--    *** Description: This Function is Called from the the Procedure        ***
--    ***              TMSINT_XFER_UTILS.RUN_JOB_EXTRACT.  The Function will ***
--    ***              be Provided Specific Information about a Given        ***
--    ***              Job in the Job Queue for the Purpose of Importing     ***
--    ***              Changes in Patient Data within the Client Source      ***
--    ***              System Applicable to the Job.  The Return Data will   ***
--    ***              be Used to UPDATE the Processing Related Columns of   ***
--    ***              the IMPORT Table.                                     ***
--    ***              If Processing is Successful a NULL Return Status will ***
--    ***              be Returned to the Caller.                            ***
--    ***              If One or More Patient Record Update Errors Occurs    ***
--    ***              During Processing the RETURN Value will be a Non-Null ***
--    ***              Error Message.  When this Occurs, the Caller may      ***
--    ***              Optionally Send an EMAIL of the Execution Results     ***
--    ***              with the Error Based on the Return Value of pInfoLOG. ***
--    ***              No EMAIL will be Needed for Successful Executions     ***
--    ***                                                                    ***
--    **************************************************************************
      FUNCTION importClinicalDataFromURL 
         (pJobTab    IN     tmsint_java_job_objt,
          pImpTab    IN OUT tmsint_xfer_xml_import_objt,
          pInfoLog   OUT    CLOB,
          pDebugFlag IN     VARCHAR2 DEFAULT 'N')
      RETURN VARCHAR2
      IS
         job_id               INTEGER          := NULL;
         rtn_status_code      VARCHAR2(1)      := NULL;
         rtn_error_msg        VARCHAR2(32767)  := NULL;
         function_status_rtn  VARCHAR2(4000)   := NULL;
         rtn_response_body    CLOB             := NULL;
         input_payload        CLOB             := NULL;
         payload_length       BINARY_INTEGER   := NULL;
         total_nrec           INTEGER          := 0;
         coding_nrec          INTEGER          := 0;
         omission_nrec        INTEGER          := 0;
         error_nrec           INTEGER          := 0;
         proc_nrec            INTEGER          := 0;
         patient_error        BOOLEAN          := FALSE;
         patient_data_found   BOOLEAN          := FALSE;

      BEGIN
--       ********************
--       *** Write to LOG ***
--       ********************
         info_log := NULL;
         generate_log(pText => CHR(9));
         generate_log(pText => 'Executing Function TMSINT_JAVA_XFER_UTILS.'||
            'ImportClinicalDataFromURL');
         generate_log(pText => 'Processing Time: '||
            TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS AM'));

--       ************************************
--       *** Verify pJobTab Contains Data ***
--       ************************************
         IF (pJobTab.COUNT = 0) THEN
             rtn_error_msg := '%%% Job Information Not Provided by Caller';
             generate_log(pText => rtn_error_msg);
             pInfoLog := info_log;
             IF (pDebugFlag = 'Y') THEN
                 print_log;
             END IF;
             RETURN rtn_error_msg;  -- Abort with Hard-Error
         END IF;
         
--       *****************************************************
--       *** Perform Initial Web Service Setup (Once)...   ***
--       *****************************************************
         BEGIN
             tmsint_java_xfer_utils.websvc_setup;
         EXCEPTION WHEN OTHERS THEN
            rtn_error_msg := SQLERRM; 
            generate_log(pText => rtn_error_msg);
            pInfoLog := info_log;
            IF (pDebugFlag = 'Y') THEN
                print_log;
            END IF;
            RETURN rtn_error_msg;
         END;

         DBMS_LOB.CREATETEMPORARY(rtn_response_body,FALSE);
         DBMS_LOB.CREATETEMPORARY(input_payload,FALSE);

--       *****************************************************
--       *** For Each Study for the Corresponding JobID... ***
--       *****************************************************
         FOR i IN pJobTab.FIRST .. pJobTab.LAST LOOP
         
--           ********************************
--           *** Write Study/JobID to LOG ***
--           ********************************
             generate_log(pText => CHR(9));
             generate_log(pText => '************************************************');
             generate_log(pText => '*** JobID:  '||pJobTab(i).job_id);
             generate_log(pText => '*** Study:  '||pJobTab(i).study_name);
             generate_log(pText => '************************************************');
             job_id := pJobTab(i).job_id;
             patient_data_found := FALSE;

--           *******************************************************
--           *** For Each Patient Record for the Current Study.. ***
--           *******************************************************
             FOR j IN pImpTab.FIRST .. pImpTab.LAST LOOP

                 IF (pJobTab(i).study_name = pImpTab(j).study) THEN
                     patient_data_found := TRUE;

--                   ***************************************************
--                   *** Write Patient and Import Record Type to LOG ***
--                   ***************************************************
                     generate_log(pText => 'Patient: '||pImpTab(j).patient||' => '||
                         pImpTab(j).file_type||' Record '||
                        '(Seqno#:'||pImpTab(j).seqno||')');
                     total_nrec := total_nrec + 1;
                     IF (pImpTab(j).file_type = 'CODING') THEN
                         coding_nrec := coding_nrec + 1;
                     ELSE
                         omission_nrec := omission_nrec + 1;
                     END IF;

--                   *************************************************************
--                   *** Populate PayLoad Variable with Import Record XML Text ***
--                   *************************************************************
                     BEGIN
                        payload_length := DBMS_LOB.GETLENGTH(input_payload);
                        IF (payload_length > 0) THEN
                            DBMS_LOB.ERASE(input_payload,payload_length,1);
                        END IF;                      
                        DBMS_LOB.WRITE(input_payload, LENGTH(pImpTab(j).html_text),
                             1, pImpTab(j).html_text);
                     EXCEPTION WHEN OTHERS THEN
                        rtn_error_msg := '%%% Error Copying HTML Text to Payload for '||
                           'Processing (Hard-Error) '||SQLERRM;
                        generate_log(pText => rtn_error_msg);   
                        pInfoLog := info_log;
                        IF (pDebugFlag = 'Y') THEN
                            print_log;
                        END IF;
                        RETURN rtn_error_msg;  -- Abort with Hard-Error
                     END;

--                   *********************************************************************
--                   *** Call Web-Service Procedure to Update Patient in Client Source ***
--                   *** System Based on HTML Text (i.e. Payload)                      ***
--                   *********************************************************************
                     BEGIN
                        tmsint_java_xfer_utils.invoke_rest_service
                          (pURL           =>  pJobTab(i).url,
                           pURLUsername   =>  pJobTab(i).url_username,
                           pURLPassword   =>  pJobTab(i).url_password,
                           pHTTPMethod    => 'POST' ,
                           pInputPayload  =>  input_payload,
                           pOutResponse   =>  rtn_response_body,
                           pOutStatusCode =>  rtn_status_code,
                           pOutErrorMsg   =>  rtn_error_msg); 
                     EXCEPTION WHEN OTHERS THEN
                        rtn_error_msg := '%%% Unahandled Error Java "RESTful Web '||
                          'Service" Procedure: '||SQLERRM;
                        generate_log(pText => rtn_error_msg);
                        pInfoLog := info_log;
                        IF (pDebugFlag = 'Y') THEN
                            print_log;
                        END IF;
                        RETURN rtn_error_msg;  -- Abort with Hard-Error
                     END;

--                   *******************************************************
--                   *** When INVOKE_REST_SERVICE Completed Successfully ***
--                   *** for Patient Record                              ***
--                   *******************************************************
                     IF (rtn_status_code = 'S') THEN 
                         proc_nrec                      := proc_nrec + 1;
                         pImpTab(j).process_flag        := 'Y';
                         pImpTab(j).process_ts          :=  SYSDATE;
                         pImpTab(j).process_status_code := 'SUCCESS';
                           --tmsint_java_xfer_utils.format_proc_status 
                           --  (pStatusCode => 'S',
                           --   pRecType    => 'CODE',
                           --   pResponse   =>  rtn_response_body);
                         pImpTab(j).process_error_msg   :=  NULL;
                         generate_log(pText => '%%% Patient Successfully Updated');

--                   *******************************************************
--                   *** When INVOKE_REST_SERVICE Completed with Error   ***
--                   *** for Patient Record                              ***
--                   *******************************************************
                     ELSIF (rtn_status_code = 'E') THEN 
                         error_nrec                     := error_nrec + 1;
                         pImpTab(j).process_flag        := 'E';
                         pImpTab(j).process_ts          :=  SYSDATE;
                         pImpTab(j).process_status_code := 'ERROR';
                           --tmsint_java_xfer_utils.format_proc_status 
                           --  (pStatusCode => 'E',
                           --   pRecType    => 'CODE',
                           --   pResponse   =>  rtn_response_body);
                         pImpTab(j).process_error_msg :=
                           tmsint_java_xfer_utils.format_proc_status 
                             (pStatusCode => 'E',
                              pRecType    => 'ERROR',
                              pResponse   =>  rtn_response_body);
                         function_status_rtn := SUBSTR(pImpTab(j).process_error_msg,1,1000);
                         generate_log(pText => '%%% '||pImpTab(j).process_error_msg);
                     END IF;
                 END IF;
                 --IF NOT(patient_data_found) THEN
                 --    generate_log(pText => '%%% No Patient to be Imported'); 
                 --END IF;
             END LOOP;  -- Patient HTML Import Record
         END LOOP;  -- End Job Study

--       ***************************************
--       *** Display Processing Stats to LOG ***
--       ***************************************
         generate_log(pText =>  CHR(9));
         generate_log(pText => 'Patient Total Records:             '||total_nrec);
         generate_log(pText => 'Patient Coding Records:            '||coding_nrec);
         generate_log(pText => 'Patient Omission Records:          '||omission_nrec);
         generate_log(pText => 'Patients w/ Successful Processing: '||proc_nrec);
         generate_log(pText => 'Patients w/ Failed Processing:     '||error_nrec);

         DBMS_LOB.FREETEMPORARY(rtn_response_body);
         DBMS_LOB.FREETEMPORARY(input_payload);
	
--       *************************************************************************
--       *** Return Execution Status to Caller.  If No Import Errors Occurred, ***
--       *** the FUNCTION_STATUS_RTN will be NULL (Success). If One or More    ***
--       *** Errors were Encountered, the FUNCTION_STATUS_RTN Variable will    ***
--       *** Contain the Error Message of the Last Error Encountered which     ***
--       *** will be Logged for the Job in the Job Queue as the Reason for     ***
--       *** Failure.                                                          ***
--       *************************************************************************
         generate_log(pText => CHR(9));
         IF (function_status_rtn IS NULL) THEN
             generate_log(pText => 'Import Processing Successfully '||
                'Completed (ImportErrors=0) for JobID '||job_id);
         ELSE
             generate_log(pText => 'Import Processing Successfully '||
                'Completed (ImportErrors='||error_nrec||') for JobID '||job_id);
         END IF;
         pInfoLog := info_log;
         IF (pDebugFlag = 'Y') THEN
             print_log;
         END IF;
         RETURN function_status_rtn;


--    *************************
--    *** Exception Handler ***
--    *************************
      EXCEPTION WHEN OTHERS THEN
         rtn_error_msg := '%%% Unhandled Error in Function '||
             'ImportClinicalDataFromURL '||SQLERRM;
         generate_log(pText => rtn_error_msg);
         pInfoLog := info_log;
         IF (pDebugFlag = 'Y') THEN
             print_log;
         END IF;
         RETURN rtn_error_msg;

      END importClinicalDataFromURL;


   END tmsint_java_xfer_utils;
/
  SHOW ERRORS

  SPOOL OFF
  EXIT

