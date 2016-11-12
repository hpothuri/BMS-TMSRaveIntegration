CREATE OR REPLACE PROCEDURE send_mail(
    p_to      IN VARCHAR2,
    p_cc      IN VARCHAR2 DEFAULT NULL,
    p_bcc     IN VARCHAR2 DEFAULT NULL,
    p_from    IN VARCHAR2,
    p_subject IN VARCHAR2,
    p_message IN VARCHAR2)
AS
  L_MAIL_CONN UTL_SMTP.CONNECTION;
  LTAB_LNAME DBMS_UTILITY.LNAME_ARRAY;
  L_SMTP_HOST VARCHAR2(100) := 'smtpx17.msoutlookonline.net';
  l_smtp_port NUMBER        := 25;
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
  l_mail_conn := UTL_SMTP.open_connection(l_smtp_host, l_smtp_port);
  UTL_SMTP.helo(l_mail_conn, l_smtp_host);
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