/*
	モジュール名	: getKanCollePosModule
	更新			: 2016-11-27 04:25
	作成者			: kanahiron
	バージョン		: 1.0
	// バージョン表記 メジャー.マイナー メジャーバージョン違いは互換性なし
*/

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

#module "getKanCollePosModule"

#define ctype GetRGB(%1, %2, %3, %4, %5) %1((%3-1-%5)*%2 + %4 \ %2)
#define TRUE 1
#define FALSE 0
//CompArrays 配列同士を比較し全て一致すれば真を返す
#define CompArrays(%1, %2, %3) %1=TRUE:foreach %2:if %2(cnt) != %3(cnt){%1 = FALSE:break}:loop
//CompArrays2 配列同士を比較し全て一致しなければ真を返す
#define CompArrays2(%1, %2, %3) %1=TRUE:foreach %2:if %2(cnt) == %3(cnt){%1 = FALSE:break}:loop
//CompArrayAndValue 配列と値を比較し全て一致すれば真を返す
#define CompArrayAndValue(%1, %2, %3) %1=TRUE:foreach %2:if %2(cnt) != %3{%1 = FALSE:break}:loop
//CompArrayAndValue2 配列と値を比較し全て一致しなければ真を返す
#define CompArrayAndValue2(%1, %2, %3) %1=TRUE:foreach %2:if %2(cnt) == %3{%1 = FALSE:break}:loop

#deffunc getKanCollePos int winID, int tempWinID, array posArray, int cx_, int cy_

	lx = -1
	ly = -1
	rx = -1
	ry = -1

	nid = ginfo(3)

	gsel winID
	sw = ginfo(12)
	sh = ginfo(13)

	buffer tempWinID, sw+4,sh+4
	chgbm 32
	pos 2,2
	gcopy winID, 0, 0, sw, sh
	mref vram, 66

	sw += 4
	sh += 4
	cx = cx_ + 2
	cy = cy_ + 2


	if ( ((cx-126) < 0) | ((cx+126) > sw)): logmes "省略0 cx": goto *en
	if ( ((cy-71) < 0)  | ((cy+71) > sh) ): logmes "省略0 cy": goto *en

	dim flag, 1
	_cx = 0
	_cy = 0
	
	//右側x座標
	repeat 2400,125
		if (cx+cnt == sw+1):break
		
		_cx = cx+cnt

		tempColor = GetRGB(vram, sw, sh, _cx, cy)
		//pset _cx-2, cy-2
		
		flag = TRUE
		repeat 5
			//pset _cx-2, (cy-70+35*cnt)-2
			if tempColor != GetRGB(vram,sw,sh,_cx,(cy-70+35*cnt)): flag = FALSE: break		 
		loop

		if (flag == TRUE){
			rx = cx+cnt
			break
		}
		
	loop
	if (rx == -1) : logmes "省略1 rx": goto *en

	//下側y座標
	repeat 1440,70
		if (cy+cnt) = sh:break

		_cy = cy + cnt

		tempColor = GetRGB(vram, sw, sh, cx, _cy)
		//pset cx-2, _cy-2

		flag = TRUE
		repeat 6
			//pset (cx-125+50*cnt)-2, _cy-2
			if tempColor != GetRGB(vram, sw, sh, (cx-125+50*cnt), _cy): flag = FALSE: break		 
		loop

		if (flag == TRUE){
			ry = cy+cnt
			break
		}
		
	loop
	if (ry == -1): logmes "省略2 ry": goto *en

	//上側y座標(0の可能性アリ)
	repeat 1440,70
		if (cy-cnt) == -1:break

		_cy = cy - cnt

		tempColor = GetRGB(vram, sw, sh, cx, _cy)
		//pset cx-2, _cy-2

		flag = TRUE
		repeat 6
			//pset (cx-125+50*cnt)-2, _cy-2
			if tempColor != GetRGB(vram, sw, sh, (cx-125+50*cnt), _cy): flag = FALSE: break		 
		loop
		if (flag == TRUE){
			ly = cy-cnt+1
			break
		}
		
	loop

	//少しでも処理負荷を減らすためにy方向でまず高さ方向を出す
	h = ry-ly
	if (h < 100) : logmes "省略3 h: "+h: goto *en//xの判定にy座標118pxで判定しているのでこれ以下はxの判定ができないので弾く


	//左側x座標(0の可能性アリ)
	repeat 2400,125
	
		if (cx-cnt) == -1:break
		
		_cx = cx-cnt

		tempColor = GetRGB(vram, sw, sh, _cx, cy)
		//pset _cx-2, cy-2
		
		flag = TRUE
		repeat 5
			//pset _cx-2, (cy-70+35*cnt)-2
			if tempColor != GetRGB(vram,sw,sh,_cx,(cy-70+35*cnt)): flag = FALSE: break		 
		loop

		if (flag == TRUE){
			lx = cx-cnt+1
			break
		}
		
	loop
	
	buffer tempWinID, 1, 1
	dim vram

	gsel nid
	w = rx-lx
	
	logmes "   x "+cx+" y "+cy+" w "+w+" h "+h+"\n"

	if ((w == 0) | (h == 0)):return 0

	if (absf(1.6666666666666667 - (1.0*w/h)) < 0.002){
		posArray = lx-2,ly-2,rx-2,ry-2
		return 1
	}
		
*en

	buffer tempWinID, 1, 1
	dim vram
	gsel nid
	return 0
		

#global