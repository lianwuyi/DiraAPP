*-- 后台回调,这里才是真正支付成功回写
*后台接收URL
*bankType%3DDEBIT%26busicd%3DWPAY%26channelOrderNum%3D4200000318201905301881957549%26charset%3Dutf-8%26chcd%3DWXP%26chcdDiscount%3D0.00%26consumerAccount%3DoEd856As8FcMrWzumDA1RJkv6LvU%26errorDetail%3DSUCCESS%26inscd%3D95091888%26mchntid%3D509595572980001%26orderNum%3D20190530234931%26payTime%3D2019-05-30+23%3A49%3A58%26respcd%3D00%26signType%3DSHA256%26terminalid%3D00000001%26transTime%3D2019-05-30+23%3A49%3A52%26txamt%3D000000000001%26txndir%3DA%26version%3D2.3.5%26voucherOrderNum%3D108920190530234953275971932uze%26sign%3D8fa5d25bc932e9eae9452b3250450bcc673b5711cdf4bf7bd5b0cd0d8e00e827
*后台接收url解码
*bankType=DEBIT&busicd=WPAY&channelOrderNum=4200000318201905301881957549&charset=utf-8&chcd=WXP&chcdDiscount=0.00&consumerAccount=oEd856As8FcMrWzumDA1RJkv6LvU&errorDetail=SUCCESS&inscd=95091888&mchntid=509595572980001&orderNum=20190530234931&payTime=2019-05-30 23:49:58&respcd=00&signType=SHA256&terminalid=00000001&transTime=2019-05-30 23:49:52&txamt=000000000001&txndir=A&version=2.3.5&voucherOrderNum=108920190530234953275971932uze&sign=8fa5d25bc932e9eae9452b3250450bcc673b5711cdf4bf7bd5b0cd0d8e00e827
*-- channelOrderNum为实际支付订单
*-- 其他字段根据实际情况写入

Define Class ctl_notice_ht As Session
    *-- 用于支付回调
	Procedure onDefault		
		channelOrderNum=HttpQueryParams("channelOrderNum")
		*?channelOrderNum  &&写库
		OrderNum1=HttpQueryParams("orderNum")
		*?OrderNum1

		*将消费表记录修改为成功
	    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
		  UPDATE [moneys] SET issuccess = 1 WHERE orderNum='<<OrderNum1>>'
		ENDTEXT
		oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
		IF oDBSQLhelper.ExeCuteSQL(lcSQLCmd)<0
		  ERROR oDBSQLHelper.errmsg
		ENDIF    
		*修改用户表
		TEXT TO lcSQLCmd NOSHOW TEXTMERGE
	      SELECT loginName,money from [moneys] where orderNum='<<OrderNum1>>'
	    ENDTEXT
 	    oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
 	    IF oDBSQLhelper.SQLQuery(lcSQLCmd,"tmp")<0
	      ERROR oDBSQLhelper.errmsg
	    ENDIF 
        SELECT tmp
        GO TOP 
        yh1 = ALLTRIM(loginName)
        je1 = money
        
	    DO CASE 
	      CASE je1 = 299
	      cs1 = 10
	      CASE je1 = 1280
	      cs1 = 50
	      CASE je1 = 5380
	      cs1 = 999
	    ENDCASE 
	    *修改用户余额表  共享消费不显示金额，只显示次数
	    TEXT TO lcSQLCmd1 NOSHOW TEXTMERGE
		  UPDATE [user] SET times=times+<<cs1>> where loginName='<<yh1>>'
		ENDTEXT
		IF oDBSQLhelper.ExeCuteSQL(lcSQLCmd1)<0
		  ERROR oDBSQLHelper.errmsg
		ENDIF   
        RETURN '{"errno":0,"errmsg":"ok"}'
        
	ENDPROC

ENDDEFINE
