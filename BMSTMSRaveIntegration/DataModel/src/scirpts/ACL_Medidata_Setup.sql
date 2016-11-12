SET SERVEROUTPUT ON SIZE UNLIMITED
BEGIN
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (ACL         => 'rave_hosts.xml'
                                   , DESCRIPTION => 'ACL for RAVE web services hosts'
                                   , principal   => 'TMSINT_JAVA'
                                   , is_grant    => TRUE
                                   , privilege   => 'connect');
 
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl       => 'rave_hosts.xml'
                                      , principal => 'TMSINT_JAVA'
                                      , is_grant  => TRUE
                                      , privilege => 'resolve');
                                      
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl       => 'rave_hosts.xml'
                                      , principal => 'TMSINT_JAVA'
                                      , is_grant  => TRUE
                                      , privilege => 'connect');
 
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(ACL  => 'rave_hosts.xml',
                                    host => 'bmsdev.mdsol.com');
 
  commit;
END;

/
show errors;