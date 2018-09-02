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

#global
