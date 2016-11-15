set serveroutput on
declare 
pEmailToList varchar2(100) := 'harish.pvr@hotmail.com';
pEmailCCList varchar2(100) := 'harish.pvr@hotmail.com';
pEmailSubject VARCHAR2(100) := 'Test mail from TMSINT_JAVA_EMAIL_UTILS.SEND';
pEmailBody CLOB;
p_body varchar2(32767) := '<?xml version="1.0" encoding="utf-8"?>
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
begin
DBMS_LOB.CREATETEMPORARY (pEmailBody, false);
 dbms_lob.writeappend(pEmailBody, LENGTH (p_body), p_body);
  
TMSINT_JAVA_EMAIL_UTILS.email(pEmailToList => pEmailToList,
                              pEmailCCList => pEmailCCList,
                              pEmailSubject => pEmailSubject,
                              pEmailBody => pEmailBody);
end;