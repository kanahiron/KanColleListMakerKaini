
#module getpathMod

#uselib "user32.dll"
#func CharLower "CharLowerW" wptr

#uselib "msvcrt.dll"
#func _wsplitpath_s "_wsplitpath_s" wptr, wptr, int, wptr, int, wptr, int, wptr, int

#deffunc local init

    sdim drive, 522
    sdim dir, 522
    sdim fname, 522
    sdim ext, 522
    sdim in, 522
    sdim win, 522
    sdim out, 522

return

#undef getpath
#defcfunc local getpath str string, int type

    cnvstow win, string
    if (type&16){
        CharLower varptr(win)
    }

    _wsplitpath_s varptr(win), varptr(drive), 260, varptr(dir), 260, varptr(fname), 260, varptr(ext), 260
    drive = cnvwtos(drive)
    dir = cnvwtos(dir)
    fname = cnvwtos(fname)
    ext = cnvwtos(ext)

    in = cnvwtos(win)

    drive +=  dir

    if ( type&8 ) {
        in = fname+ext
    } else: if ( type&32 ) {
        in = drive
    }

    switch( type&7 )
        case 1		// Name only ( without ext )
            out = strmid(in, 0, strlen(in)-strlen(ext))
            swbreak
        case 2
            out = ext
            swbreak
        default
            out = in
            swbreak
    swend
return out

#global
init@getpathMod
