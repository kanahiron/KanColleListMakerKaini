
#ifndef chgbm

#module

#uselib	"user32.dll"
#func GetDC "GetDC" int
#func ReleaseDC "ReleaseDC" int,int

#uselib "gdi32.dll"
#func CreateDIBSection "CreateDIBSection" int,int,int,int,int,int
#func CreateCompatibleBitmap "CreateCompatibleBitmap" int,int,int
#func SelectObject "SelectObject" int,int
#func DeleteObject "DeleteObject" int 

#deffunc chgbm int bpp
	mref bm,67
	if bpp==0{
		GetDC 0
		hdisp=stat
		CreateCompatibleBitmap hdisp, bm.1, bm.2
		hnewbm=stat
		ReleaseDC 0,hdisp
		bm.5=0
	}else{
		dupptr bminfo,bm.6,40
		wpoke bminfo,14,bpp
		bminfo.5=0
		CreateDIBSection 0,bm.6,0,varptr(bm.5),0,0
		hnewbm=stat
	}
	SelectObject hdc,hnewbm
	DeleteObject bm.7
	bm.7=hnewbm
	bm.67=(bm.1*bpp+31)/32*4
	bm.16=bm.67*bm.2
return
#global

#endif


//ÉxÅ[ÉX AverageHash6.hsp
#module

	#deffunc isHomeport_init int wndId

		homeportBufId = wndId
		basisAHash = 25663381, -1212828160

		sxRatio = 1.0* (280)/800
		syRatio = 1.0* (41)	/480
		wRatio =  1.0* (240)/800
		hRatio =  1.0* (20)	/480

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