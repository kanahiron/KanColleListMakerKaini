#include "modclbk3.hsp"

//！注意！
//mesboxは1つしか設置できません！
#module TweetEditBoxMod
#uselib "user32.dll"
#func GetWindowLong "GetWindowLongW" wptr,wptr
#func SetWindowLong "SetWindowLongW" wptr,wptr,wptr
#func CallWindowProc "CallWindowProcW" wptr,wptr,wptr,wptr,wptr
#func GetKeyboardState "GetKeyboardState" wptr
#func sendmsg "SendMessageW" int, int, int, int
#func postmsg "PostMessageW" int, int, int, int

#define WM_CHAR			0x0102

#define EM_SETSEL		0x00B1

#define GWL_EXSTYLE		-20
#define GWL_STYLE		-16
#define GWL_WNDPROC		0xFFFFFFFC

#define VK_RETURN	0x0D
#define VK_CONTROL	0x11
#define WS_EX_CLIENTEDGE 0x00000200

#define SetTweetEditBox( %1, %2, %3, %4, %5=1, %6=-1) _SetTweetEditBox@TweetEditBoxMod %1, %2, %3, %4, %5, %6
#deffunc local _SetTweetEditBox var tweetText, int sizew, int sizeh, int messageID_, int style, int len

	hwnd@TweetEditBoxMod = hwnd
	messageID = messageID_
	wordCount = 0
	dim kbState, 64

	mesbox tweetText, sizew, sizeh, style, len
	tMBid = stat
	hEditControl = objinfo_hwnd(tMBid)

	newclbk3 pEditControlProc, 4, *OnEditControlProc
	pDefEditControlProc = GetWindowLong(hEditControl, GWL_WNDPROC)
	SetWindowLong hEditControl, GWL_WNDPROC, pEditControlProc

return tMBid

#deffunc DelTweetEditBox onexit
	SetWindowLong hEditControl, GWL_WNDPROC, pDefEditControlProc
return

*OnEditControlProc
	clbkargprotect args

	if (args(0) == hEditControl){
		if (args(1) == WM_CHAR){
			if (GetKeyboardState(varptr(kbState))){
				// Ctrl+Enter
				if ( (peek(kbState, VK_RETURN)&0x80) == 0x80 && (peek(kbState, VK_CONTROL)&0x80) == 0x80){
					sendmsg hwnd@TweetEditBoxMod, messageID, 0, 0
					return 1
				}
				// Ctrl+A
				if ( (peek(kbState, 'A')&0x80) == 0x80 && (peek(kbState, VK_CONTROL)&0x80) == 0x80){
					sendmsg hEditControl, EM_SETSEL, 0, -1
					return 1
				}
			}
		}
	}

return CallWindowProc( pDefEditControlProc, args(0), args(1) ,args(2), args(3))
#global

#if 0

#include "HSP3utf.as"
#define WM_TWEET 0x8001

	screen 0: title ""+hwnd
	objmode 2
	font "メイリオ", 13

	screen 1: title ""+hwnd
	oncmd gosub *tweet, WM_TWEET

	sdim tweetText, 1024
	SetTweetEditBox@TweetEditBoxMod tweetText, 640, 100, WM_TWEET

	stop

*tweet
	pos 0, 100
	color 255, 255, 255: boxf: color
	mes "「"+tweetText+"」"
return
#endif
