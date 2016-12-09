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
		if strsize = -1 : return 2
	return 0
		
	#deffunc GetIni str sect, str para, var vari
		if inipath = "" : return 1
		switch vartype(vari)
			case 2
				sdim dummy,1024
				dupptr size, varptr(vari) - 16, 4
				GetPrivateProfileString sect, para, "", varptr(dummy),512, inipath
				vari = cnvwtos(dummy)
				return 0
			swbreak
	
			case 3
				sdim dummy
				GetPrivateProfileString sect, para, "", varptr(dummy), 64, inipath
				vari = double(cnvwtos(dummy))
				return 0
			swbreak
	
			case 4
				sdim dummy
				GetPrivateProfileString sect, para, "", varptr(dummy), 64, inipath
				vari = int(cnvwtos(dummy))
				return 0
			swbreak
		swend
		return 1
		
	#deffunc WriteIni str sect, str para, var vari
		if inipath = "" : return 1
		switch vartype(vari)
			case 2 : case 3 : case 4
				WritePrivateProfileString sect, para, str(vari), inipath
				return 0
		swend
		return 1
#global