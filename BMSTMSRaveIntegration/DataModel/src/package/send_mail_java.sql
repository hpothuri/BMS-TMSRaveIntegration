CREATE OR REPLACE FUNCTION send_mail_with_auth(
    pFromAddress  IN VARCHAR2,
    pEmailTOList  IN VARCHAR2,
    pEmailCCList  IN VARCHAR2,
    pEmailSubject IN VARCHAR2,
    pEmailBody    IN VARCHAR2,
    pUsername     IN VARCHAR2,
    pPassword     IN VARCHAR2,
    pSmtphost     IN VARCHAR2,
    pSmtpport     IN VARCHAR2)
  RETURN VARCHAR2
IS
  LANGUAGE JAVA NAME 'com/rave/tmsint/EmailUtil.sendMail
  (java.lang.String,
  java.lang.String,
  java.lang.String,
  java.lang.String,
  java.lang.String,
  java.lang.String,
  java.lang.String,
  java.lang.String,
  java.lang.String) return java.lang.String';