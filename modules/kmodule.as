/**
 * ユーティリティ関数のモジュール
 */
#module kmodule
	/* WinAPI */
	#uselib "user32.dll"
		#func GetSystemMetrics "GetSystemMetrics" int
	#const SM_CYCAPTION 4
	#const SM_CXDLGFRAME 7
	#const SM_CYDLGFRAME 8

	/**
	 * exist命令の関数版
	 * (※グローバル変数strsizeを変更する)
	 * @param file_path 存在しているかを確認したいファイルのパス
	 * @return ファイルパスがfile_pathの場所にファイルが存在していればファイルサイズ、そうでない場合は-1
	 */
	#defcfunc _exist str file_path
		exist file_path
	return strsize

	/**
	 * 指定したパスにあるファイルを安全に削除する
	 * (存在しないパスに対してdelete命令を実行するとエラーになるため)
	 * @param file_path ファイルのパス
	 * @return ファイルパスの先にあるファイルが存在する時にのみファイルを削除
	 */
	#deffunc local SafeDelete str file_path
		if _exist(file_path) >= 0 :delete file_path
	return

	/**
	 * 以下のフィールドの値を初期化する
	 * menuH : 通常のタイトルバーの高さ＋タイトルバーがあり、サイズが変更できないウィンドウの周囲を囲む枠の高さ
	 * menuW : タイトルバーがあり、サイズが変更できないウィンドウの周囲を囲む枠の幅
	 */
	#deffunc local Init
		menuH = GetSystemMetrics(SM_CYCAPTION) + GetSystemMetrics(SM_CYDLGFRAME)
		menuW = GetSystemMetrics(SM_CXDLGFRAME)
	return

	/**
	 * 先のフィールド値と併せて考えると、
	 * _mousex : マウスカーソルのウィンドウに対する相対X座標で、mousexとほぼ同じ意味
	 * _mousey : マウスカーソルのウィンドウに対する相対Y座標で、mouseyとほぼ同じ意味
	 */
	#define global _mousex mousex_()
	#defcfunc mousex_
	return (ginfo_mx - ginfo_wx1 - menuW)

	#define global _mousey mousey_()
	#defcfunc mousey_
	return (ginfo_my - ginfo_wy1 - menuH)

	/**
	 * 現在noteselしている文字列型に対し、指定した行の文字列を返す
	 * @param line_number 行数指定
	 * @return (line_number+1)行目の文字列
	 */
	#defcfunc _noteget int lineNumber
		noteget retVal, lineNumber
	return retVal

	/**
	 * 与えられた文字列を暗号化する
	 */
	#defcfunc local EncStr str p1_
		len = strlen(p1_)
		sdim p1, len + 1
		sdim encdata, int(1.5 * len) + 3
		p1 = p1_
		randomize 3141
		repeat len
			poke p1, cnt, (peek(p1, cnt) xor rnd(256))
		loop
		randomize 5926
		repeat len
			poke p1, cnt, (peek(p1, cnt) xor rnd(256))
		loop
		randomize 5358
		repeat len
			poke p1, cnt, (peek(p1, cnt) xor rnd(256))
		loop
		Encode@machine_base64 p1, len, encData
		encData = strf("%02X%s", len, encData)
		strrep encData, "\n", ""
	return encData

	/**
	 * 与えられた文字列を暗号化する
	 */
	#defcfunc local DecStr var p1_
		len = int("$" + strmid(p1_, 0,2 ))
		sdim p1, strlen(p1_) + 1
		sdim decData, len + 10
		p1 = strmid(p1_, 2, strlen(p1_) - 2)
		Decode@machine_base64 p1, strlen(p1), decData
		randomize 3141
		repeat len
			poke decData, cnt, (peek(decData, cnt) xor rnd(256))
		loop
		randomize 5926
		repeat len
			poke decData, cnt, (peek(decData, cnt) xor rnd(256))
		loop
		randomize 5358
		repeat len
			poke decData, cnt, (peek(decData, cnt) xor rnd(256))
		loop
	return decData
#global
