/*

**このモジュールはつーさ氏がつーさのくーかん(http://tu3.jp/)にて配布している「フォルダ選択ダイアログモジュール」をkanahironが改変したものです。**
元配布元 :http://tu3.jp/0110

*/

#ifndef __hsp3utf__
	dialog "このモジュールはHSP3utfが必要です。\nメインソースでincludeしてください。\n\nモジュール:BrowseFolder_kai_utf",1,"終了します"
	end
#endif

#ifndef xdim
#uselib "kernel32.dll"
#func global VirtualProtect@_xdim "VirtualProtect" var,int,int,var
#define global xdim(%1,%2) dim %1,%2: VirtualProtect@_xdim %1,%2*4,$40,x@_xdim
#endif

#module __BrowseFolder_kai_utf__

#uselib "comdlg32"
#func GetOpenFileName "GetOpenFileNameW" int
#func GetSaveFileName "GetSaveFileNameW" int
#cfunc CommDlgExtendedError "CommDlgExtendedError"
#uselib "user32.dll"
#func SendMessage "SendMessageW" int,int,int,int
#uselib "ole32.dll"
#func CoTaskMemFree "CoTaskMemFree" int
#uselib "shell32.dll"
#cfunc SHBrowseForFolder "SHBrowseForFolderW" int
#cfunc SHGetPathFromIDList "SHGetPathFromIDListW" int,int

#define BIF_RETURNONLYFSDIRS	0x0001
//ファイルシステムディレクトリのみを返します。それ以外のアイテムが選択されているときには、[OK]ボタンは灰色表示になります。
#define BIF_DONTGOBELOWDOMAIN	0x0002
//ダイアログボックスのツリービューコントロールにドメインレベルのネットワークフォルダを含めないようにします。
#define BIF_STATUSTEXT			0x0004
//ダイアログボックスにステータス領域を表示します。表示テキストを設定するには、コールバック関数からダイアログボックスにメッセージを送信します。
#define BIF_RETURNFSANCESTORS	0x0008
//シェルネームスペース階層構造の中でルートフォルダの下にあるファイルシステムサブフォルダのみを返します。それ以外のアイテムが選択されているときには、[OK]ボタンは灰色表示になります。
#define BIF_EDITBOX				0x0010
//Version 4.71 以降： ユーザーがアイテム名を書き込むことができるエディットコントロールを表示します。
#define BIF_VALIDATE			0x0020
//Version 4.71 以降： ユーザーがエディットコントロールに無効な名前を入力した場合に、 BFFM_VALIDATEFAILED メッセージとともにコールバック関数が呼び出されます。BIF_EDITBOXフラグが指定されていない場合は、このフラグは無視されます。
#define BIF_NEWDIALOGSTYLE		0x0040
//Version 5.0 以降： 新しいユーザーインターフェースを使用します。従来のダイアログボックスよりも大きい、リサイズ可能なダイアログボックスが表示され、ダイアログボックスへのドラッグアンドドロップ、フォルダの再整理、ショートカットメニュー、新しいフォルダ作成、削除、その他のショートカットメニューコマンドが追加されます。このフラグを使用するには、あらかじめOleInitialize関数またはCoInitialize関数を呼び出してCOMを初期化しておく必要があります。
#define BIF_USENEWUI			0x0050
//Version 5.0 以降： エディットコントロールを持つ、新しいユーザーインターフェースを使用します。このフラグはBIF_EDITBOX|BIF_NEWDIALOGSTYLEと同等です。このフラグを使用するには、あらかじめOleInitialize関数またはCoInitialize関数を呼び出してCOMを初期化しておく必要があります。
#define BIF_BROWSEINCLUDEURLS	0x0080
//Version 5.0 以降： URLを表示することができるようにします。BIF_USENEWUIとBIF_BROWSEINCLUDEFILESが同時に指定されていなければなりません。これらのフラグが設定されているとき、選択されたアイテムを含むフォルダがサポートする場合にのみ、URLが表示されます。アイテムの属性を問い合わせるためにフォルダのIShellFolder::GetAttributesOf メソッドが呼び出されたときに、フォルダによってSFGAO_FOLDER属性フラグが設定された場合にのみ、URLが表示されます。
#define BIF_UAHINT				0x0100
//Version 6.0 以降： エディットコントロールの代わりに、ダイアログボックスに用法ヒントを追加します。BIF_NEWDIALOGSTYLEフラグとともに指定しなければなりません。
#define BIF_NONEWFOLDERBUTTON	0x0200
//Version 6.0 以降： ダイアログボックスに「新しいフォルダ」ボタンを表示しないようにします。BIF_NEWDIALOGSTYLEフラグとともに指定しなければなりません。
#define BIF_NOTRANSLATETARGETS	0x0400
//Version 6.0 以降： 選択されたアイテムがショートカットであるとき、そのリンク先ではなく、ショートカットファイル自体のPIDLを返します。
#define BIF_BROWSEFORCOMPUTER	0x1000
//コンピュータのみを返します。それ以外のアイテムが選択されているときには、[OK]ボタンは灰色表示になります。
#define BIF_BROWSEFORPRINTER	0x2000
//プリンタのみを返します。それ以外のアイテムが選択されているときには、OK ボタンは灰色表示になります。
#define BIF_BROWSEINCLUDEFILES	0x4000
//Version 4.71 以降： フォルダとファイルを表示します。
#define BIF_SHAREABLE			0x8000
//Version 5.0 以降： リモートシステム上にある共有リソースを表示できるようにします。BIF_USENEWUIフラグとともに指定しなければなりません。

#ifndef TRUE
#define global FALSE 0
#define global TRUE  1
#endif

#define global BrowseFolder(%1,%2="",%3=0)  _BrowseFolder %1,%2,%3
#define global BrowseFolder2(%1,%2="",%3=1) _BrowseFolder %1,%2,%3

#deffunc _BrowseFolder str _szTitle, str _defaultfolder , int flag

	// flagが0の時は「新しいフォルダ」ボタンを非表示、1の時は表示

	sdim retfldr, 1024
	sdim _retfldr, 1024
	sdim szTitle, 1024
	sdim inifldr, 1024

	xdim fncode, 8

	cnvstow szTitle, _szTitle
	//cnvstow inifldr, _defaultfolder
	inifldr = _defaultfolder
	if flag = FALSE{
		ulFlags = BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE
	} else {
		ulFlags = BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE | BIF_NONEWFOLDERBUTTON
	}

	fncode = $08247c83,$8b147501,$ff102444,$68016a30,$00000466,$102474ff,$330450ff,$0010c2c0
	hbdata = varptr(inifldr), varptr(SendMessage)
	BROWSEINFO = hwnd, 0, varptr(retfldr), varptr(szTitle), ulFlags, varptr(fncode), varptr(hbdata), 0
	pidl = SHBrowseForFolder(varptr(BROWSEINFO))
	fret = SHGetPathFromIDList(pidl,varptr(_retfldr))
	CoTaskMemFree pidl

	retfldr = cnvwtos(_retfldr)
	mref stt,64 : stt = fret
return retfldr

#global

//unicode対応サンプルコード
#if 0

	sdim String,256
	repeat 64
		ccnt = cnt*3
		poke String,ccnt+0,0xe2
		poke String,ccnt+1,0x98
		poke String,ccnt+2,0x80+cnt
	loop

	BrowseFolder String,"C:\\"			//新しいフォルダボタン有り
	//BrowseFolder2 String,"C:\\" 		//新しいフォルダボタン無し1
	//BrowseFolder String,"C:\\",1		//新しいフォルダボタン無し2
	if stat = TRUE{
		mes refstr
	} else {
		mes "未選択"
	}

#endif
