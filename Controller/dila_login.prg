* user表
DEFINE CLASS dila_login as Session

  PROCEDURE login && 登录-------------------------
    PRIVATE yh1,mm1
    *** 获取变量
    yh1=httpqueryparams("phone")
    mm1=md5(httpqueryparams("password"))
    *** 查询注册号是否存在
	oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg")
	ss1 = oDBSQLhelper.GetSingle(stringformat("SELECT COUNT(*) FROM [user] WHERE loginName='{1}' and loginPwd='{2}'",yh1,mm1))
    IF ss1>0
      RETURN '{"errno":0,"errmsg":"ok"}'
    ELSE 
      ERROR "密码错误或账户不存在" && '{"errno":1,"errmsg":"密码错误或账户不存在"}'
	ENDIF	
  ENDPROC 

  PROCEDURE register && 注册------------------------
    LOCAL yh1,mm1,yqr1
    *** 获取变量
    yh1=httpqueryparams("tel") 
    mm1=md5(httpqueryparams("password"))
    *** 查询注册号是否保存过
	oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg")
	ss1 = oDBSQLhelper.GetSingle(stringformat("SELECT COUNT(*) FROM [user] WHERE loginName='{1}'",yh1))
	IF ss1>0
	  ERROR "账户已经被注册"
	ENDIF 
	*** 保存数据
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
	  INSERT INTO [user] (loginName,loginPwd,times,createtime) VALUES ('<<yh1>>','<<mm1>>',1,getdate())
	ENDTEXT
	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
	IF oDBSQLhelper.ExeCuteSQL(lcSQLCmd)<0
	  ERROR oDBSQLHelper.errmsg
	ENDIF
	
	*** 生成4位数验证码
	bit4Rand1 = INT(RAND()*9000)+1000 && 4位随机数
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
	  UPDATE [user] SET bit4Rand=<<bit4Rand1>> where loginName='<<yh1>>'
	ENDTEXT
	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
	IF oDBSQLhelper.ExeCuteSQL(lcSQLCmd)<0
	  ERROR oDBSQLHelper.errmsg
	ENDIF 	  	
	
	DO WHILE .T.
	  *** 生成一个随机6位数，并检查是否重复，不重复则变成邀请码
	  sjs1=INT(RAND()*900000)+100000 && 6位随机数
	  oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg")
	  sjsss1 = oDBSQLhelper.GetSingle(stringformat("SELECT COUNT(*) FROM [user] WHERE inviterid='{1}'",sjs1))
	  
	  IF sjsss1=0 && 数据不存在，跳出循环，写入user表里。
	    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
		  UPDATE [user] SET inviterid=<<sjs1>> where loginName='<<yh1>>'
		ENDTEXT
		oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
		IF oDBSQLhelper.ExeCuteSQL(lcSQLCmd)<0
		  ERROR oDBSQLHelper.errmsg
		ENDIF 	  
		EXIT 
	  ENDIF 
	ENDDO 
	
	RETURN '{"errno":0,"errmsg":"ok"}'
  ENDPROC 
  
  PROCEDURE getcode && 获取验证码--------------------
    yh1=httpqueryparams("tel")
    *** 查询用户4位数验证码
	oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg")
	ss2 = oDBSQLhelper.GetSingle(stringformat("SELECT bit4Rand FROM [user] WHERE loginName='{1}'",yh1))
	IF ss2<=0
	  ERROR "验证码获取错误，请联系客服"
	ENDIF 
	
	oXML = Createobject("Microsoft.XMLHTTP")
	*** 设置变量。
	key1 = "5ee2e6487b823965556e"   && 密钥 
	uid1 = "ebong1"               && 登陆账号
	smsMob1  = yh1 && ALLTRIM(thisform.text1.value) && 接收信息的号码    例如："15986989933"
	smsText1 = "尊敬的客户，您的验证码是："+ALLTRIM(STR(ss2))
	*** 发送语句。（与API接口对应）
	lcUrl = "http://gbk.api.smschinese.cn/?"+"Uid="+uid1+"&"+"key="+key1+"&"+"smsMob="+smsMob1+"&"+"smsText="+smsText1
	oXML.Open("POST", lcUrl, .F.)&&  发送语句
	PostData  = " " + Chr(13) + Chr(10)
	oXML.setRequestHeader("Content-Length", Len(PostData))
	oXML.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	oXML.setRequestHeader("Content-type", "text/xml;charset=gb2312")
	oXML.Send(PostData)
	Do While oXML.ReadyState <> 4
	    =Inkey(1)
	ENDDO
	Release oXML
	oXML = Null
	
	RETURN '{"errno":0,"errmsg":"ok"}'
  ENDPROC 
  
  PROCEDURE changepassword && 修改密码------------------------
    PRIVATE yh1,xmm1,zcsr1,yzm1
    *** 获取变量
    yh1=httpqueryparams("tel") 
    yzm1 = VAL(httpqueryparams("code")) && 验证码
    xmm1=md5(httpqueryparams("NewPassword"))
    zcsr1=md5(httpqueryparams("ConfirmPassword"))
    *** 检查密码是否相同
    IF ALLTRIM(xmm1)<>ALLTRIM(zcsr1)
      ERROR "输入的密码不一致"
    ENDIF 
    *** 查询注册号是否保存过
	oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg")
	ss1 = oDBSQLhelper.GetSingle(stringformat("SELECT COUNT(*) FROM [user] WHERE loginName='{1}'",yh1))
	IF ss1<=0
	  ERROR "查找不到该用户"
	ENDIF 
	**************
	**对比验证码
	oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg")
	ss2 = oDBSQLhelper.GetSingle(stringformat("SELECT bit4Rand FROM [user] WHERE loginName='{1}'",yh1))
    IF ALLTRIM(STR(ss2)) <> ALLTRIM(STR(yzm1))
      ERROR "验证码错误，请重新获取或联系客服"
    ENDIF 
	**************
	*** 保存数据
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
	  UPDATE [user] SET loginPwd = '<<xmm1>>' WHERE loginName='<<yh1>>'
	ENDTEXT
	oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
	IF oDBSQLhelper.ExeCuteSQL(lcSQLCmd)<0
	  ERROR oDBSQLHelper.errmsg
	ENDIF
	RETURN '{"errno":0,"errmsg":"ok"}'
  ENDPROC 

ENDDEFINE 