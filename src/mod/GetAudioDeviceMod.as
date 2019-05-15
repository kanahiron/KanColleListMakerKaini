#ifndef mod_execconsole
    #include "../lib/pipe2_utf.as"
#endif

// GetAudioDeviceMod
// ffmpegを利用してオーディオデバイスの一覧を取得する

// 命令
// GetAudioDevice str p1, var p2
// オーディオデバイスの一覧を取得
// p1 - ffmpegのパス
// p2 - str型の改行区切りで返されるオーディオデバイスの一覧
#module "GetAudioDeviceMod"

#ifndef timeGetTime
#uselib "winmm.dll"
#func timeGetTime "timeGetTime"
#endif

#ifndef CharLower
#uselib "user32.dll"
#func CharLower "CharLowerW" wptr
#endif

#deffunc GetAudioDevice str ffmpegpath, var output, local pid, local buf, local tBuf1

	if (ffmpegpath == ""): return -1

    sdim output, 1024
	sdim buf, 1024*10
	sdim tBuf, 1024*4 //汎用一時変数

    cmdm = strf("%s -list_devices true -f dshow -i audio", ffmpegpath)

	pipe2exec cmdm
	pid = stat
	if (pid==-1): return -1 //実行に失敗した

    timelimit = timeGetTime() + 1500 //1.5秒でループから抜けるようにする
    do
        pipe2check pid
        if (stat&2): pipe2get pid, tBuf: buf += tBuf
        if (stat&4): pipe2err pid, tBuf: buf += tBuf
        if (stat==0): _break
        await 100
	until (timelimit < timeGetTime())

	pipe2term pid

    //オーディオデバイス名抽出処理
    tBuf = strmid(buf, 0, 6) //ffmpegの出力から頭6Byte取得
    cnvstow tBuf, tBuf
    CharLower varptr(tBuf) //unicode版CharLowerを使いたいがためにこんな冗長に…
    tBuf = cnvwtos(tBuf)
    if tBuf != "ffmpeg": return -1 //実行ファイルがffmpegではなかった

	notesel buf
	repeat notemax
		noteget tBuf, cnt //tBufを使い回す
		if (strmid(tBuf, 0, 1) == "["){
			getstr tBuf, tBuf, instr(tBuf, 0, "] ")+2, 0
			if (strmid(tBuf, 0, 2) == " \""){
				getstr tBuf, tBuf, instr(tBuf, 0, "\"")+1, '\"'
				output + = tBuf+"\n"
			}
		}
	loop
return 0

#global
