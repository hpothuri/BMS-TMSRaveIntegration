package com.rave.tmsint;

import java.sql.SQLException;
import java.sql.Connection;
import oracle.jdbc.OracleTypes;
import oracle.sql.ORAData;
import oracle.sql.ORADataFactory;
import oracle.sql.Datum;
import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import oracle.jpub.runtime.MutableArray;

public class TmsintXferHtmlWsObjTbl implements ORAData, ORADataFactory
{
  public static final String _SQL_NAME = "TMSINT_XFER_HTML_WS_OBJT";
  public static final int _SQL_TYPECODE = OracleTypes.ARRAY;

  MutableArray _array;

private static final TmsintXferHtmlWsObjTbl _TmsintXferHtmlWsObjTblFactory = new TmsintXferHtmlWsObjTbl();

  public static ORADataFactory getORADataFactory()
  { return _TmsintXferHtmlWsObjTblFactory; }
  /* constructors */
  public TmsintXferHtmlWsObjTbl()
  {
    this((TmsintXferHtmlWsObjRec[])null);
  }

  public TmsintXferHtmlWsObjTbl(TmsintXferHtmlWsObjRec[] a)
  {
    _array = new MutableArray(2002, a, TmsintXferHtmlWsObjRec.getORADataFactory());
  }

  /* ORAData interface */
  public Datum toDatum(Connection c) throws SQLException
  {
    return _array.toDatum(c, _SQL_NAME);
  }

  /* ORADataFactory interface */
  public ORAData create(Datum d, int sqlType) throws SQLException
  {
    if (d == null) return null; 
    TmsintXferHtmlWsObjTbl a = new TmsintXferHtmlWsObjTbl();
    a._array = new MutableArray(2002, (ARRAY) d, TmsintXferHtmlWsObjRec.getORADataFactory());
    return a;
  }

  public int length() throws SQLException
  {
    return _array.length();
  }

  public int getBaseType() throws SQLException
  {
    return _array.getBaseType();
  }

  public String getBaseTypeName() throws SQLException
  {
    return _array.getBaseTypeName();
  }

  public ArrayDescriptor getDescriptor() throws SQLException
  {
    return _array.getDescriptor();
  }

  /* array accessor methods */
  public TmsintXferHtmlWsObjRec[] getArray() throws SQLException
  {
    return (TmsintXferHtmlWsObjRec[]) _array.getObjectArray(
      new TmsintXferHtmlWsObjRec[_array.length()]);
  }

  public TmsintXferHtmlWsObjRec[] getArray(long index, int count) throws SQLException
  {
    return (TmsintXferHtmlWsObjRec[]) _array.getObjectArray(index,
      new TmsintXferHtmlWsObjRec[_array.sliceLength(index, count)]);
  }

  public void setArray(TmsintXferHtmlWsObjRec[] a) throws SQLException
  {
    _array.setObjectArray(a);
  }

  public void setArray(TmsintXferHtmlWsObjRec[] a, long index) throws SQLException
  {
    _array.setObjectArray(a, index);
  }

  public TmsintXferHtmlWsObjRec getElement(long index) throws SQLException
  {
    return (TmsintXferHtmlWsObjRec) _array.getObjectElement(index);
  }

  public void setElement(TmsintXferHtmlWsObjRec a, long index) throws SQLException
  {
    _array.setObjectElement(a, index);
  }

}
