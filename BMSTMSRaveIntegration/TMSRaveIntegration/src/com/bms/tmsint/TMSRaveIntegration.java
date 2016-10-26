package com.bms.tmsint;

import com.bms.tmsint.pojo.DataLine;
import com.bms.tmsint.pojo.ReturnStatus;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.Writer;

import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.X509Certificate;

import java.sql.Array;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Struct;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

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

import org.apache.commons.codec.binary.Base64;
import org.apache.http.HttpException;
import org.apache.http.HttpStatus;
import org.apache.http.auth.AuthScope;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.auth.Credentials;
import org.apache.http.conn.ssl.TrustStrategy;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpHead;
import org.apache.http.conn.socket.LayeredConnectionSocketFactory;
import org.apache.http.conn.ssl.X509HostnameVerifier;
import org.apache.http.conn.socket.ConnectionSocketFactory;
import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;

import java.io.IOException;

import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLException;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocket;

import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpHead;
import org.apache.http.config.Registry;
import org.apache.http.config.RegistryBuilder;
import org.apache.http.conn.socket.ConnectionSocketFactory;
import org.apache.http.conn.socket.LayeredConnectionSocketFactory;
import org.apache.http.conn.socket.PlainConnectionSocketFactory;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.conn.ssl.SSLContexts;
import org.apache.http.conn.ssl.TrustStrategy;
import org.apache.http.conn.ssl.X509HostnameVerifier;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;

import org.w3c.dom.Document;

import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.util.EntityUtils;

public class TMSRaveIntegration {
    public TMSRaveIntegration() {
        super();
    }

    public static final String FILE_SEPERATOR = System.getProperty("file.separator");
    private static final String SRC_TYPE_URL = "URL";
    private static final String SRC_TYPE_TXT_FILE = "TEXT";
    private static final String TEXT_FILE_DIRECTORY = "D:\\deploy";
    //    private static final String TEXT_FILE_DIRECTORY = "C:\\Users\\SBG_PC521\\Downloads";
    private static final String EXTRACT_TEXT_FILE_LOCATION = TEXT_FILE_DIRECTORY + "\\textfile.txt";
    private static final String IMPORT_TEXT_FILE_NAME_PREFIX = "ImportTextFile";
    //     private static final String TEXT_FILE_DIRECTORY ="C:\\Users\\SBG_PC521\\Downloads\\FLAT FILE Integration.txt";

    private static final String EXTRACT_TYPE_INCREMENTAL = "INCREMENTAL";
    private static final String EXTRACT_TYPE_CUMULATIVE = "CUMULATIVE";
    private static final String JOB_STATUS_SUBMITTED = "SUBMITTED";
    private static final String JOB_STATUS_EXTRACTED = "EXTRACTED";
    private static final String JOB_STATUS_ERROR = "ERROR_EXT";

    private static void deleteExtractData(Connection conn, CallableStatement cstmt) throws SQLException {
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

    private static List<DataLine> fetchDataLinesFromURL(Connection conn, String jobId) throws SQLException,
                                                                                       MalformedURLException,
                                                                                       IOException,
                                                                                       NoSuchAlgorithmException,
                                                                                       KeyManagementException {
        List<DataLine> dataLines = new ArrayList<DataLine>();
        PreparedStatement stmt = null;
        ResultSet rs = null;

        //  2.) Determine WHAT DatafileURLS are applicable to the client at hand...
        String sqlQuery =
            "  SELECT j.job_id," + "           j.datafile_url," + "           j.url_user_name," + "           j.url_password," +
            "           j.data_extract_type," +
            "           to_char(next_incr_extract_ts,'YYYY-MM-DD')||'T'||to_char(next_incr_extract_ts,'HH24:MI:SS') next_incr_extract_ts," +
            "           m.dcm_name," + "           m.vt_name" +
            "  FROM TABLE(tmsint_job_queue_utils.process_from_job_queue(pJobStatus => 'SUBMITTED'))   j," +
            "       TABLE(tmsint_xfer_utils.query_dict_mapping()) m" + "  WHERE j.datafile_id = m.datafile_id" +
            "  AND j.job_id = ?" + "  ORDER by j.job_priority, j.job_id, j.datafile_id";

        stmt = conn.prepareStatement(sqlQuery);
        stmt.setString(1, jobId);
        rs = stmt.executeQuery();

        StringBuilder sourceUrl = null;
        while (rs.next()) {
            //  3.) For EACH client datafile record retrieved in the cursor query above, (using your Java magic)
            //       Connect to the DatafileURL using the URLUserName and URLPassword.
            //       Each Line of the HTML data file should be written to the HTLM extract staging table
            //       via the API below:

            String extractType = rs.getString("data_extract_type");

            sourceUrl = new StringBuilder(rs.getString("datafile_url") + "/" + rs.getString("dcm_name"));

            if (EXTRACT_TYPE_INCREMENTAL.equals(extractType) && rs.getString("next_incr_extract_ts") != null)
                sourceUrl.append("?start=" + rs.getString("next_incr_extract_ts"));

            String userName = rs.getString("url_user_name");
            String password = rs.getString("url_password");

            if (sourceUrl != null && userName != null && password != null)
                dataLines.addAll(getClinicalDataFromMedidata(jobId, sourceUrl.toString(), userName, password));
        }

        JDBCUtil.closeResultSet(rs);
        JDBCUtil.closeStatement(stmt);
        return dataLines;
    }

    private static void insertExtractedDataIntoTMS(Connection conn, CallableStatement cstmt,
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

    private static void analyzeExtractTable(Connection conn, CallableStatement cstmt) throws SQLException {
        String sqlQuery = "begin TMSINT_XFER_UTILS.ANALYZE_XFER_TABLES(); end;";
        cstmt = conn.prepareCall(sqlQuery);
        cstmt.executeUpdate();
    }


    public static String extractClinicalDataFromURL() {
        String returnMsg = "Clinical data has been successfully extracted from Medidata and pushed to TMS.";
        List<DataLine> dataLines = null;
        Connection conn = null;
        CallableStatement cstmt = null;
        Statement stmt = null;
        ResultSet rs = null;
        String jobId = null;

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

            // DELETE EXISTING ROWS IN EXTRACT TABLE
            try {
                deleteExtractData(conn, cstmt);
            } catch (Exception e) {
                returnMsg =
                        "Error while clearing the processed data. Please check the database logs for more details.\n" +
                        e.getMessage();
                return returnMsg;
            }

            // ITERATE OVER JOBS IN SUBMITTED STATE
            try {
                String sqlQuery =
                    "  SELECT DISTINCT job_id, client_alias " + "  FROM TABLE( tmsint_job_queue_utils.process_from_job_queue(pJobStatus => 'SUBMITTED'))";

                stmt = conn.createStatement();
                rs = stmt.executeQuery(sqlQuery);

                while (rs.next()) {

                    jobId = rs.getString("job_id");
                    dataLines = new ArrayList<DataLine>();

                    try {
                        dataLines.addAll(fetchDataLinesFromURL(conn, jobId));

                        // insert extracted lines for the current job
                        insertExtractedDataIntoTMS(conn, cstmt, dataLines);

                        //UPDATE JOB STATUS TO EXTRACTED
//                        updateJobStatus(conn, jobId, rs.getString("client_alias"), JOB_STATUS_EXTRACTED, null);

                    } catch (Exception e) {
                        e.printStackTrace();
                        returnMsg = "Error while processing job " + jobId + ".The error message is " + e.getMessage();

                        //UPDATE JOB STATUS TO ERROR_EXT
//                        try {
//                            updateJobStatus(conn, jobId, rs.getString("client_alias"), JOB_STATUS_ERROR,
//                                            e.getMessage());
//                        } catch (Exception ex) {
//                            e.printStackTrace();
//                            returnMsg =
//                                    returnMsg + "Error while setting job status to ERROR_EXT for job id" + jobId + ".Error message is " +
//                                    e.getMessage();
//                            return returnMsg;
//                        }
                    }
                }

            } catch (Exception e) {
                returnMsg = "Error while fetching the jobs in submitted state.\n" +
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

    private static void updateJobStatus(Connection conn, String jobId, String clientAlias, String jobStatus,
                                 String errorMessage) throws SQLException {
        CallableStatement cstmt = null;
        String sqlQuery = "begin tmsint_job_queue_utils.update_job_status(?,?,?,?); end;";
        cstmt = conn.prepareCall(sqlQuery);
        cstmt.setString("pJobID", jobId);
        cstmt.setString("pClientAlias", clientAlias);
        cstmt.setString("pJobStatus", jobStatus);
        cstmt.setString("pErrorMsg", errorMessage);
        cstmt.executeUpdate();

        JDBCUtil.closeStatement(cstmt);
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
                returnMsg =
                        "Error while obtaining the database connection. Please check if the database is running.\n" +
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


    private static List<DataLine> getClinicalDataFromMedidata(String jobId, String sourceUrl, String userName,
                                                       String password) throws MalformedURLException, IOException,
                                                                               NoSuchAlgorithmException,
                                                                               KeyManagementException {
        System.out.println("Job Id -> " + jobId + " Extracting data for URL - " + sourceUrl);
        List<DataLine> dataLines = new ArrayList<DataLine>();
        List<String> textLines = new ArrayList<String>();

        //                HttpClient client = new HttpClient(); // Apache's Http client
        //                Credentials credentials = new UsernamePasswordCredentials(userName, password);
        //
        //                client.getState().setCredentials(AuthScope.ANY, credentials);
        //                client.getState().setProxyCredentials(AuthScope.ANY, credentials); // may not be necessary
        //
        //                client.getParams().setAuthenticationPreemptive(true); // send authentication details in the header
        //
        //                GetMethod httpget = new GetMethod(sourceUrl);
        //                int statusCode = client.executeMethod(httpget);

        //        String authString = userName + ":" + password;
        //        String authString = "DCaruso:QuanYin1";
        //        byte[] authEncBytes = Base64.encodeBase64(authString.getBytes());
        //        String authStringEnc = new String(authEncBytes);
        //        //        ignoreAllTrusts();
        //
        //        URL url = new URL(sourceUrl.replace(" ", "%20"));
        //        URLConnection con = url.openConnection();
        //        con.setRequestProperty("Authorization", "Basic " + authStringEnc);
        //
        //        //                if (statusCode == HttpStatus.SC_OK) {
        //        //                    BufferedInputStream reader = new BufferedInputStream(httpget.getResponseBodyAsStream());
        //        BufferedInputStream reader = new BufferedInputStream(con.getInputStream());
        //        BufferedReader br = new BufferedReader(new InputStreamReader(reader));
        String line = returnHttpGetResponse(sourceUrl, userName, password);
        if (line != null) {
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
                    dataLines.add(new DataLine(sourceUrl, text, jobId));
            }
        }
        //                }
        return dataLines;
    }

    private static String returnHttpGetResponse(String url, String userName, String password) {

        String response = null;

        CloseableHttpClient closeableHttpClient = null;
        CloseableHttpResponse closeableHttpResponse = null;
        CredentialsProvider credsProvider = new BasicCredentialsProvider();
        credsProvider.setCredentials(AuthScope.ANY, new UsernamePasswordCredentials(userName, password));

        try {
            HttpGet httpGet = null;
            TrustStrategy trustStrategy = null;
            SSLContext sslContext = null;
            X509HostnameVerifier x509HostnameVerifier = null;
            LayeredConnectionSocketFactory sslConnectionSocketFactory = null;
            Registry<ConnectionSocketFactory> registry = null;
            PoolingHttpClientConnectionManager poolingHttpClientConnectionManager = null;
            RequestConfig requestConfig = null;

            httpGet = new HttpGet(url.replace(" ", "%20"));

            trustStrategy = new TrustStrategy() {
                    @Override
                    public boolean isTrusted(X509Certificate[] xcs, String authType) throws CertificateException {
                        return true;
                    }
                };

            sslContext =
                    SSLContexts.custom().useSSL().loadTrustMaterial(null, trustStrategy).setSecureRandom(new SecureRandom()).build();

            x509HostnameVerifier = new X509HostnameVerifier() {
                    @Override
                    public void verify(String host, SSLSocket ssl) throws IOException {
                        //do nothing
                    }

                    @Override
                    public void verify(String host, X509Certificate cert) throws SSLException {
                        //do nothing                                                            //do nothing
                    }

                    @Override
                    public void verify(String host, String[] cns, String[] subjectAlts) throws SSLException {
                        //do nothing
                    }

                    @Override
                    public boolean verify(String string, SSLSession ssls) {
                        return true;
                    }
                };

            //either one works
            sslConnectionSocketFactory =
                    new SSLConnectionSocketFactory(sslContext, new String[] { "TLSv1" }, null, SSLConnectionSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
            //            sslConnectionSocketFactory =
            //                    new SSLConnectionSocketFactory(sslContext, new String[] { "TLSv1" }, null, x509HostnameVerifier);

            registry =
                    RegistryBuilder.<ConnectionSocketFactory>create().register("http", PlainConnectionSocketFactory.getSocketFactory()).register("https",
                                                                                                                                                 sslConnectionSocketFactory).build();

            poolingHttpClientConnectionManager = new PoolingHttpClientConnectionManager(registry);

            requestConfig = RequestConfig.custom().setConnectTimeout(5000). //5 seconds
                    setConnectionRequestTimeout(5000).setSocketTimeout(5000).build();

            closeableHttpClient =
                    HttpClientBuilder.create().setDefaultRequestConfig(requestConfig).setSslcontext(sslContext).setHostnameVerifier(x509HostnameVerifier).setSSLSocketFactory(sslConnectionSocketFactory).setConnectionManager(poolingHttpClientConnectionManager).setDefaultCredentialsProvider(credsProvider).build();

            if (closeableHttpClient != null) {
                
                closeableHttpResponse = closeableHttpClient.execute(httpGet);
                if (closeableHttpResponse != null) {
                    int statusCode = closeableHttpResponse.getStatusLine().getStatusCode();
                    if (200 == statusCode)
                        response = EntityUtils.toString(closeableHttpResponse.getEntity());
                }
            }
        } catch (NoSuchAlgorithmException noSuchAlgorithmException) {
            System.out.println(noSuchAlgorithmException.getMessage());
        } catch (KeyStoreException keyStoreException) {
            System.out.println(keyStoreException.getMessage());
        } catch (KeyManagementException keyManagementException) {
            System.out.println(keyManagementException.getMessage());
        } catch (IOException iOException) {
            System.out.println(iOException.getMessage());
        } finally {
            if (closeableHttpResponse != null) {
                try {
                    closeableHttpResponse.close();
                } catch (IOException iOException) {
                    System.out.println(iOException.getMessage());
                }
            }
            if (closeableHttpClient != null) {
                try {
                    closeableHttpClient.close();
                } catch (IOException iOException) {
                    System.out.println(iOException.getMessage());
                }
            }
        }
        return response;
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
            //            status.setErrorMessage(HttpStatus.getStatusText(con.getResponseCode()) + "-" + con.getInputStream());
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


    private static String format(String unformattedXml) {
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

    private static Document parseXmlFile(String in) {
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
        SSLContext sc = SSLContext.getInstance("TLSv1");
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
        TMSRaveIntegration ex = new TMSRaveIntegration();
        //        ex.returnHttpGetResponse("https://bmsdev.mdsol.com/RaveWebServices/studies/TMS Coding Study 1(DEV)/datasets/regular/PRETRTEV","DCaruso","QuanYin1");
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
            "      </ItemGroupData>" + "     </FormData>" + "    </StudyEventData>" + "   </SubjectData>" +
            "</ClinicalData>" + "</ODM>";

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
}
