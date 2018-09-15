#ifndef ChangeBitmapDepth
	#include "../lib/ChangeBitmapDepth.as"
#endif
#ifndef PerceptualHashMod
	#include "../lib/PerceptualHashMod.as"
#endif

// isHomeportModule
// 艦これのキャプチャから母港か否かを判定する
#module

    //isHomeport_init
	//モジュールの初期化命令
	#deffunc isHomeport_init int wndId

		homeportBufId = wndId
		basisAHash = 25663381, -1212828160

		sxRatio = 1.0* (280)/800
		syRatio = 1.0* (41)	/480
		wRatio =  1.0* (240)/800
		hRatio =  1.0* (20)	/480

		//できるだけ高速に動作させるためバッファの初期化を先に行う
		buffer homeportBufId, 8, 9
		chgbm 32
		mref homeportVram, 66

	return

	#defcfunc isHomeport int wndId, int sw_, int sh_

		nid = ginfo(3)

		if (sw_ == 0 |  sh_ == 0){
			gsel wndId
			sx = ginfo_winx
			sy = ginfo_winy
		} else {
			sx = sw_
			sy = sh_
		}

		gsel homeportBufId
		pos 0, 1
		gzoom 8, 8, wndId, int(sxRatio*sx), int(syRatio*sy), int(wRatio*sx), int(hRatio*sy), 1

		gsel nid

		CmptAHash aHash, homeportVram
		dist = HammingDist(aHash, basisAHash)

		if (dist < 16){
			return 1
		} else {
			return 0
		}

#global
