package com.rave.tmsint;


import com.rave.tmsint.pojo.DataLine;
import com.rave.tmsint.pojo.ReturnStatus;
import java.net.URLEncoder;
import org.apache.commons.codec.binary.Base64;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.DataOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.Writer;

import java.net.MalformedURLException;

import java.net.URL;
import java.net.MalformedURLException;

import java.net.URLConnection;

import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.X509Certificate;

import java.sql.Array;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Struct;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.jws.WebMethod;
import javax.jws.WebService;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import oracle.jdbc.OracleConnection;
import oracle.jdbc.OracleTypes;

import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import oracle.sql.StructDescriptor;

//import org.apache.commons.httpclient.Credentials;
//import org.apache.commons.httpclient.HttpClient;
//import org.apache.commons.httpclient.HttpException;
//import org.apache.commons.httpclient.HttpStatus;
//import org.apache.commons.httpclient.UsernamePasswordCredentials;
//import org.apache.commons.httpclient.auth.AuthScope;
//import org.apache.commons.httpclient.methods.GetMethod;
//import org.apache.commons.httpclient.methods.PostMethod;
//import org.apache.commons.httpclient.methods.StringRequestEntity;
import org.apache.commons.lang3.StringUtils;
import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;

import org.w3c.dom.Document;

import org.xml.sax.InputSource;
import org.xml.sax.SAXException;



public class MedidataTMSIntegration {
    public MedidataTMSIntegration() {
        super();
    }
 /**   public static final String FILE_SEPERATOR = System.getProperty("file.separator");
    private static final String SRC_TYPE_URL = "URL";
    private static final String SRC_TYPE_TXT_FILE = "TEXT";
    private static final String TEXT_FILE_DIRECTORY = "D:\\deploy";
    //    private static final String TEXT_FILE_DIRECTORY = "C:\\Users\\SBG_PC521\\Downloads";
    private static final String EXTRACT_TEXT_FILE_LOCATION = TEXT_FILE_DIRECTORY + "\\textfile.txt";
    private static final String IMPORT_TEXT_FILE_NAME_PREFIX = "ImportTextFile";
    //     private static final String TEXT_FILE_DIRECTORY ="C:\\Users\\SBG_PC521\\Downloads\\FLAT FILE Integration.txt";
    
    private static final String EXTRACT_TYPE_INCREMENTAL = "INCREMENTAL";
    private static final String EXTRACT_TYPE_CUMULATIVE = "CUMULATIVE";

    private void deleteExtractData(Connection conn, CallableStatement cstmt) throws SQLException {
        String sqlQuery = "begin TMSINT_XFER_UTILS.DELETE_EXTRACT_DATA(?,?); end;";
        cstmt = conn.prepareCall(sqlQuery);
        cstmt.setString(1, null);
        cstmt.setString(2, null);
        cstmt.executeUpdate();
    }

//    private List<DataLine> fetchDataLinesFromTextFile(Connection conn, Statement stmt,
//                                                      String fileLocation) throws FileNotFoundException, IOException {
//        List<DataLine> dataLines = new ArrayList<DataLine>();
//        List<String> textLines = new ArrayList<String>();
//        FileInputStream is = new FileInputStream(fileLocation);
//        BufferedReader buf = new BufferedReader(new InputStreamReader(is));
//        String line = buf.readLine().trim();
//        StringBuilder sb = new StringBuilder();
//        while (line != null) {
//            if (line.length() > 0) {
//                line = StringUtils.stripStart(line.trim(), "-");
//                sb.append(line).append("\n");
//            }
//            line = buf.readLine();
//        }
//        String fileAsString = sb.toString();
//        fileAsString = format(fileAsString);
//        textLines.addAll(Arrays.asList(fileAsString.split("\\r\\n|\\n|\\r")));
//
//        if (!textLines.isEmpty()) {
//            for (String text : textLines) {
//                // ignore xml declaration lines
//                if (!text.startsWith("<?xml"))
//                    dataLines.add(new DataLine("https://pharmanet.mdsol.com/RaveWebServices/studies/PNET-DEMO(DEV)/datasets/regular",
//                                               text));
//            }
//        }
//        return dataLines;
//    }

    private List<DataLine> fetchDataLinesFromURL(Connection conn, Statement stmt, ResultSet rs) throws SQLException,
                                                                                                       MalformedURLException,
                                                                                                       IOException,
                                                                                                       NoSuchAlgorithmException,
                                                                                                       KeyManagementException {
        List<DataLine> dataLines = new ArrayList<DataLine>();
        //  2.) Determine WHAT DatafileURLS are applicable to the client at hand...
        String sqlQuery =
            "  SELECT j.job_id," + 
            "           j.datafile_url," + 
            "           j.url_user_name," + 
            "           j.url_password," + 
            "           j.data_extract_type," + 
            "           to_char(next_incr_extract_ts,'YYYY-MM-DD')||'T'||to_char(next_incr_extract_ts,'HH24:MI:SS') next_incr_extract_ts," + 
            "           m.dcm_name," + 
            "           m.vt_name" + 
            "    FROM TABLE(tmsint_job_queue_utils.process_from_job_queue(pJobStatus => 'SUBMITTED'))   j," + 
            "       TABLE(tmsint_xfer_utils.query_dict_mapping()) m" + 
            "  WHERE j.datafile_id = m.datafile_id" + 
            " ORDER by j.job_priority, j.job_id, j.datafile_id";

        stmt = conn.createStatement();
        rs = stmt.executeQuery(sqlQuery);
        
        StringBuilder sourceUrl = null;
        while (rs.next()) {
            //  3.) For EACH client datafile record retrieved in the cursor query above, (using your Java magic)
            //       Connect to the DatafileURL using the URLUserName and URLPassword.
            //       Each Line of the HTML data file should be written to the HTLM extract staging table
            //       via the API below:
            
            String extractType = rs.getString("data_extract_type");
            String jobId = rs.getString("job_id");
            
            sourceUrl = new StringBuilder(rs.getString("datafile_url") + "/" + rs.getString("dcm_name"));
            
            if (EXTRACT_TYPE_INCREMENTAL.equals(extractType) && rs.getString("next_incr_extract_ts") != null)
                sourceUrl.append("?start=" + rs.getString("next_incr_extract_ts"));

            String userName = rs.getString("url_user_name");
            String password = rs.getString("url_password");

            if (sourceUrl != null && userName != null && password != null)
                dataLines.addAll(getClinicalDataFromMedidata(jobId,sourceUrl.toString(), userName, password));
        }
        return dataLines;
    }

    private void insertExtractedDataIntoTMS(Connection conn, CallableStatement cstmt,
                                            List<DataLine> dataLines) throws SQLException {
        if (dataLines != null && dataLines.size() > 0) {

            Struct[] dataLineSqlRecList = new Struct[dataLines.size()];
            for (int i = 0; i < dataLines.size(); i++) {
                dataLineSqlRecList[i] =
                        conn.createStruct("TMSINT_XFER_HTML_WS_OBJR", new Object[] { dataLines.get(i).getUrl(),
                                                                                     dataLines.get(i).getText(),
                                                                                     dataLines.get(i).getJobId() });
            }

            System.out.println("Number of lines to be inserted : " + dataLineSqlRecList.length);

            //                                Array dataLineSqlTabType =
            //                                    ((OracleConnection)conn).createOracleArray("TMSINT_XFER_HTML_WS_OBJT",
            //                                                                               dataLineSqlRecList);
            ArrayDescriptor arrayDescriptor = ArrayDescriptor.createDescriptor("TMSINT_XFER_HTML_WS_OBJT", conn);
            ARRAY dataLineSqlTabType = new ARRAY(arrayDescriptor, conn, dataLineSqlRecList);


            String sqlQuery = "begin TMSINT_XFER_UTILS.INSERT_EXTRACT_DATA(?); end;";
            cstmt = conn.prepareCall(sqlQuery);
            cstmt.setArray(1, dataLineSqlTabType);
            cstmt.executeUpdate();
        }
    }

    private void analyzeExtractTable(Connection conn, CallableStatement cstmt) throws SQLException {
        String sqlQuery = "begin TMSINT_XFER_UTILS.ANALYZE_XFER_TABLES(); end;";
        cstmt = conn.prepareCall(sqlQuery);
        cstmt.executeUpdate();
    }


    public String extractClinicalDataFromURL() {
        String returnMsg = "Clinical data has been successfully extracted from Medidata and pushed to TMS.";
        List<DataLine> dataLines = null;
        Connection conn = null;
        CallableStatement cstmt = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {

            try {
                //                conn = JDBCUtil.getDSConnection();
                conn = JDBCUtil.getConnection();
            } catch (Exception e) {
                returnMsg =
                        "Error while obtaining the database connection. Please check if the data source is active.\n" +
                    e.getMessage();
                return returnMsg;
            }

            try {
                deleteExtractData(conn, cstmt);
            } catch (Exception e) {
                returnMsg =
                        "Error while clearing the processed data. Please check the database logs for more details.\n" +
                        e.getMessage();
                return returnMsg;
            }


            try {
                dataLines = fetchDataLinesFromURL(conn, stmt, rs);
            } catch (SQLException e) {
                returnMsg =
                        "Error while hitting the sql to fetch candidate data files. Please check the database logs for more details.";
                return returnMsg;
            } catch (Exception e) {
                e.printStackTrace();
                returnMsg = "Error reading the data from Medidata.\n" +
                        e.getMessage();
                return returnMsg;
            }

            try {
                insertExtractedDataIntoTMS(conn, cstmt, dataLines);

            } catch (Exception e) {
                returnMsg = "Error while pushing the data to interface tables.\n" +
                        e.getMessage();
                return returnMsg;
            }


            try {
                analyzeExtractTable(conn, cstmt);
            } catch (Exception e) {
                returnMsg =
                        "Error while analyzing the transfer tables. Please check the database logs for more details.\n" +
                    e.getMessage();
                return returnMsg;
            }

        } catch (Exception e) {
            e.printStackTrace();

        } finally {
            JDBCUtil.closeResultSet(rs);
            JDBCUtil.closeStatement(cstmt);
            JDBCUtil.closeStatement(stmt);
            JDBCUtil.closeConnection(conn);
        }
        return returnMsg;
    }


//    public String extractClinicalDataFromText() {
//        String returnMsg = "Clinical data has been successfully extracted from Medidata and pushed to TMS.";
//        List<DataLine> dataLines = null;
//        Connection conn = null;
//        CallableStatement cstmt = null;
//        Statement stmt = null;
//        ResultSet rs = null;
//
//        try {
//
//            try {
//                //                conn = JDBCUtil.getDSConnection();
//                conn = JDBCUtil.getConnection();
//            } catch (Exception e) {
//                returnMsg =
//                        "Error while obtaining the database connection. Please check if the data source is active.\n" +
//                    e.getMessage();
//                return returnMsg;
//            }
//
//            try {
//                deleteExtractData(conn, cstmt);
//            } catch (Exception e) {
//                returnMsg =
//                        "Error while clearing the processed data. Please check the database logs for more details.\n" +
//                        e.getMessage();
//                return returnMsg;
//            }
//
//
//            try {
//                dataLines = fetchDataLinesFromTextFile(conn, stmt, EXTRACT_TEXT_FILE_LOCATION);
//            } catch (Exception e) {
//                e.printStackTrace();
//                returnMsg = "Error reading the data from Medidata.\n" +
//                        e.getMessage();
//                return returnMsg;
//            }
//
//            try {
//                insertExtractedDataIntoTMS(conn, cstmt, dataLines);
//
//            } catch (Exception e) {
//                returnMsg = "Error while pushing the data to interface tables.\n" +
//                        e.getMessage();
//                return returnMsg;
//            }
//
//
//            try {
//                analyzeExtractTable(conn, cstmt);
//            } catch (Exception e) {
//                returnMsg =
//                        "Error while analyzing the transfer tables. Please check the database logs for more details.\n" +
//                    e.getMessage();
//                return returnMsg;
//            }
//
//        } catch (Exception e) {
//            e.printStackTrace();
//
//        } finally {
//            JDBCUtil.closeResultSet(rs);
//            JDBCUtil.closeStatement(cstmt);
//            JDBCUtil.closeStatement(stmt);
//            JDBCUtil.closeConnection(conn);
//        }
//        return returnMsg;
//    }

    private static final int POST_REQBODY_COL_INDX = 5;

    public String fullTMSIntegration() {
        String returnMsg = "Clinical data has been successfully processed in TMS for integration with Medidata.";
        Connection conn = null;
        CallableStatement cstmt = null;
        String sqlQuery = null;

        try {

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
//                conn =
//                DriverManager.getConnection("jdbc:oracle:thin:TMSINT_XFER_INV/TMSINT_XFER_INV@//23.246.122.46:79/ORT501",
//                            "TMSINT_PROC_INV", "TMSINT_PROC_INV");
                conn =
DriverManager.getConnection("jdbc:oracle:thin:TMSINT_XFER_INV/TMSINT_XFER_INV@//23.246.122.46:78/TMS51",
                            "TMSINT_PROC_INV", "TMSINT_PROC_INV");
            } catch (Exception e) {
                returnMsg = "Error while obtaining the database connection. Please check if the database is running.\n" +
                    e.getMessage();
                return returnMsg;
            }

            sqlQuery = "begin tmsint_proc_utils.RUN_TMS_INTEGRATION(); end;";
            cstmt = conn.prepareCall(sqlQuery);
            cstmt.executeUpdate();

        } catch (Exception e) {
            returnMsg = "Error while processing data in TMS for integration with Medidata.\n" +
                    e.getMessage();
            e.printStackTrace();
        } finally {
            JDBCUtil.closeStatement(cstmt);
            JDBCUtil.closeConnection(conn);
        }
        return returnMsg;
    }

    private void updatePostStatusToTMS(Connection conn, CallableStatement cstmt,
                                       Struct[] returnSqlRecList) throws SQLException {
        ArrayDescriptor arrayDescriptor = ArrayDescriptor.createDescriptor("TMSINT_XFER_HTML_IMPORT_OBJT", conn);
        ARRAY returnSqlTabType = new ARRAY(arrayDescriptor, conn, returnSqlRecList);

        String sqlQuery = "begin TMSINT_XFER_UTILS.UPDATE_IMPORT_DATA(?); end;";
        cstmt = conn.prepareCall(sqlQuery);
        cstmt.setArray(1, returnSqlTabType);
        cstmt.executeUpdate();
    }

    private Object[] selectDataToBeImported(Connection conn, CallableStatement cstmt) throws SQLException {
        String sqlQuery = "{ ? = call TMSINT_XFER_UTILS.SELECT_IMPORT_DATA(?,?,?) }";
        cstmt = conn.prepareCall(sqlQuery);
        cstmt.registerOutParameter(1, OracleTypes.ARRAY, "TMSINT_XFER_HTML_IMPORT_OBJT");
        cstmt.setString(2, null);
        cstmt.setString(3, null);
        cstmt.setString(4, "N");
        cstmt.executeUpdate();

        return (Object[])((Array)cstmt.getObject(1)).getArray();
    }

    public String importClinicalDataToURL() {
        String returnMsg = "Clinical data has been successfully imported to Medidata.";
        Connection conn = null;
        CallableStatement cstmt = null;
        StructDescriptor recTypeDescriptor = null;
        ResultSetMetaData metaData = null;
        ReturnStatus postOperStatus = null;
        Struct currRec = null;

        try {

            try {
                conn = JDBCUtil.getConnection();
                //                conn = JDBCUtil.getDSConnection();
            } catch (Exception e) {
                returnMsg =
                        "Error while obtaining the database connection. Please check if the data source is active.\n" +
                    e.getMessage();
                return returnMsg;
            }

            try {

                Object[] importDataTblType = selectDataToBeImported(conn, cstmt);
                recTypeDescriptor =
                        StructDescriptor.createDescriptor("TMSINT_XFER_HTML_IMPORT_OBJR", (OracleConnection)conn);
                metaData = recTypeDescriptor.getMetaData();

                Struct[] returnSqlRecList = new Struct[importDataTblType.length];
                int i = 0;

                for (Object importDataRecType : importDataTblType) {
                    currRec = (Struct)importDataRecType;
                    postOperStatus =
                            postClinicalDataToMedidata("https://pharmanet.mdsol.com/RaveWebServices/webservice.aspx?PostODMClinicalData",
                                                       (String)currRec.getAttributes()[POST_REQBODY_COL_INDX],
                                                       "DCaruso", "QuanYin2");

                    returnSqlRecList[i] = constructImportSqlRecType(currRec, postOperStatus, conn);
                    i++;
                }

                try {
                    updatePostStatusToTMS(conn, cstmt, returnSqlRecList);
                } catch (Exception e) {
                    returnMsg = "Error while updating the post status to TMS.\n" +
                    e.getMessage();
                    return returnMsg;
                }

            } catch (Exception e) {
                returnMsg =
                        "Error while fetching the records to be imported to Medidata. Please check if the data source is active and function TMSINT_XFER_UTILS.SELECT_IMPORT_DATA is accessible.\n" +
                    e.getMessage();
                return returnMsg;
            }

        } catch (Exception e) {
            returnMsg = "Error while importing data from TMS to Medidata.\n" +
                    e.getMessage();
            e.printStackTrace();
        } finally {
            JDBCUtil.closeStatement(cstmt);
            JDBCUtil.closeConnection(conn);
        }
        return returnMsg;
    }


//    public String importClinicalDataToText() {
//        String returnMsg = "Clinical data has been successfully imported to text files.";
//        Connection conn = null;
//        CallableStatement cstmt = null;
//        StructDescriptor recTypeDescriptor = null;
//        ResultSetMetaData metaData = null;
//        ReturnStatus postOperStatus = null;
//        Struct currRec = null;
//        List<String> importTextFiles = new ArrayList<String>();
//        try {
//
//            try {
//                conn = JDBCUtil.getConnection();
//                //                conn = JDBCUtil.getDSConnection();
//            } catch (Exception e) {
//                returnMsg =
//                        "Error while obtaining the database connection. Please check if the data source is active.\n" +
//                    e.getMessage();
//                return returnMsg;
//            }
//
//            try {
//
//                Object[] importDataTblType = selectDataToBeImported(conn, cstmt);
//                recTypeDescriptor =
//                        StructDescriptor.createDescriptor("TMSINT_XFER_HTML_IMPORT_OBJR", (OracleConnection)conn);
//                metaData = recTypeDescriptor.getMetaData();
//
//                Struct[] returnSqlRecList = new Struct[importDataTblType.length];
//                int i = 0;
//
//                for (Object importDataRecType : importDataTblType) {
//                    currRec = (Struct)importDataRecType;
//
//                    postOperStatus =
//                            postClinicalDataToText((String)currRec.getAttributes()[POST_REQBODY_COL_INDX], IMPORT_TEXT_FILE_NAME_PREFIX +
//                                                   i + ".txt");
//                    importTextFiles.add(IMPORT_TEXT_FILE_NAME_PREFIX + i + ".txt");
//                    returnSqlRecList[i] = constructImportSqlRecType(currRec, postOperStatus, conn);
//                    i++;
//                }
//
//                // send all text files via email
//                if (importTextFiles.size() > 0)
//                    EmailUtil.sendEmailWithAttachments(TEXT_FILE_DIRECTORY, importTextFiles);
//
//                try {
//                    if (returnSqlRecList != null && returnSqlRecList.length > 0)
//                        updatePostStatusToTMS(conn, cstmt, returnSqlRecList);
//                } catch (Exception e) {
//                    returnMsg = "Error while updating the post status to TMS.\n" +
//                    e.getMessage();
//                    return returnMsg;
//                }
//
//            } catch (Exception e) {
//                returnMsg =
//                        "Error while fetching the records to be imported to Medidata. Please check if the data source is active and function TMSINT_XFER_UTILS.SELECT_IMPORT_DATA is accessible.\n" +
//                    e.getMessage();
//                return returnMsg;
//            }
//
//        } catch (Exception e) {
//            returnMsg = "Error while importing data from TMS to Medidata.\n" +
//                    e.getMessage();
//            e.printStackTrace();
//        } finally {
//            JDBCUtil.closeStatement(cstmt);
//            JDBCUtil.closeConnection(conn);
//        }
//        return returnMsg;
//    }


    private Struct constructImportSqlRecType(Struct structBeforePost, ReturnStatus postStatus,
                                             Connection conn) throws SQLException {


        Object[] attrs = structBeforePost.getAttributes();
        attrs[7] = "Y";
        attrs[8] = new Date(new java.util.Date().getTime());
        attrs[9] = postStatus.getStatus();
        attrs[10] = postStatus.getErrorMessage();
        Struct structAfterPost = conn.createStruct("TMSINT_XFER_HTML_IMPORT_OBJR", attrs);
        return structAfterPost;
    }


    private List<DataLine> getClinicalDataFromMedidata(String jobId, String sourceUrl, String userName,
                                                       String password) throws MalformedURLException, IOException,
                                                                               NoSuchAlgorithmException,
                                                                               KeyManagementException {
        System.out.println("Extracting data for URL - " + sourceUrl);
        List<DataLine> dataLines = new ArrayList<DataLine>();
        List<String> textLines = new ArrayList<String>();

        //        HttpClient client = new HttpClient(); // Apache's Http client
        //        Credentials credentials = new UsernamePasswordCredentials(userName, password);
        //
        //        client.getState().setCredentials(AuthScope.ANY, credentials);
        //        client.getState().setProxyCredentials(AuthScope.ANY, credentials); // may not be necessary
        //
        //        client.getParams().setAuthenticationPreemptive(true); // send authentication details in the header
        //
        //        GetMethod httpget = new GetMethod(sourceUrl);
        //        int statusCode = client.executeMethod(httpget);

        String authString = userName + ":" + password;
        byte[] authEncBytes = Base64.encodeBase64(authString.getBytes());
        String authStringEnc = new String(authEncBytes);
        ignoreAllTrusts();
        URL url = new URL(sourceUrl);
        URLConnection con = url.openConnection();
        con.setRequestProperty("Authorization", "Basic " + authStringEnc);

        //        if (statusCode == HttpStatus.SC_OK) {
        //            BufferedInputStream reader = new BufferedInputStream(httpget.getResponseBodyAsStream());
        BufferedInputStream reader = new BufferedInputStream(con.getInputStream());
        BufferedReader br = new BufferedReader(new InputStreamReader(reader));
        String line = null;
        while ((line = br.readLine()) != null) {
            line = line.replaceAll("[^\\x20-\\x7e]", "");
            line = format(line);
            //                System.out.println("Formatted xml before split");
            //                System.out.println("----------------------------");
            //                System.out.println(line);
            textLines.addAll(Arrays.asList(line.split("\\r\\n|\\n|\\r")));
        }

        if (!textLines.isEmpty()) {
            for (String text : textLines) {
                // ignore xml declaration lines
                if (!text.startsWith("<?xml"))
                    dataLines.add(new DataLine(sourceUrl, text,jobId));
            }
        }
        //        }
        return dataLines;
    }

    private ReturnStatus postClinicalDataToMedidata(String serviceUrl, String xmlReqBody, String userName,
                                                    String password) throws IOException, HttpException,
                                                                            NoSuchAlgorithmException,
                                                                            KeyManagementException {
        
//        SSLContext sslContext = SSLContexts.custom().loadTrustMaterial(null, new TrustStrategy() {
//
//                       @Override
//                       public boolean isTrusted(final X509Certificate[] chain, final String authType) throws CertificateException {
//                           return true;
//                       }
//                   })
//                   .build();
//
//           SSLConnectionSocketFactory sslsf = new SSLConnectionSocketFactory(
//                   sslContext,
//                   NoopHostnameVerifier.INSTANCE);

//                HttpClient client = new HttpClient(); // Apache's Http client
//                Credentials credentials = new UsernamePasswordCredentials(userName, password);
//                client.getState().setCredentials(AuthScope.ANY, credentials);
//                client.getState().setProxyCredentials(AuthScope.ANY, credentials); // may not be necessary
//                client.getParams().setAuthenticationPreemptive(true); // send authentication details in the header
//        
//                PostMethod httppost = new PostMethod(serviceUrl);
//                httppost.setRequestHeader("Content-Type", "text/xml");
//                httppost.setRequestEntity(new StringRequestEntity(xmlReqBody, "application/xml", "UTF-8"));
//                int statusCode = client.executeMethod(httppost);

        String authString = userName + ":" + password;
        byte[] authEncBytes = Base64.encodeBase64(authString.getBytes());
        String authStringEnc = new String(authEncBytes);
        ignoreAllTrusts();
        URL url = new URL(serviceUrl);
        HttpsURLConnection con = (HttpsURLConnection)url.openConnection();
        con.setRequestMethod("POST");
        con.setRequestProperty("Authorization", "Basic " + authStringEnc);
        con.setRequestProperty("Content-Type", "text/xml");
        //                con.setRequestProperty("Content-Length", Integer.toString(xmlReqBody.length()));
        con.setDoOutput(true);
        DataOutputStream wr = new DataOutputStream(con.getOutputStream());
        wr.write(xmlReqBody.getBytes("UTF-8"));
        wr.flush();
        wr.close();

        ReturnStatus status = new ReturnStatus();
//          if (statusCode == HttpStatus.SC_OK)
        if (con.getResponseCode() == HttpStatus.SC_OK)
            status.setStatus(ReturnStatus.SUCCESS);
        else {
            status.setStatus(ReturnStatus.FAIL);
            status.setErrorCode(con.getResponseCode() + "");
            status.setErrorMessage(HttpStatus.getStatusText(con.getResponseCode())+ "-" + con.getInputStream());
        }
        return status;
    }

//    private ReturnStatus postClinicalDataToText(String xmlReqBody, String fileName) throws IOException, HttpException {
//        ReturnStatus status = new ReturnStatus();
//        FileWriter writer = null;
//        File file = null;
//        try {
//            file = new File(TEXT_FILE_DIRECTORY, fileName);
//            file.createNewFile();
//            writer = new FileWriter(file);
//            writer.write(format(xmlReqBody));
//            status.setStatus(ReturnStatus.SUCCESS);
//
//        } catch (IOException e) {
//            status.setStatus(ReturnStatus.FAIL);
//            status.setErrorMessage(e.getMessage());
//        } finally {
//
//            if (writer != null)
//                writer.close();
//
//        }
//        return status;
//    }


    private String format(String unformattedXml) {
        try {
            final Document document = parseXmlFile(unformattedXml);

            OutputFormat format = new OutputFormat(document);
            format.setLineWidth(65);
            format.setIndenting(true);
            format.setIndent(2);
            Writer out = new StringWriter();
            XMLSerializer serializer = new XMLSerializer(out, format);
            serializer.serialize(document);

            return out.toString();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private Document parseXmlFile(String in) {
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();
            InputSource is = new InputSource(new StringReader(in));
            return db.parse(is);
        } catch (ParserConfigurationException e) {
            throw new RuntimeException(e);
        } catch (SAXException e) {
            throw new RuntimeException(e);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private void ignoreAllTrusts() throws NoSuchAlgorithmException, KeyManagementException {

        // Create a trust manager that does not validate certificate chains
        TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
                public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                    return null;
                }

                public void checkClientTrusted(X509Certificate[] certs, String authType) {
                }

                public void checkServerTrusted(X509Certificate[] certs, String authType) {
                }
            } };

        // Install the all-trusting trust manager
        SSLContext sc = SSLContext.getInstance("SSL");
        sc.init(null, trustAllCerts, new java.security.SecureRandom());
        HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());

        // Create all-trusting host name verifier
        HostnameVerifier allHostsValid = new HostnameVerifier() {
            public boolean verify(String hostname, SSLSession session) {
                return true;
            }
        };

        // Install the all-trusting host verifier
        HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
    }

   
    public static void main(String[] args) {
        MedidataTMSIntegration ex = new MedidataTMSIntegration();
        System.out.println(ex.extractClinicalDataFromURL());
        
     //   System.out.println(ex.importClinicalDataToURL());
        
        
        String postReqBody =

        "<?xml version=\"1.0\" encoding=\"utf-8\"?>" + 
        "<ODM CreationDateTime=\"2016-07-06T03:45:00.884-00:00\" FileOID=\"44d0db09-6fc0-4790-b5a2-fa0984938b20\" FileType=\"Transactional\" ODMVersion=\"1.3\" xmlns=\"http://www.cdisc.org/ns/odm/v1.3\" xmlns:mdsol=\"http://www.mdsol.com/ns/odm/metadata\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">" + 
        "<ClinicalData StudyOID=\"PNET-RV-01(Dev)\" MetaDataVersionOID=\"1426\" >" + 
        "  <SubjectData SubjectKey=\"001DC-33\" TransactionType=\"Update\">" + 
        "   <SiteRef LocationOID=\"001\" />" + 
        "    <StudyEventData StudyEventOID=\"CM\" StudyEventRepeatKey=\"1\" TransactionType=\"Update\">" + 
        "     <FormData FormOID=\"CM\" FormRepeatKey=\"1\" TransactionType=\"Update\">" + 
        "      <ItemGroupData ItemGroupOID=\"CM_LOG_LINE\" ItemGroupRepeatKey=\"1\" TransactionType=\"Upsert\">" + 
        "       <ItemData ItemOID=\"CM.CLASSIFY\" Value=\"PONATINIB\" TransactionType=\"Upsert\"/>" + 
        "       <ItemData ItemOID=\"CM.DICTVER\" Value=\"WHODDEHDBMAR16\" TransactionType=\"Upsert\"/>" + 
        "       <ItemData ItemOID=\"CM.INGREDS\" Value=\"Ponatinib\" TransactionType=\"Upsert\"/>" + 
        "      </ItemGroupData>" + 
        "     </FormData>" + 
        "    </StudyEventData>" + 
        "   </SubjectData>" + 
        "</ClinicalData>" + 
        "</ODM>";

//                try {
//                    ex.postClinicalDataToMedidata("https://pharmanet.mdsol.com/RaveWebServices/webservice.aspx?PostODMClinicalData",
//                                                  postReqBody, "DCaruso", "QuanYin2");
//                } catch (HttpException e) {
//                    e.printStackTrace();
//                } catch (IOException e) {
//                    e.printStackTrace();
//                } catch (NoSuchAlgorithmException e) {
//            e.printStackTrace();
//        } catch (KeyManagementException e) {
//            e.printStackTrace();
//        }

        //        try {
//            System.out.println(ex.postClinicalDataToText(postReqBody,"TestImportToText.txt"));
//        } catch (HttpException e) {
//        } catch (IOException e) {
//        }
    }

**/
}
