package com.rave.tmsint.pojo;

import com.rave.tmsint.JDBCUtil;

import java.io.Serializable;

import java.sql.Connection;
import java.sql.Array;
import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;

import oracle.sql.ARRAY;

import java.util.List;
import java.util.ArrayList;

import oracle.sql.ArrayDescriptor;

public class ExtractXmlFile implements SQLData {
    public ExtractXmlFile(List<ExtractXmlLine> xmlLines) {
        super();
        this.xmlLines = xmlLines;
    }
    public ExtractXmlFile() {
        super();
    }
    
    private String sql_type;
    private List<ExtractXmlLine> xmlLines;

    @Override
    public String getSQLTypeName() throws SQLException {
        return "TMSINT_XFER_HTML_WS_OBJT";
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {
        sql_type = typeName;
        Array array = stream.readArray();
        this.xmlLines = new ArrayList<ExtractXmlLine>();
        for (Object obj : (Object[])array.getArray()) {
            xmlLines.add((ExtractXmlLine)obj);
        }
    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        try {
            Connection conn = JDBCUtil.getConnection();
            ArrayDescriptor desc = ArrayDescriptor.createDescriptor(getSQLTypeName(), conn);
            ARRAY a = new ARRAY(desc, conn, xmlLines);
            stream.writeArray(a);
        } catch (Exception e) {
            System.out.println("Exception Occured in writeSQL of Employee" + e);
        }
    }
}
