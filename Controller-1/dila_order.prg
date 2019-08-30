* 蒂拉订单-----------------

DEFINE CLASS dila_order as Session 

  PROCEDURE order && 显示订单-------------------------
    yh1 = httpqueryparams("phone")
*!*	    cp1 = httpqueryparams("goodsid")
*!*	    sl1 = httpqueryparams("Num")
*!*	    dz1 = httpqueryparams("addressid")
*!*	    psfs1 = httpqueryparams("paytype")
*!*	    yf1 = httpqueryparams("freight")
*!*	    ly1 = httpqueryparams("remark")
    *查询我的收货地址        SELECT [goods].goodsid,[goods].goodsname,[goods].brands,[goods].goodsstock,[goods].marketprice*cartNum,[goods].goodsunit FROM [carts] left outer join goods ON [carts].goodsid = [goods].goodsid where loginname='<<yh1>>'  
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
      SELECT username,userphone,useraddress FROM [address] WHERE isdefault=1 AND loginName='<<yh1>>' 
    ENDTEXT
 	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
      ERROR oDBSQLhelper.errmsg
    ENDIF 
    RETURN cursortojson("tmp")
  ENDPROC 

  PROCEDURE addorder && 下单-------------------------
    yh1 = httpqueryparams("phone")
    cp1 = httpqueryparams("goodsid")
    cpmc1 = httpqueryparams("goodsname")
    sl1 = httpqueryparams("num")
    dz1 = httpqueryparams("addressid")
    psfs1 = httpqueryparams("paytype")
    IF ALLTRIM(psfs1)='到付'
      psfs1 = 1
    ELSE 
      psfs1 = 0
    ENDIF 
    yf1 = httpqueryparams("freight")
    ly1 = httpqueryparams("remark")
*!*	    fjid1 = httpqueryparams("parentid")
    *查询我的收货地址        SELECT [goods].goodsid,[goods].goodsname,[goods].brands,[goods].goodsstock,[goods].marketprice*cartNum,[goods].goodsunit FROM [carts] left outer join goods ON [carts].goodsid = [goods].goodsid where loginname='<<yh1>>'  
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
		INSERT INTO [orders] (loginName,goodsid,ordernum,goodsname,addressid,paytype,freight,remark) VALUES ('<<yh1>>',<<cp1>>,<<sl1>>,'<<cpmc1>>',<<dz1>>,<<psfs1>>,<<yf1>>,'<<ly1>>')
    ENDTEXT
	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
	IF oDBSQLhelper.ExeCuteSQL(lcSQLCmd)<0
	  ERROR oDBSQLHelper.errmsg
	ENDIF
	RETURN '{"errno":0,"errmsg":"ok"}'
  ENDPROC 

  PROCEDURE cart && 显示购物车-------------------------
    yh1 = httpqueryparams("phone")
    *查询我的收货地址
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
      SELECT cartNum,[goods].goodsid,[goods].goodsname,[goods].brands,[goods].goodsstock,[goods].marketprice*cartNum,[goods].goodsunit,[goods].marketprice*cartNum as money FROM [carts] left outer join goods ON [carts].goodsid = [goods].goodsid where loginname='<<yh1>>'  
    ENDTEXT
 	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
      ERROR oDBSQLhelper.errmsg
    ENDIF 
    RETURN cursortojson("tmp")
  ENDPROC 

  PROCEDURE addcart && 添加购物车------------------------
    *** 获取变量
    yh1=httpqueryparams("phone") 
    cpid1=VAL(httpqueryparams("goodsid"))
    sl1 = VAL(httpqueryparams("cartNum"))
    *** 查询
	oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg")
	ss1 = oDBSQLhelper.GetSingle(stringformat("SELECT COUNT(*) FROM [carts] WHERE loginName='{1}' and goodsid={2}",yh1,cpid1))

	IF ss1>0
	  *** 修改数据
      TEXT TO lcSQLCmd NOSHOW TEXTMERGE
	    UPDATE [carts] SET cartNum=<<sl1>> WHERE loginName='<<yh1>>' AND goodsid=<<cpid1>>
	  ENDTEXT
	ELSE 
	  *** 保存数据
	  TEXT TO lcSQLCmd NOSHOW TEXTMERGE
		INSERT INTO [carts] (loginName,goodsid,cartNum) VALUES ('<<yh1>>',<<cpid1>>,<<sl1>>)
	  ENDTEXT	
	ENDIF 
	
	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
	IF oDBSQLhelper.ExeCuteSQL(lcSQLCmd)<0
	  ERROR oDBSQLHelper.errmsg
	ENDIF
	RETURN '{"errno":0,"errmsg":"ok"}'
  ENDPROC 

  PROCEDURE assets && 显示我的资产 -------------------
    yh1 = httpqueryparams("phone")
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
      SELECT cash,balance FROM [user] where loginName='<<yh1>>'
    ENDTEXT	
 	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF
    RETURN cursortojson("tmp")
  ENDPROC 

  PROCEDURE stock && 显示我的库存 -------------------
    yh1 = httpqueryparams("phone")
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
      SELECT goodsname,stock FROM [userstock] where loginName='<<yh1>>'
    ENDTEXT	
 	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF
    RETURN cursortojson("tmp")
  ENDPROC 
  
  PROCEDURE low_order && 显示我的下级库存 -------------------
    yh1 = httpqueryparams("phone")
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
      SELECT createtime,goodsname,cash,ordernum FROM [orders] where loginName='<<yh1>>'
    ENDTEXT	
 	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF
    RETURN cursortojson("tmp")
  ENDPROC 
  
ENDDEFINE 