DEFINE CLASS dila_machine as Session

  PROCEDURE runmachine  
    *LOCATE zhid1,bh1,sc1,je1,ms1,zh1,my1,fwqbm1,token1,zt1
    *** 获取变量
    yh1=httpqueryparams("phone") && 账户ID
    bh1=httpqueryparams("code")  && 机器编号
    
    *** 从machine 查询机器账户信息-------------------------
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
      SELECT * FROM machine WHERE code='<<bh1>>'
    ENDTEXT
    oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"machine")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF 
    SELECT machine
    GO TOP 
    sc1=timer && 运行时长，值不能超过1440

    *** 从account查询账户信息-------------------------------------
	oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg") 
    IF oDBSQLhelper.SQLQuery("select * from account","account")<0
	  ERROR oDBSQLhelper.errmsg
    ENDIF 
    SELECT account
    GO TOP 
    zh1 = ALLTRIM(account)
    my1 = ALLTRIM(md5key)  && ALLTRIM(MD5(ALLTRIM(key))) && 把密钥用MD5方式加密，
    fwqbm1 = ALLTRIM(num)
    *RETURN cursortojson("account")
    
    *** 查询账户金额是否充足，
	TEXT TO lcSQLCmd NOSHOW TEXTMERGE
      SELECT times FROM [user] WHERE loginName='<<yh1>>'
    ENDTEXT
    oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"user")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF 
    SELECT user
    GO TOP 
    ye1 = times
	IF ye1=0
	  ERROR "账户余额次数不足，请充值"
	ENDIF 

	*** 【获取token】------------------------------------------
	cUrl="https://twwl.sailafeinav.com/shemachineapi/gettoken/"
	xmlhttp=Createobject("Microsoft.XMLHTTP")
	xmlhttp.Open("POST", ALLTRIM(cUrl), .F.)
	xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	xmlhttp.send("account="+zh1+"&key="+my1)
    cJson = xmlhttp.responseText && 将返回来的数据赋值到cJson里
	oJSON=foxjson_parse(cJson)
	token1 = ALLTRIM(oJson.item("token"))	
    *RETURN token1

     *** 【获取机器状态states】------------------------------
	cUrl="https://twwl.sailafeinav.com/shemachineapi/states/"
	xmlhttp=Createobject("Microsoft.XMLHTTP")
	xmlhttp.Open("POST", ALLTRIM(cUrl), .F.)
	xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    xmlhttp.send("token="+token1+"&account="+zh1+"&num="+fwqbm1+"&code="+bh1+"&type=one") 
    cJson1 = xmlhttp.responseText && 将返回来的数据赋值到cJson里  
    *RETURN cjson1
	oJSON1=foxjson_parse(cJson1)
    zt1=ALLTRIM(oJSON1.item("states").item(1))  && 获取状态码
	DO CASE 
	  CASE zt1="run"
	  ERROR "机器正在运行"
	  CASE zt1="noreg"
	  ERROR "机器编号不存在"
	  CASE zt1="error"
	  ERROR "机器没有上线也没有运行"
*!*	      CASE zt1="link" && 
*!*	      ERROR "机器已经上线"
	ENDCASE 

    *** 【启动机器runmachine】-----------------------------------
	cUrl="https://twwl.sailafeinav.com/shemachineapi/runmachine/"
	xmlhttp=Createobject("Microsoft.XMLHTTP")
	xmlhttp.Open("POST", ALLTRIM(cUrl), .F.)
	xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    xmlhttp.send("token="+token1+"&account="+zh1+"&num="+fwqbm1+"&code="+bh1+"&timer="+ALLTRIM(STR(sc1))) 
    cJson2 = xmlhttp.responseText && 将返回来的数据赋值到cJson里 
    * RETURN cJson2 && 成功返回   {"msg":"success","code":1}
	oJSON1=foxjson_parse(cJson2)
    cg1=oJSON1.item("code")  && 获取状态码    

    IF cg1=1
      ** 去user表减数
	  TEXT TO lcSQLCmd1 NOSHOW TEXTMERGE
        UPDATE [user] SET times = times-1 WHERE loginName='<<yh1>>'
      ENDTEXT
	  oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
      IF oDBSQLhelper.ExeCuteSQL(lcSQLCmd1)<0
	    ERROR oDBSQLHelper.errmsg
	  ENDIF

	  ** 添加消费记录
	  TEXT TO lcSQLCmd2 NOSHOW TEXTMERGE
        INSERT INTO moneys (datasrc,moneytype,loginName,code,createtime,type) VALUES (2,0,'<<yh1>>','<<bh1>>',getdate(),0)
      ENDTEXT
	  oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
	  IF oDBSQLhelper.ExeCuteSQL(lcSQLCmd2)<0
	    ERROR oDBSQLHelper.errmsg
	  ENDIF
    
      RETURN '{"errno":0,"errmsg":"ok"}'
    ELSE
      ERROR "开机失败"
    ENDIF 
    
  ENDPROC

  PROCEDURE restartmachine  
    *** 获取变量
    bh1=httpqueryparams("code")  && 机器编号
    
    *** 从machine 查询机器账户信息-------------------------
    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
      SELECT * FROM machine WHERE code='<<bh1>>'
    ENDTEXT
    oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	IF oDBSQLhelper.SQLQuery(lcSQLCmd,"machine")<0
	  ERROR oDBSQLhelper.errmsg
	ENDIF 
    SELECT machine
    GO TOP 
    sc1=0 && timer && 运行时长，值不能超过1440
          
    *** 从account查询账户信息-------------------------------------
	oDBSQLhelper=NEWOBJECT("MSSQLHelper","MSSQLHelper.prg") 
    IF oDBSQLhelper.SQLQuery("select * from account","account")<0
	  ERROR oDBSQLhelper.errmsg
    ENDIF 
    SELECT account
    GO TOP 
    zh1 = ALLTRIM(account)
    my1 = ALLTRIM(md5key)  && ALLTRIM(MD5(ALLTRIM(key))) && 把密钥用MD5方式加密，
    fwqbm1 = ALLTRIM(num)
    *RETURN cursortojson("account")

	*** 【获取token】------------------------------------------
	cUrl="https://twwl.sailafeinav.com/shemachineapi/gettoken/"
	xmlhttp=Createobject("Microsoft.XMLHTTP")
	xmlhttp.Open("POST", ALLTRIM(cUrl), .F.)
	xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	xmlhttp.send("account="+zh1+"&key="+my1)
    cJson = xmlhttp.responseText && 将返回来的数据赋值到cJson里
	oJSON=foxjson_parse(cJson)
	token1 = ALLTRIM(oJson.item("token"))	
    *RETURN token1

    *** 【重启机器restartmachine】-----------------------------------
	cUrl="https://twwl.sailafeinav.com/shemachineapi/runmachine/"
	xmlhttp=Createobject("Microsoft.XMLHTTP")
	xmlhttp.Open("POST", ALLTRIM(cUrl), .F.)
	xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    xmlhttp.send("token="+token1+"&account="+zh1+"&num="+fwqbm1+"&code="+bh1+"&timer="+ALLTRIM(STR(sc1))) 
    cJson2 = xmlhttp.responseText && 将返回来的数据赋值到cJson里 
    * RETURN cJson2 && 成功返回   {"msg":"success","code":1}
	oJSON1=foxjson_parse(cJson2)
    cg1=oJSON1.item("code")  && 获取状态码    
    IF cg1=1
      RETURN '{"errno":0,"errmsg":"ok"}'
    ELSE
      ERROR "重启机器失败"
    ENDIF 
    	    
  ENDPROC

ENDDEFINE 