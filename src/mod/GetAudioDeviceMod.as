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

#deffunc GetAudioDevice str ffmpegpath, var output

	sdim output, 1024*4

	if (ffmpegpath == ""): return

	sdim buf, 1024*10
	sdim buf1, 1024*10
	sdim buf2, 1024*10

	cmdm = strf("%s -list_devices true -f dshow -i audio", ffmpegpath)

	pipe2exec cmdm
	pid = stat
	if(pid == -1): dialog "実行失敗": return

	repeat
		pipe2check pid
		if stat & 2: pipe2get pid, buf: buf1 + = buf
		if stat & 4: pipe2err pid, buf: buf2 + = buf
		if (stat == 0): break

		wait 10
	loop

	pipe2term pid

	if strlen(buf1) != 0: buf = buf1
	if strlen(buf2) != 0: buf = buf2

	sdim tempBuf, 1024*10

	notesel buf
	repeat notemax
		noteget temp, cnt
		if (strmid(temp, 0, 1) == "["){
			getstr temp, temp, instr(temp, 0, "] ")+2, 0
			if (strmid(temp, 0, 2) == " \""){
				getstr temp, temp, instr(temp, 0, "\"")+1, '\"'
				tempBuf + = temp+"\n"
			}
		}
	loop

	output = tempBuf
return

#global
