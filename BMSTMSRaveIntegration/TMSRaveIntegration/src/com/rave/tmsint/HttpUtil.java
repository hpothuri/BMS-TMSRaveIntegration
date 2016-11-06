package com.rave.tmsint;

import com.rave.tmsint.pojo.ReturnStatus;

import java.io.IOException;

import java.io.UnsupportedEncodingException;

import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLException;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocket;

import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.config.Registry;
import org.apache.http.config.RegistryBuilder;
import org.apache.http.conn.socket.ConnectionSocketFactory;
import org.apache.http.conn.socket.LayeredConnectionSocketFactory;
import org.apache.http.conn.socket.PlainConnectionSocketFactory;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.conn.ssl.SSLContexts;
import org.apache.http.conn.ssl.TrustStrategy;
import org.apache.http.conn.ssl.X509HostnameVerifier;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.http.util.EntityUtils;

public class HttpUtil {
    public HttpUtil() {
        super();
    }

    public static ReturnStatus getHttpResponse(String url, String userName, String password) throws IOException,
                                                                                                    NoSuchAlgorithmException,
                                                                                                    KeyStoreException,
                                                                                                    KeyManagementException {

        ReturnStatus response = null;
        CloseableHttpClient closeableHttpClient = null;
        CloseableHttpResponse closeableHttpResponse = null;
        HttpGet httpGet = null;

        try {
            closeableHttpClient = prepareHttpClient(userName, password);
            httpGet = new HttpGet(url.replace(" ", "%20"));
            if (closeableHttpClient != null) {
                closeableHttpResponse = closeableHttpClient.execute(httpGet);
                if (closeableHttpResponse != null)
                    response = populateReturnStatus(closeableHttpResponse);
            }
        } finally {
            closeHttpResponse(closeableHttpResponse);
            closeHttpClient(closeableHttpClient);
        }
        return response;
    }

    private static void closeHttpClient(CloseableHttpClient closeableHttpClient) {
        if (closeableHttpClient != null) {
            try {
                closeableHttpClient.close();
            } catch (IOException iOException) {
                System.out.println(ExceptionUtils.getStackTrace(iOException));
            }
        }
    }

    private static void closeHttpResponse(CloseableHttpResponse closeableHttpResponse) {
        if (closeableHttpResponse != null) {
            try {
                closeableHttpResponse.close();
            } catch (IOException iOException) {
                System.out.println(ExceptionUtils.getStackTrace(iOException));
            }
        }
    }

    public static void ignoreAllTrusts() throws NoSuchAlgorithmException, KeyManagementException {

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

    private static CloseableHttpClient prepareHttpClient(String userName,
                                                         String password) throws NoSuchAlgorithmException,
                                                                                 KeyStoreException,
                                                                                 KeyManagementException {

        CloseableHttpClient closeableHttpClient = null;
        CredentialsProvider credsProvider = new BasicCredentialsProvider();
        credsProvider.setCredentials(AuthScope.ANY, new UsernamePasswordCredentials(userName, password));
        TrustStrategy trustStrategy = null;
        SSLContext sslContext = null;
        X509HostnameVerifier x509HostnameVerifier = null;
        LayeredConnectionSocketFactory sslConnectionSocketFactory = null;
        Registry<ConnectionSocketFactory> registry = null;
        PoolingHttpClientConnectionManager poolingHttpClientConnectionManager = null;
        RequestConfig requestConfig = null;

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


        return closeableHttpClient;
    }

    public static ReturnStatus postHttpRequest(String postUrl, String xmlReqBody, String userName,
                                               String password) throws NoSuchAlgorithmException, KeyStoreException,
                                                                       KeyManagementException,
                                                                       UnsupportedEncodingException, IOException,
                                                                       ClientProtocolException {
        ReturnStatus status = null;
        CloseableHttpClient closeableHttpClient = null;
        CloseableHttpResponse closeableHttpResponse = null;
        HttpPost httpPost = null;
        StringEntity entity = null;

        try {
            closeableHttpClient = prepareHttpClient(userName, password);
            httpPost = new HttpPost(postUrl.replace(" ", "%20"));
            entity = new StringEntity(xmlReqBody);
            httpPost.setEntity(entity);
            httpPost.setHeader("Content-type", "text/xml");

            if (closeableHttpClient != null) {
                closeableHttpResponse = closeableHttpClient.execute(httpPost);
                if (closeableHttpResponse != null)
                    status = populateReturnStatus(closeableHttpResponse);
            }
        } finally {
            closeHttpResponse(closeableHttpResponse);
            closeHttpClient(closeableHttpClient);
        }
        return status;
    }

    private static ReturnStatus populateReturnStatus(CloseableHttpResponse closeableHttpResponse) throws IOException {
        ReturnStatus status = new ReturnStatus();
        int statusCode = closeableHttpResponse.getStatusLine().getStatusCode();
        if (200 == statusCode) {
            status.setStatus(ReturnStatus.SUCCESS);
            status.setResponseBody(EntityUtils.toString(closeableHttpResponse.getEntity()));
        } else {
            status.setStatus(ReturnStatus.FAIL);
            status.setErrorMessage(closeableHttpResponse.getStatusLine().getStatusCode() + " : " +
                                   closeableHttpResponse.getStatusLine().getReasonPhrase());
            status.setResponseBody(EntityUtils.toString(closeableHttpResponse.getEntity()));
        }
        return status;
    }

}
