#ifndef mod_execconsole
    #include "pipe2_utf.as"
#endif

#module unzipMod

#ifndef TRUE
    #define TRUE 1
    #define FALSE 0
#endif

    chkFlg = FALSE
    unzipAvailFlg = FALSE

    #defcfunc unzipChk
        logmes "unzipChk_start"
        sdim buf, 256
        sdim buf_, 256
        pipe2exec "PowerShell $PSVersionTable.PSVersion.Major"
        pid = stat
        if(pid == -1): return FALSE
        repeat 20
            pipe2check pid
            if (stat & 2): pipe2get pid, buf_: buf += buf_
            if (stat == 0):break
            wait 10
        loop
        pipe2term pid
        pid = 0

        PSMajorVer = int(buf)
        PSMajorVer = 9
        dim buf
        dim buf_

return (PSMajorVer>=5)

#deffunc unzip str zippath

    if (chkFlg==FALSE){
        chkFlg = TRUE
        unzipAvailFlg = unzipChk()
    }
    if (unzipAvailFlg==FALSE){
        return -1
    }

    sdim buf, 1024*10
    pipe2exec strf("PowerShell Expand-Archive -Path \"%s\" -Force", zippath)

    pid = stat
    if(pid == -1): dim buf: return -2
    unzipFlg = 0
    repeat 100
        pipe2check pid
        if (stat == 0){
            unzipFlg = 1
            break
        }
        wait 10
    loop
    pipe2term pid

    if (unzipFlg==0){
        dim buf
        return -2
    }
return 0

#global
