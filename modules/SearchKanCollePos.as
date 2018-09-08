/**
 * 艦これの座標を画面から検索するモジュール
 * 基本的には「ウィンドウIDを受け取ると、Rectangleの候補一覧と候補数を返す」ように揃えている
 */

#if 0
    #include "../SubSource/FunctionDefinition.hsp"
#endif

#include "ChangeBitmapDepth.as"

#module SearchKanCollePos
    /* 各種定数設定 */
    #const DEFAULT_GAME_WINDOW_WIDTH 1200  //標準的なゲーム画面のXサイズ
    #const DEFAULT_GAME_WINDOW_HEIGHT 720  //標準的なゲーム画面のYサイズ
    #const MAX_ZOOM_RATIO 3.0  //ゲーム画面がMAX_ZOOM_RATIO倍まで大きくてもOK、といった意味
    #const MIN_ZOOM_RATIO 0.4  //ゲーム画面がMIN_ZOOM_RATIO倍まで小さくてもOK、といった意味
    #const STICK_ESCBUTTON 128
    #const STICK_LEFTBUTTON 256
    #const STICK_RIGHTBUTTON 512
    #define TRUE 1
    #define FALSE 0
    #define BASE_ASPECT_RATIO 0.6
    #const MREF_VRAM 66

    #const SM_XVIRTUALSCREEN 76
    #const SM_YVIRTUALSCREEN 77
    #const SM_CXVIRTUALSCREEN 78
    #const SM_CYVIRTUALSCREEN 79
    #const IDC_ARROW 32512
    #const MAKEINTRESOURCE 32515
    #const GCL_HCURSOR -12

    #define VIRTUAL_DISPLAY_X GetSystemMetrics@(SM_XVIRTUALSCREEN)
	#define VIRTUAL_DISPLAY_Y GetSystemMetrics@(SM_YVIRTUALSCREEN)
	#define VIRTUAL_DISPLAY_W GetSystemMetrics@(SM_CXVIRTUALSCREEN)
	#define VIRTUAL_DISPLAY_H GetSystemMetrics@(SM_CYVIRTUALSCREEN)

    /* 最小値を返す */
    #defcfunc local Min int a, int b
        if (a > b) :return b
    return a

    /* 最大値を返す */
    #defcfunc local Max int a, int b
        if (a > b) :return a
    return b

    /* 指定した点のRGB値を取得する。(R<<16)|(G<<8)|B */
    #defcfunc local _pget int x, int y
        pget x, y
    return ((ginfo_r << 16) | (ginfo_g << 8) | (ginfo_b))

    /* 「chggm 32」した状況下で、指定した点のRGB値を取得する。(R<<16)|(G<<8)|B */
    #defcfunc local _pget2 int x, int y
    return vram(x + (windowHeight - 1 - y) * windowWidth)

    /**
     * ListMakerModule#getKanCollePosで採用されているアルゴリズム
     * (mx, my)は艦これの画面内の(ウィンドウIDに対する)1座標であり、それを含む艦これの画面を検出する
     */
    #defcfunc local SemiAuto int windowId, array rectangles, int mx, int my
        // 定数設定
        MIN_GAME_WINDOW_WIDTH_HALF = 250 / 2
        MIN_GAME_WINDOW_HEIGHT_HALF = 150 / 2
        MIN_GAME_WINDOW_WIDTH_QUARTER = MIN_GAME_WINDOW_WIDTH_HALF / 2
        MIN_GAME_WINDOW_HEIGHT_QUARTER = MIN_GAME_WINDOW_HEIGHT_HALF / 2

        // 事前準備
        gsel windowId
        window_width = ginfo_sx
        window_height = ginfo_sy

        // 画面が小さすぎるときは検出しないようにする
        if (mx < MIN_GAME_WINDOW_WIDTH_HALF) :return 0
        if (mx + MIN_GAME_WINDOW_WIDTH_HALF >= window_width) :return 0
        if (my < MIN_GAME_WINDOW_HEIGHT_HALF) :return 0
        if (my + MIN_GAME_WINDOW_HEIGHT_HALF >= window_height) :return 0

        // 艦これの画面の右下座標の更に1ピクセル右下(通称：座標2)のX座標rxを取得する
        // つまり、(mx, my)からある程度右に進んだ点Aについて、AからMIN_GAME_WINDOW_HEIGHT_QUARTER間隔で
        // 縦方向に上下2点づつ取得し、それらの色がAの色と同じなら、AのX座標がrxだと推定される
        maxRightX = Min(mx + DEFAULT_GAME_WINDOW_WIDTH * MAX_ZOOM_RATIO, window_width)
        for px, mx + MIN_GAME_WINDOW_WIDTH_HALF, maxRightX
            tempColor = _pget(px, my)
            flg = TRUE
            for py, my - MIN_GAME_WINDOW_HEIGHT_HALF, my + MIN_GAME_WINDOW_HEIGHT_HALF + 1, MIN_GAME_WINDOW_HEIGHT_QUARTER
                if (_pget(px, py) != tempColor) :flg = FALSE :_break
            next
            if (flg) :logmes "rx = " + px + "(" + tempColor + ")" :_rx = px :_break
        next

        // 座標2のY座標ryを取得する
        maxRightY = Min(my + DEFAULT_GAME_WINDOW_HEIGHT * MAX_ZOOM_RATIO, window_height)
        for py, my + MIN_GAME_WINDOW_HEIGHT_HALF, maxRightY
            tempColor = _pget(mx, py)
            flg = TRUE
            for px, mx - MIN_GAME_WINDOW_WIDTH_HALF, my + MIN_GAME_WINDOW_WIDTH_HALF + 1, MIN_GAME_WINDOW_WIDTH_QUARTER
                if (_pget(px, py) != tempColor) :flg = FALSE :_break
            next
            if (flg) :logmes "ry = " + py + "(" + tempColor + ")" :_ry = py :_break
        next

        // 艦これの画面の左上座標の更に1ピクセル左上(通称：座標1)のY座標lyを取得する
        minLeftY = Max(my - DEFAULT_GAME_WINDOW_HEIGHT * MAX_ZOOM_RATIO, -1)
        for py, my - MIN_GAME_WINDOW_HEIGHT_HALF, minLeftY, -1
            tempColor = _pget(mx, py)
            flg = TRUE
            for px, mx - MIN_GAME_WINDOW_WIDTH_HALF, my + MIN_GAME_WINDOW_WIDTH_HALF + 1, MIN_GAME_WINDOW_WIDTH_QUARTER
                if (_pget(px, py) != tempColor) :flg = FALSE :_break
            next
            if (flg) :logmes "ly = " + py + "(" + tempColor + ")" :_ly = py :_break
        next

        // 縦幅があまりに小さすぎる際は、候補ではないとして弾く
        _height = _ry - _ly - 1
        if (_height < 100) :return 0

        // 座標1のX座標lxを取得する
        minLeftX = Max(mx - DEFAULT_GAME_WINDOW_WIDTH * MAX_ZOOM_RATIO, -1)
        for px, mx - MIN_GAME_WINDOW_WIDTH_HALF, minLeftX, -1
            tempColor = _pget(px, my)
            flg = TRUE
            for py, my - MIN_GAME_WINDOW_HEIGHT_HALF, my + MIN_GAME_WINDOW_HEIGHT_HALF + 1, MIN_GAME_WINDOW_HEIGHT_QUARTER
                if (_pget(px, py) != tempColor) :flg = FALSE :_break
            next
            if (flg) :logmes "lx = " + px + "(" + tempColor + ")" :_lx = px :_break
        next

        // 縦横比がおかしい場合は、候補ではないとして弾く
        _width = _rx - _lx - 1
        if (abs(_height * 5 / 3 - _width) >= 3) :return 0

        // 保存用のバッファーを用意
        dim rectangles, 4, 1
        rectangles(0, 0) = _lx + 1, _ly + 1, _width, _height
    return 1

    /**
     * ListMakerModule#KanCollePosManualやListMakerModule#SelectCapturePosで採用されているアルゴリズム
     * ・windowIdは事前に仮想ディスプレイ全体をBitBltされているbuffer
     * ・overlayWindowIdは仮想ディスプレイ全体と同じサイズのレイヤードウィンドウでbgscr
     * ・bgWindowIdは仮想ディスプレイ全体と同じサイズのbgscrで、windowIdの内容がコピーされている
     * ・bgWindowIdを最前面表示にして左上を仮想ディスプレイ左上に合わせ、
     * 　マウスをドラッグする動きにoverlayWindowIdの位置・大きさを合わせている。
     * 　マウスボタンを離すと、「選択枠の辺の中央Xから1ピクセルづつ内側を確認していき、
     * 　Xと異なる色に行き当たったところでその辺の絞りが完了したとみなす」といったノリ
     * ・Escキーか右マウスボタンを押すと強制終了する
     * ・この関数の終了時、関数実行前にgselしていたウィンドウIDにgselし直す
     * ・戻り値はRECTが想定されており、選択失敗時はオール0になる。
     * 　Rectangleに変換しても、選択失敗時はオール0になる計算
     * 　(なお、marginCutFlgがFALSEならば、選択した後のトリミング過程が発生しない)
     */
    #defcfunc local Manual int windowId, array rectangles, int overlayWindowId, int bgWindowId, int marginCutFlg
        // 以前のカレントウィンドウIDを記憶
        currentWindowId = ginfo_sel

        // 保存用のバッファーを用意
        dim rectangles, 4, 1
        rectangles(0, 0) = 0, 0, 0, 0
        rectangleCount = 0

        // ウィンドウ周りの準備を行う
        ;bgWindowIdを最前面表示にして左上を仮想ディスプレイ左上に合わせる
    	gsel bgWindowId, 2
    	bgWindowIdHandle = hwnd
    	MoveWindow@ bgWindowIdHandle, VIRTUAL_DISPLAY_X, VIRTUAL_DISPLAY_Y, VIRTUAL_DISPLAY_W, VIRTUAL_DISPLAY_H, TRUE
        ;マウスカーソルをクロス状に変更しておく
    	LoadCursor@ 0, MAKEINTRESOURCE
    	SetClassLong@ bgWindowIdHandle, GCL_HCURSOR, stat
        ;overlayWindowIdを非表示にしておく
    	gsel overlayWindowId, -1
    	overlayWindowIdHandle = hwnd
    	MoveWindow@ overlayWindowIdHandle, 0, 0, 0, 0, 0

        // マウス選択のループ
        selectFlg = FALSE       //選択中はTRUE
        selectBeginPos.0 = 0, 0 //選択開始時のマウス座標(スクリーン座標系)
        selectAreaRect.0 = 0, 0, 0, 0   //選択範囲のRect(スクリーン座標系)
        while (TRUE)
            // キー入力状態を読み取る(左マウスボタンは押しっぱなしも検知)
            stick ky, STICK_LEFTBUTTON, 0

            // 左マウスボタンを押していた際の処理
            if (ky & STICK_LEFTBUTTON){
                if (selectFlg == FALSE){
                    // 選択始めの状態
                    selectBeginPos(0) = ginfo_mx
                    selectBeginPos(1) = ginfo_my
                    selectFlg = TRUE
                }else{
                    // 選択中の状態
                    //selectAreaRectを随時更新しつつ、その結果によってoverlayWindowIdを選択範囲上に表示させている
                    selectAreaRect(0) = Min(selectBeginPos(0), ginfo_mx)
                    selectAreaRect(1) = Min(selectBeginPos(1), ginfo_my)
                    selectAreaRect(2) = Max(selectBeginPos(0), ginfo_mx) - selectAreaRect(0)
                    selectAreaRect(3) = Max(selectBeginPos(1), ginfo_my) - selectAreaRect(1)
                    gsel overlayWindowId, 2
    				MoveWindow@ overlayWindowIdHandle, selectAreaRect(0), selectAreaRect(1), selectAreaRect(2), selectAreaRect(3), TRUE
                 }
            }else :if ((ky & STICK_ESCBUTTON) || (ky & STICK_RIGHTBUTTON)){
                // Escキー or 右マウスボタンを押した際の処理
                ; オーバーレイウィンドウを非表示にする
                gsel overlayWindowId, -1
                ; bgWindowIdにおけるマウスポインタの設定を元に戻す
    			gsel bgWindowId
    			LoadCursor@ 0, IDC_ARROW
    			SetClassLong@ bgWindowIdHandle, GCL_HCURSOR, stat
                ; bgWindowIdを非表示にする
    			gsel bgWindowId, -1
    			_break
            }else {
                // 何も押しておらず、選択を外した瞬間ならば、選択範囲についての処理を行う
                if (selectFlg) {
                    // 選択状態を解除
                    selectFlg = FALSE

                    // overlayWindowIdとbgWindowIdを非表示にする
                    ; オーバーレイウィンドウを非表示にする
                    gsel overlayWindowId, -1
                    ; bgWindowIdにおけるマウスポインタの設定を元に戻す
        			gsel bgWindowId
        			LoadCursor@ 0, IDC_ARROW
        			SetClassLong@ bgWindowId, GCL_HCURSOR, stat
                    ; bgWindowIdを非表示にする
        			gsel bgWindowId, -1

                    // 選択部分から艦これの画面を検出する
                    gsel windowId
                    if (marginCutFlg){
                        ;初期範囲を算出する
                        dim tempRect, 4
                        tempRect(0) = selectAreaRect(0) - VIRTUAL_DISPLAY_X
                        tempRect(1) = selectAreaRect(1) - VIRTUAL_DISPLAY_Y
                        tempRect(2) = selectAreaRect(2)
                        tempRect(3) = selectAreaRect(3)
                        ;まず左辺から絞る
                        tempColor = _pget(tempRect(0), tempRect(1) + tempRect(3) / 2)
                        for px, tempRect(0), tempRect(0) + tempRect(2) / 2
                            if (_pget(px, tempRect(1) + tempRect(3) / 2) != tempColor) {
                                rectangles(0, 0) = px
                                _break
                            }
                        next
                        ;次に右辺
                        tempColor = _pget(tempRect(0) + tempRect(2), tempRect(1) + tempRect(3) / 2)
                        for px, tempRect(0) + tempRect(2), tempRect(0) + tempRect(2) / 2, -1
                            if (_pget(px, tempRect(1) + tempRect(3) / 2) != tempColor) {
                                rectangles(2, 0) = px - rectangles(0, 0)
                                _break
                            }
                        next
                        ;次に上辺
                        tempColor = _pget(tempRect(0) + tempRect(2) / 2, tempRect(1))
                        for py, tempRect(1), tempRect(1) + tempRect(3) / 2
                            if (_pget(tempRect(0) + tempRect(2) / 2, py) != tempColor) {
                                rectangles(1, 0) = py
                                _break
                            }
                        next
                        ;最後に下辺
                        tempColor = _pget(tempRect(0) + tempRect(2) / 2, tempRect(1) + tempRect(3))
                        for py, tempRect(1) + tempRect(3), tempRect(1) + tempRect(3) / 2, -1
                            if (_pget(tempRect(0) + tempRect(2) / 2, py) != tempColor) {
                                rectangles(3, 0) = py - rectangles(1, 0)
                                _break
                            }
                        next
                    }else{
                        rectangles(0, 0) = selectAreaRect(0) - VIRTUAL_DISPLAY_X
                        rectangles(1, 0) = selectAreaRect(1) - VIRTUAL_DISPLAY_Y
                        rectangles(2, 0) = selectAreaRect(2)
                        rectangles(3, 0) = selectAreaRect(3)
                    }

                    // 検出できているかを確認する。駄目なら再度選択させる
                    if (rectangles(2, 0) >= 99 && rectangles(3, 0) >= 59) {
                        gsel overlayWindowId, 2
        				MoveWindow@ overlayWindowIdHandle, rectangles(0, 0) + VIRTUAL_DISPLAY_X, rectangles(1, 0) + VIRTUAL_DISPLAY_Y, rectangles(2, 0), rectangles(3, 0), TRUE
        				dialog "正しく取得できていますか？", 2, "確認"
        				if (stat == 6) {
        					gsel overlayWindowId, -1
                            rectangleCount = 1
        					_break
        				}
                    }else {
                        dialog "取得に失敗しました\n再度選択しますか？", 2, "確認"
        				if (stat == 7) {
        					gsel overlayWindowId, -1
        					_break
        				}
                    }
                    ;bgWindowIdを最前面表示にして左上を仮想ディスプレイ左上に合わせる
                	gsel bgWindowId, 2
                	bgWindowIdHandle = hwnd
                	MoveWindow@ bgWindowIdHandle, VIRTUAL_DISPLAY_X, VIRTUAL_DISPLAY_Y, VIRTUAL_DISPLAY_W, VIRTUAL_DISPLAY_H, TRUE
                    ;マウスカーソルをクロス状に変更しておく
                	LoadCursor@ 0, MAKEINTRESOURCE
                	SetClassLong@ bgWindowIdHandle, GCL_HCURSOR, stat
                    ;overlayWindowIdを非表示にしておく
                	gsel overlayWindowId, -1
                	overlayWindowIdHandle = hwnd
                	MoveWindow@ overlayWindowIdHandle, 0, 0, 0, 0, TRUE
                    ;選択範囲をリセット
                    selectBeginPos.0 = 0, 0 //選択開始時のマウス座標(スクリーン座標系)
                    selectAreaRect.0 = 0, 0, 0, 0   //選択範囲のRect(スクリーン座標系)
                }
            }
            await 16
        wend

        // カレントウィンドウを元に戻す
        gsel currentWindowId
    return rectangleCount

    /**
     * ListMakerModule#CheckKanCollePosのコードを斜め読みして再現した
     * つまり、「縦横比が正しいか」「クロップ枠と1ピクセル内側の色が違うか」を見ている
     */
    #defcfunc local isValidRect int windowId, int rectX, int rectY, int rectW, int rectH
        logmes("isValidRect")
        /* 縦横比が正しいか？ */
        aspect_ratio_diff = absf(BASE_ASPECT_RATIO - 1.0 * rectW / rectH)
        if (aspect_ratio_diff > 0.021) :return FALSE

        /* クロップ枠と1ピクセル内側の色が違うか？ */
        // 以前のカレントウィンドウIDを記憶
        currentWindowId = ginfo_sel
        // 定数を準備
        ddim ratio, 5
    	ratio = 0.9, 0.82, 0.73, 0.5, 0.12
        // 各辺について確認する
        gsel windowId
        result = FALSE
        while(TRUE)
            // 上枠について確認する
            flg1 = TRUE
            tempColor = _pget(rectX + ratio(0) * rectW, rectY - 1)
            for k, 1, length(ratio)
                if (_pget(rectX + ratio(k) * rectW, rectY - 1) != tempColor) {
                    flg1 = FALSE
                    _break
                }
            next
            if (flg1 == FALSE) :_break
            flg2 = FALSE
            for k, 0, length(ratio)
                if (_pget(rectX + ratio(k) * rectW, rectY) != tempColor) {
                    flg = TRUE
                    _break
                }
            next
            if (flg1 == FALSE) :_break
            // 下枠
            flg1 = TRUE
            tempColor = _pget(rectX + ratio(0) * rectW, rectY + rectH)
            for k, 1, length(ratio)
                if (_pget(rectX + ratio(k) * rectW, rectY + rectH) != tempColor) {
                    flg1 = FALSE
                    _break
                }
            next
            if (flg1 == FALSE) :_break
            flg2 = FALSE
            for k, 0, length(ratio)
                if (_pget(rectX + ratio(k) * rectW, rectY + rectH - 1) != tempColor) {
                    flg = TRUE
                    _break
                }
            next
            if (flg1 == FALSE) :_break
            _break
            // 左枠
            flg1 = TRUE
            tempColor = _pget(rectX - 1, rectY + ratio(0) * rectH)
            for k, 1, length(ratio)
                if (_pget(rectX - 1, rectY + ratio(k) * rectH) != tempColor) {
                    flg1 = FALSE
                    _break
                }
            next
            if (flg1 == FALSE) :_break
            flg2 = FALSE
            for k, 0, length(ratio)
                if (_pget(rectX, rectY + ratio(k) * rectH) != tempColor) {
                    flg = TRUE
                    _break
                }
            next
            if (flg1 == FALSE) :_break
            // 右枠
            flg1 = TRUE
            tempColor = _pget(rectX + rectW, rectY + ratio(0) * rectH)
            for k, 1, length(ratio)
                if (_pget(rectX + rectW, rectY + ratio(k) * rectH) != tempColor) {
                    flg1 = FALSE
                    _break
                }
            next
            if (flg1 == FALSE) :_break
            flg2 = FALSE
            for k, 0, length(ratio)
                if (_pget(rectX + rectW - 1, rectY + ratio(k) * rectH) != tempColor) {
                    flg = TRUE
                    _break
                }
            next
            if (flg1 == FALSE) :_break
            //
            result = TRUE
            _break
        wend
        // カレントウィンドウを元に戻す
        gsel currentWindowId
    return result

    /**
     * ListMakerModule#getKanCollePosAutoで採用されているアルゴリズム
     */
    #defcfunc local Auto int windowId, array rectangles, int tempId
        /*startTime = timeGetTime@()*/

        /* 以前のカレントウィンドウIDを記憶 */
        currentWindowId = ginfo_sel

        /* 各種定数を初期化 */
        ;ゲーム画面として認識する最小サイズ
        MIN_GAME_WINDOW_WIDTH = int(MIN_ZOOM_RATIO * DEFAULT_GAME_WINDOW_WIDTH)
        MIN_GAME_WINDOW_HEIGHT = int(MIN_ZOOM_RATIO * DEFAULT_GAME_WINDOW_HEIGHT)
        ;ゲーム画面として認識する最大サイズ
        MAX_GAME_WINDOW_WIDTH = int(MAX_ZOOM_RATIO * DEFAULT_GAME_WINDOW_WIDTH)
        MAX_GAME_WINDOW_HEIGHT = int(MAX_ZOOM_RATIO * DEFAULT_GAME_WINDOW_HEIGHT)
        ;最小サイズのウィンドウの大きさ-1をSTEP_COUNTで割った間隔で画素を読み取る
        ;※例えば、ワーストケースでMIN_GAME_WINDOW_WIDTH=301だったとしても、
        ;　STEP_WIDTHは100になる。すると、横幅がMIN_GAME_WINDOW_WIDTHな画面を
        ;　STEP_WIDTH間隔で引かれた方眼の上で動かした場合、画面の上辺に少なくとも
        ;　STEP_COUNT本の方眼の線が通ることが保証される
        ; (※実際には、HSPの速度上の問題により、STEP_COUNT=2としてループアンローリングしている)
        STEP_WIDTH = (MIN_GAME_WINDOW_WIDTH - 1) / 2
        STEP_HEIGHT = (MIN_GAME_WINDOW_HEIGHT - 1) / 2
        /*endTime = timeGetTime@()
        logmes "" + (endTime - startTime) + "ms"
        startTime = endTime*/

        /**
         * 上辺を検出(PHASE1・PHASE2相当)
         * 1. STEP_WIDTHピクセルごとに画素を読み取る(Y=yとY=y+1)
         * 2. 以下の2配列の中で、「A1〜A{STEP_COUNT}は全部同じ色」かつ
         *    「B1〜B{STEP_COUNT}のどれかはAxと違う色」である箇所を見つける
         *   Y=y  [..., A1, A2, .., A{STEP_COUNT}, ...]
         *   Y=y+1[..., B1, B2, .., B{STEP_COUNT}, ...]
         * STEP_WIDTHを上記計算式にしているのは、Y=yにおいて確実に
         * 「位置A1〜A{STEP_COUNT}」の区間の長さ⊆ゲーム画面の最小横幅(MIN_GAME_WINDOW_WIDTH)
         * とするためである。「⊆」が満たされないと取りこぼしが発生しかねない。
         * また、「B1〜B{STEP_COUNT}のどれかはAxと違う色」でないと、関数定義における
         * 「↑の1ピクセル内側に、色Aと異なる色が1ピクセル以上存在する」を満たせない
         * 可能性が生じる(ステップサーチなので「可能性」で弾いている)。
         *
         * なお、rectYList1はY=yの列のy座標、rectXList1はそれぞれにおけるA1のX座標である
         */
        gsel windowId
        windowWidth = ginfo_winx
        windowHeight = ginfo_winy
        buffer tempId, windowWidth, windowHeight
        chgbm@ 32
        mref vram, MREF_VRAM
        gcopy windowId, 0, 0, windowWidth, windowHeight
        dim rectXList1, 5 :dim rectYList1, 5 :rectList1Size = 0
        LIMIT_WIDTH = windowWidth - MIN_GAME_WINDOW_WIDTH - 1
        LIMIT_HEIGHT = windowHeight - MIN_GAME_WINDOW_HEIGHT - 1
        for y, 0, LIMIT_HEIGHT
            // まず、Y=yの候補を検索する
            for x, 0, LIMIT_WIDTH, STEP_WIDTH
                // 辺の色の候補を取得
                tempColor = _pget2(x, y)
                // Y=yの候補たりうるかを調査し、駄目ならスキップする
                if (_pget2(x + STEP_WIDTH, y) != tempColor) :_continue
                if (_pget2(x + STEP_WIDTH * 2, y) != tempColor) :_continue
                // Y=y+1の方もチェックする
                if (_pget2(x, y + 1) != tempColor) {
                    // 候補が見つかったので追加
                    rectYList1(rectList1Size) = y
                    rectXList1(rectList1Size) = x
                    rectList1Size++
                }else: if (_pget2(x + STEP_WIDTH, y + 1) != tempColor) {
                    // 候補が見つかったので追加
                    rectYList1(rectList1Size) = y
                    rectXList1(rectList1Size) = x
                    rectList1Size++
                }else: if (_pget2(x + STEP_WIDTH * 2, y + 1) != tempColor) {
                    // 候補が見つかったので追加
                    rectYList1(rectList1Size) = y
                    rectXList1(rectList1Size) = x
                    rectList1Size++
                }
            next
        next
        /*endTime = timeGetTime@()
        logmes "" + (endTime - startTime) + "ms"
        startTime = endTime*/

        /**
         * 上辺を確認(PHASE3相当)
         * A1〜A{STEP_COUNT}が同じ色かを確認する
         */
        dim rectXList2, 5 :dim rectYList2, 5 :rectList2Size = 0
        for k, 0, rectList1Size
            tempColor = _pget2(rectXList1(k), rectYList1(k))
            flg = TRUE
            xLimit = rectXList1(k) + 2 * STEP_WIDTH
            y = rectYList1(k)
            for x, rectXList1(k) + 1, xLimit
                if (_pget2(x, y) != tempColor) :flg = FALSE :_break
            next
            if (flg) {
                // 候補が見つかったので追加
                rectXList2(rectList2Size) = rectXList1(k)
                rectYList2(rectList2Size) = rectYList1(k)
                rectList2Size++
            }
        next
        /*endTime = timeGetTime@()
        logmes "" + (endTime - startTime) + "ms"
        startTime = endTime*/

        /**
         * 左辺を検出(PHASE4相当)
         * 上辺の候補の左側を走査し、左辺となりうる辺を持ちうるかを調査する
         * ・上記のA1ピクセルより左側STEP_WIDTHピクセルの間に、「左上座標」の候補があると考えられる
         * ・ゆえに順番に1ピクセルづつ見ていき、縦方向の辺を持ちうるかをチェックする
         * ・候補になりうるかの判定には、上辺の検索と同じくステップサーチを用いる
         */
        dim rectXList3, 5 :dim rectYList3, 5 :rectList3Size = 0
        for k, 0, rectList2Size
            tempColor = _pget2(rectXList2(k), rectYList2(k))
            xLimit = Max(rectXList2(k) - STEP_WIDTH, -1)
            y0 = rectYList2(k)
            y1 = rectYList2(k) + STEP_HEIGHT
            y2 = rectYList2(k) + STEP_HEIGHT * 2
            for x, rectXList2(k) - 1, xLimit, -1
                if (_pget2(x, y0) != tempColor) :_break
                // X=xの候補たりうるかを調査し、駄目ならスキップする
                if (_pget2(x, y1) != tempColor) :_continue
                if (_pget2(x, y2) != tempColor) :_continue
                // X=x+1の方もチェックする
                if (_pget2(x + 1, y1) != tempColor) {
                    // 候補が見つかったので追加
                    rectXList3(rectList3Size) = x
                    rectYList3(rectList3Size) = rectYList2(k)
                    rectList3Size++
                }else: if (_pget2(x + 1, y2) != tempColor) {
                    // 候補が見つかったので追加
                    rectXList3(rectList3Size) = x
                    rectYList3(rectList3Size) = rectYList2(k)
                    rectList3Size++
                }
            next
        next
        /*endTime = timeGetTime@()
        logmes "" + (endTime - startTime) + "ms"
        startTime = endTime*/

        /**
         * 左辺を確認(PHASE5相当)
         * 左辺が同じ色かを確認する
         */
        dim rectXList4, 5 :dim rectYList4, 5 :rectList4Size = 0
        for k, 0, rectList3Size
            tempColor = _pget2(rectXList3(k), rectYList3(k))
            flg = TRUE
            yLimit = rectYList3(k) + 2 * STEP_HEIGHT
            for y, rectYList3(k) + 1, yLimit
                if (_pget2(rectXList3(k), y) != tempColor) :flg = FALSE :_break
            next
            if (flg) {
                // 候補が見つかったので追加
                rectXList4(rectList4Size) = rectXList3(k)
                rectYList4(rectList4Size) = rectYList3(k)
                rectList4Size++
            }
        next
        /*endTime = timeGetTime@()
        logmes "" + (endTime - startTime) + "ms"
        startTime = endTime*/

        /**
         * 右辺・下辺を確認し、候補に追加する
         */
        ddim ratio, 5
        ratio = 0.9, 0.82, 0.73, 0.5, 0.12
        dim rectangles, 4 :rectangleSize = 0
        for k, 0, rectList4Size
            // xは枠の右下x座標
            for x, rectXList4(k) + MIN_GAME_WINDOW_WIDTH + 1, windowWidth
                w = x - rectXList4(k) - 1
                // 枠の右下y座標を算出
                y = Min(rectYList4(k) + BASE_ASPECT_RATIO * w + 1, windowHeight - 1)
                h = y - rectYList4(k) - 1
                // 枠の色を取得
                tempColor = _pget2(rectXList4(k), rectYList4(k))
                // 走査(右辺)
                flg1 = TRUE
                for j, 0, length(ratio)
                    if (_pget2(x, rectYList4(k) + ratio(j) * h + 1) != tempColor) {
                        flg1 = FALSE
                        _break
                    }
                next
                if (flg1 == FALSE){
                    _continue
                }
                flg2 = FALSE
                for j, 0, length(ratio)
                    if (_pget2(x - 1, rectYList4(k) + ratio(j) * h + 1) != tempColor) {
                        flg2 = TRUE
                        _break
                    }
                next
                if (flg2 == FALSE) {
                    _continue
                }
                // 走査(下辺)
                flg1 = TRUE
                for j, 0, length(ratio)
                    if (_pget2(rectXList4(k) + ratio(j) * w + 1, y) != tempColor) {
                        flg1 = FALSE
                        _break
                    }
                next
                if (flg1 == FALSE) {
                    _continue
                }
                flg2 = FALSE
                for j, 0, length(ratio)
                    if (_pget2(rectXList4(k) + ratio(j) * w + 1, y - 1) != tempColor) {
                        flg2 = TRUE
                        _break
                    }
                next
                if (flg2 == FALSE) {
                    _continue
                }
                // 追記
                rectangles(0, rectangleSize) = rectXList4(k) + 1, rectYList4(k) + 1, w, h
                rectangleSize++
            next
        next
        /*endTime = timeGetTime@()
        logmes "" + (endTime - startTime) + "ms"
        startTime = endTime*/

        /* カレントウィンドウを元に戻す */
        gsel currentWindowId
        /*endTime = timeGetTime@()
        logmes "" + (endTime - startTime) + "ms"
        startTime = endTime*/
    return rectangleSize
#global

#if 0
    title "座標取得処理のテスト"
    buffer 1
    picload "座標認識テスト用-2.png"

    /*// アルゴリズム1
    dim rectangles //無くてもいいが警告消しに使用
    gsel 1 :count = SemiAuto@SearchKanCollePos(1, rectangles, 1059, 1099) :gsel 0
    mes "【アルゴリズム1】"
    gosub *show_result

    // アルゴリズム2
    gsel 1 :count = Auto@SearchKanCollePos(1, rectangles) :gsel 0
    mes "【アルゴリズム3】(" + elapsedTime + "ms)"
    gosub *show_result*/

    repeatTime = 10
    startTime = timeGetTime()
    for k, 0, repeatTime
        gsel 1 :gsel 0
    next
    elapsedTime1 = timeGetTime() - startTime
    startTime = timeGetTime()
    for k, 0, repeatTime
        gsel 1 :count = Auto@SearchKanCollePos(1, rectangles) :gsel 0
    next
    elapsedTime2 = timeGetTime() - startTime

    mes "【アルゴリズム3】(" + (1.0 * (elapsedTime2 - elapsedTime1) / repeatTime) + "ms)"

    //gsel 1 :count = Auto@SearchKanCollePos(1, rectangles) :gsel 0

    gosub *show_result
    assert
    end

    *show_result
        mes "個数：" + count
        sdim textBuffer, 4096
        for k, 0, count
            x = rectangles(0, k)
            y = rectangles(1, k)
            w = rectangles(2, k)
            h = rectangles(3, k)
            textBuffer += strf("(%d,%d)-%dx%d,", x, y, w, h)
        next
        mes "候補：" + textBuffer
    return
#endif
