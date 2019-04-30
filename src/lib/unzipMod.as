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

#defcfunc local unzipChk local buf, local buf_, local pid
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
    PSMajorVer = int(buf)
return (PSMajorVer>=5)

#define global unzip(%1, %2="") unzip_@unzipMod %1, %2
#deffunc local unzip_ str zippath, str destpath, local buf, local pid, local cmd

    if (chkFlg==FALSE){
        chkFlg = TRUE
        unzipAvailFlg = unzipChk()
    }
    if (unzipAvailFlg==FALSE){
        return -1
    }

    sdim buf, 1024*10
    cmd = strf("PowerShell Expand-Archive -Path \"%s\"" , zippath)
    if (destpath!=""){
        cmd += strf(" -DestinationPath \"%s\"" , destpath)
    }
    cmd += " -Force"
    pipe2exec cmd
    pid = stat
    if(pid == -1): return -2
    unzipFlg = 0
    repeat 100
        pipe2check pid
        if (stat == 0){
            unzipFlg = 1
            break
        }
        await 100
    loop
    pipe2term pid

    if (unzipFlg==0): return -2
return 0

#global
