
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


//ƒx[ƒX AverageHash6.hsp
#module

	#deffunc isHomeport_init int wndId

		homeportBufId = wndId
		homeportArr = 0,0,1,0,0,0,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,1,1,1,0,0,1,1,0,0
		homeportArrLen = length(homeportArr)
	
		wRatio = 0.03125
		hRatio = 0.0625
		sx1Ratio = 0.821875
		sx2Ratio = 0.9125
		syRatio = 0.067709


	return

	#defcfunc isHomeport int wndId

		nid = ginfo(3)

		buffer homeportBufId, 10, 3
		chgbm 32
		mref homeportVram, 66

		avg = 0
		dim arr, 24

		gsel wndId
		sx = ginfo_winx
		sy = ginfo_winy

		gsel homeportBufId
		pos 0,0
		gzoom 5, 3, wndId, int(sx1Ratio*sx), int(syRatio*sy), int(wRatio*sx), int(hRatio*sy), 1
		pos 5,0
		gzoom 5, 3, wndId, int(sx2Ratio*sx), int(syRatio*sy), int(wRatio*sx), int(hRatio*sy), 1
		
		repeat homeportArrLen
			arr(cnt) = (( (homeportVram(cnt)&0xFF)*29 + ((homeportVram(cnt)>>8)&0xFF)*150 + ((homeportVram(cnt)>>16)&0xFF)*77 ) >> 8) & 0xFF
			avg += arr(cnt)
		loop

		avg /= homeportArrLen

		count = 0
		repeat homeportArrLen
			 if (avg < arr(cnt)) != homeportArr(cnt):count++
		loop

		gsel nid

		if (count < 4){
			return 1
		} else {
			return 0
		}

#global

/*

	screen 0


	loadArr = "40", "n1", "n2", "n3", "100+" 

	isHomeport_init 2

	repeat length(loadArr)
		buffer 1
		picload loadArr(cnt)+".png"
		gsel 0
		mes isHomeport(1)
	loop
//*/