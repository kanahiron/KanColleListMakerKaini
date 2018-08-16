#module
	#uselib "kernel32"
	#func WritePrivateProfileString "WritePrivateProfileStringW" wstr, wstr, wstr, wstr
	#func GetPrivateProfileString "GetPrivateProfileStringW" wstr, wstr, wstr, int, int, wstr

	#deffunc SetIni str path
		inipath = path
		if instr(inipath, 0, ":") = -1 : inipath = "" : return 1
		fname = getpath(path, 8)
		fpath = getpath(path, 32)
		fpath = strmid(fpath, 0, strlen(fpath) - 1)
		opath = dir_cur
		chdir fpath
		inipath = dir_cur + "\\" + fname
		chdir opath
		exist inipath
		if strsize = -1 {
			tempBuf = ""
			wpoke tempBuf,0,0xFEFF
			bsave inipath,tempBuf,2

			return 2
		}
	return 0

	#define global GetIni(%1, %2, %3, %4="") GetIni_ %1, %2, %3, %4
	#deffunc GetIni_ str sect, str para, array vari, str defParam
		if inipath = "" : return 1

		sdim tempBuf,2082
		GetPrivateProfileString sect, para, "", varptr(tempBuf),2080, inipath
		if (stat == 0) {
			tempBuf = defParam
		} else {
			tempBuf = cnvwtos(tempBuf)
		}
		if (strmid(tempBuf,0,1) == "\""){
			//•¶š—ñŒ^
			strrep tempBuf,"\"\"","\""
			if (tempBuf == "\""){
				sdim vari
				return 0
			}
			dQuartoParse tempBuf,tempArray
			if (stat == 1):return 1
			sdim vari,256,length(tempArray)

			repeat length(tempArray)
				vari(cnt) = tempArray(cnt)
			loop

			return 0
		} else {
			//®”Œ^‚©À”Œ^

			tempBuf = "\""+ tempBuf +"\""
			dQuartoParse tempBuf,tempArray
			if (stat == 1):return 1

			if (instr(tempArray(0),0,".") == -1){
				//®”Œ^‚Å‚µ‚½
				dim vari, length(tempArray)
				repeat length(tempArray)
					vari(cnt) = int(tempArray(cnt))
				loop
				return 0
			} else {
				//À”Œ^‚Å‚µ‚½
				ddim vari, length(tempArray)
				repeat length(tempArray)
					vari(cnt) = double(tempArray(cnt))
				loop
				return 0
			}
		}

	return 1

	#deffunc WriteIni str sect, str para, array vari
		if inipath = "" : return 1

		sdim tempBuf,1040

		switch vartype(vari)
			case 2 //•¶š—ñŒ^
				repeat length(vari)
					tempBuf += "\"\""+vari(cnt)+"\"\", "
				loop
				tempBuf = strmid(tempBuf,0,strlen(tempBuf)-2)
				WritePrivateProfileString sect, para, tempBuf, inipath
				return 0
			swbreak

			case 3: case 4 //À”Œ^,®”Œ^
				repeat length(vari)
					tempBuf += "\""+str(vari(cnt))+"\", "
				loop
				tempBuf = strmid(tempBuf,0,strlen(tempBuf)-2)
				WritePrivateProfileString sect, para, tempBuf, inipath
				return 0
			swbreak

		swend
		return 1

#global

#module
#deffunc dQuartoParse var buf,array vari

	//buf = "\"‚ \\\"\\\"‚¢\\\"\\\"\\\"‚¤‚¦‚¨‚©\ \" ,\"‚±‚ñ‚¿‚­‚íI\""
	//mes "u"+buf+"v"

	count = 0
	index = 0
	temp1 = 0
	repeat
		temp1 = instr(buf,index,"\"")
		if (temp1 == -1):break
		if (strmid(buf,index+temp1-1,1) != "\\"):count++
		index += temp1+1
	loop

	if ((count\2) != 0) | (count == 0):return 1
	sdim vari,256,(count/2)

	temp1 = 0
	temp2 = 0
	index = 0

	repeat

		temp1 = instr(buf,index,"\"") + index
		temp2 = instr(buf,index+1,"\"") + index
		repeat
			if (strmid(buf,temp2,1) != "\\"):break
			temp2 = instr(buf,temp2+2,"\"") + temp2+1
		loop
		vari(cnt) =  strmid(buf,temp1+1,temp2-temp1)

		index = instr(buf,temp2+2,"\"") + temp2+2
		if (index == (instr(buf,index+1,"\"") + index+1)): break

	loop
return 0

#global
