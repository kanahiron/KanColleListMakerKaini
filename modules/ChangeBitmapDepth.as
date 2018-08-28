/* ChangeBitmapDepth モジュール
 * HSPの24bitなbitmapをnbitに変換する(n = 8, 24, 32)
 * 24bit以外のビッド深度は一部標準命令が使用不能(gzoomなど)
 */
#module ChangeBitmapDepth
	/* WinAPI */
	#uselib	"user32.dll"
		#func GetDC "GetDC" int
		#func ReleaseDC "ReleaseDC" int, int
	#uselib "gdi32.dll"
		#func CreateDIBSection "CreateDIBSection" int, int, int, int, int, int
		#func CreateCompatibleBitmap "CreateCompatibleBitmap" int, int, int
		#func SelectObject "SelectObject" int, int
		#func DeleteObject "DeleteObject" int
	#const NULL 0
	#define DIB_RGB_COLORS	$0000

	/* その他定数 */
	#const MREF_BMSCR 67

	/**
	 *カレントウィンドウのBMSCR構造体について、色深度をbppで指定したものに変更する
	 * @param bpp 色深度(8, 24, 32から選択。0にするとリセット)
	 */
	#deffunc chgbm int bpp
		mref bm, MREF_BMSCR
		if bpp == 0 {
			GetDC NULL
			hDisp = stat
			CreateCompatibleBitmap hDisp, bm(1), bm(2)
			hnewbm = stat
			ReleaseDC NULL, hdisp
			bm(5) = 0
		} else {
			dupptr bmInfo, bm(6), 40
			wpoke bmInfo, 14, bpp
			bmInfo(5) = 0
			CreateDIBSection NULL, bm(6), DIB_RGB_COLORS, varptr(bm(5)), NULL, 0
			hnewbm = stat
		}
		SelectObject hdc, hnewbm
		DeleteObject bm(7)
		bm(7) = hnewbm
		bm(67) = (bm(1) * bpp + 31) / 32 * 4
		bm(16) = bm(67) * bm(2)
	return
#global
