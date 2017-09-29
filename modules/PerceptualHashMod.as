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
	mref bm, 67
	if (bpp == 0){
		GetDC 0
		hdisp = stat
		CreateCompatibleBitmap hdisp, bm(1), bm(2)
		hnewbm = stat
		ReleaseDC 0, hdisp
		bm(5) = 0
	}else{
		dupptr bminfo, bm(6), 40
		wpoke bminfo, 14, bpp
		bminfo(5) = 0
		CreateDIBSection 0, bm(6) , 0, varptr(bm(5)), 0, 0
		hnewbm=stat
	}
	SelectObject hdc, hnewbm
	DeleteObject bm(7)
	bm(7) = hnewbm
	bm(67) = (bm(1)*bpp+31)/32*4
	bm(16) = bm(67)*bm(2)
return
#global
#endif

#module

#defcfunc PopCnt int _bit

	num = _bit

	num = (num & 0x55555555) + (num >> 1 & 0x55555555)
    num = (num & 0x33333333) + (num >> 2 & 0x33333333)
    num = (num & 0x0f0f0f0f) + (num >> 4 & 0x0f0f0f0f)
    num = (num & 0x00ff00ff) + (num >> 8 & 0x00ff00ff)
    
return (num & 0x0000ffff) + (num >>16 & 0x0000ffff)

#define global ctype HammingDist( %1, %2) PopCnt(%1(0) xor %2(0)) + PopCnt(%1(1) xor %2(1))


#deffunc CmptDHash array hash, array vram

	dim hash, 2

	pLum = (( (vram(0)&0xFF)*18 + ((vram(0)>>8)&0xFF)*158 + ((vram(0)>>16)&0xFF)*80 ) >> 8) & 0xFF

	repeat 64
		lum = (( (vram(cnt+1)&0xFF)*18 + ((vram(cnt+1)>>8)&0xFF)*158 + ((vram(cnt+1)>>16)&0xFF)*80 ) >> 8) & 0xFF
		hash(cnt/32) <<= 1
		hash(cnt/32) |= (pLum > lum)
		pLum = lum
	loop

return

#deffunc CmptAHash array hash, array vram

	dim hash, 2
	dim tCol, 64
	avgCol = 0

	repeat 64
		tCol(cnt) = (( (vram(cnt+1)&0xFF)*18 + ((vram(cnt+1)>>8)&0xFF)*158 + ((vram(cnt+1)>>16)&0xFF)*80 ) >> 8) & 0xFF
		avgCol += tCol(cnt)
	loop

	avgCol /= 64
	
	repeat 64
		hash(cnt/32) <<= 1
		hash(cnt/32) |= (tCol(cnt) > avgCol)
	loop

	dim tCol, 0
return



#global