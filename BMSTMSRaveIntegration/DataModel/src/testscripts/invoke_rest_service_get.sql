set serveroutput on
declare
l_status_code varchar2(1);
l_error_message varchar2(4000);
l_response CLOB;
l_offset number default 1;
l_str varchar2(4000) := null;
l_xmlresponse  XMLTYPE;
BEGIN
 DBMS_LOB.CREATETEMPORARY (l_response, true);
tmsint_java_xfer_utils.invoke_rest_service(
    p_url           => 'https://bmsdev.mdsol.com/RaveWebServices/studies/TMS CODING STUDY 1(DEV)/datasets/regular/PREMED',
    p_input_payload => null,
    p_http_method   => 'GET',
    p_username      => 'DCaruso',
    p_password      => 'QuanYin1',
    p_response      =>l_response,
    p_status_code   =>l_status_code,
    p_error_message =>l_error_message
  );
    dbms_output.put_line('Result : ' || l_status_code);
--  dbms_output.put_line(l_response);
dbms_output.put_line('Error : ' || l_error_message);

       dbms_output.put_line(dbms_lob.getlength(l_response));
--      l_response := dbms_lob.substr(l_response,dbms_lob.instr(l_response,'<'));
       l_response := DBMS_LOB.SUBSTR(l_response,
                              DBMS_LOB.GETLENGTH(l_response) -
                              DBMS_LOB.INSTR(l_response,'<')+1,
                              DBMS_LOB.INSTR(l_response,'<'));
       dbms_output.put_line(dbms_lob.getlength(l_response));
--       
--       loop exit when l_offset > dbms_lob.getlength(l_response);
--         dbms_output.put_line( dbms_lob.substr( l_response, 255, l_offset ) );
--         l_offset := l_offset + 255;
--       end loop;
l_xmlresponse := XMLTYPE.CREATEXML(l_response);
 l_str := l_xmlresponse.extract('/*').getstringval();
                          LOOP
                              EXIT WHEN l_str IS NULL;
                              dbms_output.put_line(SUBSTR(l_str,1,INSTR(l_str,CHR(10))-1));                                                      
                              l_str := SUBSTR(l_str,INSTR(l_str,CHR(10))+1);
                         END LOOP;
       
        DBMS_LOB.FREETEMPORARY(l_response);
end;