/**
 * ユーティリティ関数のモジュール
 */
#module kmodule
	/* WinAPI */
	#uselib "user32.dll"
		#func GetSystemMetrics "GetSystemMetrics" int
	#const SM_CYCAPTION		4
	#const SM_CXDLGFRAME	7
	#const SM_CYDLGFRAME	8
	#const SM_CXFRAME		32
	#const SM_CYFRAME		33

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
	 * menuW : タイトルバーがあり、サイズ可変ウィンドウの周囲を囲む枠の幅
	 */
	#deffunc local Init
		menuH = GetSystemMetrics(SM_CYCAPTION) + GetSystemMetrics(SM_CXFRAME)
		menuW = GetSystemMetrics(SM_CYFRAME)
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
	 * バイナリを無理やり文字列にして返す(与えられた変数中のNull文字をスペースに置換する)
	 * @param in 入力バイナリの入った変数
	 * @param len バイナリのサイズ(Byte)
	 * @return 文字列
	 */
	#defcfunc b2s var in, int len
		sdim out, len+1
		memcpy out, in, len
		repeat len
			if (peek(out, cnt)==0):poke out, cnt, ' '
		loop
	return out

#global
