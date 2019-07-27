* 生成远程桌面连接文件
Local lcRDPFile, lcRDPString, lcServer, lcLogin, lcPass, lcDoMain, lcRun
m.lcRDPFile = Addbs(Justpath(Sys(16,1))) + "RemoteDesktop.rdp"
m.lcServer = "125.93.50.26" && 远程服务器IP
m.lcLogin = "administrator"
m.lcPass ="19880628"
m.lcDoMain = ""
m.lcRun = "D:\program Files\VFP9\vfp9.exe"

m.lcRDPString = ""

TEXT To m.lcRDPString Additive Textmerge Noshow
screen mode id:i:2
desktopwidth:i:1024
desktopheight:i:768
session bpp:i:16
winposstr:s:0,1,78,15,878,615
full address:s:<<m.lcServer>>
compression:i:1
keyboardhook:i:2
audiomode:i:0
redirectdrives:i:0
redirectprinters:i:1
redirectcomports:i:0
redirectsmartcards:i:1
displayconnectionbar:i:0
autoreconnection enabled:i:1
authentication level:i:0
username:s:<<m.lcLogin>>
domain:s:<<m.lcDoMain>>
alternate shell:s:<<m.lcRun>>
shell working directory:s:
password <<GetRdpPassword(m.lcPass)>>
disable wallpaper:i:1
disable full window drag:i:0
disable menu anims:i:0
disable themes:i:1
disable cursor setting:i:0
bitmapcachepersistenable:i:1
ENDTEXT

If Strtofile(m.lcRDPString,m.lcRDPFile) > 0
    #Define SW_SHOW 5
    Declare Integer WinExec In Kernel32 String, Integer
    = WinExec([mstsc.exe "]+m.lcRDPFile+["], SW_SHOW)
Endif

Return 

Procedure GetRdpPassword(tcString)

    #Define CRYPTPROTECT_LOCAL_MACHINE    4 && RtlMoveMemory

    Declare Integer CryptProtectData In crypt32 ;
        String  pDataIn_DATA_BLOB, ;
        integer szDataDescr, ;
        Integer pOptionalEntropy_DATA_BLOB, ;
        Integer pvReserved, ;
        Integer pPromptStruct_CRYPTPROTECT_PROMPTSTRUCT, ;
        Integer dwFlags, ;
        String @  pDataOut_DATA_BLOB
    Declare integer LocalAlloc in win32api integer ,integer 
    Declare Integer LocalFree In win32api Integer

Local nLen,cInStr,cOutStr,cRetStr
Local hData,hOutData

    tcString=Strconv(tcString,5)
    nLen=Len(tcString)
    hData=LocalAlloc(0,nLen)
    Sys(2600,hData,nLen,tcString) &&copy to stack
    
    cInStr=BinToC(nLen,"4rs") + BinToC(hData,"4rs")
    cOutStr=Replicate(Chr(0),8)
    If CryptProtectData(cInStr, 0, 0, 0, 0, CRYPTPROTECT_LOCAL_MACHINE, @cOutStr) <> 0
        nLen=CToBin(Left(cOutStr,4),"4rs")
        hOutData=CToBin(right(cOutStr,4),"4rs")

        cRetStr=Sys(2600,hOutData,nLen) &&get from stack
        LocalFree(hOutData) 
    Else
        MessageBox("error")
    EndIf 
    LocalFree(hData) 
    
    Return "51:b:"+Strconv(cRetStr,15)
EndProc