#module jsonParse

#deffunc json_sel str p1
	if vartype(mssc) != vartype("comobj") {
		newcom mssc, "MSScriptControl.ScriptControl"
		mssc("Language") = "JScript"
	}
	
	sdim jsontext, strlen(p1)+3
	jsontext = p1
	if (strmid(jsontext,0,1) != "["): jsontext = "["+jsontext+"]"
	
	mssc -> "addCode" "obj = "+ jsontext +";"
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