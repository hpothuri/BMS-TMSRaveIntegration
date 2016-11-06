package com.rave.tmsint;


import com.rave.tmsint.pojo.ReturnStatus;

import java.sql.Connection;


import java.sql.SQLException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import oracle.sql.ArrayDescriptor;
import oracle.sql.STRUCT;
import oracle.sql.ARRAY;
import oracle.sql.Datum;
import oracle.sql.StructDescriptor;

import org.apache.commons.lang3.exception.ExceptionUtils;


public class ExtractClinicalData {
    public ExtractClinicalData() {
        super();
    }

    public static void getClinicalDataFromMedidata(String jobId, String sourceUrl, String userName, String password,
                                                   ARRAY[] xmlResponse, String[] errorMessage) {
        System.out.println("Job Id -> " + jobId + " Extracting data for URL - " + sourceUrl);
        List<String> textLines = new ArrayList<String>();
        Connection conn = null;
        STRUCT[] dataLines = null;
        StructDescriptor recStruct = null;
        ArrayDescriptor arrayDesc = null;
        ReturnStatus response = null;
        try {
            conn = JDBCUtil.getConnection();

            recStruct = StructDescriptor.createDescriptor("TMSINT_XFER_HTML_WS_OBJR", conn);
            arrayDesc = ArrayDescriptor.createDescriptor("TMSINT_XFER_HTML_WS_OBJT", conn);

            response = HttpUtil.getHttpResponse(sourceUrl, userName, password);

            if (response.getStatus().equals(ReturnStatus.SUCCESS)) {
                String xmlBody = response.getResponseBody();
                if (xmlBody != null) {
                    xmlBody = xmlBody.replaceAll("[^\\x20-\\x7e]", "");
                    xmlBody = XMLUtil.format(xmlBody);
                    textLines.addAll(Arrays.asList(xmlBody.split("\\r\\n|\\n|\\r")));
                }

                if (!textLines.isEmpty()) {
                    dataLines = new STRUCT[textLines.size()];
                    for (int i = 0; i < textLines.size(); i++) {
                        // ignore xml declaration lines
                        if (!textLines.get(i).startsWith("<?xml")) {
                            Object[] obj = new Object[3];
                            obj[0] = sourceUrl;
                            obj[1] = textLines.get(i);
                            obj[2] = jobId;
                            dataLines[i] = new STRUCT(recStruct, conn, obj);
                        }
                    }
                    xmlResponse[0] = new ARRAY(arrayDesc, conn, dataLines);
                }
            } else
                errorMessage[0] = response.getErrorMessage() + response.getResponseBody();
        } catch (Exception e) {
            errorMessage[0] = ExceptionUtils.getStackTrace(e);
        }
    }
    
    public static void main(String[] args) {
        ARRAY[] xmlResponse = new ARRAY[1];
        String[] errorMessage = new String[1];      
        ExtractClinicalData.getClinicalDataFromMedidata("999", "https://bmsdev.mdsol.com/RaveWebServices/studies/TMS CODING STUDY 1(DEV)/datasets/regular/PREMED", "DCaruso", "QuanYin1", xmlResponse, errorMessage);
        try {
            Object[] objArr = (Object[]) xmlResponse[0].getArray();
                   for(int i=1; i<objArr.length;i++){
                       STRUCT st = (STRUCT)objArr[i];
                       Datum[] obj = st.getOracleAttributes();
                       System.out.println(obj[1].stringValue());
                   }
        } catch (SQLException e) {
        }
        System.out.println(errorMessage[0]);
    

    }
}