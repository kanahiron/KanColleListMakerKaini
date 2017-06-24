
#module

#uselib	"user32.dll"
#func GetDC "GetDC" int
#func ReleaseDC "ReleaseDC" int, int

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



#module R4HBGC
#uselib "kernel32.dll"
#func VirtualAllocR4HBGC "VirtualAlloc" int, int, int, int
#func VirtualFreeR4HBGC "VirtualFree" int, int, int
#define NULL                   0x00000000
#define PAGE_EXECUTE_READWRITE 0x00000040
#define MEM_COMMIT             0x00001000
#define MEM_RESERVE            0x00002000
#define MEM_DECOMMIT           0x00004000
#define MEM_RELEASE            0x00008000
#deffunc R4HBGC_destructor onexit
	if(NULL != getkancollewindowposauto_C_ptr) {
		VirtualFreeR4HBGC getkancollewindowposauto_C_ptr, 184, MEM_DECOMMIT
		VirtualFreeR4HBGC getkancollewindowposauto_C_ptr, 0, MEM_RELEASE
		getkancollewindowposauto_C_ptr = NULL
	}
	return
#deffunc R4HBGC_constructor
	R4HBGC_destructor
	VirtualAllocR4HBGC NULL, 184, MEM_RESERVE, PAGE_EXECUTE_READWRITE
	VirtualAllocR4HBGC stat, 184, MEM_COMMIT, PAGE_EXECUTE_READWRITE
	getkancollewindowposauto_C_ptr    = stat
	dupptr getkancollewindowposauto_C_bin, stat, 184, vartype("int")
	getkancollewindowposauto_C_bin.0  = $6C8B5553, $C0331024, $57DB3356, $840FED85, $00000094, $1424748B
	getkancollewindowposauto_C_bin.6  = $1C24548B, $0024648D, $819E0C8B, $FFFFFFE1, $750A3B00, $9E348D72
	getkancollewindowposauto_C_bin.12 = $830CC283, $03BF04C6, $EB000000, $00498D03, $E1810E8B, $00FFFFFF
	getkancollewindowposauto_C_bin.18 = $75F84A3B, $4E8B4001, $FFE18104, $3B00FFFF, $0175FC4A, $084E8B40
	getkancollewindowposauto_C_bin.24 = $FFFFE181, $0A3B00FF, $8B400175, $E1810C4E, $00FFFFFF, $75044A3B
	getkancollewindowposauto_C_bin.30 = $4E8B4001, $FFE18110, $3B00FFFF, $0175084A, $14C68340, $4F14C283
	getkancollewindowposauto_C_bin.36 = $F883AE75, $8B19740F, $8B142474, $431C2454, $820FDD3B, $FFFFFF78
	getkancollewindowposauto_C_bin.42 = $835D5E5F, $C35BFFC8, $8B5D5E5F, $00C35BC3
	return
#define global getKanColleWindowPosAuto_C(%1, %2, %3) \
	prm@R4HBGC = varptr(%1), %2, varptr(%3):\
	mref value@R4HBGC, 64:\
	value@R4HBGC = callfunc(prm@R4HBGC, getkancollewindowposauto_C_ptr@R4HBGC, 3)
#global
R4HBGC_constructor



#module "ListMakerModule"

#uselib	"user32.dll"
#func MoveWindow "MoveWindow" int, int, int, int, int, int
#func LoadCursor "LoadCursorW" int, int
#func SetClassLong "SetClassLongW" int, int, int

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


#deffunc init_ListMakerMod array disinfo_

	dim resultdata,16
	resultdata = 0x0029556B ,0x00174357 ,0x000C384C ,0x000E384B ,0x001A4256 ,0x001E4557 ,0x001A3E51 ,0x00395D6E ,0x00294B5D ,0x0016384A ,0x0017394B ,0x0017394B ,0x0016384C ,0x0017394D ,0x0017394D ,0x0017394D
	//0,122
	
	dim mapmovedata,16
	mapmovedata = 0x00ABAB92 ,0x00ABA991 ,0x006D7560 ,0x003B4430 ,0x002C3220 ,0x00474B37 ,0x005F614C ,0x006C715F ,0x00777B71 ,0x0076736E ,0x007E7B54 ,0x009EA041 ,0x00AEB037 ,0x008F8E37 ,0x004A6C4D ,0x00409897
	//167,479
	
	dim homeportdata,16
	homeportdata = 0x00C9AC3B ,0x00AC901D ,0x00B69A27 ,0x00B69A25 ,0x00A88D15 ,0x00A1860C ,0x00A2880A ,0x00947A00 ,0x00A28806 ,0x00977E00 ,0x00B19812 ,0x00917800 ,0x00A28A00 ,0x00A78F04 ,0x00988000 ,0x009A7100
	// 33,106
	
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


#deffunc getKanCollePosAuto int imageid,array sscap,int bufid

	nid = ginfo(3)

	gsel imageid
	sw = ginfo(12)
	sh = ginfo(13)
	
	buffer bufid, sw, sh
	
	chgbm 32
	
	gcopy imageid,0,0,sw,sh
	mref vram,66
	
	gsel nid
	
	getkancollewindowposauto_C vram, sw*sh, homeportdata
	if stat != -1{
		//homeportdata 33,106
		sscap(0) = (stat\sw)+disinfo(0)-33, ((sh-1)-stat/sw)+disinfo(1)-106
		sscap(2) = sscap(0)+800, sscap(1)+480
		gsel bufid: chgbm
		gsel nid
		return 1
	}

	getkancollewindowposauto_C vram, sw*sh, resultdata
	if stat != -1{
		//resultdata 0,122
		sscap(0) = (stat\sw)+disinfo(0)-0, ((sh-1)-stat/sw)+disinfo(1)-122
		sscap(2) = sscap(0)+800, sscap(1)+480
		gsel bufid: chgbm
		gsel nid
		return 1
	}
	
	getkancollewindowposauto_C vram, sw*sh, mapmovedata
	if stat != -1{
		//mapmovedata 167,479
		sscap(0) = (stat\sw)+disinfo(0)-167, ((sh-1)-stat/sw)+disinfo(1)-479
		sscap(2) = sscap(0)+800, sscap(1)+480
		gsel bufid: chgbm
		gsel nid
		return 1
	}

	gsel bufid: chgbm
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


#deffunc CheckKanCollePos int imageid, int posX, int posY

	nid = ginfo(3)

	ddim ratio, 5
	ratio = 0.9, 0.82, 0.73, 0.5, 0.12

	po = posX, posY
	po2 = -1, -1

	stX = 319
	stY = 191

	pccX = 0
	pccY = 0
	dim tccX, 5
	dim tccY, 5
	flagX = 0
	flagY = 0
	as = 0.0

	topCnt = 0

	success = FALSE

	gsel imageid, 0

	repeat 2400, stY
		topCnt = cnt
		x = cnt
		y = int(0.6 * cnt + 0.5)

		pget po(0)+ topCnt -1, po(1) + ratio(0)*y
		pccX = (ginfo_b << 16 | ginfo_g << 8 | ginfo_r)

		pget po(0) + ratio(0)*x, po(1)+y -1
		pccY = (ginfo_b << 16 | ginfo_g << 8 | ginfo_r)

		repeat 5
			pget po(0)+ topCnt, po(1) + ratio(cnt)*y
			tccX(cnt) = (ginfo_b << 16 | ginfo_g << 8 | ginfo_r)

			pget po(0) + ratio(cnt)*x, po(1)+y
			tccY(cnt) = (ginfo_b << 16 | ginfo_g << 8 | ginfo_r)

			//デバッグ用 これをコメントアウトすると成功判定の一部が壊れる
			//color 255, 0, 0
			//pset po(0) + ratio(cnt)*x, po(1)+y
			//pset po(0)+ topCnt, po(1) + ratio(cnt)*y
		loop
		CompArrayAndValue flagX, tccX, tccX(0)
		CompArrayAndValue flagY, tccY, tccY(0)
		
		if ( flagX && flagY ){
			//デバッグ用
			//title strf("%4d %4d %4d %4d %4d %4d %4d %f", x, y, pccX, tccX(0), pccY, tccY(0), topCnt, absf(1.0*(y)/(x) - 0.6))
			//wait 120
			if ( pccX != tccX(0) && pccY != tccY(0)){
				as = absf(1.0*(y)/(x) - 0.6)
				if (as <= 0.021){
					po2(0) = x + po(0)-1
					po2(1) = y + po(1)-1
					success = TRUE
					break
				}
				
			}
		}
		await
	loop


	gsel nid


return success

	
;#defcfunc getbufid

#global

#module "GetAudioDeviceMod"

#deffunc GetAudioDevice str ffmpegpath, var output

	sdim buf, 1024*10
	sdim buf1, 1024*10
	sdim buf2, 1024*10
	sdim output, 1024*4

	cmdm = strf("%s  -list_devices true -f dshow -i audio", ffmpegpath)
	
	pipe2exec cmdm
	pid = stat
	if(pid == -1): dialog "実行失敗": return
	
	repeat
		pipe2check pid
		if stat & 2: pipe2get pid, buf: buf1 += buf
		if stat & 4: pipe2err pid, buf: buf2 += buf
		if (stat == 0):break
		
		wait 10
	loop

	pipe2term pid
	
	if strlen(buf1) != 0 :buf = buf1
	if strlen(buf2) != 0 :buf = buf2

	sdim tempBuf, 1024*10
	
	notesel buf
	repeat notemax
		noteget temp, cnt
		if (strmid(temp, 0, 1) == "["){
			getstr temp, temp, instr(temp, 0, "] ")+2, 0
			if (strmid(temp, 0, 2) == " \""){
				getstr temp, temp, instr(temp, 0, "\"")+1, '\"'
				tempBuf += temp+"\n"
			}
		}
	loop

	output = tempBuf

return



#global 