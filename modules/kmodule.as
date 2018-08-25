#module kmodule

	#define global acls color 255, 255, 255 : boxf : color

	#uselib "winmm.dll"
		#cfunc msec "timeGetTime"

	#uselib "user32.dll"
		#cfunc GetSystemMetrics "GetSystemMetrics" int
		#func mouse_event "mouse_event" int
		#func keybd_event "keybd_event" int, int, int

	#deffunc kmclick
		mouse_event 2
		await 34
		mouse_event 4
		await
	return

	#defcfunc kmmesmsec int msec_time
		msec_zi = msec_time/3600000
	 	msec_hun = (msec_time\3600000)/60000
	 	msec_byou = ((msec_time\3600000)\60000)/1000
	return strf("%02d時 %02d分 %02d秒",msec_zi,msec_hun,msec_byou)

	#defcfunc kmgetfps
		asad = msec() / 200
		fpss(asad&31)++ ; フレームカウント
		if bktp ! asad {
			bktp = asad
			cfps = 0

			repeat 5, 1
				cfps += fpss((asad-cnt)&31)
			loop

			repeat 20, 1
				fpss((asad+cnt)&31) = 0
			loop
		}
	return cfps

	#defcfunc kmflick int sticksign, int flicklen
		mousey_ = mousey
		if sticksign & 256 {
			if flag = 0{
				flag = 1
				my = mousey_
			}
		} else {
			if flag {
				flag = 0
				if (abs(my-mousey_) > flicklen) & (my != 0) {
					my = 0
					return 2
				}
				if (abs(mousey_ - my) > flicklen) & (my != 0) {
					my = 0
					return 4
				}
			} else {
				return 0
			}
		}
	return -1

	#defcfunc kmflick2 int kf_sti
		kf_mx2 = mousex
		kf_my2 = mousey
		kf_flicklen = 100
		kf_clicklen = 5
		if kf_sti & 256{
			if kf_flag = 0{
				kf_flag = 1
				kf_mx = mousex
				kf_my = mousey
			}
		} else {
			if kf_flag {
				kf_flag = 0
				if ((kf_mx-kf_mx2) > kf_kflicklen){
					rv = 1
				}
				if ((kf_mx-kf_mx2) < (kf_flicklen*-1)){
					rv = 4
				}
				if ((kf_my-kf_my2) > kf_flicklen){
					rv = 2
				}
				if ((kf_my-kf_my2) < (kf_flicklen*-1)){
					rv = 8
				}
				kf_mx = kf_mx2
				kf_my = kf_my2
			} else {
				rv = -1
			}
		}
		if rv != -1{
			kf_framecount = 0
			kf_flag2 = 0
			kf_flag3 = 0
			kf_clickcount = 0
		}
		if kf_sti & 256{
			if kf_flag2 = 0 & kf_framecount = 0{
				kf_flag2 = 1
				kf_framecount = kf_clicklen
			}
			if kf_framecount & kf_flag3 = 0{
				kf_clickcount++
			}
			kf_flag3++
		} else {
			kf_flag3 = 0
			if kf_framecount = 0 & kf_flag2 = 1{
				kf_flag2 = 0
				if kf_clickcount = 1:rv = 16
				if kf_clickcount >= 2:rv = 32
				kf_framecount = 0
				kf_clickcount = 0
			}
		}
		if kf_framecount : kf_framecount--
	return rv

	#define global kmkeybd(%1,%2=1) kmkeybd_ %1,%2

	#deffunc kmkeybd_ str kmkeybdstr ,int waittime
		kmkeybdstr_ = kmkeybdstr
		await
		repeat strlen(kmkeybdstr_)
			temp = peek(kmkeybdstr_,cnt)
			if temp = 46:temp = 190
			if temp = 47:temp = 191
			if temp = 58:temp = 186
			if ( (temp >= 97) & (temp <= 122) ):temp-=32
			keybd_event temp,0,0:await waittime
			keybd_event temp,0,2:await waittime
		loop
	return

	#deffunc kmpaste
		keybd_event 17,0,0:await 16
		keybd_event 86,0,0:await 16
		keybd_event 86,0,2:await 16
		keybd_event 17,0,2:await 16
	return

	#define global kmkeybd2(%1,%2=0) kmkeybd_2 %1,%2
	#deffunc kmkeybd_2 str kmkeybdstr2 ,int waittime2
		kmkeybdstr_2 = kmkeybdstr2
		await
		repeat 6
			temp2 = peek(kmkeybdstr_2,cnt) -32
			keybd_event temp2,0,0:await waittime2
			keybd_event temp2,0,2:await waittime2
		loop
	return

	#defcfunc kmexist str p1
		exist p1
	return strsize

	#deffunc kmsplit var bun,array db
		ias = 0
		repeat length(db)
			kekka = ""
			getstr kekka,bun,ias,','
			if strsize = 0 : break
			db.cnt = kekka
			ias += strsize
		loop
	return

	#defcfunc kmrnd int kmrndp1,int kmrndp2
	return kmrndp1 + rnd(kmrndp2)

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

	#defcfunc kmscrposx
	return (ginfo(4)+menuw)

	#defcfunc kmscrposy
	return (ginfo(5)+menuh)

	#defcfunc kmnoteget int a
		noteget s,a
	return s

	#defcfunc instr2 val b,str c
		a = -1
		a = instr(b,0,c)
		if a = -1:z=0
		if a >= 0:z=1
	return z

	#deffunc hold60fps
		a++
		if a != 3{
			await 17
		} else {
			a=0
			await 16
		}
	return

	#deffunc hold30fps
		a++
		if a != 3{
			await 33
		} else {
			a=0
			await 34
		}
	return

	#defcfunc OSVer
		osv = sysinfo(0)
		if osv = "WindowsNT ver5.1" : return 1
		if osv = "WindowsNT ver6.0" : return 0
		if osv = "WindowsNT ver6.1" : return 0
	return -1

	#defcfunc kmgetstr var b1,int b2,int b3,int b4
		sdim getstr2_d,b4+1
		getstr getstr2_d,b1,b2,b3,b4
	return getstr2_d

	#defcfunc kmcmdstr
		sdim kmcmdstr_ ,256
		kmcmdstr_ = dirinfo(4)
		if peek(kmcmdstr_,0) = '"' : getstr kmcmdstr_, kmcmdstr_, 1, '"'
	return kmcmdstr_

	#defcfunc kmgetkey int kmgetkey_int1
		 kmgetkey_int2 = 0
		getkey kmgetkey_int2,kmgetkeyint1
	return  kmgetkey_int2

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
