package com.rave.tmsint.pojo;

import java.math.BigDecimal;

import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.io.Serializable;
public class ExtractXmlLine implements SQLData {
    
    public ExtractXmlLine(String file_name, String html_text,BigDecimal job_id) {
        super();
        this.file_name = file_name;
        this.html_text = html_text;
        this.job_id = job_id;        
    }
    
    public ExtractXmlLine() {
        super();
    }

    private String sql_type;
    private String file_name;
    private String html_text;
    private BigDecimal job_id;    

    @Override
    public String getSQLTypeName() throws SQLException {
        return "TMSINT_XFER_HTML_WS_OBJR";
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {
        sql_type = typeName;
        job_id = stream.readBigDecimal();
        file_name = stream.readString();
        html_text = stream.readString();
    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        stream.writeBigDecimal(job_id);
        stream.writeString(file_name);
        stream.writeString(html_text);
    }
}
