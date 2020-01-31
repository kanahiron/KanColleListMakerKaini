/*=======================================================================================================
                                                                                    拡張算術モジュール
HSP3.4β4       2014. 5. 1  64bit割り算の研究用スクリプト
                      5. 9  __int64 論理・加減乗除余の計算一式製作完了、モジュール化、HDL対応
                      5.30  [結合]Locus関連  [変更]Int64_ToStr10(高速化)  [追加]Str2,Str16追加など
                      6.17  [変更]Int64_ToStr10(も～～っと高速化)
                      6.27  [追加]ExCal_Round0to2PI,Int64_ToDouble,Int64_FromDouble
---------------------------------------------------------------------------------------------------------
%dll        ;                   HDL(HSP Document Library)対応ファイル。commonに放り込むだけで対応します。
和謹製モジュール
%port       ;                 DLLやモジュールを別途用意する必要はありません。Win32APIは使用していません。
Win
%author     ;                                            Copyright (C) 2014 衣日和 All rights reserved.
衣日和
%url        ;                                   最新版はこちらから。なんかてきとーWEB Site『略して仮。』
http://www.tvg.ne.jp/menyukko/
%note       ;                                                                           標準ファイル名
ExCalcModule.hsp をインクルードする。
64bit整数のTwinInt詳細：Int64_FromInt32
%======================================================================================================*/

#ifndef ExCalcModuleIncluded
#define ExCalcModuleIncluded
#module ExCalcModule                ; えくすとらかるきゅれーしょんもじゅーる(最近変換してくれないorz)

/*=======================================================================================================
%index  ;                                                               第１パート -コマかい計算チップ集-
%group
拡張算術モジュール
%------------------------------------------------------------------------------------------------------*/
#const ExCalC2PAI   M_PI*2                          ; [定数]2π  ExCalc Const 2 * pi

/*-------------------------------------------------------------------------------------------------------
%index
ExCal_Distance
2点間の距離(1次元座標系)
%prm
(x1, x2)
x1, x2 [数値]2点の X 座標
%inst
2点間の距離(絶対値)を求めて数値(int型)で返します。
%href
ExCal_Distance2
ExCal_Distance3
ExCal_Distance4
%index
ExCal_Distance2
2点間の距離(2次元座標系)
%prm
(x1, y1, x2, y2)
x1, y1, x2, y2 [数値]2点の X,Y 座標
%inst
2点間の距離(絶対値)を求めて数値(int型)で返します。
%href
ExCal_Distance
ExCal_Distance3
ExCal_Distance4
%index
ExCal_Distance3
2点間の距離(3次元座標系)
%prm
(x1, y1, z1, x2, y2, z2)
x1, y1, z1, x2, y2, z2 [数値]2点の X,Y,Z 座標
%inst
2点間の距離(絶対値)を求めて数値(int型)で返します。
%href
ExCal_Distance
ExCal_Distance2
ExCal_Distance4
%index
ExCal_Distance4
2点間の距離(4次元座標系)
%prm
(x1, y1, z1, a1, x2, y2, z2, a2)
x1, y1, z1, a1, x2, y2, z2, a2 [数値]2点の X,Y,Z,+α 座標
%inst
2点間の距離(絶対値)を求めて数値(int型)で返します。
%href
ExCal_Distance
ExCal_Distance2
ExCal_Distance3
%------------------------------------------------------------------------------------------------------*/
#defcfunc ExCal_Distance int x, int w
    return abs(x-w)

#defcfunc ExCal_Distance2 int x, int y, int w, int h                ; 同ネタ es_dist とか distance2
    return int(sqrt( (x-w)*(x-w) + (y-h)*(y-h) ))

#defcfunc ExCal_Distance3 int x, int y, int z, int w, int h, int d  ; 同ネタ d3dist()
    return int(sqrt( (x-w)*(x-w) + (y-h)*(y-h) + (z-d)*(z-d) ))

#defcfunc ExCal_Distance4 int x, int y, int z, int t, int w, int h, int d, int p
    return int(sqrt( (x-w)*(x-w) + (y-h)*(y-h) + (z-d)*(z-d) + (t-p)*(t-p) ))   ; t-pに係数欲しい

/*-------------------------------------------------------------------------------------------------------
%index
ExCal_Round0to2PI
環状実数変換(0.0～2π)
%prm
(Value)
Value [実数]計算元の実数値
%inst
0.0よりも小さい、または2π以上の実数値を 0.0 <= n < 2π に収まるように環状(2πまで進んだらまた0に戻って進むように)計算します。
この関数は 0.0 <= n < 2π の実数値を返します。
%------------------------------------------------------------------------------------------------------*/
#defcfunc ExCal_Round0to2PI double d
    db = 1.4047194095691357e+162, sin(d), cos(d)                    ; [公式] tanθ=sinθ/cosθ
    if db(2) == 0.0  : db(2) = double("2.2250738585072014e-308")    ; あるのか？こんなこと(0割り回避)
    db = atan(db(1) / db(2))                                        ; atanは -90°～90°の範囲 ->ラジで
    if db(2) < 0  : db += M_PI  : else  : if db(1) < 0  : db += ExCalC2PAI  ; sin.cosの正負で範囲補正
    return db                   ; 内部で実数演算・円周率・三角関数を使っているので精度は"それなり"

/*=======================================================================================================
%index  ;                                                                   第２パート -64bit整数演算-
%group
拡張算術モジュール(64bit整数)
%--------------------------------------------------------------------------------------------------------
TwinIntのaliasセット(紛らわしいので組み合わせを決めておく)      近藤中尉←誰だよw(混同注意)
    Lower32：r(Return) m(Mod)  u(あんだー) l(ろーわー)          l:ろう、ろーわー、れふと
    Upper32：v(Value)  s(stat) t(とっぷ)   h(はいやー)          u:あんだー、あっぱー

使い回し変数(ib)のバッティングを避ける
    Level.1:変数使わない  Level.2:渡された変数のみ使う
    Level.3:ib(0～3)短縮マクロのダミー用、ib(4～7)を使う
    Level.4:ib(0～7)内部で呼び出すLv.3命令用、ib(8～11)を使う
    Level.5:とかもう意味フ。ib(12～15)

動作テストメモ  前例がないのでだいぶ苦戦した
    #includeのファイル
        "longint.hsp"  "NagomiStructure.hsp"                    計算結果妥当性
        "hspext.as"  "llmod3/llmod3.hsp"  "llmod3/input.hsp"    電卓連携、コピペなど
        "d3m.hsp"                                               速度調査用
    longintの特性
        フローオーバー・ボローオーバーの切り捨てが無いため結果が一致しないことがある
        16進変換は/16\16していくしか無いかも…(strfは8桁しか返さない)
        peek系のアクセスはStoreの方、Loadじゃない。
    Win電卓の特性（電卓のトレースを妥当な結果とする）
        計算式の貼り付けで答えが表示される 123+456-789= ただしaplstrで送れる文字は数字(0～9)のみと心得よ
        aplkeyは'0'～'9'、'A'～'F'を送れるけど特殊キーコードは効かなかった。ショートカットの入力は失敗
        '='は$0D、'-'は$6D、'*'は$6Aを使用する。
        結果をクリップボードに送らせるには、mouse_eventでメニューバーの編集をクリックさせて'C'する
    テストパターン
        tespa = $00000000, $00000001, $7FFFFFFF, $80000000, $FFFFFFFF   ; 極値仕様
        repeat 625                                                      ; 5,25,125,625 ← 必要に応じて
            pr1L(cnt) = tespa(cnt \ 5)         : pr1H(cnt) = tespa((cnt / 5) \ 5)
            pr2L(cnt) = tespa((cnt / 25) \ 5)  : pr2H(cnt) = tespa((cnt / 125))
        loop
%--------------------------------------------------------------------------------------------------------
%index
Int64_FromInt32
int型整数をTwinIntへ変換
%prm
(Number)
Number [数値]int型数値
%inst
この関数はNumberが正数の場合$00000000(0)を、負数の場合$FFFFFFFF(-1)を返します。この関数は、
    TwinInt(下位) = Number
    TwinInt(上位) = Int64_FromInt32(Number)
とすることでint型数値をTwinIntに変換(キャスト)する目的で使用します。

■HSP式 int型
符号付き32ビット整数。-2147483648～2147483647の数値を表す一般的な整数型です。最上位ビットに符号が当てられます。

■衣日和式 TwinInt
符号付き64ビット整数。-9223372036854775808～9223372036854775807を表現します(__int64、LONGLONGなど)。
情報量を確保するためint型を２つ使用した特殊な形態をしています。最上位ビットに符号を当てています(下位を示すintには符号ビットはありませんので注意です)。
%------------------------------------------------------------------------------------------------------*/
#defcfunc Int64_FromInt32 int n
    return n >> 31

/*-------------------------------------------------------------------------------------------------------
%index
Int64_GetBit
TwinIntから1bit抽出
%prm
(LowPart, HighPart, BitNumber)
LowPart   [数値]TwinInt(下位)
HighPart  [数値]TwinInt(上位)
BitNumber [数値]取得ビット番号(0～63)
%inst
TwinIntから任意ビットのフラグを取り出します。
この関数の戻り値は0または1のどちらかとなります(ただしBitNumberに規定の範囲外を指定した場合-1を返します)。
BitNumber=0が最下位ビット(0:偶数 or 1:奇数)でBitNumber=63が最上位ビット(0:正数 or 1:負数)です。
%------------------------------------------------------------------------------------------------------*/
#defcfunc Int64_GetBit int u, int t, int b
    if  0 <= b & b <= 31  : return u >>  b       & 1
    if 32 <= b & b <= 63  : return t >> (b - 32) & 1
    return -1

/*-------------------------------------------------------------------------------------------------------
%index
Int64_Compare64
TwinIntとTwinIntの大小比較
%prm
(LowPart1, HighPart1, LowPart2, HighPart2)
LowPart1  [数値]TwinInt1(下位)
HighPart1 [数値]TwinInt1(上位)
LowPart2  [数値]TwinInt2(下位)
HighPart2 [数値]TwinInt2(上位)
%inst
２つのTwinIntを比較してその結果を返します。この関数は、
    TwinInt1 > TwinInt2 の時、 1
    TwinInt1 = TwinInt2 の時、 0
    TwinInt1 < TwinInt2 の時、-1
のいずれかを返します。
%------------------------------------------------------------------------------------------------------*/
#defcfunc Int64_Compare64 int u, int t, int l, int h        ; tuが大きければ+   hlなら-
    if t != h  : if t > h  : return 1 : else : return -1
    if u != l {
        if (u & $80000000) != (l & $80000000)  : if u & $80000000  : return 1 : else : return -1
        if (u & $7FFFFFFF)  > (l & $7FFFFFFF)  : return 1 : else : return -1
    }
    return 0

#defcfunc UInt64_Compare64 int u, int t, int l, int h       ; unsigned __int64 (除算で必要なため製作)
    if t != h {
        if (t & $80000000) != (h & $80000000)  : if t & $80000000  : return 1 : else : return -1
        if (t & $7FFFFFFF)  > (h & $7FFFFFFF)  : return 1 : else : return -1
    }
    if u != l {
        if (u & $80000000) != (l & $80000000)  : if u & $80000000  : return 1 : else : return -1
        if (u & $7FFFFFFF)  > (l & $7FFFFFFF)  : return 1 : else : return -1
    }
    return 0

/*-------------------------------------------------------------------------------------------------------
%index
Int64_LShift
TwinIntを左(乗算)方向にビットシフト
%prm
Res_LowPart, Res_HighPart, LowPart, HighPart, BitCount
Res_LowPart  [変数]結果が代入される変数(下位)
Res_HighPart [変数]結果が代入される変数(上位)
LowPart      [数値]TwinInt(下位)
HighPart     [数値]TwinInt(上位)
BitCount     [数値]シフトするビット数(0～63)
%inst
TwinIntをBitCountで指定したビット分だけ上位に送ります。あふれたビット情報は切り捨てられ、下位には値0のビットが補填されます。
正常に完了した場合、statに1が返ります。BitCountが既定の範囲外だった場合、代入は行われずstatに0が返ります。
%href
Int64_RShift
%index
Int64_RShift
TwinIntを右(除算)方向にビットシフト
%prm
Res_LowPart, Res_HighPart, LowPart, HighPart, BitCount
Res_LowPart  [変数]結果が代入される変数(下位)
Res_HighPart [変数]結果が代入される変数(上位)
LowPart      [数値]TwinInt(下位)
HighPart     [数値]TwinInt(上位)
BitCount     [数値]シフトするビット数(0～63)
%inst
TwinIntをBitCountで指定したビット分だけ下位に送ります。あふれたビット情報は切り捨てられ、上位には符号ビットの複製が補填されます。
正常に完了した場合、statに1が返ります。BitCountが既定の範囲外だった場合、代入は行われずstatに0が返ります。
%href
Int64_LShift
%------------------------------------------------------------------------------------------------------*/
#deffunc Int64_LShift var r, var v, int u, int t, int b
    if b < 0 | 63 < b  : return 0                           ; 電卓は結果が定義されてないとか言い出した。
    if 32 <= b  : r = 0  : v = u << (b - 32)  : return 1    ; 32bit以上シフトする。
    if  0 == b  : r = u  : v = t  :             return 1    ; 0bitシフト。
    v = (t << b) | (u >> (32 - b) & ($7FFFFFFF >> (31 - b)))
    r = u << b
    return 1

#deffunc Int64_RShift var r, var v, int u, int t, int b
    if b < 0 | 63 < b  : return 0                           ; 電卓は結果が定義されてないとか言い出した。
    if 32 <= b  : v = t >> 31  : r = t >> (b - 32)  : return 1  ; 32bit以上シフト(符号複製有り)。
    if  0 == b  : r = u  : v = t  : return 1                    ; 0bitシフト。
    v = t >> b
    r = (t << (32 - b)) | (u >> b & ($7FFFFFFF >> (b - 1)))
    return 1

/*-------------------------------------------------------------------------------------------------------
%index
Int64_CalcAdd64
TwinIntとTwinIntの加算(足し算)
%prm
Res_LowPart, Res_HighPart, LowPart1, HighPart1, LowPart2, HighPart2
Res_LowPart  [変数]和が代入される変数(下位)
Res_HighPart [変数]和が代入される変数(上位)
LowPart1     [数値]TwinInt1(下位)
HighPart1    [数値]TwinInt1(上位)
LowPart2     [数値]TwinInt2(下位)
HighPart2    [数値]TwinInt2(上位)
%inst
加算結果が64bitを超える場合は標準動作(オーバービットの切り捨て、最大値+1が最小値になるやつ)をします。

符号反転(正負反転、負数に対しては絶対値の取得)するための命令風お手軽マクロを用意しました。
    Int64_Complement2 R_LP, R_HP, LP1, HP1
%href
Int64_CalcSub64
Int64_CalcMul64
Int64_CalcDivMod64
%------------------------------------------------------------------------------------------------------*/
#deffunc Int64_CalcAdd64 var r, var v, int u, int t, int l, int h   ; Level.3(実質2) Addition
    r = (u & $FFFF) + (l & $FFFF)                                   ; 最下位16bitとキャリー
    v = (u >> 16 & $FFFF) + (l >> 16 & $FFFF) + (r >> 16 & $FFFF)   ; 中下位16bitときゃりーのテンポラリ
    r = (r & $FFFF) | (v << 16 & $FFFF0000)                         ; 下位32bit確定
    v = (v >> 16 & $FFFF) + t + h                                   ; 上位32bit確定
    return

; Int64_Complement2     2の補数取得用命令風マクロ
#define global Int64_Complement2(%1,%2,%3,%4)   Int64_CalcAdd64 %1,%2,(%3)^$FFFFFFFF,(%4)^$FFFFFFFF,1

/*-------------------------------------------------------------------------------------------------------
%index
Int64_CalcSub64
TwinIntとTwinIntの減算(引き算)
%prm
Res_LowPart, Res_HighPart, LowPart1, HighPart1, LowPart2, HighPart2
Res_LowPart  [変数]差が代入される変数(下位)
Res_HighPart [変数]差が代入される変数(上位)
LowPart1     [数値]TwinInt1(下位)
HighPart1    [数値]TwinInt1(上位)
LowPart2     [数値]TwinInt2(下位)
HighPart2    [数値]TwinInt2(上位)
%inst
TwinInt1が被減数、TwinInt2が減数です。

符号反転が目的の場合は、減算命令(0 - n)よりも加算命令(Int64_CalcAdd64)を使用します。
%href
Int64_CalcAdd64
Int64_CalcMul64
Int64_CalcDivMod64
%------------------------------------------------------------------------------------------------------*/
#deffunc Int64_CalcSub64 var r, var v, int u, int t, int l, int h   ; Level.3(実質2) subtraction
    Int64_Complement2 r, v, l, h                ; 2の補数
    Int64_CalcAdd64   r, v, u, t, r, v          ; 足し算
    return

/*-------------------------------------------------------------------------------------------------------
%index
Int64_CalcMul64
TwinIntとTwinIntの乗算(掛け算)
%prm
Res_LowPart, Res_HighPart, LowPart1, HighPart1, LowPart2, HighPart2
Res_LowPart  [変数]積が代入される変数(下位)
Res_HighPart [変数]積が代入される変数(上位)
LowPart1     [数値]TwinInt1(下位)
HighPart1    [数値]TwinInt1(上位)
LowPart2     [数値]TwinInt2(下位)
HighPart2    [数値]TwinInt2(上位)
%inst
乗算結果が64bitを超える場合は標準動作(オーバービットの切り捨て)をします。乗算では数値が大きく増えますので注意してください。

符号反転が目的の場合は、乗算命令(n * -1)よりも加算命令(Int64_CalcAdd64)を使用します。
%href
Int64_CalcAdd64
Int64_CalcSub64
Int64_CalcDivMod64
%------------------------------------------------------------------------------------------------------*/
#deffunc Int64_CalcMul64 var r, var v, int u, int t, int l, int h   ; Level.3(実質2) multiplication
    r = 0  : v = 0
    repeat 64                           ; 符号ビットまで一緒に処理できる
        Int64_LShift r, v, r, v, 1                                          ; ×2して
        if Int64_GetBit(u, t, 63 - cnt)  : Int64_CalcAdd64 r, v, r, v, l, h ; 乗数を＋
    loop
    return
    ; あぁぁ、悲しいほどにしんぷるいずぐっじょぶ。３日かけてこれで良かったとはorz
    ; ※オーバーフローするため乗数の64bit化はあまりメリットが無い

/*-------------------------------------------------------------------------------------------------------
%index
Int64_CalcDivMod64
TwinIntとTwinIntの除算(割り算)
%prm
Res_LowPart1, Res_HighPart1, Res_LowPart2, Res_HighPart2, LowPart1, HighPart1, LowPart2, HighPart2
Res_LowPart1  [変数]商が代入される変数(下位)
Res_HighPart1 [変数]商が代入される変数(上位)
Res_LowPart2  [変数]余が代入される変数(下位)
Res_HighPart2 [変数]余が代入される変数(上位)
LowPart1      [数値]TwinInt1(下位)
HighPart1     [数値]TwinInt1(上位)
LowPart2      [数値]TwinInt2(下位)
HighPart2     [数値]TwinInt2(上位)
%inst
除算の商(割り算の答え)と余(割り算のあまり)を算出します。TwinInt1が被除数、TwinInt2が除数です。
負数を使用した場合は、HSPと同等の符号処理を行います(商は0に近い方で余が負数になることがあります)。

符号反転が目的の場合は、除算命令(n / -1)よりも加算命令(Int64_CalcAdd64)を使用します。

また、結果の一部だけを取得するための命令風お手軽マクロを用意しました。
    Int64_CalcDiv64 R_LP1, R_HP1, LP1, HP1, LP2, HP2  ; 商のみ取得
    Int64_CalcMod64 R_LP2, R_HP2, LP1, HP1, LP2, HP2  ; 余のみ取得
%href
Int64_CalcAdd64
Int64_CalcSub64
Int64_CalcMul64
%------------------------------------------------------------------------------------------------------*/
;   hoge = $80000000 / -1   ; ←この計算、HSPでシステムエラーが起きたorz
#deffunc Int64_CalcDivMod64 var r, var v, var m, var s, int u, int t, int l, int h  ; Level.3
    r = 0  : v = 0  : m = 0  : s = 0        ; 9日かかってついに辿り着いた完全形 division and remainder
    if l == 0 & h == 0  : return h / l          ; 除数が 0 (0割り落ち)      いっぺんしんでみ
    if u == 0 & t == 0  : return                ; 被除数が 0 (全部 0 返し)  そいつ価値ない

    ib(4) = u, t, l, h
    if t < 0  : Int64_Complement2 ib(4), ib(5), u, t    ; 絶対値(正側)に統一
    if h < 0  : Int64_Complement2 ib(6), ib(7), l, h    ; →負の最大にも対応
    ; 絶対値をとったので 0～9223372036854775808 の範囲   0～9223372036854775807までは63bitで表せ、そして
    ; -9223372036854775808 は2の補数でも$8000000000000000になる←unsigned __int64 として見ればいいのだ！

    repeat 64                           ; 符号なしに変換したので全ビットで処理すればいい
        Int64_LShift m, s, m, s, 1
        Int64_CalcAdd64 m, s, m, s, Int64_GetBit(ib(4), ib(5), 63 - cnt)
        Int64_LShift r, v, r, v, 1
        if 0 <= UInt64_Compare64(m, s, ib(6), ib(7)) {  ; 2進数なので、引けないか1こ引けるかのどっちか
            Int64_CalcSub64 m, s, m, s, ib(6), ib(7)
            Int64_CalcAdd64 r, v, r, v, 1
        }
    loop

    if (t < 0) ^ (h < 0)  : Int64_Complement2 r, v, r, v    ; 商の符号処理
    if  t < 0             : Int64_Complement2 m, s, m, s    ; 余の符号処理
    return      ; 結構低速なのよ、この除算... 引き算は足し算２回で実装されているから...

#define global Int64_CalcDiv64(%1,%2,%3,%4,%5,%6)   Int64_CalcDivMod64 %1,%2,ib@ExCalcModule(2),ib@ExCalcModule(3),%3,%4,%5,%6
#define global Int64_CalcMod64(%1,%2,%3,%4,%5,%6)   Int64_CalcDivMod64 ib@ExCalcModule,ib@ExCalcModule(1),%1,%2,%3,%4,%5,%6

/*-------------------------------------------------------------------------------------------------------
%index
Int64_ToStr10
TwinIntを10進数文字列へ変換
%prm
(LowPart, HighPart)
LowPart  [数値]TwinInt(下位)
HighPart [数値]TwinInt(上位)
%inst
この関数はTwinIntを10進数文字列にしたものを返します。TwinIntは最大で19桁(符号込みなら20文字、+null)の文字列へ変換されます。
最小桁数で表現され(上位の無意味な"0"はありません)、負数の場合は"-"記号が付加されます(正数の場合は"+"はありません)。
%href
Int64_FromStr10
%index
Int64_FromStr10
10進数文字列をTwinIntへ変換
%prm
Res_LowPart, Res_HighPart, String10
Res_LowPart  [変数]結果が代入される変数(下位)
Res_HighPart [変数]結果が代入される変数(上位)
String10     [文字]変換元の文字列
%inst
String10の先頭から数字("0"～"9")が記載された範囲が対象です。先頭の一文字のみ"+"か"-"の記載が可能です。
また、64bitの範囲(最大19桁)を超えた場合の動作は未定です。
%href
Int64_ToStr10
%------------------------------------------------------------------------------------------------------*/
#defcfunc Int64_ToStr10 int u, int t        ; Level.4
;                                               ; プラン：1 破棄。１ケタ毎にやってた。
;   sb = ""                                     ; プラン：2 これでもかなり早くなったと思ってたのに、、、
;   ib(8) = u, t, 1637368611, -90972280
;   repeat 3                                ; 一度に9桁(intで扱える範囲)処理するので、3回やれば27桁も
;       Int64_CalcDivMod64 ib(8), ib(9), ib(10), ib(11), ib(8), ib(9), 1000000000
;       if ib(8) == 0 & ib(9) == 0  : sb = str(ib(10)) + sb  : break    ; 被除数がなくなったら終わり
;       sb = strf("%09d%s", abs(ib(10)), sb)
;   loop
;   return sb
    db = 1.4047194095691357e+162                ; 最速プラン：3
    lpoke db, 0, u  : lpoke db, 4, t                ; 整数計算にdouble型が出てくるなんて...
    return strf("%I64d", db)
    ; 最速理論:"プラン1→プラン2で6分の1ぐらい" "プラン2→プラン3で200弱分の1ぐらいΣ(゜Д゜)エッ！？"

#deffunc Int64_FromStr10 var r, var v, str s    ; Level.4
    r = 0  : v = 0
    ib(8) = 1, 0
    if 21 <= strlen(s)  : ib(8) = 0
    sb = s
    repeat strlen(sb)
        ib(9) = peek(sb, cnt)
        if ib(9) < '0' | '9' < ib(9) {
            if cnt == 0 {
                if ib(9) == '+'  : continue
                if ib(9) == '-'  : ib(8) += 2  : continue
            }
            ib(8) = (ib(8) | 1) ^ 1
            break
        }
        Int64_CalcMul64 r, v, r, v, 10
        Int64_CalcAdd64 r, v, r, v, ib(9) - '0'
    loop
    if ib(8) & 2  : Int64_Complement2 r, v, r, v
    if ib(8) & 1  : return 1    ; うまくいった可能性が高い  うまー！
    return 0                    ; ぜったいまちがってる

/*-------------------------------------------------------------------------------------------------------
%index
Int64_ToStr2
TwinIntを2進数文字列へ変換
%prm
(LowPart, HighPart)
LowPart  [数値]TwinInt(下位)
HighPart [数値]TwinInt(上位)
%inst
この関数はTwinIntを2進数文字列にしたものを返します。TwinIntは64文字の文字列へ変換されます。
%href
Int64_FromStr2
%index
Int64_FromStr2
2進数文字列をTwinIntへ変換
%prm
Res_LowPart, Res_HighPart, String2
Res_LowPart  [変数]結果が代入される変数(下位)
Res_HighPart [変数]結果が代入される変数(上位)
String2      [文字]変換元の文字列
%inst
String2の先頭から数字("0"か"1")が記載された範囲が対象です。64文字を超える分は切り捨てられます。
%href
Int64_ToStr2
%------------------------------------------------------------------------------------------------------*/
#defcfunc Int64_ToStr2 int u, int t
    sb = strf("%64s", "(C)衣日和")      ; 64文字+nullを保証する
    repeat 64
        poke sb, cnt, Int64_GetBit(u, t, 63 - cnt) + '0'
    loop
    return sb

#deffunc Int64_FromStr2 var r, var v, str s
    r = 0  : v = 0
    sb = s
    repeat 64
        ib(8) = peek(sb, cnt)
        if ib(8) != '0' & ib(8) != '1'  : break
        Int64_LShift r, v, r, v, 1
        if ib(8) == '1'  : r ++
    loop
    return

/*-------------------------------------------------------------------------------------------------------
%index
Int64_FromStr16
16進数文字列をTwinIntへ変換
%prm
Res_LowPart, Res_HighPart, String16
Res_LowPart  [変数]結果が代入される変数(下位)
Res_HighPart [変数]結果が代入される変数(上位)
String16     [文字]変換元の文字列
%inst
String16の先頭から数字("0"～"9"、"A"～"F"、"a"～"f")が記載された範囲が対象です。16文字を超える分は切り捨てられます。

また、TwinIntから16進数文字列へ変換するための関数風お手軽マクロを用意しました。
    val = Int64_ToStr16c(LowPart, HighPart)  ; 大文字(A～F)使用
    val = Int64_ToStr16s(LowPart, HighPart)  ; 小文字(a～f)使用
%------------------------------------------------------------------------------------------------------*/
#deffunc Int64_FromStr16 var r, var v, str s
    r = 0  : v = 0
    sb = s
    repeat 16
        ib(8) = peek(sb, cnt), -1
        if '0' <= ib(8) & ib(8) <= '9'  : ib(9) = ib(8) - '0'
        if 'a' <= ib(8) & ib(8) <= 'f'  : ib(9) = ib(8) - 'a' + 10
        if 'A' <= ib(8) & ib(8) <= 'F'  : ib(9) = ib(8) - 'A' + 10
        if ib(9) == -1  : break
        Int64_LShift r, v, r, v, 4  : r += ib(9)
    loop
    return

#define global ctype Int64_ToStr16c(%1,%2) strf("%%08X%%08X",%2,%1) ; Capital Letter
#define global ctype Int64_ToStr16s(%1,%2) strf("%%08x%%08x",%2,%1) ; Small Letter

/*-------------------------------------------------------------------------------------------------------
%index
Int64_ToDouble
TwinIntをdouble型実数へ変換
%prm
(LowPart, HighPart, Expo)
LowPart  [数値]TwinInt(下位)
HighPart [数値]TwinInt(上位)
Expo     [数値]小数点位置(基数10の指数)
%inst
この関数はTwinIntをdouble型実数にしたものを返します。また、Expoに小数点の位置を指定することが可能です。例えば
    ・TwinInt: 125、Expo:-2 ならば       1.25
    ・TwinInt: 125、Expo: 0 ならば     125.0
    ・TwinInt: 125、Expo: 1 ならば    1250.0
    ・TwinInt:-125、Expo: 3 ならば -125000.0
のようになります。

TwinIntの最大桁数が19桁なのに対してdouble型の有効桁数が15桁(最大桁から連続した15桁)であることに留意してください。Expoは概ね-280～280の範囲で有効です。
%href
Int64_FromDouble
%index
Int64_FromDouble
double型実数をTwinIntへ変換
%prm
Res_LowPart, Res_HighPart, DoubleValue
Res_LowPart  [変数]結果が代入される変数(下位)
Res_HighPart [変数]結果が代入される変数(上位)
DoubleValue  [実数]変換元の実数
%inst
double型の実数をTwinIntに変換します。この実数は
    Ｎ×(10のＥ乗)  ; ※Ｎは整数で表現できる最小値
の形式で表され、Res_LowPart,Res_HighPartにＮが、システム変数statにＥが代入されます。例えば
    ・12400.0    ならば、 124 と stat: 2
    ・  124.0    ならば、 124 と stat: 0
    ・   -1.24   ならば、-124 と stat:-2
    ・    0.0124 ならば、 124 と stat:-4
のようになります。

なお、実数値は表現可能な範囲で近似値として保持されているため、
    ・0.0125 の時、12500000000000001 と stat:-18
のような結果が返る場合もあります。
%href
Int64_ToDouble
%------------------------------------------------------------------------------------------------------*/
#defcfunc Int64_ToDouble int u, int t, int e
    return double(Int64_ToStr10(u, t) + "e" + e)

#deffunc Int64_FromDouble var u, var t, double d    ; Level.5
    sb = strf("%.18e", d)                   ; 有効桁数は15なので18だと過剰演出
    ib(12) = int(strmid(sb, -1, 4)) - 18    ; "%.18e"は実数を n.ddddddddddddddddddefaaa で表現(桁数固定)
    getstr sb, sb, 0, 'e'                   ;   n:整数部  .:文字.  d:小数部  e:文字e  f:+or-  a:指数
    sb = strtrim(sb, 3, '.')                ; 指数値を取得 → 要済みe以降除去 → 小数点除去 ←イマココ
    ib(13) = strlen(sb)                     ; 'e'  '.'  '0'  顔文字ではない。それぞれは文字コード。
    sb = strtrim(sb, 2, '0')                ; 文字数を控えて右から続く0を除去
    ib(12) += ib(13) - strlen(sb)           ; 文字数の差は除去した0の数→指数に反映(最初の18は反映済み)
    Int64_FromStr10 u, t, sb                ; 残った数字列をTwinIntに変換
    return ib(12)                           ; 指数値はシステム変数statに返す

/*=======================================================================================================
%index  ;                                                                       第３パート -軌跡演算-
%group
拡張算術モジュール(軌跡計算)
%--------------------------------------------------------------------------------------------------------
Locus [数]軌跡 [正]位置・場所
パラメタ変数 LocusPrm(i*8+0) = Mode, point, rad, rad, Offset, prm1, prm2, prm3
    point:回転軸オフセ  rad:回転角double(関係ないけど構造体の8byte境界を意識)
    Offset:第１点の位置  prm:その他のストック
aliasセット -4軸目は使い方次第
    x,y,z,t(time) - w(width),h(high),d(depth),p(parallel)       r,g,b とかもいいかも。
座標系の精度はshort(16bit -32768～32767)
%------------------------------------------------------------------------------------------------------*/
#define ctype LocusSXY(%1,%2)   (((%1)&$FFFF)|((%2)<<16&$FFFF0000)) ; Long X,Y を Short に変換
#define ctype LocusLX(%1)       ((%1)<<16>>16)      ; Short から X を取り出して Long に戻す
#define ctype LocusLY(%1)       ((%1)    >>16)      ; Short から Y を取り出して Long に戻す
#enum LocusMode_Circle = 1                          ; [定数]パラメータモード えん
#enum LocusMode_Rect                                ; [定数]パラメータモード くけい
#enum LocusMode_Bezier                              ; [定数]パラメータモード べじえ

/*-------------------------------------------------------------------------------------------------------
%index
Locus_SetCircle
軌跡算出の計算式を設定(楕円、円)
%prm
ID, x1, y1, x2, y2
ID     [数値]メモリ番号(0～)
x1～y2 [数値]矩形の始点(通常左上)と終点(通常右下)の座標
%inst
軌跡計算をするために基本となる楕円の外観を設定します。IDで指定したメモリのそれまでの設定はクリアされます。
無回転の楕円はcircle命令で描画可能です。
%href
Locus_SetRect
Locus_SetBezier
Locus_SetRotate
Locus_GetPoint
%index
Locus_SetRect
軌跡算出の計算式を設定(矩形、長方形)
%prm
ID, x1, y1, x2, y2
ID     [数値]メモリ番号(0～)
x1～y2 [数値]矩形の始点(通常左上)と終点(通常右下)の座標
%inst
軌跡計算をするために基本となる矩形の外観を設定します。IDで指定したメモリのそれまでの設定はクリアされます。
無回転の矩形はboxf命令で描画可能です。
%href
Locus_SetCircle
Locus_SetBezier
Locus_SetRotate
Locus_GetPoint
%index
Locus_SetBezier
軌跡算出の計算式を設定(ベジェ曲線)
%prm
ID, x1, y1, x2, y2, x3, y3, x4, y4
ID     [数値]メモリ番号(0～)
x1, y1 [数値]始点座標
x2～y3 [数値]制御点座標1、制御点座標2
x4, y4 [数値]終点座標
%inst
軌跡計算をするために基本となる3次ベジェ曲線を設定します。IDで指定したメモリのそれまでの設定はクリアされます。
ベジェ曲線は、始点と終点を結ぶ曲線ですが基本的に制御点上は通過しません。APIなどを使ってなめらかに描画することができます。
%href
Locus_SetCircle
Locus_SetRect
Locus_SetRotate
Locus_GetPoint
%------------------------------------------------------------------------------------------------------*/
#deffunc Locus_SetCircle int i, int x, int y, int w, int h
    LocusPrm(i*8  ) = LocusMode_Circle, 0, 0, 0, LocusSXY(x,y), LocusSXY((w-x)/2,(h-y)/2), 0, 0
    ; prm1=X半径とY半径
    return

#deffunc Locus_SetRect int i, int x, int y, int w, int h
    LocusPrm(i*8  ) = LocusMode_Rect, 0, 0, 0, LocusSXY(x,y), LocusSXY(w-x,h-y), 0, 0
    LocusPrm(i*8+6) = abs(w-x)*2 + abs(h-y)*2   ; prm1=矩形サイズ  prm2=周囲全長
    return

#deffunc Locus_SetBezier int i, int x, int y, int w, int h, int a, int b, int c, int d
    LocusPrm(i*8  ) = LocusMode_Bezier, 0, 0, 0, 0, 0, 0, 0
    LocusPrm(i*8+4) = LocusSXY(x,y), LocusSXY(w-x,h-y), LocusSXY(a-x,b-y), LocusSXY(c-x,d-y)
    ; prm1=第2点の位置(Offsetからの距離として)  prm2=々  prm3=ゝ
    return

/*-------------------------------------------------------------------------------------------------------
%index
Locus_SetRotate
軌跡算出の計算式を設定(回転)
%prm
ID, angle, OffsetX, OffsetY
ID        [数値]メモリ番号(0～)
angle     [実数]回転角度(ラジアン、1周=2π・時計回り)
OffsetX,Y [数値]回転中心点の始点からのずれ量
%inst
軌跡計算をするときに回転させる角度をIDごとに設定します。回転の中心は始点座標ですがオフセット指定(dot)でずらすことが可能です。
%href
Locus_SetCircle
Locus_SetRect
Locus_SetBezier
Locus_GetPoint
%------------------------------------------------------------------------------------------------------*/
#deffunc Locus_SetRotate int i, double t, int x, int y
    db = t
    lpoke LocusPrm(i*8+2), 0, lpeek(db, 0)
    lpoke LocusPrm(i*8+3), 0, lpeek(db, 4)
    LocusPrm(i*8+1) = LocusSXY(x,y)
    return

/*-------------------------------------------------------------------------------------------------------
%index
Locus_GetPoint
設定した計算式から軌跡を算出
%prm
ID, ResX, ResY, Pos, MaxPos
ID         [数値]メモリ番号(0～)
ResX, ResY [変数]結果のX,Y座標が代入される変数(int型)
Pos        [数値]分割線分値
MaxPos     [数値]分割線分値の最大
%inst
軌跡計算の計算結果を取得します。変数にはMaxPos個に分割した時のPos番目の座標が返ります。Pos=0からPos=MaxPosまでの点を順番に繋ぐことでなめらかな図形を描くことができます。
Posが0～MaxPosの範囲にない場合、0～MaxPosの範囲になるように環状処理されます。これにより惑星軌道のような無限ループをPosのカウントアップのみで表現可能です。
Pos=0かMaxPos=0の時、始点(回転時はその始めの点)座標を返します。
PosやMaxPosに負数値を用いることも可能です(進行方向が逆になったりならなかったりします)。

※楕円の円周の目安は、(X方向半径+Y方向半径)*π です(つまり2πr)。
※矩形の4角の座標は、MaxPosに矩形周囲長を指定すれば Pos=0,X辺長,周囲長/2,周囲長/2+X辺長,(周囲長) になります。
%href
Locus_SetCircle
Locus_SetRect
Locus_SetBezier
Locus_SetRotate
Locus_Print
%------------------------------------------------------------------------------------------------------*/
#deffunc Locus_GetPoint int i, var x, var y, int c, int m
    ib = LocusLX(LocusPrm(i*8+5)), LocusLY(LocusPrm(i*8+5))     ; [共通]prm1分解 Short To Long
    db = 1.4047194095691357e+162, 1.4047194095691357e+162, 0.0  ; [共通]結果座標X格納場所,Y,進行度
    if m {                                                      ;       進行度は 0.0 ～ 1.0 の範囲
        db(2) = double(c) / m
        if 1.0 < db(2)  : db(2) -= int(db(2))
        if db(2) < 0.0  : db(2) -= int(db(2)) - 1
    }

    if LocusPrm(i*8) == LocusMode_Circle {              ; サークルの時
        db = cos(ExCalC2PAI * db(2)) * ib + ib, sin(ExCalC2PAI * db(2)) * ib(1) + ib(1)
    }

    if LocusPrm(i*8) == LocusMode_Rect {                ; レクたんの時
        db(3) = db(2) * LocusPrm(i*8+6)                     ; 始点からの距離
        if db(3) < LocusPrm(i*8+6) / 2 {                    ; 半周未満ならば
            if db(3) < absf(ib) {                               ; 第１辺上
                db = db(3), 0.0
            } else {                                            ; 第２辺上
                db = absf(ib), db(3) - absf(ib)
            }
        } else {                                            ; 半周以上ならば
            if db(3) <= absf(ib) + LocusPrm(i*8+6) / 2 {        ; 第３辺上
                db = absf(ib) - db(3) + LocusPrm(i*8+6) / 2, absf(ib(1))
            } else {                                            ; 第４辺上
                db = 0.0, double(LocusPrm(i*8+6)) - db(3)
            }
        }
        if ib   < 0  : db    *= -1                          ; 負数の時の処理
        if ib.1 < 0  : db(1) *= -1
    }

    if LocusPrm(i*8) == LocusMode_Bezier {              ; ベジェさんの時
        db(3) = 1.0 - db(2)
        db(4) = db(3) * db(3) * db(2) * 3, db(3) * db(2) * db(2) * 3, db(2) * db(2) * db(2)
        db    = db(4) * ib(0) + db(5) * LocusLX(LocusPrm(i*8+6)) + db(6) * LocusLX(LocusPrm(i*8+7))
        db(1) = db(4) * ib(1) + db(5) * LocusLY(LocusPrm(i*8+6)) + db(6) * LocusLY(LocusPrm(i*8+7))
        ; オフセット形式で保持しているため第1点の座標は 0,0 だから省略
        ; x = (1-n)*(1-n)*(1-n)*x1 + 3*(1-n)*(1-n)*n*x2 + 3*(1-n)*n*n*x3 + n*n*n*x4
    }

    ; 回転処理の反映
    if LocusPrm(i*8+2) != 0 | LocusPrm(i*8+3) != 0 {                ; 回転角が指定されている時
        ib = LocusLX(LocusPrm(i*8+1)), LocusLY(LocusPrm(i*8+1))     ; 回転中心の点オフセ Short To Long
        db(2) = 1.4047194095691357e+162, db(0) - ib, db(1) - ib(1)  ; オフセ反映
        lpoke db(2), 0, LocusPrm(i*8+2)                             ; 回転角取得
        lpoke db(2), 4, LocusPrm(i*8+3)
        db(0) = db(3) * cos(db(2)) - db(4) * sin(db(2)) + ib
        db(1) = db(3) * sin(db(2)) + db(4) * cos(db(2)) + ib(1)
    }

    ; 開始位置オフセットの反映と整数化(変数型に合わせるのもいいかも？)
    x = LocusLX(LocusPrm(i*8+4)) + db(0)            ; これは単純な端数切捨て法
    y = LocusLY(LocusPrm(i*8+4)) + db(1)
    ; db    += LocusLX(LocusPrm(i*8+4))             ; こっちは四捨五入するやりかた。
    ; db(1) += LocusLY(LocusPrm(i*8+4))
    ; if 0 <= db(0)  : x = int(db(0) + 0.5)  : else  : x = int(db(0) - 0.5)
    ; if 0 <= db(1)  : y = int(db(1) + 0.5)  : else  : y = int(db(1) - 0.5)
    return

/*-------------------------------------------------------------------------------------------------------
%index
Locus_Print
軌跡を実線で描画する
%prm
ID
ID [数値]メモリ番号(0～)
%inst
IDで指定した軌跡を画面に描画するためのお任せ命令です。
%href
Locus_GetPoint
%------------------------------------------------------------------------------------------------------*/
#deffunc Locus_Print int i
    Locus_GetPoint i, ib(4), ib(5), ,  : pos ib(4), ib(5)
    if LocusPrm(i*8) == LocusMode_Circle {              ; サークルの時
        ib(6) = abs(LocusLX(LocusPrm(i*8+5))) * 2 + abs(LocusLY(LocusPrm(i*8+5))) * 2
        repeat ib(6), 1
            Locus_GetPoint i, ib(4), ib(5), cnt, ib(6)  : line ib(4), ib(5)
        loop
        pset ib(4), ib(5)
    }
    if LocusPrm(i*8) == LocusMode_Rect {                ; レクたんの時
        ib(6) = abs(LocusLX(LocusPrm(i*8+5)))
        Locus_GetPoint i, ib(4), ib(5), ib(6),                     LocusPrm(i*8+6)  : line ib(4), ib(5)
        Locus_GetPoint i, ib(4), ib(5), 1,                         2                : line ib(4), ib(5)
        Locus_GetPoint i, ib(4), ib(5), ib(6) + LocusPrm(i*8+6)/2, LocusPrm(i*8+6)  : line ib(4), ib(5)
        Locus_GetPoint i, ib(4), ib(5), 2,                         2                : line ib(4), ib(5)
    }
    if LocusPrm(i*8) == LocusMode_Bezier {              ; ベジェさんの時
        ; 分割数プラン1  3点中、始点から一番遠い点までの距離
        ;ib(6) = 0                                          ; このプランは凹凸が小さいとボコるかもorz
        ;repeat 3, i * 8 + 5
        ;   ib(7) = ExCal_Distance2(LocusLX(LocusPrm(cnt)),LocusLY(LocusPrm(cnt)))
        ;   if ib(6) < ib(7)  : ib(6) = ib(7)
        ;loop

        ; 分割数プラン2  始点～制御点1 と 制御点2～終点 の距離のうち長い方
        ib(6) = ExCal_Distance2(LocusLX(LocusPrm(i*8+5)), LocusLY(LocusPrm(i*8+5)))
        ib(7) = ExCal_Distance2(LocusLX(LocusPrm(i*8+6)), LocusLY(LocusPrm(i*8+6)), LocusLX(LocusPrm(i*8+7)), LocusLY(LocusPrm(i*8+7)))
        if ib(6) < ib(7)  : ib(6) = ib(7)

        ; 分割数プラン3  始点～制御点1 と 制御点2～終点 の距離のうち短い方 ⇒重なってたら 0 べ？

        ib(6) = ib(6) / 2 + 1                   ; とりあえず間引く＆最低1回保障
        repeat ib(6), 1
            Locus_GetPoint i, ib(4), ib(5), cnt, ib(6)  : line ib(4), ib(5)
        loop
    }
    return

; http://www.tvg.ne.jp/menyukko/ ; Copyright(C) 2014 衣日和 All rights reserved.
#global
#endif
