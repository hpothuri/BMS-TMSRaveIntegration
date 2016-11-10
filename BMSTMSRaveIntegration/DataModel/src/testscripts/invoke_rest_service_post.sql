set serveroutput on
declare
l_status_code varchar2(1);
l_error_message varchar2(4000);
l_response CLOB;
 l_offset number default 1;
 l_input_payload CLOB;
 l_post_req_body varchar2(32767) := '<?xml version="1.0" encoding="utf-8"?>
<ODM FileType="Transactional" FileOID="131e5e07-22b8-4da9-8048-33f4452492a3" CreationDateTime="2016-10-28T17:09:30.100-00:00" ODMVersion="1.3" xmlns:mdsol="http://www.mdsol.com/ns/odm/metadata" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.cdisc.org/ns/odm/v1.3">
<ClinicalData StudyOID="TMS Coding Study 1(DEV)" MetaDataVersionOID="114" >
  <SubjectData SubjectKey="001-00001" TransactionType="Update">
   <SiteRef LocationOID="RKB_001" />
    <StudyEventData StudyEventOID="CONMED" StudyEventRepeatKey="1" TransactionType="Update">
     <FormData FormOID="CONMED" FormRepeatKey="1" TransactionType="Update">
      <ItemGroupData ItemGroupOID="CONMED_LOG_LINE" ItemGroupRepeatKey="3" TransactionType="Upsert">
       <ItemData ItemOID="CONMED.CMTRT" Value="BARACLUDE  (ENTECAVIR)" TransactionType="Context">
        <mdsol:Query Recipient="Site from Dictionary" RequiresResponse="Yes" Value="Please clarify (5th request)" Status="Open"/>
       </ItemData>
      </ItemGroupData>
     </FormData>
    </StudyEventData>
   </SubjectData>
</ClinicalData>
</ODM>';

BEGIN
 DBMS_LOB.CREATETEMPORARY (l_response, false);
  DBMS_LOB.CREATETEMPORARY (l_input_payload, FALSE);
  dbms_lob.writeappend(l_input_payload, LENGTH (l_post_req_body), l_post_req_body);
  
tmsint_java_xfer_utils.invoke_rest_service(
    p_url           => 'https://bmsdev.mdsol.com/RaveWebServices/webservice.aspx?PostODMClinicalData',
    p_input_payload => l_input_payload,
    p_http_method   => 'POST',
    p_username      => 'DCaruso',
    p_password      => 'QuanYin1',
    p_response      =>l_response,
    p_status_code   =>l_status_code,
    p_error_message =>l_error_message
  );
    dbms_output.put_line('Result : ' || l_status_code);
--  dbms_output.put_line(l_response);
dbms_output.put_line('Error : ' || l_error_message);

--       dbms_output.put_line(dbms_lob.getlength(l_response));
----      l_response := dbms_lob.substr(l_response,dbms_lob.instr(l_response,'<'));
--       l_response := dbms_lob.substr(l_response,4,4);
--       dbms_output.put_line(dbms_lob.getlength(l_response));
--       
--       loop exit when l_offset > dbms_lob.getlength(l_response);
--         dbms_output.put_line( dbms_lob.substr( l_response, 255, l_offset ) );
--         l_offset := l_offset + 255;
--       end loop;
       
        DBMS_LOB.FREETEMPORARY(l_response);
end;