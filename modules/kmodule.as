/**
 * ユーティリティ関数のモジュール
 */
#module kmodule
	#uselib "user32.dll"
		#cfunc GetSystemMetrics "GetSystemMetrics" int

	#defcfunc kmexist str file_path
		exist file_path
	return strsize

	#deffunc kmmouse_init
		menuh = GetSystemMetrics(4)+GetSystemMetrics(8)
		menuw = GetSystemMetrics(7)
	return

	#define global kmmousex kmmousex_()

	#define global kmmousey kmmousey_()

	#defcfunc kmmousex_
	return (ginfo(0)-ginfo(4)-menuw)

	#defcfunc kmmousey_
	return (ginfo(1)-ginfo(5)-menuh)

	#defcfunc kmnoteget int a
		noteget s,a
	return s

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
		strrep@encdata,"\n",""
	return encdata

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
