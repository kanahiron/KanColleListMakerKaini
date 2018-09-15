//#include "hsp3utf.as"

#ifndef __hsp3utf__
	dialog "このモジュールはHSP3utfが必要です。\nメインソースでincludeしてください。\n\nモジュール:FFMPEGLog",1,"終了します"
	end
#endif

#module FFMPEGLog_mod

#undef sendmsg@FFMPEGLog_mod

#uselib "user32.dll"
#func GetWindowLong "GetWindowLongW" int, int
#func SetWindowLong "SetWindowLongW" int, int, int
#func sendmsg "SendMessageW" int, int, int, int
#func ShowWindow "ShowWindow" int, int

#uselib "kernel32.dll"
#func MultiByteToWideChar "MultiByteToWideChar" int, int, int, int, int, int

#define ES_AUTOVSCROLL	0x0040

#define WM_SETTEXT		0x000C
#define EM_LINESCROLL	0x00B6
#define EM_GETLINECOUNT	0x00BA

#deffunc MakeFFMPEGLogWindow int wndID

	screen wndID, 1024, 900, 2
	hffWindow = hwnd

	title@hsp "FFMPEGLogWindow"

	ffLogVideo = ""
	ffLogAudio = ""
	ffLogEncode = ""
	mesbox ffLogVideo, 1024, 300
	hFfLogVideo = objinfo_hwnd(stat)
	mesbox ffLogAudio, 1024, 300
	hFfLogAudio = objinfo_hwnd(stat)
	mesbox ffLogEncode, 1024, 300
	hFfLogEncode = objinfo_hwnd(stat)

	sdim vInBuf, 4096
	sdim aInBuf, 4096
	sdim eInBuf, 4096
	sdim wideCharBuf, 4096

return

#deffunc ResetFFMPEGLog

	ffLogVideoBufSize = 4096
	ffLogAudioBufSize = 4096
	ffLogEncodeBufSize  = 4096
	ffLogVideoSize = 0
	ffLogAudioSize = 0
	ffLogEncodeSize  = 0
	sdim ffLogVideo, ffLogVideoBufSize+2
	sdim ffLogAudio, ffLogAudioBufSize+2
	sdim ffLogEncode, ffLogEncodeBufSize+2

	sendmsg hFfLogVideo, WM_SETTEXT, 0, varptr(ffLogVideo)
	sendmsg hFfLogAudio, WM_SETTEXT, 0, varptr(ffLogAudio)
	sendmsg hFfLogEncode, WM_SETTEXT, 0, varptr(ffLogEncode)

return


#define global  AddFFMPEGLog( %1="", %2="", %3="") addFFMPEGLog_ %1, %2, %3
#deffunc AddFFMPEGLog_ str vStr, str aStr, str eStr

	if (vInBuf != vStr){
		vInBuf = vStr
		addSize = MultiByteToWideChar( 65001, 0, varptr(vInBuf), strlen(vInBuf), 0, 0)*2
		if (addSize) {

			if ( (ffLogVideoSize+addSize) > ffLogVideoBufSize ){
				ffLogVideoBufSize += addSize*2
				memexpand ffLogVideo, ffLogVideoBufSize+2
			}
			MultiByteToWideChar 65001, 0, varptr(vInBuf), strlen(vInBuf)+1, varptr(ffLogVideo)+ffLogVideoSize, addSize+2
			ffLogVideoSize += addSize

			sendmsg hFfLogVideo, WM_SETTEXT, 0, varptr(ffLogVideo)
			sendmsg hFfLogVideo, EM_LINESCROLL, 0, sendmsg(hFfLogVideo, EM_GETLINECOUNT, 0, 0)
		}
	}

	if (aInBuf != aStr){
		aInBuf = aStr
		addSize = MultiByteToWideChar( 65001, 0, varptr(aInBuf), strlen(aInBuf), 0, 0)*2
		if (addSize) {
			if ( (ffLogAudioSize+addSize) > ffLogAudioBufSize ){
				ffLogAudioBufSize += addSize*2
				memexpand ffLogAudio, ffLogAudioBufSize+2
			}
			MultiByteToWideChar 65001, 0, varptr(aInBuf), strlen(aInBuf)+1, varptr(ffLogAudio)+ffLogAudioSize, addSize+2
			ffLogAudioSize += addSize

			sendmsg hFfLogAudio, WM_SETTEXT, 0, varptr(ffLogAudio)
			sendmsg hFfLogAudio, EM_LINESCROLL, 0, sendmsg(hFfLogAudio, EM_GETLINECOUNT, 0, 0)
		}
	}

	if (eInBuf != eStr){
		eInBuf = eStr
		addSize = MultiByteToWideChar( 65001, 0, varptr(eInBuf), strlen(eInBuf), 0, 0)*2
		if (addSize) {
			if ( (ffLogEncodeSize+addSize) > ffLogEncodeBufSize ){
				ffLogEncodeBufSize += addSize*2
				memexpand ffLogEncode, ffLogEncodeBufSize+2
			}
			MultiByteToWideChar 65001, 0, varptr(eInBuf), strlen(eInBuf)+1, varptr(ffLogEncode)+ffLogEncodeSize, addSize+2
			ffLogEncodeSize += addSize

			sendmsg hFfLogEncode, WM_SETTEXT, 0, varptr(ffLogEncode)
			sendmsg hFfLogEncode, EM_LINESCROLL, 0, sendmsg(hFfLogEncode, EM_GETLINECOUNT, 0, 0)
		}
	}
return

#deffunc ShowFFMPEGLog
	ShowWindow hffWindow, 5
return

#deffunc HideFFMPEGLog
	ShowWindow hffWindow, 0
return

#defcfunc GetVideoStartTime
	ddim time, 1
	sdim tbuf
	tbuf = cnvwtos(ffLogVideo)
	timeStrIndex = instr(tbuf, 0, "Duration: N/A, start: ")
	if ( timeStrIndex != -1){
		TimeStr = ""
		getstr TimeStr, tbuf, timeStrIndex+22, ' '
		time = double(TimeStr)
	}
	dim tbuf //メモリ使用を抑えるため
return time

#defcfunc GetAudioStartTime
	ddim time, 1
	sdim tbuf
	tbuf = cnvwtos(ffLogAudio)
	timeStrIndex = instr(tbuf, 0, "Duration: N/A, start: ")
	if ( timeStrIndex != -1){
		TimeStr = ""
		getstr TimeStr, tbuf, timeStrIndex+22, ' '
		time = double(TimeStr)
	}
	dim tbuf //メモリ使用を抑えるため
return time

#global

#if 0

	MakeFFMPEGLogWindow
	ResetFFMPEGLog

	//ShowFFMPEGLog
	pants = "ぱんつぱんつぱんつぱんつ"

	repeat

		addFFMPEGLog pants+cnt+"\n", pants+"ぱんつ！\nぱんつ！！ "+cnt+"\n", pants+"ぱんつ\nぱんつ！\nぱんつ！！ "+cnt+"\n"
		await

	loop

#endif
