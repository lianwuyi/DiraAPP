* �����̳� -------------------------------------------------

DEFINE CLASS dila_goods As Session

  PROCEDURE mallhome && �̳���ҳ---------------------------
    yh1 =  httpqueryparams("phone")
    sj1 =  httpqueryparams("parentid") && �ϼ�id�����Ƽ���ID
    cp1 =  httpqueryparams("goodsid")
	oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg") && ����Դ�
    IF oDBSQLhelper.SQLQuery("SELECT goodsname,goodsimg,marketprice,goodsid from goods where issale=1","tmp")<0 && marketprice �г��ۣ�issale �Ƿ��ϼ�
	  ERROR oDBSQLhelper.errmsg
	ENDIF 
	RETURN cursortojson("tmp")
  ENDPROC 
  
  PROCEDURE mallhomelist && �̳ǲ�Ʒ��ϸ---------------------------
    yh1 = httpqueryparams("phone")
    sj1 = httpqueryparams("parentid") && �ϼ�id�����Ƽ���ID
    cp1 = httpqueryparams("goodsid") 
    sl1 = VAL(httpqueryparams("num"))
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
      SELECT goodsname,goodsimg,marketprice,brands,goodsstock,num from goods WHERE goodsid=<<cp1>>
    ENDTEXT
 	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
      ERROR oDBSQLhelper.errmsg
    ENDIF 
    RETURN cursortojson("tmp")
  ENDPROC 
  
  PROCEDURE buyers && ��ʾ�����
    oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg") && ����Դ�
    IF oDBSQLhelper.SQLQuery("SELECT * from buyers order by createtime desc","tmp")<0 
	  ERROR oDBSQLhelper.errmsg
	ENDIF 
	RETURN cursortojson("tmp")
  ENDPROC
  
  PROCEDURE camera && ������
    *����ͼƬ
    oFile=getupfile()
    cFilename1=getwwwrootpath("img")+SYS(2015)+"."+JUSTEXT(oFile.oFieldColl.item("file1").filename)
    STRTOFILE(oFile.oFieldColl.item("file1").FieldData,cFilename1)
*!*	    oFile=getupfile()
*!*	    cFilename2=getwwwrootpath("img")+SYS(2015)+"."+JUSTEXT(oFile.oFieldColl.item("file2").filename)
*!*	    STRTOFILE(oFile.oFieldColl.item("file2").FieldData,cFilename2)
*!*	    oFile=getupfile()
*!*	    cFilename3=getwwwrootpath("img")+SYS(2015)+"."+JUSTEXT(oFile.oFieldColl.item("file3").filename)
*!*	    STRTOFILE(oFile.oFieldColl.item("file3").FieldData,cFilename3)
        
    yh1 = VAL(oFile.oFieldColl.item("userid").FieldData)   
    bz1 = oFile.oFieldColl.item("remark").FieldData &&���������
    
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
	  SELECT userid,nickname,headimg FROM [user] WHERE userid = <<yh1>>
	ENDTEXT
	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
      ERROR oDBSQLhelper.errmsg
    ENDIF 
    nc1 = ALLTRIM(nickname)
    tx1 = ALLTRIM(headimg)
    * �����������Ϣ
    TEXT TO lcSQLCmd1 NOSHOW TEXTMERGE
	  INSERT INTO [buyers] (userid,nickname,headimg,img1,remark,createtime) VALUES (<<yh1>>,'<<nc1>>','<<tx1>>','<<cFilename1>>','<<bz1>>',getdate())
	ENDTEXT
	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
	IF oDBSQLhelper.ExeCuteSQL(lcSQLCmd1)<0
	  ERROR oDBSQLHelper.errmsg
	ENDIF
	RETURN '{"errno":0,"errmsg":"ok"}'
  ENDPROC 

ENDDEFINE