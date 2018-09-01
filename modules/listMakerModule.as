#ifndef chgbm
	#include "ChangeBitmapDepth.as"
#endif

// listMakerModule
// 座標取得など雑多な機能が詰まったモジュール(よろしくない)

//命令
// init_ListMakerMod array p1
// モジュールの初期化
// p1 - 要素数4のint型配列 ディスプレイすべてを1枚の仮想ディスプレイに見立てたときの左上x,y 幅w, 高さh
//
// getKanCollePos		マウスオーバーで艦これの座標を取得する(自動取得その2)
// かきとちゅう
// KanCollePosManual	ドラッグで艦これの座標を取得する(手動取得)
// かきとちゅう
// SelectCapturePos		ツイートウィンドウから呼び出されるキャプチャ範囲取得
// かきとちゅう
#module "ListMakerModule"

#uselib	"user32.dll"
#func MoveWindow "MoveWindow" int, int, int, int, int, int
#func LoadCursor "LoadCursorW" int, int
#func SetClassLong "SetClassLongW" int, int, int

#define ctype GetRGB(%1, %2, %3, %4, %5) %1((%3-1-%5)*%2 + %4 \ %2)
#define TRUE 1
#define FALSE 0

//CompArrays 配列同士を比較し全て一致すれば真を返す
#define CompArrays(%1, %2, %3) %1 = TRUE: foreach %2: if %2(cnt) != %3(cnt){%1 = FALSE: break}: loop
//CompArrays2 配列同士を比較し全て一致しなければ真を返す
#define CompArrays2(%1, %2, %3) %1 = TRUE: foreach %2: if %2(cnt) == %3(cnt){%1 = FALSE: break}: loop
//CompArrayAndValue 配列と値を比較し全て一致すれば真を返す
#define CompArrayAndValue(%1, %2, %3) %1 = TRUE: foreach %2: if %2(cnt) != %3{%1 = FALSE: break}: loop
//CompArrayAndValue2 配列と値を比較し全て一致しなければ真を返す
#define CompArrayAndValue2(%1, %2, %3) %1 = TRUE: foreach %2: if %2(cnt) == %3{%1 = FALSE: break}: loop


#deffunc init_ListMakerMod array disinfo_

	dim tsscap, 4
	dim mxy, 2
	dim mxy_, 2
	dim mwh, 2
	dim sti
	dim cliflag
	dim ccolor, 3
	dim nid
	dim disinfo, 4

	repeat 4
		disinfo(cnt) = disinfo_(cnt)
		logmes ""+disinfo(cnt)
	loop

return

#deffunc CheckKanCollePos int imageid, int posX, int posY, int sizeX, int sizeY

	nid = ginfo(3)

	ddim ratio, 5
	ratio = 0.9, 0.82, 0.73, 0.5, 0.12

	po = posX, posY
	po2 = -1, -1

	stX = int(1.0*BASE_SIZE_W*ZOOM_MIN)-1
	stY = int(1.0*BASE_SIZE_H*ZOOM_MIN)-1

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

	repeat BASE_SIZE_W*ZOOM_MAX, stY
		topCnt = cnt
		x = cnt
		y = int(BASE_ASPECT_RATIO * cnt + 0.5)

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
				as = absf( BASE_ASPECT_RATIO - 1.0*y/x )
				if (as <= 0.021){
					po2(0) = x + po(0)
					po2(1) = y + po(1)
					success = TRUE
					break
				}

			}
		}
		await
	loop

	gsel nid
return ( success && (po2(0)-po(0)) == sizex )

#global
