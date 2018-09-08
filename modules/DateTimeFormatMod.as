/**
 * 日付と時刻をフォーマット文字列から作成するモジュール
 */

#module DateTimeFormatMod

	#uselib "kernel32.dll"
	#func GetLocalTime "GetLocalTime" int

	/**
	 * 初期化処理
	 */
	#deffunc local Init

		dim localTime, 4

		eMonthFullArr = "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"	//MMMM
		eMonthAbbreviationsArr = "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"									//MMM

		eDayOfWeekFullArr = "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"											//edddd
		eDayOfWeekAbbreviationsArr = "Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"																//eddd

		jDayOfWeekFullArr = "日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"													//jdddd
		jDayOfWeekAbbreviationsArr = "日", "月", "火", "水", "木", "金", "土"																		//jddd

		eTimeDivisionArr = "AM","PM"		//ett
		jTimeDivisionArr = "午前","午後"	//jtt

	return

	/**
	 * 指定したフォーマットの文字列を返す
	 * @param _st フォーマット文字列
	 */
	#defcfunc local Format str _st

		sdim st
		st = _st

		GetLocalTime varptr(localTime)

		year4 = ""+ wpeek(localTime(0), 0)					//yyyy
		year2 = strf("%02d", wpeek(localTime(0), 0)\100)	//yy
		year1 = ""+ wpeek(localTime(0), 0) \ 100			//y

		month2 = strf("%02d", wpeek(localTime(0), 2))		//MM
		month1 = ""+ wpeek(localTime(0), 2)					//M

		mouhtNum = wpeek(localTime(0), 2) -1
		dayOfWeekNum = wpeek(localTime(1), 0)
		timeDivisionNum = wpeek(localTime(2), 0) / 12

		day2 = strf("%02d", wpeek(localTime(1), 2)) 		//dd
		day1 = ""+ wpeek(localTime(1), 2)					//d

		hour242 = strf("%02d", wpeek(localTime(2), 0))		//HH
		hour241 = ""+ wpeek(localTime(2), 0)				//H

		hour122 = strf("%02d", wpeek(localTime(2), 0) \ 12)	//hh
		hour121 = ""+ wpeek(localTime(2), 0) \ 12			//h

		min2 = strf("%02d", wpeek(localTime(2), 2))			//mm
		min1 = ""+ wpeek(localTime(2), 2)					//m

	 	sec2 = strf("%02d", wpeek(localTime(3), 0))			//ss
	 	sec1 = ""+ wpeek(localTime(3), 0)					//s

	 	msec = strf("%03d", wpeek(localTime(3), 2))			//ms

		strrep st, "<yyyy>", year4
		strrep st, "<yy>", year2
		strrep st, "<y>", year1
		strrep st, "<MMMM>", eMonthFullArr(mouhtNum)
		strrep st, "<MMM>", eMonthAbbreviationsArr(mouhtNum)
		strrep st, "<MM>", month2
		strrep st, "<M>", month1
		strrep st, "<edddd>", eDayOfWeekFullArr(dayOfWeekNum)
		strrep st, "<eddd>", eDayOfWeekAbbreviationsArr(dayOfWeekNum)
		strrep st, "<jdddd>", jDayOfWeekFullArr(dayOfWeekNum)
		strrep st, "<jddd>", jDayOfWeekAbbreviationsArr(dayOfWeekNum)
		strrep st, "<dd>", day2
		strrep st, "<d>", day1
		strrep st, "<hh>", hour122
		strrep st, "<h>", hour121
		strrep st, "<ett>", eTimeDivisionArr(timeDivisionNum)
		strrep st, "<jtt>", jTimeDivisionArr(timeDivisionNum)
		strrep st, "<HH>",hour242
		strrep st, "<H>", hour241
		strrep st, "<mm>", min2
		strrep st, "<m>", min1
		strrep st, "<ss>", sec2
		strrep st, "<s>", sec1
		strrep st, "<ms>", msec

	return st

    /**
	 * ファイル名として利用できない文字が無いかチェックする
	 * @param _st フォーマット文字列
	 */
	#deffunc local isValidFileName str _filename
        sdim filename
		filename = _filename
		if instr(filename, 0, "<") != -1: return 0
		if instr(filename, 0, ">") != -1: return 0
		if instr(filename, 0, "\\") != -1: return 0
		if instr(filename, 0, "/") != -1: return 0
		if instr(filename, 0, ":") != -1: return 0
		if instr(filename, 0, "*") != -1: return 0
		if instr(filename, 0, "?") != -1: return 0
		if instr(filename, 0, "!") != -1: return 0
		if instr(filename, 0, "\"") != -1: return 0
		if instr(filename, 0, "|") != -1: return 0
	return 1

    /**
	 * ミリ秒を"mm:ss:ms"形式の文字列に変換する
	 * @param _ms ミリ秒
	 */
	#defcfunc local cnvMilliSecondToMMSSMS int _ms
		ms = limit(_ms, 0, 5999999)
	return strf("%02d:%02d.%03d", (ms/1000/60), (ms/1000\60), (ms\1000))

#global
Init@DateTimeFormatMod


#if 0 //サンプル

	st =  "年　　　　<yyyy>-<yy>-<y>\n"
	st += "月　　　　<MMMM>-<MMM>-<MM>-<M>\n"
	st += "曜日　　　<edddd>-<jdddd>-<eddd>-<jddd>\n"
	st += "日　　　　<dd>-<d>\n"
	st += "午前午後　<ett>-<jtt>\n"
	st += "12時間　　<hh>-<h>\n"
	st += "24時間　　<HH>-<H>\n"
	st += "分　　　　<mm>-<m>\n"
	st += "秒　　　　<ss>-<s>\n"
	st += "ミリ秒　　<ms>"

	mes Format@DateTimeFormatMod(st)

	isValidFileName@DateTimeFormatMod "d"
	mes stat

	isValidFileName@DateTimeFormatMod "<>"
	mes stat

	stop

#endif
