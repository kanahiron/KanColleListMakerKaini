#include "sqlele.hsp"

/**
 * 国際化対応を行うモジュール
 */
#module i18n
    /**
     * データベースを初期化
     */
    #deffunc local Init
        sql_open "language.db"
    return

    #defcfunc local GetText str lang, str key
        sql_q "SELECT value FROM message WHERE lang='" + lang + "' AND key='" + key + "'"
        if stat == 0 :return ""
    return sql_v("value")
#global
