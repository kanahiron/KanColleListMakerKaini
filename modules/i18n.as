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
        defaultLang = ""
    return

    /**
     * デフォルトの言語設定を行う
     * @param lang 言語設定
     */
    #deffunc local SetLanguage str lang
        defaultLang = lang
    return

    /**
     * 言語設定とキーにマッチした翻訳テキストを返す
     * @param lang 言語設定
     * @param key キー
     */
    #defcfunc local GetTextLong str lang, str key
        sql_q "SELECT value FROM message WHERE lang='" + lang + "' AND key='" + key + "'"
        if stat == 0 :return ""
    return sql_v("value")

    /**
     * デフォルトの言語設定とキーにマッチした翻訳テキストを返す
     * @param key キー
     */
    #defcfunc local GetText str key
        if defaultLang == "" :return ""
        sql_q "SELECT value FROM message WHERE lang='" + defaultLang + "' AND key='" + key + "'"
        if stat == 0 :return ""
    return sql_v("value")
#global
