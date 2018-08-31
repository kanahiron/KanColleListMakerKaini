#module jsonParse

#deffunc json_sel str p1
	if vartype(mssc) != vartype("comobj") {
		newcom mssc, "MSScriptControl.ScriptControl"
		mssc("Language") = "JScript"
	}
	mssc -> "addCode" "obj = "+ p1 +";"
return

#defcfunc json_val str p1
	comres result
	mssc -> "Eval" "obj"+ p1 +" === null"
	if (result == -1) : return ""
	mssc -> "Eval" "obj"+ p1
return result

#defcfunc json_length str p1
	comres result
	mssc -> "Eval" "obj"+ p1 +".length"
return result

#deffunc json_unsel
	sdim jsontext,0
return

#global
