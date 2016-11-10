package com.rave.tmsint;

import java.sql.SQLException;
import java.sql.Connection;
import oracle.jdbc.OracleTypes;
import oracle.sql.ORAData;
import oracle.sql.ORADataFactory;
import oracle.sql.Datum;
import oracle.sql.REF;
import oracle.sql.STRUCT;

public class TmsintXferHtmlWsObjRecRef implements ORAData, ORADataFactory
{
  public static final String _SQL_BASETYPE = "TMSINT_XFER_HTML_WS_OBJR";
  public static final int _SQL_TYPECODE = OracleTypes.REF;

  REF _ref;

private static final TmsintXferHtmlWsObjRecRef _TmsintXferHtmlWsObjRecRefFactory = new TmsintXferHtmlWsObjRecRef();

  public static ORADataFactory getORADataFactory()
  { return _TmsintXferHtmlWsObjRecRefFactory; }
  /* constructor */
  public TmsintXferHtmlWsObjRecRef()
  {
  }

  /* ORAData interface */
  public Datum toDatum(Connection c) throws SQLException
  {
    return _ref;
  }

  /* ORADataFactory interface */
  public ORAData create(Datum d, int sqlType) throws SQLException
  {
    if (d == null) return null; 
    TmsintXferHtmlWsObjRecRef r = new TmsintXferHtmlWsObjRecRef();
    r._ref = (REF) d;
    return r;
  }

  public static TmsintXferHtmlWsObjRecRef cast(ORAData o) throws SQLException
  {
     if (o == null) return null;
     try { return (TmsintXferHtmlWsObjRecRef) getORADataFactory().create(o.toDatum(null), OracleTypes.REF); }
     catch (Exception exn)
     { throw new SQLException("Unable to convert "+o.getClass().getName()+" to TmsintXferHtmlWsObjRecRef: "+exn.toString()); }
  }

  public TmsintXferHtmlWsObjRec getValue() throws SQLException
  {
     return (TmsintXferHtmlWsObjRec) TmsintXferHtmlWsObjRec.getORADataFactory().create(
       _ref.getSTRUCT(), OracleTypes.REF);
  }

  public void setValue(TmsintXferHtmlWsObjRec c) throws SQLException
  {
    _ref.setValue((STRUCT) c.toDatum(_ref.getJavaSqlConnection()));
  }
}
