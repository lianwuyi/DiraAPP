* 蒂拉订单-----------------

DEFINE CLASS dila_order as Session 

*!*	  PROCEDURE order && 显示订单-------------------------
*!*	    yh1 = httpqueryparams("phone")

*!*		oDBSQLhelper=Newobject("MSSQLhelper","MSSQLhelper.prg")
*!*		oQiyuJson=Newobject("QiyuJson","QiyuJson.prg")

*!*		TEXT TO lcSQLCmd NOSHOW TEXTMERGE PRETEXT 1+2
*!*		  SELECT username,userphone,useraddress,addressid FROM [address] WHERE isdefault=1 AND loginName='<<yh1>>'
*!*		ENDTEXT
*!*		nRow=oDBSQLhelper.SQLQuery(lcSQLCmd,"buy_main")
*!*		If nRow<0
*!*		  Error oDBSQLhelper.errmsg
*!*		Endif
*!*		oQiyuJson.AppendCursorToObj("buy_main","data")

*!*		TEXT TO lcSQLCmd NOSHOW TEXTMERGE PRETEXT 1+2
*!*		   select [goods].goodsname,[goods].brands,[goods].marketprice,[carts].goodsid,[carts].num,[goods].marketprice*[carts].num as total from [carts] left OUTER JOIN [goods] on [carts].goodsid=[goods].goodsid where [carts].num>0 and [carts].loginName='<<yh1>>'
*!*		ENDTEXT
*!*		nRow=oDBSQLhelper.SQLQuery(lcSQLCmd,"buy_detail")
*!*		*nRow=oDBSQLhelper.SQLQuery(lcSQLCmd,"buy_detail2")
*!*		If nRow<0
*!*			Error oDBSQLhelper.errmsg
*!*		Endif
*!*		oQiyuJson.appendcursor("buy_detail",nRow,"test")  &&单表
*!*		*oQiyuJson.appendcursor("buy_detail2",nRow,"test1")  &&单表
*!*		_cliptext=oQiyuJson.tojson()
*!*	    RETURN _cliptext
*!*	  ENDPROC 

  PROCEDURE default_map && 显示默认地址-------------------------
    yh1 = httpqueryparams("phone")
   
	TEXT TO lcSQLCmd NOSHOW TEXTMERGE 
	  SELECT username,userphone,useraddress,addressid FROM [address] WHERE isdefault=1 AND loginName='<<yh1>>'
	ENDTEXT
 	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF
    RETURN cursortojson("tmp")
  ENDPROC 

  PROCEDURE order && 显示购物车里的产品到下单界面-------------------------
    yh1 = httpqueryparams("phone")

	TEXT TO lcSQLCmd NOSHOW TEXTMERGE
	   select [goods].goodsname,[goods].brands,[goods].marketprice,[orders].goodsid,[orders].num,[goods].marketprice*[orders].num as total from [orders] left OUTER JOIN [goods] on [orders].goodsid=[goods].goodsid where [orders].loginName='<<yh1>>'
	ENDTEXT
 	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF
    RETURN cursortojson("tmp")
  ENDPROC   
  
  PROCEDURE all_orders && 显示全部订单-------------------------
    yh1 = httpqueryparams("phone")

	TEXT TO lcSQLCmd NOSHOW TEXTMERGE
	    SELECT orderNo,status,SUM(totalmoney) as totalmoney from [orders] where loginName='<<yh1>>' GROUP BY orderNo,status
	ENDTEXT
 	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF
    RETURN cursortojson("tmp")
  ENDPROC   

  PROCEDURE dfh_orders && 显示待发货-------------------------
    yh1 = httpqueryparams("phone")

	TEXT TO lcSQLCmd NOSHOW TEXTMERGE
	    SELECT orderNo,status,SUM(totalmoney) as totalmoney from [orders] where loginName='<<yh1>>' AND status='待发货' GROUP BY orderNo,status
	ENDTEXT
 	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF
    RETURN cursortojson("tmp")
  ENDPROC 

  PROCEDURE over_orders && 显示确认收货-------------------------
    yh1 = httpqueryparams("phone")

	TEXT TO lcSQLCmd NOSHOW TEXTMERGE
	    SELECT orderNo,status,SUM(totalmoney) as totalmoney from [orders] where loginName='<<yh1>>' AND status='确认收货' GROUP BY orderNo,status
	ENDTEXT
 	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF
    RETURN cursortojson("tmp")
  ENDPROC 

  PROCEDURE addorder && 下单【结算】-------------------------
    yh1 = httpqueryparams("phone")
    dz1 = httpqueryparams("addressid")
    ly1 = httpqueryparams("remark")
    ddh1 = httpqueryparams("orderNo")
*!*	    fjid1 = httpqueryparams("parentid")
    *查询我的收货地址       
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
		UPDATE [orders] SET addressid='<<dz1>>',remark='<<ly1>>',status='已提交上级' WHERE orderNo='<<ddh1>>'
    ENDTEXT
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
      SELECT createtime,goodsname,cash,num FROM [orders] where loginName='<<yh1>>'
    ENDTEXT	
 	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF
    RETURN cursortojson("tmp")
  ENDPROC 
  
ENDDEFINE 

