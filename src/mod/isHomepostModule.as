#ifndef ChangeBitmapDepth
	#include "../lib/ChangeBitmapDepth.as"
#endif
#ifndef PerceptualHashMod
	#include "../lib/PerceptualHashMod.as"
#endif

// isHomeportMod
// 艦これのキャプチャから母港か否かを判定する
#module isHomeportMod

    //isHomeport_init
	//モジュールの初期化命令
	#deffunc local init int wndId

		homeportBufId = wndId
		basisDHash = 0x00988e66, 0x71888e46

		sxRatio = 1.0* (1092)/BASE_SIZE_W
		syRatio = 1.0* (46)	 /BASE_SIZE_H
		wRatio =  1.0* (30)  /BASE_SIZE_W
		hRatio =  1.0* (50)	 /BASE_SIZE_H

		//できるだけ高速に動作させるためバッファの初期化を先に行う
		buffer homeportBufId, 8, 9
		chgbm 32
		mref homeportVram, 66

		dim dHash, 2

	return

	#defcfunc local isHomeport int wndId, int sw_, int sh_

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
		pos 0, 0
		gzoom 8, 8, wndId, int(sxRatio*sx+0.5), int(syRatio*sy+0.5), int(wRatio*sx+0.5), int(hRatio*sy+0.5), 1

		gsel nid
		CmptDHash dHash, homeportVram

	return HammingDist(dHash, basisDHash)<16

#global
