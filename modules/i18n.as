/**
 * 国際化対応を行うモジュール
 */
#module i18n
    /**
     * データベースを初期化
     */
    #deffunc local Init
        defaultLang = ""
        sdim keyList, 512, 5
        sdim valueList, 512, 5
        dataCount = 0
        LoadIni@i18n
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
        index = BinarySearch(lang + "," + key, 0, dataCount - 1)
        if index < 0 :return "[not found]"
    return valueList(index)

    /**
     * デフォルトの言語設定とキーにマッチした翻訳テキストを返す
     * @param key キー
     */
    #defcfunc local GetText str key
        index = BinarySearch(defaultLang + "," + key, 0, dataCount - 1)
        if index < 0 :return "[not found]"
    return valueList(index)

    #deffunc local LoadIni
    	notesel textBuffer
    	noteload "language.csv"
        repeat notemax
            noteget tempStr, cnt
            split tempStr, ",", temp
            keyList(dataCount) = temp(0) + "," + temp(1)
            valueList(dataCount) = temp(2)
            dataCount++
        loop
        noteunsel
        dim textBuffer, 1

        // 以下コムソート
        h = dataCount
        isSwapped = 0
        while h > 1 || isSwapped
            if h > 1 :h = h * 10 / 13
            isSwapped = 0
            for i, 0, dataCount - h
                key1 = keyList(i)
                key2 = keyList(i + h)
                if (key1 ! key2) > 0 {
                    temp = key1
                    keyList(i) = key2
                    keyList(i + h) = temp
                    temp = valueList(i)
                    valueList(i) = valueList(i + h)
                    valueList(i + h) = temp
                    isSwapped = 1
                }
            next
        wend
    return

    /**
     * キー配列に対して二分検索を行う
     * @param bkey キー
     * @param bmin インデックスの最小値
     * @param bmax インデックスの最大値
     * @param bmid インデックスの間の数
     */
    #defcfunc BinarySearch str bkey, int bmin, int bmax, local bmid
        if bmin > bmax :return -1
        bmid = bmin + (bmax - bmin) / 2
        if (keyList(bmid) ! bkey) > 0 {
            return BinarySearch(bkey, bmin, bmid - 1)
        }
        if (keyList(bmid) ! bkey) < 0 {
            return BinarySearch(bkey, bmid + 1, bmax)
        }
        return bmid
    return bmid
#global
