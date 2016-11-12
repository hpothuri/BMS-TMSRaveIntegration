SET SERVEROUTPUT ON SIZE UNLIMITED
BEGIN
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (ACL         => 'smtp_host.xml'
                                   , DESCRIPTION => 'ACL for SMTP(email) hosts'
                                   , principal   => 'TMSINT_JAVA'
                                   , is_grant    => TRUE
                                   , privilege   => 'connect');
                                   
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl       => 'smtp_host.xml'
                                      , principal => 'TMSINT_JAVA'
                                      , is_grant  => true
                                      , privilege => 'resolve');
 
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl       => 'smtp_host.xml'
                                      , principal => 'TMSINT_JAVA'
                                      , is_grant  => TRUE
                                      , privilege => 'connect');
                                      
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL    (acl        => 'smtp_host.xml'
                                      , host       => 'smtpx17.msoutlookonline.net'
                                      , lower_port => 80
                                      , upper_port => NULL);
 
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL    (acl        => 'smtp_host.xml'
                                      , host       => 'smtpx17.msoutlookonline.net'
                                      , lower_port => 25
                                      , upper_port => NULL);
 
  commit;
END;

/
show errors;