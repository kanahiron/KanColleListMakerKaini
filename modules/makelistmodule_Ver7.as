
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




#module makelistmodule

#define ctype GetRGB(%1, %2, %3, %4, %5) %1((%3-1-%5)*%2 + %4 \ %2)
#define TRUE 1
#define FALSE 0


#deffunc init_makelist array disinfo_
	
	dim tsscap,4
	dim mxy,2
	dim mxy_,2
	dim mwh,2
	dim sti
	dim cliflag
	dim ccolor,3
	dim nid
	dim disinfo,4
	
	repeat 4
		disinfo(cnt) = disinfo_(cnt)
	loop
	
	//4ディスプレイ全体の最左座標
	//5ディスプレイ全体の最上座標
	//6ディスプレイ全体の横幅
	//7ディスプレイ全体の縦幅

	
return



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



#deffunc KanCollePosManual int imageid1,array sscap,int imageid3,int imageid4

	nid = ginfo(3)
	tsscap(0) = 0,0,0,0
	sscap(0) = 0,0,0,0
	mxy(0) = 0,0
	mxy_(0) = 0,0
	mwh = 0,0
	cliflag = 0
	ccolor(0) = 0,0,0

	/*
	screen imageid5,,,2
	//*/

	//imageId3がレイヤードウィンドウ
	
	gsel imageid4,2 //背景
	imagehwnd4 = hwnd
	MoveWindow imagehwnd4,disinfo(0),disinfo(1),disinfo(2),disinfo(3),1
	LoadCursor 0, 32515
	SetClassLong imagehwnd4, -12, stat

	gsel imageid3,-1
	imagehwnd3 = hwnd 
	MoveWindow imagehwnd3,0,0,0,0,0

	repeat
	
		ginfo0 = int(ginfo(0))
		ginfo1 = int(ginfo(1))
		
		stick sti,256,0
		if sti = 256{
			if cliflag = 0{
				cliflag = 1
				mxy_(0) = ginfo0
				mxy_(1) = ginfo1
				
			}
			if cliflag = 1{

				mwh(0) = abs(mxy_(0) - ginfo0)
				mwh(1) = abs(mxy_(1) - ginfo1)
				
				if mxy_(0) < ginfo0 {
					mxy(0) = mxy_(0)
				} else {
					mxy(0) = ginfo0
				}
		
				if mxy_(1) < ginfo1 {
					mxy(1) = mxy_(1)
				} else {
					mxy(1) = ginfo1
				}
				gsel imageid3,2
				MoveWindow imagehwnd3,mxy(0),mxy(1),mwh(0),mwh(1),1
				
			}
		}
			
		if (sti = 0 & cliflag = 1){
			cliflag = 0
	
			//
			gsel imageid3,-1
			gsel imageid4
			LoadCursor 0, 32512
			SetClassLong imagehwnd4, -12, stat
			gsel imageid4,-1
	
			////////////////////////////////////////
			gsel imageid1
		
			tsscap(0) = mxy(0) - disinfo(0)
			tsscap(1) = mxy(1) - disinfo(1)
			tsscap(2) = mxy(0) + mwh(0) - disinfo(0)
			tsscap(3) = mxy(1) + mwh(1) - disinfo(1)

			pget tsscap(0),tsscap(1)+mwh(1)/2
			ccolor(0) = ginfo_r ,ginfo_g, ginfo_b
			repeat mwh(0)/2,1
				ccnt = cnt
				pget tsscap(0)+cnt,tsscap(1)+mwh(1)/2
				if (ccolor(0) != ginfo_r) | (ccolor(1) != ginfo_g) | (ccolor(2) != ginfo_b) {
					sscap(0) = tsscap(0)+cnt + disinfo(0)
					break
				}
			loop

			pget tsscap(2),tsscap(3)-mwh(1)/2
			ccolor(0) = ginfo_r ,ginfo_g, ginfo_b
			repeat mwh(0)/2,1
				ccnt = cnt
				pget tsscap(2)-cnt,tsscap(3)-mwh(1)/2
				if (ccolor(0) != ginfo_r) | (ccolor(1) != ginfo_g) | (ccolor(2) != ginfo_b) {
					sscap(2) = tsscap(2)-cnt + disinfo(0)+1
					break
				}
			loop

			pget tsscap(0)+mwh(0)/2,tsscap(1)
			ccolor(0) = ginfo_r ,ginfo_g, ginfo_b
			repeat mwh(1)/2
				ccnt = cnt
				pget tsscap(0)+mwh(0)/2,tsscap(1)+cnt
				if (ccolor(0) != ginfo_r) | (ccolor(1) != ginfo_g) | (ccolor(2) != ginfo_b) {
					sscap(1) = tsscap(1)+cnt + disinfo(1)
					break
				}
			loop

			pget tsscap(2)-mwh(0)/2,tsscap(3)
			ccolor(0) = ginfo_r ,ginfo_g, ginfo_b
			repeat mwh(1)/2
				ccnt = cnt
				pget tsscap(2)-mwh(0)/2,tsscap(3)-cnt
				if (ccolor(0) != ginfo_r) | (ccolor(1) != ginfo_g) | (ccolor(2) != ginfo_b) {
					sscap(3) = tsscap(3)-cnt+1 + disinfo(1)
					break
				}
			loop
			/////////////////////
	
			sscapwh(0) = sscap(2)-sscap(0),sscap(3)-sscap(1)
			if sscapwh(0) >= 99 & sscapwh(1) >= 59{
				/*
				screen  imageid5,sscapwh(0),sscapwh(1),,(ginfo(20)-sscapwh(0))/2,(ginfo(21)-sscapwh(1))/2
				gsel imageid5,1
				title "抽出結果"
				gcopy imageid1,sscap(0)-disinfo(0),sscap(1)-disinfo(1),sscapwh(0),sscapwh(1)
				*/

				gsel imageid3,2
				MoveWindow imagehwnd3, sscap(0), sscap(1), sscap(2)-sscap(0), sscap(3)-sscap(1), 1
			
							
							
				dialog "正しく取得できていますか？",2,"確認"
				if stat = 6{
					gsel imageid3,-1
					break
				}
			} else {
				dialog "取得に失敗しました\n再度選択しますか？",2,"確認"
				if stat = 7{
					gsel imageid3,-1
					break
				}
			}
	
			gsel imageid4,2
			MoveWindow imagehwnd4,disinfo(0),disinfo(1),disinfo(2),disinfo(3),1
			LoadCursor 0, 32515
			SetClassLong imagehwnd4, -12, stat
			//gsel imageid5,-1
			
			tsscap(0) = 0,0,0,0
			sscap(0) = 0,0,0,0
			mxy(0) = 0,0
			mxy_(0) = 0,0
			mwh = 0,0
			MoveWindow imagehwnd3,0,0,0,0,1
		}
			
		if (sti = 128){
			gsel imageid3,-1
			gsel imageid4
			LoadCursor 0, 32512
			SetClassLong imagehwnd4, -12, stat
			gsel imageid4,-1
			break
		}
			
		redraw 1
		await 16
	loop

	//gsel imageid5,-1
	gsel nid
	
return

	
;#defcfunc getbufid

#global

