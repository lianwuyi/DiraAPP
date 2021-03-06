* 蒂拉商城 -------------------------------------------------

DEFINE CLASS dila_goods As Session

  PROCEDURE mallhome && 商城首页---------------------------
    yh1 =  httpqueryparams("phone")
    sj1 =  VAL(httpqueryparams("parentid"))
    IF sj1 <> 0
	  oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg") && 框架自带
      IF oDBSQLhelper.SQLQuery("SELECT goodsname,goodsimg,marketprice,goodsid from goods where issale=1","tmp")<0 && marketprice 市场价，issale 是否上架
	    ERROR oDBSQLhelper.errmsg
	  ENDIF 
	  RETURN cursortojson("tmp")
	ELSE 
	  RETURN "请先升级为代理商"
    ENDIF 

  ENDPROC 
  
  PROCEDURE mallhomelist && 商城产品明细---------------------------
    yh1 = httpqueryparams("phone")
    sj1 = httpqueryparams("parentid") && 上级id，即推荐人ID
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
  
  PROCEDURE buyers && 显示买家秀
    oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg") && 框架自带
    IF oDBSQLhelper.SQLQuery("SELECT * from buyers order by createtime desc","tmp")<0 
	  ERROR oDBSQLhelper.errmsg
	ENDIF 
	RETURN cursortojson("tmp")
  ENDPROC
  
  PROCEDURE camera && 卖家秀
    *保存图片
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
    bz1 = oFile.oFieldColl.item("remark").FieldData &&买家秀评论
    
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
	  SELECT userid,nickname,headimg FROM [user] WHERE userid = <<yh1>>
	ENDTEXT
	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
      ERROR oDBSQLhelper.errmsg
    ENDIF 
    nc1 = ALLTRIM(nickname)
    tx1 = ALLTRIM(headimg)
    * 保存买家秀信息
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