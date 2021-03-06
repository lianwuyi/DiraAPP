DEFINE CLASS ctl_payhtml As Session
  Function toPay
	lnOrder=Ttoc(Datetime(),1)+ALLTRIM(STR(SECONDS()*1000)) && 订单号到毫秒
	oPay=Newobject("QiyuPay_ysy","QiyuPay_ysy.prg")
	oPay.backUrl="http://193.112.63.140:802/ctl_notice_ht.fsp"  &&支付回调
	oPay.frontUrl="http://193.112.63.140:802/ctl_notice.fsp"  &&支付完成跳转
	
	*lcOrder=Ttoc(Datetime(),1)+ALLTRIM(STR(SECONDS()*1000))  &&订单号不能重复,最好到毫秒	
	*?lnOrder
	yh1 = httpqueryparams("phone")
	lnje = VAL(httpqueryparams("money"))
	lnje1 =1 && lnje*100 && 付款金额
	payurl=oPay.YSY_H5Pay(lnOrder,"商品",lnje1,"509595572980001","56fc7ecf68862a976317417bcc35f575")  &&蒂拉
	
	    **添加消费记录
	    TEXT TO lcSQLCmd NOSHOW TEXTMERGE
	      INSERT INTO [moneys] (datasrc,type,money,loginName,createtime,ordernum) VALUES (1,1,<<lnje>>,'<<yh1>>',getdate(),'<<lnOrder>>')
	    ENDTEXT
	    oDBSQLhelper=NEWOBJECT("MSSQLhelper","MSSQLhelper.prg")
	    IF oDBSQLhelper.ExeCuteSQL(lcSQLCmd)<0
	      ERROR oDBSQLHelper.errmsg
	    ENDIF 
	    
	TEXT TO lchtml NOSHOW TEXTMERGE 
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=1,maximum-scale=1,user-scalable=no" />
	<title>支付</title>
	<style>
		body {font-family: 'Helvetica Neue',Helvetica,sans-serif;font-size: 17px;line-height: 21px;color: #000;background-color: #efeff4;-webkit-overflow-scrolling: touch;}
		a{text-decoration:none;}
		.mui-bar-nav {top: 0;-webkit-box-shadow: 0 1px 6px #ccc;box-shadow: 0 1px 6px #ccc;}
		.mui-bar {position: fixed;z-index: 10;right: 0;left: 0;height: 44px;padding-right: 10px;padding-left: 10px;border-bottom: 0;background-color: #f7f7f7;-webkit-box-shadow: 0 0 1px rgba(0,0,0,.85);box-shadow: 0 0 1px rgba(0,0,0,.85);-webkit-backface-visibility: hidden;backface-visibility: hidden;}
		.mui-bar-nav.mui-bar .mui-icon {margin-right: -10px;margin-left: -10px;padding-right: 10px;padding-left: 10px;}
		.mui-bar.mui-bar-nav a{color: #dfd1ae;}
		.mui-bar.mui-bar-nav a, .mui-bar.mui-bar-nav h1, .mui-bar.mui-bar-nav h5, .mui-bar.mui-bar-nav input {color: #dfd1ae;}
		.mui-icon {font-family: Muiicons;font-size: 24px;font-weight: 400;font-style: normal;line-height: 1;display: inline-block;text-decoration: none;-webkit-font-smoothing: antialiased;}
		.mui-pull-left {float: left;}
		.mui-bar.mui-bar-nav a, .mui-bar.mui-bar-nav h1, .mui-bar.mui-bar-nav h5, .mui-bar.mui-bar-nav input {color: #dfd1ae;}
		.mui-bar .mui-title {right: 40px;left: 40px;display: inline-block;overflow: hidden;width: auto;margin: 0;text-overflow: ellipsis;}
		.mui-title {font-size: 17px;font-weight: 500;line-height: 44px;position: absolute;display: block;width: 100%;margin: 0 -10px;padding: 0;text-align: center;white-space: nowrap;color: #000;}
		/*底部*/
		.mui-bar-nav~.mui-content {padding-top: 44px;}
		.mui-content {background-color: #efeff4;}
		.mui-table-view {position: relative;margin-top: 0;margin-bottom: 0;padding-left: 0;list-style: none;background-color: #fff;}
		.mui-table-view-cell {position: relative;overflow: hidden;padding: 11px 15px;}
		.mui-table-view:before {position: absolute;right: 0;left: 0;height: 1px;content: '';-webkit-transform: scaleY(.5);transform: scaleY(.5);background-color: #c8c7cc;top: -1px;}
		.mui-table-view:after {position: absolute;right: 0;bottom: 0;left: 0;height: 1px;content: '';-webkit-transform: scaleY(.5);transform: scaleY(.5);background-color: #c8c7cc;}
		.mui-table-view-cell:after {position: absolute;right: 0;bottom: 0;left: 15px;right: 15px;height: 1px;content: '';-webkit-transform: scaleY(.5);transform: scaleY(.5);background-color: #c8c7cc;}
		.mui-btn-pink {margin: 11px 27%;color: #fff;border: solid 1px #dfd1ae;background: -webkit-gradient(linear, left top, left bottom, from(#e4d8c8), to(#dfd1ae));}
		.mui-btn{font-size: 14px;font-weight: 400;line-height: 1.42;position: relative;display: inline-block;margin-bottom: 0;padding: 9px 60px;cursor: pointer;transition: all;transition-timing-function: linear;transition-duration: .2s;text-align: center;vertical-align: top;white-space: nowrap;border-radius: 3px;border-top-left-radius: 3px;border-top-right-radius: 3px;border-bottom-right-radius: 3px;border-bottom-left-radius: 3px;}
	</style>
</head>

<body>
	<header class="mui-bar mui-bar-nav">
		<a class="mui-action-back mui-icon mui-icon-left-nav mui-pull-left"></a>
		<h1 class="mui-title">支付</h1>
	</header>
	<div class="mui-content">
		<ul class="mui-table-view">
			<li class="mui-table-view-cell">手机号:<<yh1>></li>
			<li class="mui-table-view-cell">订单号:<<lnOrder>></li>
			<li class="mui-table-view-cell">金额:<<lnje>></li>
		</ul>
		<a href="<<ALLTRIM(payurl)>>" class="mui-btn mui-btn-pink"> 支付 </a>

	</div>
</body>
</html>	
	ENDTEXT
        
	Return lchtml
  ENDFUNC

Enddefine
