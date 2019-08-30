DEFINE CLASS ctl_payhtml As Session
Function toPay
	lnOrder=Ttoc(Datetime(),1)
	oPay=Newobject("QiyuPay_ysy","QiyuPay_ysy.prg")
	*oPay.backUrl="http://qiyu.free.idcfengye.com/ctl_notice_ht.fsp"  &&支付回调
	*oPay.frontUrl="http://qiyu.free.idcfengye.com/ctl_notice.fsp"  &&支付完成跳转
	oPay.backUrl="http://193.112.63.140:802/ctl_notice_ht.fsp"  &&支付回调
	oPay.frontUrl="http://193.112.63.140:802/ctl_notice.fsp"  &&支付完成跳转
	lcOrder=Ttoc(Datetime(),1)  &&订单号不能重复,最好到毫秒	
	yh1 = httpqueryparams("phone")
	lnje = VAL(httpqueryparams("money"))
	lnje1 = lnje*100 && 付款金额
	payurl=oPay.YSY_H5Pay(lcOrder,"商品",lnje1,"509595572980001","56fc7ecf68862a976317417bcc35f575")  &&蒂拉
	
	TEXT TO lchtml NOSHOW TEXTMERGE PRETEXT 1+2

		<!DOCTYPE html>
		<html>
			<head>
				<meta charset="UTF-8">
				<meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=1,maximum-scale=1,user-scalable=no" />
				<title>支付</title>
				<style>
					body {font-family: 'Helvetica Neue',Helvetica,sans-serif;font-size: 17px;line-height: 21px;color: #000;background-color: #efeff4;-webkit-overflow-scrolling: touch;}
					a{text-decoration:none;}					
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
				<div class="mui-content">
					<ul class="mui-table-view">
						<li class="mui-table-view-cell">用户:
							<<yh1>></li>
						<li class="mui-table-view-cell">订单号:
							<<lcOrder>></li>
						<li class="mui-table-view-cell">金额:
							<<lnje>></li>
					</ul>
					<a href=" >>" class="mui-btn mui-btn-pink"> 支付 </a>
				</div>
			</body>
		</html>

	ENDTEXT
        

    
	Return lchtml
Endfunc

Enddefine
