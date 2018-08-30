/**
 * 艦これの座標を画面から検索するモジュール
 * 基本的には「ウィンドウIDを受け取ると、Rectangleの候補一覧と候補数を返す」ように揃えている
 */
#module SearchKanCollePos
    /* 各種定数設定 */
    #const DEFAULT_GAME_WINDOW_WIDTH 1200  //標準的なゲーム画面のXサイズ
    #const DEFAULT_GAME_WINDOW_HEIGHT 720  //標準的なゲーム画面のYサイズ
    #const MAX_ZOOM_RATIO 3  //ゲーム画面がMAX_ZOOM_RATIO倍まで大きくてもOK、といった意味
    #define TRUE 1
    #define FALSE 0

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
#global
