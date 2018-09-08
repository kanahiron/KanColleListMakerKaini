/*
 * 独自形式のiniファイルを読み書きするモジュール
 * 文字列を2重のダブルクオート、実数、整数をダブルクオートで囲って表現する
 * 同じ型に限り配列を利用でき、カンマ区切りで表現する
 * 文字コードはUTF-16LE
 * ex)
 * 整数配列 : key="Integer1", "Integer2"
 * 文字列配列 : key=""String1"", ""String2""
 */

#module iniMod
	#uselib "kernel32"
	#func WritePrivateProfileString "WritePrivateProfileStringW" wstr, wstr, wstr, wstr
	#func GetPrivateProfileString "GetPrivateProfileStringW" wstr, wstr, wstr, int, int, wstr

	/**
	 * iniファイルを読み込む
	 * @param path iniファイルのパス
	 */
	#deffunc local Load str path
		inipath = path
		if instr(inipath, 0, ":") = -1 : inipath = "" : return 1
		fname = getpath(path, 8)
		fpath = getpath(path, 32)
		fpath = strmid(fpath, 0, strlen(fpath) - 1)
		opath = dir_cur
		chdir fpath
		inipath = dir_cur + "\\" + fname
		chdir opath
		if _exist(inipath) == -1 {
			tempBuf = ""
			wpoke tempBuf, 0, 0xFEFF
			bsave inipath, tempBuf, 2
			return 2
		}
	return 0

	/**
	 * 変数に値を読み込む 変数は自動的に初期化される
	 * @param sect セクション文字列
	 * @param para パラメタ文字列
	 * @param vari 値が返される変数
	 * @param defParam パラメタが存在しない場合に返されるデフォルト値
	 */
	#define Get(%1, %2, %3, %4="") Get_@iniMod %1, %2, %3, %4
	#deffunc local Get_ str sect, str para, array vari, str defParam
		if inipath = "" : return 1

		sdim tempBuf, 2082
		GetPrivateProfileString sect, para, "", varptr(tempBuf), 2080, inipath
		if (stat == 0) {
			tempBuf = defParam
		} else {
			tempBuf = cnvwtos(tempBuf)
		}
		if (strmid(tempBuf, 0, 1) == "\""){
			//文字列型
			strrep tempBuf, "\"\"", "\""
			if (tempBuf == "\""){
				sdim vari
				return 0
			}
			dQuartoParse@iniMod tempBuf, tempArray
			if (stat == 1):return 1
			sdim vari, 256, length(tempArray)

			repeat length(tempArray)
				vari(cnt) = tempArray(cnt)
			loop

			return 0
		} else {
			//整数型か実数型

			tempBuf = "\""+ tempBuf +"\""
			dQuartoParse@iniMod tempBuf, tempArray
			if (stat == 1):return 1

			if (instr(tempArray(0), 0, ".") == -1){
				//整数型でした
				dim vari, length(tempArray)
				repeat length(tempArray)
					vari(cnt) = int(tempArray(cnt))
				loop
				return 0
			} else {
				//実数型でした
				ddim vari, length(tempArray)
				repeat length(tempArray)
					vari(cnt) = double(tempArray(cnt))
				loop
				return 0
			}
		}

	return 1

	/**
	 * iniファイルに値を書き込む
	 * @param sect セクション文字列
	 * @param para パラメタ文字列
	 * @param vari 書き込む値の入った変数
	 */
	#deffunc local Write str sect, str para, array vari
		if inipath = "" : return 1

		sdim tempBuf, 1040

		switch vartype(vari)
			case 2 //文字列型
				repeat length(vari)
					tempBuf += "\"\""+vari(cnt)+"\"\", "
				loop
				tempBuf = strmid(tempBuf, 0, strlen(tempBuf)-2)
				WritePrivateProfileString sect, para, tempBuf, inipath
				return 0
			swbreak

			case 3: case 4 //実数型, 整数型
				repeat length(vari)
					tempBuf += "\""+str(vari(cnt))+"\", "
				loop
				tempBuf = strmid(tempBuf, 0, strlen(tempBuf)-2)
				WritePrivateProfileString sect, para, tempBuf, inipath
				return 0
			swbreak

		swend
	return 1

	/**
	 * ダブルクオートで囲まれた文字列をパースし配列変数に格納する
	 * @param buf ダブルクオートで囲まれた文字列
	 * @param vari 値が返される変数
	 */
	#deffunc local dQuartoParse var buf, array vari

		count = 0
		index = 0
		temp1 = 0
		repeat
			temp1 = instr(buf, index, "\"")
			if (temp1 == -1):break
			if (strmid(buf, index+temp1-1, 1) != "\\"):count++
			index += temp1+1
		loop

		if ((count\2) != 0) | (count == 0):return 1
		sdim vari, 256, (count/2)

		temp1 = 0
		temp2 = 0
		index = 0
		repeat

			temp1 = instr(buf, index, "\"") + index
			temp2 = instr(buf, index+1, "\"") + index
			repeat
				if (strmid(buf, temp2, 1) != "\\"):break
				temp2 = instr(buf, temp2+2, "\"") + temp2+1
			loop
			vari(cnt) = strmid(buf, temp1+1, temp2-temp1)

			index = instr(buf, temp2+2, "\"") + temp2+2
			if (index == (instr(buf, index+1, "\"") + index+1)): break

		loop
	return 0

#global
