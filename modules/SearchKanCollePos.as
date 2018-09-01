/**
 * 艦これの座標を画面から検索するモジュール
 * 基本的には「ウィンドウIDを受け取ると、Rectangleの候補一覧と候補数を返す」ように揃えている
 */
#module SearchKanCollePos
    /* 各種定数設定 */
    #const DEFAULT_GAME_WINDOW_WIDTH 1200  //標準的なゲーム画面のXサイズ
    #const DEFAULT_GAME_WINDOW_HEIGHT 720  //標準的なゲーム画面のYサイズ
    #const MAX_ZOOM_RATIO 3  //ゲーム画面がMAX_ZOOM_RATIO倍まで大きくてもOK、といった意味
    #const STICK_ESCBUTTON 128
    #const STICK_LEFTBUTTON 256
    #const STICK_RIGHTBUTTON 512
    #define TRUE 1
    #define FALSE 0

    #const SM_XVIRTUALSCREEN 76
    #const SM_YVIRTUALSCREEN 77
    #const SM_CXVIRTUALSCREEN 78
    #const SM_CYVIRTUALSCREEN 79
    #const IDC_ARROW 32512
    #const MAKEINTRESOURCE 32515
    #const GCL_HCURSOR -12

    #const VIRTUAL_DISPLAY_X GetSystemMetrics(SM_XVIRTUALSCREEN)
	#const VIRTUAL_DISPLAY_Y GetSystemMetrics(SM_YVIRTUALSCREEN)
	#const VIRTUAL_DISPLAY_W GetSystemMetrics(SM_CXVIRTUALSCREEN)
	#const VIRTUAL_DISPLAY_H GetSystemMetrics(SM_CYVIRTUALSCREEN)

    /* 最小値を返す */
    #defcfunc local Min int a, int b
        if (a > b) :return b
    return a

    /* 最大値を返す */
    #defcfunc local Max int a, int b
        if (a > b) :return a
    return b

    /* 指定した点のRGB値を取得する。(R<<16)+(G<<8)+B */
    #defcfunc local _pget int x, int y
        pget x, y
    return (ginfo_r << 16) + (ginfo_g << 8) + (ginfo_b)

    /**
     * ListMakerModule#getKanCollePosで採用されているアルゴリズム
     * (mx, my)は艦これの画面内の(ウィンドウIDに対する)1座標であり、それを含む艦これの画面を検出する
     */
    #defcfunc local method1 int windowId, array rectangles, int mx, int my
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
        dim rectangles, 1, 4
        rectangles(0, 0) = _lx + 1
        rectangles(0, 1) = _ly + 1
        rectangles(0, 2) = _width
        rectangles(0, 3) = _height
    return 1

    /**
     * ListMakerModule#KanCollePosManualで採用されているアルゴリズム
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
     */
    #defcfunc local method2 int windowId, array rectangles, int overlayWindowId, int bgWindowId
        // 以前のカレントウィンドウIDを記憶
        currentWindowId = ginfo_sel

        // 保存用のバッファーを用意
        dim rectangles, 1, 4
        rectangles(0, 0) = 0
        rectangles(0, 1) = 0
        rectangles(0, 2) = 0
        rectangles(0, 3) = 0
        rectangleCount = 0

        // ウィンドウ周りの準備を行う
        ;bgWindowIdを最前面表示にして左上を仮想ディスプレイ左上に合わせる
    	gsel bgWindowId, 2
    	bgWindowIdHandle = hwnd
    	MoveWindow bgWindowIdHandle, VIRTUAL_DISPLAY_X, VIRTUAL_DISPLAY_Y, VIRTUAL_DISPLAY_W, VIRTUAL_DISPLAY_H, TRUE
        ;マウスカーソルをクロス状に変更しておく
    	LoadCursor 0, MAKEINTRESOURCE
    	SetClassLong bgWindowIdHandle, GCL_HCURSOR, stat
        ;overlayWindowIdを非表示にしておく
    	gsel overlayWindowId, -1
    	overlayWindowIdHandle = hwnd
    	MoveWindow overlayWindowIdHandle, 0, 0, 0, 0, 0

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
                    gsel imageid3, 2
    				MoveWindow overlayWindowIdHandle, selectAreaRect(0), selectAreaRect(1), selectAreaRect(2), selectAreaRect(3), TRUE
                 }
            }else :if ((ky & STICK_ESCBUTTON) || (ky & STICK_RIGHTBUTTON)){
                // Escキー or 右マウスボタンを押した際の処理
                ; オーバーレイウィンドウを非表示にする
                gsel overlayWindowId, -1
                ; bgWindowIdにおけるマウスポインタの設定を元に戻す
    			gsel bgWindowId
    			LoadCursor 0, IDC_ARROW
    			SetClassLong bgWindowId, GCL_HCURSOR, stat
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
        			LoadCursor 0, IDC_ARROW
        			SetClassLong bgWindowId, GCL_HCURSOR, stat
                    ; bgWindowIdを非表示にする
        			gsel bgWindowId, -1

                    // 選択部分から艦これの画面を検出する
                    gsel windowId
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
                            rectangles(0, 2) = px - rectangles(0, 0)
                            _break
                        }
                    next
                    ;次に上辺
                    tempColor = _pget(tempRect(0) + tempRect(2) / 2, tempRect(1))
                    for py, tempRect(1), tempRect(1) + tempRect(3) / 2
                        if (_pget(tempRect(0) + tempRect(2) / 2, py) != tempColor) {
                            rectangles(0, 1) = py
                            _break
                        }
                    next
                    ;最後に下辺
                    tempColor = _pget(tempRect(0) + tempRect(2) / 2, tempRect(1) + tempRect(3))
                    for py, tempRect(1) + tempRect(3), tempRect(1) + tempRect(3) / 2, -1
                        if (_pget(tempRect(0) + tempRect(2) / 2, py) != tempColor) {
                            rectangles(0, 3) = py - rectangles(0, 1)
                            _break
                        }
                    next

                    // 検出できているかを確認する。駄目なら再度選択させる
                    if (tempRect(2) >= 99 && tempRect(3) >= 59) {
                        gsel overlayWindowId, 2
        				MoveWindow overlayWindowIdHandle, tempRect(0) + VIRTUAL_DISPLAY_X, tempRect(1), + VIRTUAL_DISPLAY_Y tempRect(2), tempRect(3), TRUE
        				dialog "正しく取得できていますか？", 2, "確認"
        				if (stat == 6) {
        					gsel overlayWindowId, -1
                            rectangles(0, 0) = tempRect(0)
                            rectangles(0, 1) = tempRect(1)
                            rectangles(0, 2) = tempRect(2)
                            rectangles(0, 3) = tempRect(3)
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
                	MoveWindow bgWindowIdHandle, VIRTUAL_DISPLAY_X, VIRTUAL_DISPLAY_Y, VIRTUAL_DISPLAY_W, VIRTUAL_DISPLAY_H, TRUE
                    ;マウスカーソルをクロス状に変更しておく
                	LoadCursor 0, MAKEINTRESOURCE
                	SetClassLong bgWindowIdHandle, GCL_HCURSOR, stat
                    ;overlayWindowIdを非表示にしておく
                	gsel overlayWindowId, -1
                	overlayWindowIdHandle = hwnd
                	MoveWindow overlayWindowIdHandle, 0, 0, 0, 0, TRUE
                    ;選択範囲をリセット
                    selectBeginPos.0 = 0, 0 //選択開始時のマウス座標(スクリーン座標系)
                    selectAreaRect.0 = 0, 0, 0, 0   //選択範囲のRect(スクリーン座標系)
                }
            }
            await 16
            _break
        wend

        // カレントウィンドウを元に戻す
        gsel currentWindowId
    return rectangleCount
#global
