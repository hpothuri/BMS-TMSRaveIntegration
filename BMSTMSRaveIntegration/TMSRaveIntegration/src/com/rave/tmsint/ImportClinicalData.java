package com.rave.tmsint;

import com.rave.tmsint.pojo.ReturnStatus;

import java.io.DataOutputStream;
import java.io.IOException;

import java.io.UnsupportedEncodingException;

import java.net.URL;

import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;

import javax.net.ssl.HttpsURLConnection;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.http.HttpException;
import org.apache.http.HttpStatus;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;

public class ImportClinicalData {
    public ImportClinicalData() {
        super();
    }

    public static void postClinicalDataToMedidata(String postUrl, String xmlReqBody, String userName,
                                                    String password,String[] statusCode, String[] responseBody, String[] errorMessage) {
        ReturnStatus status = null;
        try {
            status = HttpUtil.postHttpRequest(postUrl, xmlReqBody, userName, password);
            statusCode[0] = status.getStatus();
            responseBody[0] = status.getResponseBody();
            errorMessage[0] = status.getErrorMessage();
        } catch (NoSuchAlgorithmException e) {
        } catch (KeyStoreException e) {
        } catch (KeyManagementException e) {
        } catch (UnsupportedEncodingException e) {
        } catch (ClientProtocolException e) {
        } catch (IOException e) {
        }
    }
    
    public static void main(String[] args){
        String xmlReqBody = "<?xml version=\"1.0\" encoding=\"utf-8\"?>" + 
        "<ODM FileType=\"Transactional\" FileOID=\"131e5e07-22b8-4da9-8048-33f4452492a3\" CreationDateTime=\"2016-10-28T17:09:30.100-00:00\" ODMVersion=\"1.3\" xmlns:mdsol=\"http://www.mdsol.com/ns/odm/metadata\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns=\"http://www.cdisc.org/ns/odm/v1.3\">" + 
        "<ClinicalData StudyOID=\"TMS Coding Study 1(DEV)\" MetaDataVersionOID=\"114\" >" + 
        "  <SubjectData SubjectKey=\"001-00001\" TransactionType=\"Update\">" + 
        "   <SiteRef LocationOID=\"RKB_001\" />" + 
        "    <StudyEventData StudyEventOID=\"CONMED\" StudyEventRepeatKey=\"1\" TransactionType=\"Update\">" + 
        "     <FormData FormOID=\"CONMED\" FormRepeatKey=\"1\" TransactionType=\"Update\">" + 
        "      <ItemGroupData ItemGroupOID=\"CONMED_LOG_LINE\" ItemGroupRepeatKey=\"2\" TransactionType=\"Upsert\">" + 
        "       <ItemData ItemOID=\"CONMED.CMTRT\" Value=\"AZACTAM  (AZTREONAM FOR INJECTION, USP)\" TransactionType=\"Context\">" + 
        "        <mdsol:Query Recipient=\"Site from Dictionary\" QueryRepeatKey=\"54018\" Status=\"Closed\"/>" + 
        "       </ItemData>" + 
        "      </ItemGroupData>" + 
        "     </FormData>" + 
        "    </StudyEventData>" + 
        "   </SubjectData>" + 
        "</ClinicalData>" + 
        "</ODM>";
        String[] statusCode = new String[5];
        String[] responseBody = new String[5];
        String[] errorMessage = new String[5];
        ImportClinicalData.postClinicalDataToMedidata("https://bmsdev.mdsol.com/RaveWebServices/webservice.aspx?PostODMClinicalData", xmlReqBody, "DCaruso", "QuanYin1", statusCode,responseBody,errorMessage);
    }

}
