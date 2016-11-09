package com.rave.tmsint;

import java.sql.SQLException;
import java.sql.Connection;
import oracle.jdbc.OracleTypes;
import oracle.sql.ORAData;
import oracle.sql.ORADataFactory;
import oracle.sql.Datum;
import oracle.sql.STRUCT;
import oracle.jpub.runtime.MutableStruct;

public class TmsintXferHtmlWsObjRec implements ORAData, ORADataFactory
{
  public static final String _SQL_NAME = "TMSINT_XFER_HTML_WS_OBJR";
  public static final int _SQL_TYPECODE = OracleTypes.STRUCT;

  protected MutableStruct _struct;

  protected static int[] _sqlType =  { 12,12,2 };
  protected static ORADataFactory[] _factory = new ORADataFactory[3];
  protected static final TmsintXferHtmlWsObjRec _TmsintXferHtmlWsObjRecFactory = new TmsintXferHtmlWsObjRec();

  public static ORADataFactory getORADataFactory()
  { return _TmsintXferHtmlWsObjRecFactory; }
  /* constructors */
  protected void _init_struct(boolean init)
  { if (init) _struct = new MutableStruct(new Object[3], _sqlType, _factory); }
  public TmsintXferHtmlWsObjRec()
  { _init_struct(true); }
  public TmsintXferHtmlWsObjRec(String fileName, String htmlText, java.math.BigDecimal jobId) throws SQLException
  { _init_struct(true);
    setFileName(fileName);
    setHtmlText(htmlText);
    setJobId(jobId);
  }

  /* ORAData interface */
  public Datum toDatum(Connection c) throws SQLException
  {
    return _struct.toDatum(c, _SQL_NAME);
  }


  /* ORADataFactory interface */
  public ORAData create(Datum d, int sqlType) throws SQLException
  { return create(null, d, sqlType); }
  protected ORAData create(TmsintXferHtmlWsObjRec o, Datum d, int sqlType) throws SQLException
  {
    if (d == null) return null; 
    if (o == null) o = new TmsintXferHtmlWsObjRec();
    o._struct = new MutableStruct((STRUCT) d, _sqlType, _factory);
    return o;
  }
  /* accessor methods */
  public String getFileName() throws SQLException
  { return (String) _struct.getAttribute(0); }

  public void setFileName(String fileName) throws SQLException
  { _struct.setAttribute(0, fileName); }


  public String getHtmlText() throws SQLException
  { return (String) _struct.getAttribute(1); }

  public void setHtmlText(String htmlText) throws SQLException
  { _struct.setAttribute(1, htmlText); }


  public java.math.BigDecimal getJobId() throws SQLException
  { return (java.math.BigDecimal) _struct.getAttribute(2); }

  public void setJobId(java.math.BigDecimal jobId) throws SQLException
  { _struct.setAttribute(2, jobId); }

}
