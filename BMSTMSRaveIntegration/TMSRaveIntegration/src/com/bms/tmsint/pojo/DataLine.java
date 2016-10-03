package com.bms.tmsint.pojo;

public class DataLine {
    public DataLine() {
        super();
    }
    
    public DataLine(String url,String text,String jobId) {
        super();
        this.url = url;
        this.text = text; 
        this.jobId = jobId;
    }
    
    
    private String url;
    private String text;
    private String jobId;

    public void setUrl(String url) {
        this.url = url;
    }

    public String getUrl() {
        return url;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getText() {
        return text;
    }

    public void setJobId(String jobId) {
        this.jobId = jobId;
    }

    public String getJobId() {
        return jobId;
    }
}
