-- *****************************************************************************
-- ***                                                                       ***
-- *** File Name:     tmsint_java_email_utils_pkg_body.sql                   ***
-- ***                                                                       ***
-- *** Date Written:  15 November 2016                                       ***
-- ***                                                                       ***
-- *** Written By:    Harish Pothuri / DBMS Consulting Inc.                  ***
-- ***                                                                       ***
-- *** Package Name:  TMSINT_JAVA_EMAIL_UTILS (Package Body)                 ***
-- ***                                                                       ***
-- *** Package Owner: TMS Integration JAVA Admin Owner (TMSINT_JAVA)         ***
-- ***                                                                       ***
-- *** Description:   This SQL Script will Create the Database Package       ***
-- ***                TMSINT_JAVA_EMAIL_UTILS Containing the Application     ***
-- ***                Email Utilities. The Application Owner Account and     ***
-- ***                all XFER and PROC Accounts will be Granted EXECUTE     ***
-- ***                Permission this Package.                               ***
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
   SPOOL ../log/tmsint_java_email_utils_pkg_body_&curr_date..log

   SELECT 'Process:  '||'tmsint_java_email_utils_pkg_body.sql'   ||CHR(10)||
          'Package:  '||'TMSINT_JAVA_EMAIL_UTILS Body'           ||CHR(10)||
          'User:     '||USER                                    ||CHR(10)||
          'Date:     '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI AM') ||CHR(10)||
          'Instance: '||global_name
   FROM global_name;
   SET FEEDBACK ON

   PROMPT 
   PROMPT *********************************************************************
   PROMPT ***      Creating TMSINT_JAVA_EMAIL_UTILS Package Body            ***
   PROMPT *********************************************************************

-- ****************************************************************************
-- ***               TMSINT_JAVA_EMAIL_UTILS Package Body                   ***
-- ****************************************************************************
   CREATE OR REPLACE PACKAGE BODY tmsint_java_email_utils 
   AS

--    **************************************************************************
--    ***                                                                    ***
--    *** Procedure:    PROCESS_RECIPIENTS                                   ***
--    ***                                                                    ***
--    *** Inputs:       p_mail_conn                                          ***
--    ***               p_list                                               ***
--    ***                                                                    ***
--    *** Description:  The Procedure will be Used to to Add Multiple        ***
--    ***               Emai Rrecipients to  the Mail Connection.            ***
--    **************************************************************************      
      PROCEDURE process_recipients(p_mail_conn IN OUT UTL_SMTP.CONNECTION,
                                   p_list      IN VARCHAR2)
     IS
         recipients DBMS_UTILITY.UNCL_ARRAY;
         list_size  INTEGER;
     BEGIN
--      **************************************************
--      *** Verify an Email Recipient was Provided...  ***
--      **************************************************
        IF (TRIM(p_list) IS NOT NULL) THEN

--          ****************************************
--          *** Process a Single Email Recipient ***
--          ****************************************
            IF (INSTR(p_list,',') = 0) THEN
                UTL_SMTP.RCPT(p_mail_conn, p_list);

--          *****************************************
--          *** Process Multiple Email Recipients ***
--          *****************************************
            ELSE
                DBMS_UTILITY.COMMA_TO_TABLE (p_list, list_size, recipients);
                FOR i IN 1 .. list_size LOOP
                   UTL_SMTP.RCPT(p_mail_conn, recipients(i));
                END LOOP;
            END IF;
        END IF;

     EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20101,'%%% Unhandled Error in '||
           'TMSINT_JAVA_EMAIL_UTILS.PROCESS_RECIPIENTS for: '||
           p_list||' - '||SQLERRM);

     END process_recipients;


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
         FROM tmsint_adm_properties
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
--    *** Procedure:    EMAIL                                                ***
--    ***                                                                    ***
--    *** Inputs:       pEmailToList (Comma Demited List)                    ***
--    ***               pEmailCCList (Comma Delimited List)                  ***
--    ***               pEmailSubject                                        ***
--    ***               pEmailBody                                           ***
--    ***                                                                    ***
--    *** Description:  The Procedure will be Called to Send Email based on  ***
--    ***               the Inputs Specified by the Caller                   ***
--    ***                                                                    ***
--    **************************************************************************
      PROCEDURE email
        (pEmailToList   IN VARCHAR2,
         pEmailCCList   IN VARCHAR2  DEFAULT NULL,
         pEmailSubject  IN VARCHAR2,
         pEmailBody     IN CLOB,
         pDebugFlag     IN VARCHAR2 DEFAULT 'N')
      IS      
          l_wallet_path           VARCHAR2(100)   :=  NULL;
          l_wallet_password       VARCHAR2(100)   := 'orawallet@123';
          l_from_address          VARCHAR2(100)   :=  NULL;
          l_smtp_host             VARCHAR2(100)   :=  NULL;
          l_smtp_port             NUMBER          :=  NULL;
          l_mail_username         VARCHAR2(100)   :=  NULL;
          l_mail_password         VARCHAR2(100)   :=  NULL;
          l_mail_conn             UTL_SMTP.CONNECTION;
          ltab_lname              DBMS_UTILITY.LNAME_ARRAY;
          l_mail_username_encoded VARCHAR2(100)   :=  NULL;
          l_mail_password_encoded VARCHAR2(100)   :=  NULL;
          nls_charset             VARCHAR2(255);
          l_smtp_ehlo_replies     UTL_SMTP.REPLIES;
          l_smtp_command_reply    UTL_SMTP.REPLY;
          l_buffer                VARCHAR2(2000);
          l_amount                PLS_INTEGER     := 2000;
          l_offset                PLS_INTEGER     := 1;
          l_email_body_length     BINARY_INTEGER;
          errm                    VARCHAR2(4000)  := NULL;
      BEGIN
--       *******************************************
--       *** Obtain the Required Property Values ***
--       *** 1.) JAVA_WALLET_PATH                ***
--       *** 2.) JAVA_EMAIL_FROM_ADDRESS         ***
--       *** 3.) JAVA_EMAIL_SMTP_HOST            ***
--       *** 4.) JAVA_EMAIL_SMTP_PORT            ***
--       *** 5.) JAVA_EMAIL_SMTP_USERNAME        ***
--       *******************************************
         l_wallet_path   := tmsint_java_email_utils.get_property_value 
                            (pPropertyName => 'JAVA_WALLET_PATH');
         l_from_address  := tmsint_java_email_utils.get_property_value 
                            (pPropertyName => 'JAVA_EMAIL_FROM_ADDRESS');
         l_smtp_host     := tmsint_java_email_utils.get_property_value 
                            (pPropertyName => 'JAVA_EMAIL_SMTP_HOST');
         l_smtp_port     := TO_NUMBER(tmsint_java_email_utils.get_property_value 
                            (pPropertyName => 'JAVA_EMAIL_SMTP_PORT'));
         l_mail_username := tmsint_java_email_utils.get_property_value 
                           (pPropertyName => 'JAVA_EMAIL_SMTP_USERNAME');
         l_mail_password := tmsint_java_email_utils.get_property_value
                           (pPropertyName => 'JAVA_EMAIL_SMTP_PASSWORD');

--       **********************************************
--       *** Encode the Email Username and Password ***
--       **********************************************
         SELECT UTL_ENCODE.TEXT_ENCODE(l_mail_username, nls_charset, 1),
                UTL_ENCODE.TEXT_ENCODE(l_mail_password, nls_charset, 1)
           INTO l_mail_username_encoded,
                l_mail_password_encoded
         FROM DUAL;        

--       ********************************
--       *** Open the SMTP Connection ***
--       ********************************
         BEGIN
            l_mail_conn := UTL_SMTP.OPEN_CONNECTION
               (host             => l_smtp_host, 
                port             => l_smtp_port,
                wallet_path      => l_wallet_path,
                wallet_password  => l_wallet_password,
                secure_connection_before_smtp => FALSE);
         EXCEPTION WHEN OTHERS THEN
            errm := '%%% Error Opening SMTP Connection '||SQLERRM;
            RAISE_APPLICATION_ERROR(-20101,errm);
         END;

--       *********************************************************
--       *** Calling EHLO to find server status and properties ***
--       *********************************************************                                           
         l_smtp_ehlo_replies := UTL_SMTP.EHLO(l_mail_conn, l_smtp_host);
         IF (UPPER(TRIM(pDebugFlag)) = 'Y') THEN
             DBMS_OUTPUT.PUT_LINE(' ***** Printing server properties *****');
             FOR i IN l_smtp_ehlo_replies.FIRST .. l_smtp_ehlo_replies.LAST 
             LOOP
                DBMS_OUTPUT.PUT_LINE(l_smtp_ehlo_replies(i).code ||
                                     l_smtp_ehlo_replies(i).text);
            END LOOP;
            DBMS_OUTPUT.PUT_LINE(' ***** End of printing server properties *****');
         END IF;
       
--       *********************************************************
--       *** Calling HELO to start the communiation            ***
--       *********************************************************         
         l_smtp_command_reply := UTL_SMTP.HELO(l_mail_conn, l_smtp_host);
         IF (UPPER(TRIM(pDebugFlag)) = 'Y') THEN
             DBMS_OUTPUT.PUT_LINE('HELO response - '        ||
                                   l_smtp_command_reply.code||
                                   l_smtp_command_reply.text);
         END IF;
       
--       *********************************************************
--       *** Calling STARTTLS to initiate TLS communication    ***
--       *********************************************************          
         l_smtp_command_reply :=  UTL_SMTP.STARTTLS(l_mail_conn);
         IF (UPPER(TRIM(pDebugFlag)) = 'Y') THEN
             DBMS_OUTPUT.PUT_LINE('STARTTLS response - '    ||
                                  l_smtp_command_reply.code ||
                                  l_smtp_command_reply.text);      
         END IF;

--       *********************************************************
--       *** Authenicating the user against the mail server    ***
--       ********************************************************* 
         l_smtp_command_reply := UTL_SMTP.COMMAND( l_mail_conn, 'AUTH', 'LOGIN');
         l_smtp_command_reply := UTL_SMTP.COMMAND( l_mail_conn, l_mail_username_encoded);
         l_smtp_command_reply := UTL_SMTP.COMMAND(l_mail_conn,l_mail_password_encoded);
         IF (UPPER(TRIM(pDebugFlag)) = 'Y') THEN
             DBMS_OUTPUT.PUT_LINE('AUTH LOGIN response - '  || 
                                  l_smtp_command_reply.code ||
                                  l_smtp_command_reply.text);
             DBMS_OUTPUT.PUT_LINE('Setting USERNAME response - ' ||
                                  l_smtp_command_reply.code      || 
                                  l_smtp_command_reply.text);
             DBMS_OUTPUT.PUT_LINE('Setting PASSWORD response - ' ||
                                  l_smtp_command_reply.code||
                                  l_smtp_command_reply.text);          
         END IF;

--       ***************************
--       *** Processing mail     ***
--       ***************************        
         UTL_SMTP.MAIL(l_mail_conn, l_from_address);
         tmsint_java_email_utils.process_recipients(l_mail_conn, pEmailToList);
         tmsint_java_email_utils.process_recipients(l_mail_conn, pEmailCCList);        

         UTL_SMTP.OPEN_DATA(l_mail_conn);
         UTL_SMTP.WRITE_DATA(l_mail_conn, 'Date: '    || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
         UTL_SMTP.WRITE_DATA(l_mail_conn, 'To: '      || REPLACE(pEmailToList, ',', ';') || UTL_TCP.crlf);    
         IF (pEmailCCList IS NOT NULL) THEN    
             UTL_SMTP.WRITE_DATA(l_mail_conn, 'CC: '  || REPLACE(pEmailCCList, ',', ';') || UTL_TCP.crlf);
         END IF;
         UTL_SMTP.WRITE_DATA(l_mail_conn, 'From: '    || l_from_address || UTL_TCP.crlf);
         UTL_SMTP.WRITE_DATA(l_mail_conn, 'Subject: ' || pEmailSubject || UTL_TCP.crlf);
         UTL_SMTP.WRITE_DATA(l_mail_conn, 'Reply-To: '|| l_from_address || UTL_TCP.crlf || UTL_TCP.crlf);
        
--       ************************
--       *** Write Email Body ***
--       ************************
         l_email_body_length := DBMS_LOB.GETLENGTH (pEmailBody);
         IF (UPPER(TRIM(pDebugFlag)) = 'Y') THEN
             DBMS_OUTPUT.PUT_LINE ('Email body length =' || l_email_body_length);
         END IF;

         IF (l_email_body_length <= 32767) THEN
            UTL_SMTP.WRITE_DATA(l_mail_conn, pEmailBody || UTL_TCP.crlf || UTL_TCP.crlf);
         ELSE
             BEGIN
                LOOP
                  DBMS_LOB.READ (pEmailBody, l_amount, l_offset, l_buffer);           
                  UTL_SMTP.WRITE_DATA(l_mail_conn, l_buffer);
                  l_offset := l_offset + l_amount;
                END LOOP;           
             EXCEPTION WHEN NO_DATA_FOUND THEN
                UTL_SMTP.WRITE_DATA(l_mail_conn,UTL_TCP.crlf || UTL_TCP.crlf);
             END;
         END IF;
         UTL_SMTP.CLOSE_DATA(l_mail_conn);
         UTL_SMTP.QUIT(l_mail_conn);                          

--    **************************
--    *** Exception Handler  ***
--    **************************
      EXCEPTION WHEN OTHERS THEN
      
         UTL_SMTP.CLOSE_DATA(l_mail_conn);
         UTL_SMTP.QUIT(l_mail_conn); 
            
         errm := '%%% Unhandled Error in TMSINT_JAVA_EMAIL_UTILS.EMAIL Sending Email to '||
            pEmailToList||' - '||SQLERRM;

         IF (UPPER(TRIM(pDebugFlag)) = 'Y') THEN
             DBMS_OUTPUT.PUT_LINE('JAVA_WALLET_PATH:          '||l_wallet_path);
           --DBMS_OUTPUT.PUT_LINE('JAVA_WALLET_PASSWORD:      '||l_wallet_password);
             DBMS_OUTPUT.PUT_LINE('JAVA_EMAIL_FROM_ADDRESS:   '||l_from_address);
             DBMS_OUTPUT.PUT_LINE('JAVA_EMAIL_SMTP_HOST:      '||l_smtp_host);
             DBMS_OUTPUT.PUT_LINE('JAVA_EMAIL_SMTP_PORT:      '||l_smtp_port);
             DBMS_OUTPUT.PUT_LINE('JAVA_EMAIL_SMTP_USERNAME:  '||l_mail_username);
           --DBMS_OUTPUT.PUT_LINE('JAVA_EMAIL_SMTP_PASSWORD:  '||l_mail_password);
         END IF;
         RAISE_APPLICATION_ERROR(-20101,errm);

      END email;


   END tmsint_java_email_utils;
/
  SHOW ERRORS

  SPOOL OFF
  EXIT

