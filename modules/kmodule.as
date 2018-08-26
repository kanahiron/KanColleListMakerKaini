/**
 * ユーティリティ関数のモジュール
 */
#module kmodule
	/* WinAPI */
	#uselib "user32.dll"
		#cfunc GetSystemMetrics "GetSystemMetrics" int
	#const SM_CYCAPTION 4
	#const SM_CXDLGFRAME 7
	#const SM_CYDLGFRAME 8

	/**
	 * 指定したファイルパスにファイルが存在するかを判定する
	 * (※グローバル変数strsizeを変更する)
	 * @param path 存在しているかを確認したいファイルのパス
	 * @return ファイルパスがpathの場所にファイルが存在していれば1、そうでない場合は0
	 */
	#defcfunc kmexist str file_path
		exist file_path
	return strsize

	/**
	 * 以下のフィールドの値を初期化する
	 * menuh : 通常のタイトルバーの高さ＋タイトルバーがあり、サイズが変更できないウィンドウの周囲を囲む枠の高さ
	 * menuw : タイトルバーがあり、サイズが変更できないウィンドウの周囲を囲む枠の幅
	 */
	#deffunc kmmouse_init
		menuh = GetSystemMetrics(SM_CYCAPTION) + GetSystemMetrics(SM_CYDLGFRAME)
		menuw = GetSystemMetrics(SM_CXDLGFRAME)
	return

	/**
	 * 先のフィールド値と併せて考えると、
	 * kmmousex : マウスカーソルのウィンドウに対する相対X座標で、mousexとほぼ同じ意味
	 * kmmousey : マウスカーソルのウィンドウに対する相対Y座標で、mouseyとほぼ同じ意味
	 */
	#define global kmmousex kmmousex_()
	#defcfunc kmmousex_
	return (ginfo_mx - ginfo_wx1 - menuw)

	#define global kmmousey kmmousey_()
	#defcfunc kmmousey_
	return (ginfo_my - ginfo_wy1 - menuh)

	/**
	 * 現在noteselしている文字列型に対し、指定した行の文字列を返す
	 * @param line_number 行数指定
	 * @return (line_number+1)行目の文字列
	 */
	#defcfunc kmnoteget int line_number
		noteget retval, line_number
	return retval

	/**
	 * 与えられた文字列を暗号化するものと思われる
	 * ただ、base64encode命令がgrepしても見つからない謎
	 */
	#defcfunc encstr str p1_,local len
		len = strlen(p1_)
		sdim p1,len+1
		sdim encdata,int(1.5*len)+3
		p1 = p1_
		randomize 3141
		repeat len
			poke p1,cnt,(peek(p1,cnt) xor rnd(256))
		loop
		randomize 5926
		repeat len
			poke p1,cnt,(peek(p1,cnt) xor rnd(256))
		loop
		randomize 5358
		repeat len
			poke p1,cnt,(peek(p1,cnt) xor rnd(256))
		loop
		base64encode p1,len,encdata
		encdata = strf("%02X%s",len,encdata)
		strrep　encdata,"\n",""
	return encdata

	/**
	 * 与えられた文字列を暗号化するものと思われる
	 * ただ、base64decode命令が（ｒｙ
	 */
	#defcfunc decstr var p1_,local len
		len = int("$"+strmid(p1_,0,2))
		sdim p1,strlen(p1_)+1
		sdim decdata,len+10
		p1 = strmid(p1_,2,strlen(p1_)-2)
		base64decode p1,strlen(p1),decdata
		randomize 3141
		repeat len
			poke decdata,cnt,(peek(decdata,cnt) xor rnd(256))
		loop
		randomize 5926
		repeat len
			poke decdata,cnt,(peek(decdata,cnt) xor rnd(256))
		loop
		randomize 5358
		repeat len
			poke decdata,cnt,(peek(decdata,cnt) xor rnd(256))
		loop
	return decdata
#global
