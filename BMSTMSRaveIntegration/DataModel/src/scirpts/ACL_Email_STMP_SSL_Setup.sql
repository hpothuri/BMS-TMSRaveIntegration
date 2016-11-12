begin

  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL    (acl        => 'smtp_host.xml'
                                      , host       => 'smtpx17.msoutlookonline.net'
                                      , lower_port => 587
                                      , upper_port => null);
                                      
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (
    acl          => 'smtp_host.xml',
    principal    => 'TMSINT_JAVA',
    is_grant     => TRUE, 
    privilege    => 'use-client-certificates');

  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
    acl          => 'smtp_host.xml',
    principal   => 'TMSINT_JAVA',
    is_grant    =>  TRUE,
    privilege   => 'use-passwords');
    
  COMMIT;
END;
/