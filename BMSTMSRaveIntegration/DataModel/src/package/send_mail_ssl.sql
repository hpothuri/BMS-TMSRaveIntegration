CREATE OR REPLACE PROCEDURE send_mail_ssl(
    p_to      IN VARCHAR2,
    p_cc      IN VARCHAR2 DEFAULT NULL,
    p_bcc     IN VARCHAR2 DEFAULT NULL,
    p_from    IN VARCHAR2,
    p_subject IN VARCHAR2,
    p_message IN VARCHAR2)
AS
  L_MAIL_CONN UTL_SMTP.CONNECTION;
  LTAB_LNAME DBMS_UTILITY.LNAME_ARRAY;
  L_SMTP_HOST             VARCHAR2(100) := 'smtpx17.msoutlookonline.net';
  l_smtp_port             NUMBER        := 587;
  l_mail_username         VARCHAR2(100) := 'harish.pothuri@clinicalserver.com';
  l_mail_password         VARCHAR2(100) := 'Abcd1234!';
  l_wallet_path           VARCHAR2(100) := 'file:E:\oracle\product\12.1.0\dbhome_1\dbms_smtp_wallet';
  l_wallet_password       VARCHAR2(100) := 'orawallet@123';
  l_domain_name           VARCHAR2(50)  := 'CLINICALSERVER.COM';
  l_mail_username_encoded varchar2(100) := null;
  l_mail_password_encoded varchar2(100) := null;
  nls_charset    varchar2(255);

  PROCEDURE PROCESS_RECIPIENTS(
      P_MAIL_CONN IN OUT UTL_SMTP.CONNECTION,
      P_LIST      IN VARCHAR2)
  AS
    RECIPIENTS DBMS_UTILITY.UNCL_ARRAY;
    list_size INTEGER;
  BEGIN
    DBMS_UTILITY.COMMA_TO_TABLE (P_LIST, list_size, RECIPIENTS);
    FOR i IN 1 .. list_size
    LOOP
      UTL_SMTP.rcpt(p_mail_conn, RECIPIENTS(i));
    END LOOP;
  END;
BEGIN
  
  begin
      select value
      into   nls_charset
      from   nls_database_parameters
      where  parameter = 'NLS_CHARACTERSET';

--    SELECT UTL_RAW.cast_to_varchar2 ( UTL_ENCODE.base64_encode (UTL_RAW.cast_to_raw (l_mail_username))) ,
--      UTL_RAW.cast_to_varchar2 ( utl_encode.base64_encode (utl_raw.cast_to_raw (l_mail_password)))
--    INTO l_mail_username_encoded,
--      l_mail_password_encoded
--    FROM dual;

      SELECT utl_encode.text_encode(l_mail_username, nls_charset, 1) ,
      utl_encode.text_encode(l_mail_password, nls_charset, 1)
    INTO l_mail_username_encoded,
      l_mail_password_encoded
    FROM dual;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20101,'%%% The Application Property '|| '"JAVA_WALLET_PATH" has Not Been Defined - Contact the '|| 'Application Administrator to Create the Property');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20101,'%%% Unhandled Error Obtaining '|| 'the "JAVA_WALLET_PATH" Property '||sqlerrm);
  END;
  l_mail_conn := utl_smtp.open_connection( host => l_smtp_host, port => l_smtp_port, wallet_path => l_wallet_path, wallet_password => l_wallet_password, secure_connection_before_smtp => false);
--  utl_smtp.helo(l_mail_conn, L_SMTP_HOST);
  UTL_SMTP.EHLO(l_mail_conn, L_SMTP_HOST);
--  utl_smtp.starttls(l_mail_conn);
  
  utl_smtp.command( l_mail_conn, 'auth login');
  utl_smtp.command( l_mail_conn, l_mail_username_encoded);
--  utl_smtp.command( l_mail_conn, l_mail_password_encoded);
--  utl_smtp.auth(l_mail_conn,l_mail_username,l_mail_password,utl_smtp.all_schemes);
  
  UTL_SMTP.mail(l_mail_conn, p_from);
  process_recipients(l_mail_conn, p_to);
  process_recipients(l_mail_conn, p_cc);
  process_recipients(l_mail_conn, p_bcc);
  UTL_SMTP.open_data(l_mail_conn);
  UTL_SMTP.write_data(l_mail_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'To: ' || p_to || UTL_TCP.crlf);
  IF TRIM(p_cc) IS NOT NULL THEN
    UTL_SMTP.write_data(l_mail_conn, 'CC: ' || REPLACE(p_cc, ',', ';') || UTL_TCP.crlf);
  END IF;
  IF TRIM(p_bcc) IS NOT NULL THEN
    UTL_SMTP.write_data(l_mail_conn, 'BCC: ' || REPLACE(p_bcc, ',', ';') || UTL_TCP.crlf);
  END IF;
  UTL_SMTP.write_data(l_mail_conn, 'From: ' || p_from || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'Subject: ' || p_subject || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'Reply-To: ' || p_from || UTL_TCP.crlf || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);
  UTL_SMTP.close_data(l_mail_conn);
  UTL_SMTP.quit(l_mail_conn);
END;