* �ɹ��� -------------------------------------------------

DEFINE CLASS dila_goods As Session

	PROCEDURE Mallhome && �̳���ҳ
*!*		  cgdid1=httpqueryparams("cgdid") && ,this.iconnid
	  TEXT TO lcSQLCmd NOSHOW TEXTMERGE
	    SELECT goodsname,goodsimg,marketprice from goods where issale=1 && marketprice �г��ۣ�issale �Ƿ��ϼ�
	  ENDTEXT
 	  oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	  IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
	    ERROR oDBSQLhelper.errmsg
	  ENDIF 
      RETURN cursortojson("tmp")
    ENDPROC 

ENDDEFINE 