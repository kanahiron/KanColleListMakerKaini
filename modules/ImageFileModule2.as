/*=======================================================================================================
                                                                    画像ファイルにいろいろするモジュール
HSP3.22         2010.12.30  新規製作
                2011. 1. 4  追加：ImgM_GetSize JPG-$C4処理
                        12  追加：ImgM_SetImageData (暫定)
                        16  修正：Jpeg Endマーカー無し対策
                            製作：ImgF_GdipPicload , ImgM_GdipPicload , ImgM_GdipGzoom
                            移植：ImgM_CalcFitSize
                        27  修正：Jpeg MarkerSize不正(NikonD700バグ？)対策
HSP3.3β1             2.16  修正：Jpeg 破損画像 対策
HSP3.22(笑)           4. 7  収穫。
                      5. 1  修正：ImgM_CalcFitSize 0割り
HSP3.3β3             7.12  製作：ImgM_GdipJpgsave
HSP3.3RC1(正式でてるのに)   9.15    製作：ImgM_GdipRotateFlip
                     11. 3  上記モジュール全て破棄(Next Stage へ)

                                                    画像ファイル操作モジュール２号 ＆ 画像加工モジュール
HSP3.3          2011.11. 3  [製作]ImgF_PicloadEx
                     12.20  [製作]ImgF_GetPicSize,ImgF_GetFormat,ImgP_CalcFitSize,ImgP_gzoom
                2012. 1. 9  [移植](コピペ)ImgF_jpgsave,ImgP_RotateFlip
                      1.11  体裁、モジュール化
HSP3.4β4       2014. 6. 7  ふたつのモジュールを統合、HDL対応
                ～    6.28  [廃止](内部関数)_ImgF_LoadAndSigCheck ⇒ ImgF_GetFormatに統合
                            [製作](内部関数)ImgM_CreateH , ImgM_CloseH
                            [編集]ImgF_PicloadEx 今さらMode2、やらないって言ってたアルファ取得
                            [編集]ImgP_gzoom 実験中に放置してたらしいorz
                            [製作]ImgP_Memsave , ImgP_FilterPastel/Vivid/Nega/SubAbs , ImgP_grotate
%--------------------------------------------------------------------------------------------------------
%dll        ;                   HDL(HSP Document Library)対応ファイル。commonに放り込むだけで対応します。
和謹製モジュール
%port       ;   DLLやモジュールを別途用意する必要はありませんがWin32APIを使用しますので環境に依存します。
Win
%author     ;                                       Copyright (C) 2010-2014 衣日和 All rights reserved.
衣日和
%url        ;                                   最新版はこちらから。なんかてきとーWEB Site『略して仮。』
http://www.tvg.ne.jp/menyukko/
%note       ;                                                                           標準ファイル名
ImageModule2.hsp をインクルードする。
WinXP以降の環境はGDI+を標準装備してます。
; com を使用します。
%======================================================================================================*/

#ifndef ImageModule2Included
#define ImageModule2Included
#module ImageModule2

#uselib "gdiplus"       ; ◆◆ ふぁきゅふぁきゅー-. orz
; ◆ Gdiplusの基礎 --------------------------------------------------------------------------------------
#func GdiplusStartup    "GdiplusStartup"    var, var, nullptr
    ; ◇おまじない                              [Rtn Token(LoadHandle?)][OpenPrm Struct][Output Struct]
#func GdiplusShutdown   "GdiplusShutdown"   int                 ; ◇さんきゅ
; ◆ ImageとBitmapとその周辺 ----------------------------------------------------------------------------
;   [Stream]はcomobj型でもOK!、でもcomにしてから渡す必要があるし管理が面倒になるよ。
;   保存パラメータは不要ならnullptrかintで定義しておけばのちの面倒は無いんだけどさ...
#func GdipLoadImageFromFile         "GdipLoadImageFromFile"     wstr, var   ; ◇↓ができたので無用です。
#func GdipLoadImageFromStream       "GdipLoadImageFromStream"   int, var    ; ◇[Stream][Rtn Image]
#func GdipSaveImageToFile           "GdipSaveImageToFile"       int, wstr, var, var
    ; ◇画像をファイル保存                                          [Image][FileName][DataFormat][Param]
#func GdipSaveImageToStream         "GdipSaveImageToStream"     int, int, var, var
    ; ◇画像を変数に保存                                            [Image][Stream][DataFormat][Param]
#func GdipCreateBitmapFromGdiDib    "GdipCreateBitmapFromGdiDib" int, int, var
    ; ◇HSP画面からBitmap製造                    [BitmapInfo(bmscr.6)][BitmapData(bmscr.5)][Rtn Bitmap]
#func GdipCloneBitmapAreaI          "GdipCloneBitmapAreaI"      int, int, int, int, int, int, var
    ; ◇BitmapからBitmap製造                    [x][y][Width][Height][PixelFormat][Bitmap][Rtn NewBitmap]
#func GdipGetImageWidth             "GdipGetImageWidth"         int, var    ; ◇[Image][Rtn Width]
#func GdipGetImageHeight            "GdipGetImageHeight"        int, var    ; ◇[Image][Rtn Height]
#func GdipImageRotateFlip           "GdipImageRotateFlip"       int, int    ; ◇[Image][FlipType]
#func GdipDisposeImage              "GdipDisposeImage"          int         ; ◇Image破棄
; ◆ ImageAttributesとゆかいな仲間たち ------------------------------------------------------------------
#func GdipCreateImageAttributes         "GdipCreateImageAttributes" var     ; ◇[Rtn ImageAttr]
#func GdipSetImageAttributesColorMatrix "GdipSetImageAttributesColorMatrix" \
                                                                    int, int, int, var, nullptr, nullptr
    ; ◇色マトリ [ImageAttr][ColorAdjustType][TRUE=SetCMat/FALSE=ClearCMat][ColorMat][GrayMat][GrayFlag]
#func GdipDisposeImageAttributes "GdipDisposeImageAttributes" int
; ◆ Matrixのジャケにさり気なく映り込む黒幕w ------------------------------------------------------------
#func GdipCreateMatrix          "GdipCreateMatrix"      var                 ; ◇作るよ。
#func GdipDeleteMatrix          "GdipDeleteMatrix"      int                 ; ◇捨てるよ。
#func GdipTranslateMatrix       "GdipTranslateMatrix"   int, float, float, int
    ; ◇                                                                    [Matrix][OffsetX][Y][Order]
#func GdipRotateMatrix          "GdipRotateMatrix"      int, float, int     ; ◇[Matrix][angle][Order]
; ◆ Graphicsが行く -------------------------------------------------------------------------------------
#func GdipCreateFromHDC         "GdipCreateFromHDC"     int, var            ; ◇hdcからGraphics製造
#func GdipDeleteGraphics        "GdipDeleteGraphics"    int                 ; ◇Graphics破棄
#func GdipSetWorldTransform     "GdipSetWorldTransform" int, int
    ; ◇GraphicsにMatrix適用                             [Graphics][Matrix]
; ◆ ImageとGraphicsの描画関係(かなりどろどろ) ----------------------------------------------------------
#func GdipDrawImageI            "GdipDrawImageI"        int, int, int, int  ; ◇[Graphics][Image][x][y]
#func GdipDrawImageRectI        "GdipDrawImageRectI"    int, int, int, int, int, int
    ; ◇                                                        [Graphics][Image][x][y][Width][Height]
#func GdipDrawImageRectRectI    "GdipDrawImageRectRectI" \
                        int, int, int, int, int, int, int, int, int, int, int, int, nullptr, nullptr
    ; ◇GraphicsにImageを転写(拡縮付き)
                    ; [Graphics][Image][Paste x][y][Width][Height][base x][y][Width][Height]
                    ;                               [UnitPixel][ImageAttributes][Callback][CallbackData]

; ☆ 定数など
; GdipCloneBitmapAreaI [PixelFormat]
#const PixelFormatIndexed           $00010000   ; Indexes into a palette
#const PixelFormatGDI               $00020000   ; Is a GDI-supported format
#const PixelFormatAlpha             $00040000   ; Has an alpha component
#const PixelFormatCanonical         $00200000 
#const PixelFormat8bppIndexed        3|( 8<<8)|PixelFormatGDI|PixelFormatIndexed
#const PixelFormat24bppRGB           8|(24<<8)|PixelFormatGDI
#const PixelFormat32bppARGB         10|(32<<8)|PixelFormatGDI|PixelFormatAlpha|PixelFormatCanonical
; GdipImageRotateFlip [FlipType]
    ; 0 = RotateNoneFlipNone    Rotate180FlipXY     ; 4 = RotateNoneFlipX   Rotate180FlipY
    ; 1 = Rotate90FlipNone      Rotate270FlipXY     ; 5 = Rotate90FlipX     Rotate270FlipY
    ; 2 = Rotate180FlipNone     RotateNoneFlipXY    ; 6 = Rotate180FlipX    RotateNoneFlipY
    ; 3 = Rotate270FlipNone     Rotate90FlipXY      ; 7 = Rotate270FlipX    Rotate90FlipY
; GdipSetImageAttributesColorMatrix [enum ColorAdjustType]
    ; ColorAdjustTypeDefault, ColorAdjustTypeBitmap, ColorAdjustTypeBrush, ColorAdjustTypePen,
    ; ColorAdjustTypeText, ColorAdjustTypeCount, ColorAdjustTypeAny/*Reserved*/

#uselib "kernel32.dll"      ; ◆◆ カーネル
#func GlobalAlloc   "GlobalAlloc"   int, int
#func GlobalFree    "GlobalFree"    int
#func GlobalLock    "GlobalLock"    int
#func GlobalUnlock  "GlobalUnlock"  int
#func GlobalSize    "GlobalSize"    int
#define GMEM_MOVEABLE      2
#define GMEM_ZEROINIT     64
#define GMEM_SHARE      8192
#define GHND              66

#uselib "Ole32.dll"         ; ◆◆ おれ
#func CreateStreamOnHGlobal "CreateStreamOnHGlobal" int, int, var   ; ◆Create Stream With GlobalMemory
        ; [GlobalHandle]グローバルメモリのハンドル(0にするとストリームが内部で用意してくれる)
        ; [DelOnRelease]1にするとストリームの解放時にグローバルメモリも削除してくれる...らしい
        ; [Rtn hStream] 出来あがったストリームのハンドルを受け取る変数
#func GetHGlobalFromStream  "GetHGlobalFromStream"  int, var  ; ◆ストリームの持つグローバルメモリを拝借

#uselib "gdi32.dll"         ; ◆◆ gdi
#func BitBlt                    "BitBlt"                    int, int, int, int, int, int, int, int, int
#func SelectObject              "SelectObject"              int, int
#func CreateCompatibleBitmap    "CreateCompatibleBitmap"    int, int, int
#func DeleteObject              "DeleteObject"              int
#func CreateCompatibleDC        "CreateCompatibleDC"        int
#func DeleteDC                  "DeleteDC"                  int
; BitBltのモード
#define SRCPAINT    $00EE0086       ; コピー元とコピー先のor
#define SRCCOPY     $00CC0020       ; 単純コピー
#define PATINVERT   $005A0049       ; ブラシとの排他的論理和
#define DSTINVERT   $00550009       ; ネガポジ反転

; GDI+を中心にハンドル管理が面倒なので実験的にお任せ命令を作ってみる
#enum ImchMode_Group01 = 0
#enum   ImchMode_GdipOpenDll        ; GDI+の本体(自動化に伴い未使用に)
#enum ImchMode_Group02
#enum   ImchMode_ImageFromStream    ; hImage from hStream       hStream
#enum   ImchMode_ImageFromWindow    ; hImage from CurrentWindow ※製作時にbb使用。
#enum   ImchMode_ImageFromImage     ; hImage from hImage        hImage, pos x, pos y, width, height, pf
#enum ImchMode_Group03
#enum   ImchMode_GraphicFromWindow  ; hGraphic from CurrentWindow
#enum ImchMode_Group04
#enum   ImchMode_Matrix             ; hMatrix
#enum ImchMode_Group05
#enum   ImchMode_ImageAttributes    ; hImageAttr
#enum ImchMode_Group06
#enum   ImchMode_StreamWithGM       ; hStream from hGlobal      hGlobal ; ※解放時にbb使用。
#enum ImchMode_Group07
#enum   ImchMode_CompBitmapObject   ; hBitmap                   hdc, sizeX, sizeY
#enum ImchMode_Group08
#enum   ImchMode_CompDC             ; hDC
#enum ImchMode_Group09
#enum   ImchMode_GlobalAlloc        ; hGlobal                   size
#enum ImchMode_Group10

#define ImchMode_UseGdipFirst   ImchMode_Group02    ; GDI+を使用する最初のグループ
#define ImchMode_UseGdipLast    ImchMode_Group06    ; GDI+を使用しない最初のグループ

;   ImchHL  ハンドルストック用＆関数内使い回しの変数(HL:HandleList)
;       (0)現在のストックハンドル数  (1)GDI+利用時のトークン＆初期化フラグ  (2～6)自由領域
;       (7)CreateHで使うテンポラ  (8～偶数)ImchMode_xxx  (9～奇数)handle

#deffunc ImgM_CreateH int m, int a, int b, int c, int d, int e, int f
    ImchHL(7) = ImchHL * 2 + 9      ; ImchHLのハンドル格納先のIndex     未初期化変数対策風記述
    ImchHL(ImchHL(7) - 1) = m, 0    ; modeとhandle
    ImchHL ++                       ; ストック数のカウント

    ;if m == ImchMode_GdipOpenDll       ; 自動化しました。↓
    if (ImchMode_UseGdipFirst < m & m < ImchMode_UseGdipLast) & ImchHL(1) == 0 {    ; GDI+ Startup
        ImchHL(2) = 1, 0, 0, 0  : GdiplusStartup ImchHL(1), ImchHL(2)
    }

    if m == ImchMode_ImageFromStream {
        GdipLoadImageFromStream a, ImchHL(ImchHL(7))
    }
    if m == ImchMode_ImageFromWindow {
        dim bb, 1                               ; ←この処理は特に意味は無いけど未初期化変数対策
        mref bb, 67
        GdipCreateBitmapFromGdiDib bb(6), bb(5), ImchHL(ImchHL(7))
    }
    if m == ImchMode_ImageFromImage {
        ;   a:元のhImage  b,c:切り出し位置XY  d,e:切り出しサイズWH  f:PixelFormat
        ImchHL(2) = PixelFormat32bppARGB        ; fのデフォルト
        if f  : ImchHL(2) = f
        GdipCloneBitmapAreaI b, c, d, e, ImchHL(2), a, ImchHL(ImchHL(7))
    }
    if m == ImchMode_GraphicFromWindow {
        GdipCreateFromHDC hdc, ImchHL(ImchHL(7))
    }
    if m == ImchMode_Matrix {
        GdipCreateMatrix ImchHL(ImchHL(7))
    }
    if m == ImchMode_GlobalAlloc {
        ;   a:確保するメモリサイズ
        GlobalAlloc GMEM_ZEROINIT | GMEM_SHARE, a  : ImchHL(ImchHL(7)) = stat
    }
    if m == ImchMode_StreamWithGM {
        ;   a:グローバルメモリのハンドル
        if a == 0  : CreateStreamOnHGlobal 0, 1, ImchHL(ImchHL(7))      ; GM指定なし
        if a != 0  : CreateStreamOnHGlobal a, 0, ImchHL(ImchHL(7))      ; GM指定あり
    }
    if m == ImchMode_ImageAttributes {
        GdipCreateImageAttributes ImchHL(ImchHL(7))
    }
    if m == ImchMode_CompBitmapObject {
        ;   a:元にするhDC  b,c:SizeWH
        CreateCompatibleBitmap a, b, c  : ImchHL(ImchHL(7)) = stat
    }
    if m == ImchMode_CompDC {
        ;   a:元にするhDC
        CreateCompatibleDC a  : ImchHL(ImchHL(7)) = stat    ; a:hDC
    }
    return ImchHL(ImchHL(7))

#deffunc ImgM_CloseH
    repeat ImchHL
        memcpy ImchHL(3), ImchHL((ImchHL - cnt - 1) * 2 + 8), 8     ; ターゲット

        ;if ImchMode_Group01<ImchHL(3) & ImchHL(3)<ImchMode_Group02  : GdiplusShutdown   ImchHL(4)
        if ImchMode_Group02<ImchHL(3) & ImchHL(3)<ImchMode_Group03  : GdipDisposeImage   ImchHL(4)
        if ImchMode_Group03<ImchHL(3) & ImchHL(3)<ImchMode_Group04  : GdipDeleteGraphics ImchHL(4)
        if ImchMode_Group04<ImchHL(3) & ImchHL(3)<ImchMode_Group05  : GdipDeleteMatrix   ImchHL(4)
        if ImchMode_Group05<ImchHL(3) & ImchHL(3)<ImchMode_Group06 {
            GdipDisposeImageAttributes ImchHL(4)
        }
        if ImchMode_Group06<ImchHL(3) & ImchHL(3)<ImchMode_Group07 {
            newcom bb, , -1, ImchHL(4)  : delcom bb
            ; ストリームの破棄はコム化してからそのコムを破棄するという処理
            ; GMを開放したら一緒にストリームも破棄されるって説明するサイトがあったんだけど嘘だよねorz
        }
        if ImchMode_Group07<ImchHL(3) & ImchHL(3)<ImchMode_Group08  : DeleteObject  ImchHL(4)
        if ImchMode_Group08<ImchHL(3) & ImchHL(3)<ImchMode_Group09  : DeleteDC      ImchHL(4)
        if ImchMode_Group09<ImchHL(3) & ImchHL(3)<ImchMode_Group10  : GlobalFree    ImchHL(4)
    loop

    if ImchHL(1)  : GdiplusShutdown ImchHL(1)       ; GDI+を開いていたなら。
    ImchHL = 0, 0
    return

/*=======================================================================================================
%index                                                                          ; 旧 "ImageFileModule"
%group
画像関連モジュール(ファイル操作２号)
%--------------------------------------------------------------------------------------------------------
%index
ImgF_GetFormat
画像ファイル解析(画像フォーマット)
%prm
(Path)
Path [文字]ファイル名(パス)
%inst
Pathで指定したファイルを分析してその記録形式を返します。またmemfile命令による擬似ファイルにも対応しています。
この関数の戻り値は以下のいずれかです。
    0 : 不明なフォーマット
    1 : BITMAP
    2 : JPEG
    3 : GIF
    4 : PNG
%------------------------------------------------------------------------------------------------------*/
#defcfunc ImgF_GetFormat str n
    ; この関数は副産物として strsize にファイルサイズを返す
    ; モジュール内変数の sb にファイルデータ全部を取得する(ImgF_GetPicSizeで使うため)
    exist n  : if strsize < 0  : return 0               ; げげげ(ファイルないよ。)
    sb = "(C)衣日和"  : memexpand sb, strsize           ; sbにファイルデータを全ロード
    bload n, sb, strsize
    if wpeek(sb, 0) == $4D42        : return 1          ; BITMAP    $42,$4D = "BM"
    if wpeek(sb, 0) == $D8FF        : return 2          ; JPEG      $FF,$D8 = "  "
    if lpeek(sb, 0) == $38464947    : return 3          ; GIF       $47,$49,$46,$38 = "GIF8"
    if lpeek(sb, 0) == $474E5089 & lpeek(sb, 4) == $0A1A0A0D  : return 4
                                            ; PNG   $89,$50,$4E,$47,$0D,$0A,$1A,$0A = " PNG    "
    return 0

/*-------------------------------------------------------------------------------------------------------
%index
ImgF_GetPicSize
画像ファイル解析(画像の大きさ)
%prm
Path, SizeX, SizeY
Path  [文字]ファイル名(パス)
SizeX [変数]画像幅(X)が代入される変数(int)
SizeY [変数]画像高(Y)が代入される変数(int)
%inst
Pathで指定したファイルを分析してその画像をロードした時のイメージサイズを取得します。またmemfile命令による擬似ファイルにも対応しています。
分析可能な形式はBMP,JPG,GIF,PNGのいずれかで、命令実行後のシステム変数statにはファイル形式を示す値が代入されます。
%------------------------------------------------------------------------------------------------------*/
#deffunc ImgF_GetPicSize str n, var x, var y
    x = 0  : y = 0                      ; とりあえずぬるぽ。…じゃなくて0を代入
    ib = ImgF_GetFormat(n)              ; フォーマットタイプ
    ib(1) = strsize                     ; データサイズ

    if ib == 1 {                        ; ビットマップフォーマット
        if lpeek(sb, 14) == 40  : x = lpeek(sb, 18)  : y =lpeek(sb, 22)     ; Windows形式
    }

    if ib == 2 {                        ; JPEGフォーマット
        ib(2) = 2                           ; offset
        repeat
            if ib(1) <= ib(2)  : break          ; アプリクラッシャー(破損ファイル)対策
            if peek(sb, ib(2)) != $FF {         ; Nikonクラッシャー対策
                ib(2) ++                            ; nicoD700nicoのバグ(？)でアプリが堕ちたょ...回避策
                continue                            ; としてMarkerらしきところまでスキップ
            }

            ib(3) = peek(sb, ib(2) + 1)
            if ib(3) == $D9  : break            ; ファイル終了のお知らせ
            if ib(3) == $C0 | ib(3) == $C2 {
                                        ; 目的地発見 (ハフマンのベースラインかプログレッシブのMarker)
                ib(4) = wpeek(sb, ib(2) + 7), wpeek(sb, ib(2) + 5)  ;トラップ発動(高さが先だったorz)
                x = (ib(4) >> 8 & $00FF) | (ib(4) << 8 & $FF00)
                y = (ib(5) >> 8 & $00FF) | (ib(5) << 8 & $FF00)
                break
            }
            ib(4) = wpeek(sb, ib(2) + 2)        ; それ以外の何かの場合
            ib(5) = (ib(4) >> 8 & $00FF) | (ib(4) << 8 & $FF00)
            ib(2) += ib(5) + 2
        loop
    }

    if ib == 3  : x = wpeek(sb, 6)  : y = wpeek(sb, 8)  ; GIFフォーマット

    if ib == 4 {                        ; PNGフォーマット
        if lpeek(sb, 12) == $52444849 {     ; $49,$48,$44,$52 = "IHDR"  ⇒IHDRヘッダーであってしかるべき
            ib(2) = lpeek(sb, 16), lpeek(sb, 20)    ; ビッグエンディアンだなんてorz...
            x = (ib(2)>>24&$FF) | (ib(2)>>8&$FF00) | (ib(2)<<8&$FF0000) | (ib(2)<<24&$FF000000)
            y = (ib(3)>>24&$FF) | (ib(3)>>8&$FF00) | (ib(3)<<8&$FF0000) | (ib(3)<<24&$FF000000)
        }
    }
    return ib

/*-------------------------------------------------------------------------------------------------------
%index
ImgF_PicloadEx
画像ファイルをロード(GDI+)
%prm
Path, Mode, Option, WinID
Path   [文字]ファイル名(パス)
Mode   [定数]画像ロードモード
    0 : ウィンドウ初期化(白)
    1 : ウィンドウの初期化はしない
    2 : ウィンドウ初期化(黒)
Option [定数]ビットフラグ
    %**00 =  0 : 描画先Window標準動作
    %**01 =  1 : WinIDをbufferで初期化
    %**10 =  2 : WinIDをscreenで初期化
    %**11 =  3 : WinIDをbgscrで初期化
    %00** =  0 : 透過情報を適用(標準)
    %01** =  4 : 透過情報は無視する
    %10** =  8 : 透過情報のみを描画
    %11** = 12 : gmode 7 で使える形式
WinID  [数値]OptionでWindow初期化指定時に利用
     0以上 : 指定IDのウィンドウを初期化
    -1以下 : 未使用ウィンドウを初期化
%inst
HSP標準のpicload命令をGDI+を使って再現します。ロードできるファイル形式はBMP,JPG,GIF,PNGなどGDI+で読み込める必要があります。またmemfile命令による擬似ファイルにも対応しています。
PathとModeはpicload命令と同等ですがOptionを指定することで拡張ロードを実行できます。
Optionでウィンドウの初期化を指定することで、picload前のひと手間(screenやgsel)を省略可能です。ただしModeが1の時はこの設定は適用されません。
OptionでPNGやGIFファイルの持つ透過ピクセル/アルファブレンドの扱いも指定可能です。
%------------------------------------------------------------------------------------------------------*/
#deffunc ImgF_PicloadEx str s, int f, int m, int w
    ; 本家がPNGに正式対応したため存在意義なくなった。でもmemfile(png時)の拡張子省けるよ viiV <kanikani
    exist s  : if strsize == -1  : return
    ib = strsize, 0, 0, 0, 0, 0, 0, 0
            ; ファイルサイズ, 画像サイズW, 画像サイズH, hGlobal, hStream, hImage, hGraphics, hImageAttr

    ImgM_CreateH ImchMode_GlobalAlloc, ib  : ib(3) = stat   ; hGlobal
    GlobalLock ib(3)                                        ; GMを固定する
    dupptr bb, stat, ib, 2                                  ; 固定したGMに変数名を割り当てる
    bload s, bb, ib, 0                                      ; 割り当てた変数にファイルの内容を流し込む
    GlobalUnlock ib(3)                                      ; 固定解除
    ImgM_CreateH ImchMode_StreamWithGM, ib(3)  : ib(4) = stat       ; GMをStream化

    ImgM_CreateH ImchMode_ImageFromStream, ib(4)  : ib(5) = stat    ; StreamからImage
    GdipGetImageWidth  ib(5), ib(1)                         ; image.横
    GdipGetImageHeight ib(5), ib(2)                         ; image.縦

    if f == 0 | f == 2 {                        ; ウィンドウの初期化を伴う
        if (m & 3) == 0 {                               ; オプションでウィンドウ指定は無い
            mref bb, 67  : ib(8) = bb(17), ginfo_sel
        } else {                                        ; オプションでウィンドウ指定が有る
            ib(8) = m & 3
            if w < 0  : ib(9) = ginfo_newid  : else  : ib(9) = w
        }
        if (m & %1100) == %1100  : ib(10) = ib(1) * 2  : else  : ib(10) = ib(1) ; 横幅

        ; ここまででibは (8)ウィンドウ形状 (9)WindowID (10)Window横幅
        if ib(8) == 1  : buffer ib(9), ib(10), ib(2)
        if ib(8) == 2  : screen ib(9), ib(10), ib(2)
        if ib(8) == 3  : bgscr  ib(9), ib(10), ib(2)
        if f == 2  : boxf                               ; モード2の時は黒塗りする
    }

    ImgM_CreateH ImchMode_GraphicFromWindow  : ib(6) = stat

    if m & %1100 {              ; オプションでアルファブレンド処理が指定されている場合
        ImgM_CreateH ImchMode_ImageAttributes  : ib(7) = stat

        if m & %0100 {              ; アルファブレンドを無視する画像描画
            ib( 8) = $3F800000, 0, 0, 0, 0, 0, $3F800000, 0, 0, 0, 0, 0, $3F800000, 0, 0
            ib(23) = 0, 0, 0, 0, 0, 0, 0, 0, $3F800000, $3F800000
            GdipSetImageAttributesColorMatrix ib(7), 1, 1, ib(8)
            GdipDrawImageRectRectI ib(6),ib(5),ginfo_cx,ginfo_cy,ib(1),ib(2),0,0,ib(1),ib(2),2,ib(7)
        }
        if m & %1000 {              ; アルファブレンドマスクの取り出し
            ib( 8) = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            ib(23) = $3F800000, $3F800000, $3F800000, 0, 0, 0, 0, 0, $3F800000, $3F800000
            GdipSetImageAttributesColorMatrix ib(7), 1, 1, ib(8)
            GdipDrawImageRectRectI ib(6),ib(5),ginfo_cx+((m>>2&1)*ib(1)),ginfo_cy,ib(1),ib(2),0,0,ib(1),ib(2),2,ib(7)
                ; 先にプレーン画像を描画しているときは、その画像の右に描画するようにする。
        }
    } else {                    ; オプションにアルファブレンド処理が指定ない場合は普通のコピー
        GdipDrawImageRectI ib(6), ib(5), ginfo_cx, ginfo_cy, ib(1), ib(2)   ; アルファは適用される
    }

    ImgM_CloseH                 ; 後始末♪
    mref bb, 67  : if bb(19) & $FFFF0000  : redraw 1        ; 再描画処理
    return

/*-------------------------------------------------------------------------------------------------------
%index
ImgF_jpgsave
画面イメージセーブ.JPG編(GDI+)
%prm
Path, Quality
Path    [文字]保存するファイル名(パス)
Quality [数値]品質
    0:高圧縮(粗い)～100:低圧縮(きめ細やか)
%inst
HSP標準のbmpsave命令みたいなものです。GDI+を使用してJPG形式でファイル保存します。品質指定付き。
%href
ImgP_Memsave
%------------------------------------------------------------------------------------------------------*/
#deffunc gdiimagesave str s, int p
	if getpath(s,18) = ".png" {
		ib     = 100,0,$557CF406,$11D31A04,$0000739A,$2EF31EF8,1,$1D5BE4B5,$452DFA4A,$B35DDD9C,$EBE70551,1,4,0
	} else {
		ib     = p,0,$557CF401,$11D31A04,$0000739A,$2EF31EF8,1,$1D5BE4B5,$452DFA4A,$B35DDD9C,$EBE70551,1,4,0
	}
    ib(13) = varptr(ib)                 ; 配列自動確保がされてもいいように確定してから代入
    ImgM_CreateH ImchMode_ImageFromWindow  : ib(1) = stat
    GdipSaveImageToFile ib(1), s, ib(2), ib(6)

    ImgM_CloseH
return ayy                              ; HSP同梱のGDI+イメージ保存にjpeg圧縮率指定が無いことに対する措置

/*=======================================================================================================
%index                                                                          ; 旧 "ImagePrintModule"
%group
画像関連モジュール(加工描画)
%--------------------------------------------------------------------------------------------------------
%index
ImgP_CalcFitSize
等倍計算(矩形に収まる画像サイズ)
%prm
Res_W, Res_H, PicW, PicH, RectW, RectH
Res_W, Res_H [変数]結果を受け取る変数(int型)
PicW,  PicH  [数値]元画像の大きさ(横幅、縦幅)
RectW, RectH [数値]矩形の大きさ(横幅、縦幅)
%inst
縦横比固定で画像を拡縮する時に指定領域に収まる最大サイズを算出します。
%href
ImgP_gzoom
%index
ImgP_gzoom
変倍して画面コピー(GDI+)
%prm
SizeX, SizeY, TrimWinID, TrimX, TrimY, TrimW, TrimH
SizeX, SizeY [数値]貼り付け時の画面サイズ
TrimWinID    [数値]コピー元のウィンドウID
TrimX, TrimY [数値]コピー元の起点座標
TrimW, TrimH [数値]コピー元の切り出しサイズ
%inst
HSP標準のgzoom命令をGDI+を使用して再現します。標準命令よりも、特に拡大時に画質が良くなるかもしれません。
画像はカレントポジションを左上とした位置にSizeXとSizeYで指定した大きさで描画されます。
TrimXとTrimYは通常左上座標ですが、TrimWやTrimHに負数値を指定することでミラー反転を行うことも可能です。
%href
ImgP_CalcFitSize
%------------------------------------------------------------------------------------------------------*/
#deffunc ImgP_CalcFitSize var x, var y, int a, int b, int w, int h
    if a == 0 | b == 0  : x = 0  : y = 0    : return    ; 0割り。
    ib = w * 10000 / a , h * 10000 / b                  ; 万分率(笑)‰。
    if ib <  ib(1)  : x = w  : y = b * ib / 10000
    if ib == ib(1)  : x = w  : y = h
    if ib >  ib(1)  : x = a * ib(1) / 10000  : y = h
    if x + 1 == w  : x = w                              ; 誤差1pixel
    if y + 1 == h  : y = h
    return                                              ; この命令で実数使ってないのは昔の名残。

#deffunc ImgP_gzoom int w, int h, int i, int x, int y, int a, int b
    ib = ginfo_sel
    gsel i   : ImgM_CreateH ImchMode_ImageFromWindow    : ib(1) = stat      ; コピー元をImageにする
    gsel ib  : ImgM_CreateH ImchMode_GraphicFromWindow  : ib(2) = stat      ; コピー先をGraphicにする
    GdipDrawImageRectRectI ib(2), ib(1), ginfo_cx, ginfo_cy, w, h, x, y, a, b, 2    ; コピー実行。
    ImgM_CloseH
    mref bb, 67  : if bb(19) & $FFFF0000  : redraw 1                        ; 再描画処理
    return

/*-------------------------------------------------------------------------------------------------------
%index
ImgP_RotateFlip
画像の反転や90°回転(GDI+)
%prm
Mode, TrimWinID, TrimX, TrimY, TrimW, TrimH
Mode         [定数]回転方法
    0 : 何もしない            (gcopy状態)
    1 : 時計回り 90°回転
    2 : 時計回り180°回転     (上下左右反転ともいう)
    3 : 時計回り270°回転
    4 :   0°回転後、左右反転 (左右反転というまでもない)
    5 :  90°回転後、左右反転
    6 : 180°回転後、左右反転 (上下反転ともいう)
    7 : 270°回転後、左右反転
TrimWinID    [数値]コピー元のウィンドウID
TrimX, TrimY [数値]コピー元の起点座標
TrimW, TrimH [数値]コピー元の切り出しサイズ
%inst
画像をミラー反転や90度回転してコピーします。画像はカレントポジションを左上とした位置に描画されます。
%href
ImgP_grotate
%------------------------------------------------------------------------------------------------------*/
#deffunc ImgP_RotateFlip int m, int i, int x, int y, int w, int h
    ib = ginfo_sel

    gsel i
    ImgM_CreateH ImchMode_ImageFromWindow                    : ib(1) = stat ; コピー元をImageにする
    ImgM_CreateH ImchMode_ImageFromImage, ib(1), x, y, w, h  : ib(2) = stat ; トリミングしたImage
    GdipImageRotateFlip ib(2), m                                            ; 回転実行。

    gsel ib
    ImgM_CreateH ImchMode_GraphicFromWindow  : ib(3) = stat         ; 貼り付け先のGraphics
    GdipDrawImageI ib(3), ib(2), ginfo_cx, ginfo_cy                 ; 貼り付け実行。

    ImgM_CloseH
    mref bb, 67  : if bb(19) & $FFFF0000  : redraw 1                ; 再描画処理
    return

/*-------------------------------------------------------------------------------------------------------
%index
ImgP_Memsave
画面イメージセーブto変数(GDI+)
%prm
Res_Bin, Format, Width, Height, Option
Res_Bin [変数]データを受け取る変数(文字列型に変換可能であること)
Format  [定数]保存形式
    1 : BMP
    2 : JPG
    3 : GIF
    4 : PNG
Width   [数値]横幅
Height  [数値]縦幅
Option  [数値]JPGの時 : 品質(0～100)
%inst
現在の画面イメージをFormatで指定したファイル形式で保存します。Res_Binで指定した変数が出力先となります。命令実行後、システム変数statに出力されたデータサイズ(byte)が代入されています。

WidthかHeightが0や省略の場合、画面全体が対象となります(画像サイズはウィンドウの初期化サイズです)。WidthとHeightが0以外の場合はカレントポジションから指定の範囲が保存されます。
保存形式が2(JPG)の場合、Optionで品質を指定します。0(高圧縮、粗い)から100(低圧縮、きめ細やか)の整数で指定可能です。省略時は0扱いです。
%href
ImgF_jpgsave
%------------------------------------------------------------------------------------------------------*/
#deffunc ImgP_Memsave var b, int m, int w, int h, int p ; 変数,形式,幅,高さ,品質
    ib = 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0, 1, 0,0,0,0,0,0,0,0
    ;   (0)GlobalSize (1)stream (2)image(結果) (3)image(works) (4)hGlobal
    ;   (5)PosX (6)PosY (7)Width (8)Height (9)PixelFormat (10～13)ImageCodec
    ;   (14)パラメ数(0だと保存に失敗するので1以上、1こも必要ない場合はパラメに無効な値をいれるとか...)
    ;   (15～18)パラメエンコーダ (19)パラメ要素数? (20)パラメ型 (21)ポインタ(っ！)
    ;   (22～)パラメエンコーダから繰り返し

    if w==0 | h==0 : ib(5) = 0,0,ginfo_sx,ginfo_sy :else: ib(5) = ginfo_cx,ginfo_cy,w,h ; トリミング

    mref bb, 67
    if bb(3)  : ib(9) = PixelFormat8bppIndexed  : else  : ib(9) = PixelFormat24bppRGB   ; ピクフォマ

    if m == 1  : ib(10) = $557CF400, $11D31A04, $0000739A, $2EF31EF8        ; BMP
    if m == 2 {
        ib(22) = p
        ib(10) = $557CF401, $11D31A04, $0000739A, $2EF31EF8                 ; JPG
        ib(14) = 1 ,$1D5BE4B5, $452DFA4A, $B35DDD9C, $EBE70551, 1, 4, varptr(ib(22))
    }
    if m == 3  : ib(10) = $557CF402, $11D31A04, $0000739A, $2EF31EF8        ; GIF
    if m == 4  : ib(10) = $557CF406, $11D31A04, $0000739A, $2EF31EF8        ; PNG

    ImgM_CreateH ImchMode_ImageFromWindow  : ib(3) = stat
    ImgM_CreateH ImchMode_ImageFromImage, ib(3), ib(5), ib(6), ib(7), ib(8), ib(9)  : ib(2) = stat

    ImgM_CreateH ImchMode_StreamWithGM  : ib(1) = stat
    GdipSaveImageToStream ib(2), ib(1), ib(10), ib(14)
    if stat  : ImgM_CloseH  : return 0                  ; 明らかな不成功とか、マジ消えろ。

    GetHGlobalFromStream ib(1), ib(4)                   ; ストリーム管理のhGlobalを拝借
    GlobalSize ib(4)  : ib = stat                       ; おおきさ
    b = "(C)衣日和"  : memexpand b, ib                  ; メモリ確保
    GlobalLock ib(4)
    dupptr bb, stat, ib, vartype("str")
    memcpy b, bb, ib
    GlobalUnlock ib(4)

    ImgM_CloseH
    return ib

/*-------------------------------------------------------------------------------------------------------
%index
ImgP_FilterPastel
画像フィルター(輝度補正)
%prm
Lumin, Width, Height
Lumin  [数値]補正値(-256～256)
Width  [数値]横幅
Height [数値]縦幅
%inst
現在の画面に対して輝度補正を行います。
WidthかHeightが0や省略の場合、画面全体が対象となります。WidthとHeightが0以外の場合はカレントポジションから指定の範囲が対象です。

Luminに輝度変化の割合を指定します。この値によって各ピクセルは、まっくろ(-256指定時)からまっしろ(256指定時)の間で変化します。なお、0を指定した時の輝度変化はありません(基準)。
Luminに正数を指定すると、パステル調の白が混じったようなやわらかい印象になります。
Luminに負数を指定すると、全体的に暗く色変化の乏しい画像になります。
%href
ImgP_FilterVivid
%index
ImgP_FilterVivid
画像フィルター(色強調)
%prm
Lumin, Width, Height
Lumin  [数値]補正値(-256～256)
Width  [数値]横幅
Height [数値]縦幅
%inst
現在の画面に対して輝度補正を行います。
WidthかHeightが0や省略の場合、画面全体が対象となります。WidthとHeightが0以外の場合はカレントポジションから指定の範囲が対象です。

Luminに輝度変化の割合を指定します。この値によって各ピクセルは色を強調するように変化します。
Luminに正数を指定すると、各ピクセルの色は濃くなります。特に暗い色ほど、より大きく輝度が下がることになります。Lumin=256の時の目安は以下の通りです。
    輝度 = 元輝度 - (255 - 元輝度)
    ※例) 元輝度が250の時、輝度は245
    ※例) 元輝度が130の時、輝度は5
Luminに負数を指定すると、各ピクセルの色は白に近づきます。Lumin=-256の時、元の輝度の2倍の輝度に変化します。
Luminに0を指定した時の輝度変化はありません(基準)。
いずれの場合も輝度が0～255の範囲に収まるように下上限処理されます。
%href
ImgP_FilterPastel
%------------------------------------------------------------------------------------------------------*/
#deffunc ImgM_FilterLight int l, int w, int h, int m    ; 光度？輝度？
    mref bb, 67                                         ; ginfoでも結構いけるけど全部これで
    ib = bb(19), bb(35), bb(33), bb(34), bb(65)         ; 再描画フラグとgmodeの現在値
    if w == 0 | h == 0  : ib(5) = 0, 0, bb(1), bb(2)  : else  : ib(5) = bb(27), bb(28), w, h    ; 範囲
    ib(9) = bb(27), bb(28)                              ; カレントポジション(忘れてた...)
    if m == 0  : gmode 5, , , limit(abs(l), 0, 256)     ; モード：ビビッドトーン
    if m == 1  : gmode 6, , , limit(abs(l), 0, 256)     ; モード：パステルトーン
    redraw 0                                            ; ネガ時のgcopyが一瞬光るので強制的にオフっとく
    if 0 < l  : BitBlt hdc, ib(5), ib(6), ib(7), ib(8), , , , DSTINVERT     ; ネガ
    pos ib(5), ib(6)  : gcopy bb(18), ib(5), ib(6), ib(7), ib(8)
    if 0 < l  : BitBlt hdc, ib(5), ib(6), ib(7), ib(8), , , , DSTINVERT     ; ポジ

    pos ib(9),ib(10)  : gmode ib(1),ib(2),ib(3),ib(4)   ; そして元の位置に戻す
    if ib & $FFFF0000  : redraw 1                       ; 再描画(設定の復元もかねて)
    return

    ; 組み合わせて4つの命令ができたけど↑最終的に1こにまとまった(笑  ↓マクロの形で提供
#define global ImgP_FilterPastel(%1,%2=0,%3=0)  ImgM_FilterLight %1,%2,%3,1
#define global ImgP_FilterVivid(%1,%2=0,%3=0)   ImgM_FilterLight %1,%2,%3,0
    ; 補正値が正数だとビビっとあざやかって感じではなくガンマとかコントラストとかが近いかも

/*-------------------------------------------------------------------------------------------------------
%index
ImgP_FilterNega
画像フィルター(ネガポジ、排他的論理和=XOR)
%prm
Width, Height
Width  [数値]横幅
Height [数値]縦幅
%inst
現在の画面に対してカレントカラーとのXOR演算を行います。
WidthかHeightが0や省略の場合、画面全体が対象となります。WidthとHeightが0以外の場合はカレントポジションから指定の範囲が対象です。

XORはいわばビット反転をする計算で、たとえば
    %11001100 ^ %00001111 → %11000011
    ※ %11001100:被数  ^:演算子  %00001111:対象ビット指定
となります。
ですので、まっしろ(255, 255, 255)とのXORはネガポジ効果を、まっくろ(0, 0, 0)とのXORは無意味となるほか、さまざまな画像効果を得ることができます。
%------------------------------------------------------------------------------------------------------*/
#deffunc ImgP_FilterNega int w, int h
    mref bb, 67
    SelectObject hdc, bb(36)  : ib = stat           ; HSPが作り置きしているブラシオブジェを設定
    if w == 0 | h == 0  : ib(1) = 0, 0, bb(1), bb(2)  : else  : ib(1) = bb(27), bb(28), w, h    ; ハニ
    BitBlt hdc, ib(1), ib(2), ib(3), ib(4), , , , PATINVERT     ; ブラシとXOR           はにっ!?→範囲
    SelectObject hdc, ib                            ; 元のブラシに戻す
    if bb(19) & $FFFF0000  : redraw 1               ; 再描画処理
    return

/*-------------------------------------------------------------------------------------------------------
%index
ImgP_FilterSubAbs
画像フィルター(2画像の差の絶対値)
%prm
DiffWinID, PosX, PosY, Width, Height
DiffWinID    [数値]画像BのウィンドウID
PosX, PosY   [数値]画像Bの左上座標
Width,Height [数値]横幅、縦幅
%inst
現在の画面(画像A)とパラメータ指定の画面(画像B)で差をとりその絶対値を示します。この画像は輝度の差が小さいほど暗い(黒い)点として表示され
    ・良く似た２つの画像の相違点を視覚的に示す
    ・圧縮による画質の劣化具合の判定
    ・色減算コピー時にクランプされている部分の視覚化
といった用途に使用可能です。

画像Aについて、WidthかHeightが0や省略の場合は現在の画面全体が対象となります。WidthとHeightが0以外の場合はカレントポジションから指定の範囲が対象です。
画像Bは指定座標を左上とする位置から画像Aと同サイズが対象となります。結果画像は画像Aを上書きする形で描画されます。
%------------------------------------------------------------------------------------------------------*/
#deffunc ImgP_FilterSubAbs int i, int x, int y, int w, int h
    ; やっていることは[A-B=C][B-A=D][C+D=E]の画像加減コピーに過ぎないが、作業用Win不要化で回りくどい。
    ; 画像ストックのコンパチはコピー元Winに合わせる(コピー元画像(計算後に残る方)の劣化を防ぐため)。
    ; [C+D=E]は、負数クランプの為、一方は 0 になっている → 論理和/排他的論理和/合算(加算)どれでもOK!

    ;   ib( 0～ 7)コピー先設定  0:WinID   1:redrawFrag   2-5:gmode   6-7:curPos
    ;   ib( 8～11)出力位置範囲  8-9:pos   10-11:size
    ;   ib(12～18)コピー元設定  12:redrawFlag   13-16:gmode   17-18:curPos
    ;   ib(19～21)ハンドルズ    19:CreateHDC   20:CreatehBitmap   21:hBitmapStock

    mref bb, 67
    ib = bb(18), bb(19), bb(35), bb(33), bb(34), bb(65), bb(27), bb(28)     ; コピー先設定(控え)
    redraw 0                                                                ; コピー先再描画オフ

    if w == 0 | h == 0 : ib(8) = 0, 0, bb(1), bb(2) :else: ib(8) = bb(27), bb(28), w, h ; 範囲計算

    gsel i                      ; ここからの hdc はコピー元
    mref bb, 67
    ib(12) = bb(19), bb(35), bb(33), bb(34), bb(65), bb(27), bb(28), 0, 0, 0    ; コピー元控え＋hndl域
    redraw 0                                                                    ; コピー元再描画オフ

    ImgM_CreateH ImchMode_CompDC, hdc  : ib(19) = stat                                  ; デバコン作り
    ImgM_CreateH ImchMode_CompBitmapObject, hdc, ib(10) * 2, ib(11)  : ib(20) = stat    ; ビトマ作り
    SelectObject ib(19), ib(20)  : ib(21) = stat                                        ; ビトマ差し替え

    BitBlt ib(19), ib(10), 0, ib(10), ib(11), hdc, x, y, SRCCOPY        ; コピー元の画像を控えておく
    gmode 6, ib(10), ib(11), 256  : pos x, y  : gcopy ib, ib(8), ib(9)  ; まずコピー元に減算実行
    BitBlt ib(19), 0, 0, ib(10), ib(11), hdc, x, y, SRCCOPY             ; 減算結果を控える
    BitBlt hdc, x, y, ib(10), ib(11), ib(19), ib(10), 0, SRCCOPY        ; コピー元は減算前に戻す

    gsel ib                     ; ここからの hdc はコピー先
    gmode 6, ib(10), ib(11), 256  : pos ib(8), ib(9)  : gcopy i, x, y   ; 次にコピー先に減算実行
    BitBlt hdc, ib(8), ib(9), ib(10), ib(11), ib(19), 0, 0, SRCPAINT    ; ふたつの減算結果を合体

    SelectObject ib(19), ib(21)                 ; 差し替えていたビトマを差し戻す
    ImgM_CloseH                                 ; APIフィニッシャー

    ; ウィンドウのCurPos/gmode/RedrawFlagを復元(WinID一致の可能性を考慮して最後にまとめて仕上げる)
    gsel i  : pos ib(17),ib(18) : gmode ib(13),ib(14),ib(15),ib(16) : if ib(12)&$FFFF0000 : redraw 1
    gsel ib : pos ib( 6), ib(7) : gmode ib( 2),ib( 3),ib( 4),ib( 5) : if ib( 1)&$FFFF0000 : redraw 1
    return

/*-------------------------------------------------------------------------------------------------------
%index
ImgP_grotate
矩形画像を回転してコピー(GDI+)
%prm
TrimWinID, TrimX, TrimY, Angle, Width, Height
TrimWinID     [数値]元画像のウィンドウID
TrimX, TrimY  [数値]元画像の起点(左上)座標
Angle         [実数]回転角度(ラジアン、1周=2π・時計回り)
Width, Height [数値]描画サイズ(横幅、縦幅)
%inst
HSP標準のgrotate命令をGDI+を使用して再現します。…が異なる点も多いです。標準命令よりも画質が良くなります。

描画はカレントポジションを中心とした位置に行われます。
描画後の矩形サイズをWidthとHeightに指定します。回転するため画像はこの矩形には収まりません。WidthかHeightを0か省略した場合は等倍コピー、大きさを指定した場合は拡大・縮小コピーになります。
元画像のサイズはgmode命令で設定した値を使用しますので、あらかじめ指定しておいてください。

gmodeのコピーモードは0か1のみに対応しています(つまりベタぬりです)。
元画像の範囲に画面外領域が含まれる場合、その領域は透過画素の扱いになります(grotateではリサイズ？されるようで、拡縮・描画位置に影響が出ます)。
%href
ImgP_RotateFlip
%------------------------------------------------------------------------------------------------------*/
;   grotateの再現と言うより、任意角回転命令としてまとめた方が簡素で良いかも？
#deffunc ImgP_grotate int i, int x, int y, double r, int w, int h
    mref bb, 67                                     ; この処理って実のところアートレットにーでーでできる
    ib = bb(18), bb(19), bb(35), bb(33), bb(34), bb(65), bb(27), bb(28)
    if w == 0 | h == 0  : ib(8) = ib(3), ib(4)  : else  : ib(8) = w, h      ; 描画サイズ
    ;   ib(0-7)描画先情報   0:WinID   1:redrawFrag   2-5:gmode   6-7:curPos←使ってなくね？
    ;   ib(8-9)貼り付け時の大きさ     ちなみにib(3-4)切り取りサイズ

    ImgM_CreateH ImchMode_Matrix  : ib(10) = stat               ; ib(10) matrix
    GdipTranslateMatrix ib(10), ginfo_cx, ginfo_cy, 0           ; 座標は、実は実数
    GdipRotateMatrix    ib(10), rad2deg(r), 0                   ; GDI+ではrad→degする
    GdipTranslateMatrix ib(10), -ginfo_cx, -ginfo_cy, 0

    ImgM_CreateH ImchMode_GraphicFromWindow  : ib(11) = stat    ; ib(11) graphic(描画先)
    GdipSetWorldTransform ib(11), ib(10)

    gsel i  : ImgM_CreateH ImchMode_ImageFromWindow  : ib(12) = stat    ; ib(12) image(元画像)
    gsel ib
    GdipDrawImageRectRectI ib(11),ib(12),ginfo_cx-ib(8)/2,ginfo_cy-ib(9)/2,ib(8),ib(9),x,y,ib(3),ib(4),2 

    ImgM_CloseH
    if ib(1) & $FFFF0000  : redraw 1
    return

; http://www.tvg.ne.jp/menyukko/ ; Copyright(C) 2010-2014 衣日和 All rights reserved.
#global
#endif