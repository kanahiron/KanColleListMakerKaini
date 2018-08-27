// ChangeBitmapDepth モジュール
// HSPの24bitなbitmapをnbitに変換する(n = 8, 24, 32)
// 24bit以外のビッド深度は一部標準命令が使用不能(gzoomなど)

#module ChangeBitmapDepth

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
	if (bpp==0){
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
		CreateDIBSection 0, bm(6), 0, varptr(bm(5)), 0, 0
		hnewbm = stat
	}
	SelectObject hdc, hnewbm
	DeleteObject bm(7)
	bm(7)=hnewbm
	bm(67)=(bm(1)*bpp+31)/32*4
	bm(16)=bm(67)*bm(2)
return
#global
