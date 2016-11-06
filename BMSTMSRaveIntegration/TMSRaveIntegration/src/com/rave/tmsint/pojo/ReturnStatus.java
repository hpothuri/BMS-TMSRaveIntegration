package com.rave.tmsint.pojo;

public class ReturnStatus {
    public ReturnStatus() {
        super();
    }
    
    public static final String SUCCESS = "SUCCESS";
    public static final String FAIL = "FAIL";
    
    private String status;
    private String responseBody;  
    private String errorMessage;

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setResponseBody(String responseBody) {
        this.responseBody = responseBody;
    }

    public String getResponseBody() {
        return responseBody;
    }
}
