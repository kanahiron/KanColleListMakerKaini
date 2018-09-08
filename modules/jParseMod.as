/**
 * json文字列をパースするモジュール
 */

#module jParseMod mssc

	/**
	 * json文字列を読み込む
	 * @param json json文字列
	 */
	#modinit str json
		newcom mssc, "MSScriptControl.ScriptControl"
		mssc("Language") = "JScript"
		mssc -> "addCode" "obj = "+ json +";"
	return

	/**
	 * キーから値を受け取る
	 * @param key キー
	 */
	#modcfunc local GetVal str key
		comres result
		mssc -> "Eval" "obj"+ key +" === null"
		if (result == -1) : return ""
		mssc -> "Eval" "obj"+ key
	return result

	/**
	 * 配列の要素数を取得する
	 * @param arrKey 配列を指すキー
	 */
	#modcfunc local GetLength str arrKey
		comres result
		mssc -> "Eval" "obj"+ arrKey +".length"
	return result

	#modterm
		delcom mssc
	return

#global
