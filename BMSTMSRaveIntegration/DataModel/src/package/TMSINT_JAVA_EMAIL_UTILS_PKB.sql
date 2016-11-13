create or replace
PACKAGE BODY tmsint_java_email_utils
   AS

--    **************************************************************************
--    ***                                                                    ***
--    *** Procedure:   PRINT_CLOB_NL                                         ***
--    ***                                                                    ***
--    *** Input:       pClob                                                 ***
--    ***                                                                    ***
--    *** Description: This Procedure will Accept a Clob Value and Parse     ***
--    ***              Display Based on a NL Character                       ***
--    ***                                                                    ***
--    **************************************************************************
      PROCEDURE print_clob_nl (pClob IN CLOB)
      IS
         pTemp VARCHAR2(255);
         errm  VARCHAR2(4000) := NULL;
      BEGIN
         FOR i IN 1 .. LENGTH(TRIM(pClob)) LOOP
             IF (ASCII(SUBSTR(pClob,i,1)) = 10) THEN
                 DBMS_OUTPUT.PUT_LINE(pTemp);
                 pTemp := NULL;
              ELSIF (i = LENGTH(pClob)) THEN
                 pTemp := pTemp || SUBSTR(pClob,i,1);
                 DBMS_OUTPUT.PUT_LINE(pTemp);
              ELSE
                 pTemp := pTemp || SUBSTR(pClob,i,1);
              END IF;
          END LOOP;
      EXCEPTION WHEN OTHERS THEN
         errm := '%%% Unhandled Error in Procedure PRINT_CLOB_NL '||
               SQLERRM;
         RAISE_APPLICATION_ERROR(-20101,errm);

      END print_clob_nl;

--    **************************************************************************
--    ***                                                                    ***
--    *** Procedure:    process_recipients                                   ***
--    ***                                                                    ***
--    *** Inputs:       p_mail_conn                                          ***
--    ***               p_list                                               ***
--    ***                                                                    ***
--    *** Description:  The Procedure will be to add multiple recipients to  ***
--    ***               mail connection.                                     ***
--    **************************************************************************      
PROCEDURE PROCESS_RECIPIENTS(
      p_mail_conn IN OUT UTL_SMTP.CONNECTION,
      p_list      IN VARCHAR2)
  AS
    recipients DBMS_UTILITY.UNCL_ARRAY;
    list_size INTEGER;
  BEGIN
    DBMS_UTILITY.COMMA_TO_TABLE (p_list, list_size, recipients);
    FOR i IN 1 .. list_size
    LOOP
      UTL_SMTP.RCPT(p_mail_conn, recipients(i));
    END loop;
  end;


--    **************************************************************************
--    ***                                                                    ***
--    *** Procedure:    email                                                ***
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
         pEmailBody     IN CLOB)
      IS      
          l_mail_conn             UTL_SMTP.CONNECTION;
          ltab_lname              DBMS_UTILITY.LNAME_ARRAY;
          l_from_address          VARCHAR2(100) := 'no-reply@bms.com';
          l_smtp_host             VARCHAR2(100) := 'smtp.gmail.com';
          l_smtp_port             NUMBER        := 587;
          l_mail_username         VARCHAR2(100) := 'dbmstestmail@gmail.com';
          l_mail_password         VARCHAR2(100) := 'dbmstestmail123';
          l_wallet_path           VARCHAR2(100) := 'file:E:\oracle\product\12.1.0\dbhome_1\dbms_smtp_wallet';
          l_wallet_password       VARCHAR2(100) := 'orawallet@123';
          l_mail_username_encoded VARCHAR2(100) := null;
          l_mail_password_encoded VARCHAR2(100) := null;
          nls_charset             VARCHAR2(255);
          l_smtp_ehlo_replies     UTL_SMTP.REPLIES;
          l_smtp_command_reply    UTL_SMTP.REPLY;
          l_buffer                VARCHAR2(2000);
          l_amount                PLS_INTEGER := 2000;
          l_offset                PLS_INTEGER := 1;
          l_email_body_length     BINARY_INTEGER;
      BEGIN

       SELECT UTL_ENCODE.TEXT_ENCODE(l_mail_username, nls_charset, 1) ,
          UTL_ENCODE.TEXT_ENCODE(l_mail_password, nls_charset, 1)
       INTO l_mail_username_encoded,
          l_mail_password_encoded
       FROM dual;       
        
       l_mail_conn := UTL_SMTP.OPEN_CONNECTION( host => l_smtp_host, 
                                                port => l_smtp_port,
                                                wallet_path => l_wallet_path,
                                                wallet_password => l_wallet_password,
                                                secure_connection_before_smtp => false);

--       *********************************************************
--       *** Calling EHLO to find server status and properties ***
--       *********************************************************                                           
       l_smtp_ehlo_replies := UTL_SMTP.EHLO(l_mail_conn, l_smtp_host);
       DBMS_OUTPUT.PUT_LINE(' ***** Printing server properties *****');
       FOR i in l_smtp_ehlo_replies.first .. l_smtp_ehlo_replies.last 
       LOOP
          DBMS_OUTPUT.PUT_LINE(l_smtp_ehlo_replies(i).code || l_smtp_ehlo_replies(i).text);
       END LOOP;
       DBMS_OUTPUT.PUT_LINE(' ***** End of printing server properties *****');
       
--       *********************************************************
--       *** Calling HELO to start the communiation            ***
--       *********************************************************         
       l_smtp_command_reply := UTL_SMTP.HELO(l_mail_conn, l_smtp_host);
       DBMS_OUTPUT.PUT_LINE('HELO response - ' || l_smtp_command_reply.code || l_smtp_command_reply.text);
       
--       *********************************************************
--       *** Calling STARTTLS to initiate TLS communication    ***
--       *********************************************************          
       l_smtp_command_reply :=  UTL_SMTP.STARTTLS(l_mail_conn);
       DBMS_OUTPUT.PUT_LINE('STARTTLS response - ' || l_smtp_command_reply.code || l_smtp_command_reply.text);      
        
--       *********************************************************
--       *** Authenicating the user against the mail server    ***
--       ********************************************************* 
       l_smtp_command_reply :=  UTL_SMTP.COMMAND( l_mail_conn, 'AUTH', 'LOGIN');
       DBMS_OUTPUT.PUT_LINE('AUTH LOGIN response - ' || l_smtp_command_reply.code || l_smtp_command_reply.text);
       l_smtp_command_reply := UTL_SMTP.COMMAND( l_mail_conn, l_mail_username_encoded);
       DBMS_OUTPUT.PUT_LINE('Setting USERNAME response - ' || l_smtp_command_reply.code || l_smtp_command_reply.text);
       l_smtp_command_reply := UTL_SMTP.COMMAND( l_mail_conn, l_mail_password_encoded);
       DBMS_OUTPUT.PUT_LINE('Setting PASSWORD response - ' || l_smtp_command_reply.code || l_smtp_command_reply.text);          

--       ***************************
--       *** Processing mail     ***
--       ***************************        
        UTL_SMTP.MAIL(l_mail_conn, l_from_address);
        process_recipients(l_mail_conn, pEmailToList);
        process_recipients(l_mail_conn, pEmailCCList);        
        UTL_SMTP.OPEN_DATA(l_mail_conn);
        UTL_SMTP.WRITE_DATA(l_mail_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
        UTL_SMTP.WRITE_DATA(l_mail_conn, 'To: ' || REPLACE(pEmailToList, ',', ';') || UTL_TCP.crlf);        
        UTL_SMTP.WRITE_DATA(l_mail_conn, 'CC: ' || REPLACE(pEmailCCList, ',', ';') || UTL_TCP.crlf);
        UTL_SMTP.WRITE_DATA(l_mail_conn, 'From: ' || l_from_address || UTL_TCP.crlf);
        UTL_SMTP.WRITE_DATA(l_mail_conn, 'Subject: ' || pEmailSubject || UTL_TCP.crlf);
        UTL_SMTP.WRITE_DATA(l_mail_conn, 'Reply-To: ' || l_from_address || UTL_TCP.crlf || UTL_TCP.crlf);
        
        l_email_body_length := DBMS_LOB.GETLENGTH (pEmailBody);
        DBMS_OUTPUT.PUT_LINE ('Email body length =' || l_email_body_length);
        IF (l_email_body_length <= 32767) THEN
           UTL_SMTP.WRITE_DATA(l_mail_conn, pEmailBody || UTL_TCP.crlf || UTL_TCP.crlf);
        ELSE
          BEGIN
           LOOP
           DBMS_LOB.READ (pEmailBody,
                          l_amount,
                          l_offset,
                          l_buffer);           
           UTL_SMTP.WRITE_DATA(l_mail_conn, l_buffer);
           l_offset := l_offset + l_amount;
           END LOOP;           
         EXCEPTION WHEN NO_DATA_FOUND THEN
           UTL_SMTP.WRITE_DATA(l_mail_conn,UTL_TCP.crlf || UTL_TCP.crlf);
         END;
        END IF;
        
        UTL_SMTP.CLOSE_DATA(l_mail_conn);
        UTL_SMTP.QUIT(l_mail_conn);                          

      END email;


   END tmsint_java_email_utils;