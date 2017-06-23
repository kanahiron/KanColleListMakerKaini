//略して仮。で配布されているMemoryMapModule.asをHSP3utf用に改変
//配布元 : http://www.tvg.ne.jp/menyukko/cauldron/hmmemorymap.html
//作成者 : 衣日和さん
//改変者 : kanahiron

/*====================================================================
                      共有メモリを使うモジュール
HSP3.0          2005.11.19
                2006. 1. 7  新規作成
HSP3.22         2011. 4. 7  再処理
HSP3.3β2             5.21  モジュール再構成、名称変更
----------------------------------------------------------------------
共有メモリ作成(HSP標準命令)
    newmod  モジュール変数, モジュール名, 共有名, Size
        モジュール変数  以降の操作対象になるモジュール型変数
        モジュール名    MemoryMapModule
        共有名          メモリの名前(同じ名前を指定することで共有できる)
        Size            メモリの確保サイズ(Byte単位)
        stat            0(失敗) or 1(新規作成した) or 2(2個目以降の作成)

共有メモリ削除(HSP標準命令)
    delmod  モジュール変数
        モジュール変数  削除対象のモジュール型変数

変数に共有メモリを割り当てる
    Mmry_DupMemory  モジュール変数, 変数名, 変数の型指定
        モジュール変数  対象のモジュール型変数
        変数名          共有メモリを割り当てる変数
                        この変数が代入・参照の対象になる
                        (dupしているだけなので自動拡張などは厳禁)
        変数の型指定    省略・0の場合は、int型
        stat            メモリの確保サイズ(Byte)が代入される

====================================================================*/
#ifndef MemoryMapModuleIncluded
#define MemoryMapModuleIncluded
#module MemoryMapModule MapHandle, StartPos, iSize
#uselib "KERNEL32.dll"
#func CreateFileMapping "CreateFileMappingW" int, nullptr, int, nullptr, int, wstr   ;stat=handle
;ファイルマッピングオブジェクト作成 -1:仮想空間, 0:属性, 4:読み書き, 0:size上, SIZE, NAME
#func CloseHandle "CloseHandle" int             ;オブジェクトハンドルをクローズする
#func MapViewOfFile "MapViewOfFile" int, int, nullptr, nullptr, nullptr     ;stat=開始位置
;仮想空間へのマッピング HANDLE, 2:読み書き, 0:Offset上, 0:Offset下, 0:全体指定
#func UnmapViewOfFile "UnmapViewOfFile" int     ;マッピング解除     開始位置
#func GetLastError "GetLastError"   ;エラーコード取得

#modinit str n, int s   ;名前と大きさ
    MapHandle  = 0  : StartPos = 0  : iSize = s ;モジュールの変数たち

    CreateFileMapping -1, 4, s, n       ;マッピングオブジェクト作成
    MapHandle = stat
    if MapHandle {
        GetLastError  : ib = stat       ;作成時の情報を取っておく
        MapViewOfFile MapHandle, 2      ;マッピング
        StartPos = stat
    }

    if MapHandle == 0 | StartPos == 0   : return 0  ;失敗
    if ib != 183                        : return 1  ;初作成
    return 2                                        ;作成完了(２個目以降)

#modterm
    if StartPos   : UnmapViewOfFile StartPos
    if MapHandle  : CloseHandle     MapHandle
    return

#modfunc Mmry_DupMemory array a, int t
    if StartPos == 0  : return 0    ;モジュール作成で失敗している
    if t == 0  : ib = 4  : else  : ib = t
    dupptr a, StartPos, iSize, ib
    return iSize

; http://www.tvg.ne.jp/menyukko/
; Copyright(C) 2005-2012 衣日和 All rights reserved.
#global
#endif