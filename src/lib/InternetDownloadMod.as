#module InternetDownloadMod

#uselib "wininet.dll"
#func InternetOpen "InternetOpenW" wptr, wptr, wptr, wptr, wptr
#func InternetConnect "InternetConnectW" wptr, wptr, wptr, wptr, wptr, wptr, wptr, wptr
#func InternetQueryDataAvailable "InternetQueryDataAvailable" wptr, wptr, wptr, wptr
#func InternetSetOption "InternetSetOptionW" wptr, wptr, wptr, wptr
#func InternetQueryOption "InternetQueryOptionW" wptr, wptr, wptr, wptr
#func InternetReadFile "InternetReadFile" wptr, wptr, wptr, wptr
#func InternetWriteFile "InternetWriteFile" wptr, wptr, wptr, wptr
#func InternetCloseHandle "InternetCloseHandle" wptr
#func HttpOpenRequest "HttpOpenRequestW" wptr, wptr, wptr, wptr, wptr, wptr, wptr, wptr
#func HttpSendRequestEx "HttpSendRequestExW" wptr, wptr, wptr, wptr, wptr
#func HttpEndRequest "HttpEndRequestW" wptr, wptr, wptr, wptr
#func HttpQueryInfo "HttpQueryInfoW" wptr, wptr, wptr, wptr, wptr

#uselib "kernel32.dll"
#func getlastError "GetLastError"
#func MultiByteToWideChar "MultiByteToWideChar" wptr,wptr,sptr,wptr,wptr,wptr

#define INTERNET_OPEN_TYPE_PRECONFIG            0
#define INTERNET_OPEN_TYPE_DIRECT               1
#define INTERNET_OPTION_CONNECT_TIMEOUT         2
#define INTERNET_OPTION_CONNECT_RETRIES			3
#define INTERNET_OPTION_SEND_TIMEOUT            5
#define INTERNET_OPTION_RECEIVE_TIMEOUT			6
#define INTERNET_OPTION_HTTP_DECODING           65
#define INTERNET_DEFAULT_HTTP_PORT              80
#define INTERNET_DEFAULT_HTTPS_PORT             443
#define INTERNET_SERVICE_HTTP                   3
#define INTERNET_FLAG_RELOAD                    0x80000000
#define INTERNET_FLAG_SECURE                    0x00800000
#define INTERNET_FLAG_NO_CACHE_WRITE            0x04000000
#define INTERNET_FLAG_DONT_CACHE                INTERNET_FLAG_NO_CACHE_WRITE
#define INTERNET_FLAG_IGNORE_CERT_DATE_INVALID  0x00002000
#define INTERNET_FLAG_IGNORE_CERT_CN_INVALID    0x00001000

#define HTTP_QUERY_STATUS_CODE 19
#define HTTP_QUERY_FLAG_NUMBER 0x20000000

#deffunc download str serverName, str apiUrl, var responseBody, int hProgress, local RequestHeader, local RequestHeaderWide, local readBuffer

	sdim RequestHeader
	server = server_
	hInet = 0		// InternetOpenのハンドル
	hConnect = 0	// InternetConnectのハンドル
	hRequest = 0	// HttpOpenRequestのハンドル
	statcode = 0	// リクエストの結果コード
	BLOCK_SIZE = 1024*512
	hsize = 0		// 取得したバイト数が代入される変数
	intSize = 4		// int型の大きさ
	connTimeOut = 1000
	sendTimeOut = 1000
	receiveTimeOut = 1000
	connRetry = 2

	method = "GET"
	httpVer = "HTTP/1.1"

	RequestHeader  = "Host: "+serverName+"\n"
	RequestHeader += "User-Agent: KanColleListMakerKaini\n"
	RequestHeader += "Accept-Encoding: gzip, deflate\n"
	RequestHeader += "Connection: close\n"
	PostData = ""
	PostDataLength = 0

	usePort = 443
	requestFlag = INTERNET_FLAG_NO_CACHE_WRITE
	requestFlag |= INTERNET_FLAG_SECURE

	//ヘッダーをUTF-16LEに変換
	RequestHeaderWideLength = MultiByteToWideChar( 65001, 0, varptr(RequestHeader), strlen(RequestHeader), 0, 0) //UTF-16文字列の 文 字 数
	sdim RequestHeaderWide, (RequestHeaderWideLength*2)+4	//UTF-16文字列を入れるバッファを確保
	MultiByteToWideChar 65001, 0, varptr(RequestHeader), strlen(RequestHeader), varptr(RequestHeaderWide), RequestHeaderWideLength+1 //UTF-8→UTF-16

	//HttpSendRequestEx用のINTERNET_BUFFERS構造体を作成
	dim INTERNET_BUFFERS, 10
	INTERNET_BUFFERS( 0) = 40
	INTERNET_BUFFERS( 2) = varptr(RequestHeaderWide)
	INTERNET_BUFFERS( 3) = RequestHeaderWideLength //リクエストヘッダの文字数
	INTERNET_BUFFERS( 7) = PostDataLength //RequestBodyだけのサイズ

	requestFlag = INTERNET_FLAG_NO_CACHE_WRITE
	requestFlag |= INTERNET_FLAG_SECURE

	//インターネットをオープン
	hInet = InternetOpen( "KanColleListMakerKaini", INTERNET_OPEN_TYPE_PRECONFIG, 0, 0, 0)
	if (hInet){
		InternetSetOption hInet, INTERNET_OPTION_CONNECT_TIMEOUT, varptr(connTimeOut), intSize
		InternetSetOption hInet, INTERNET_OPTION_SEND_TIMEOUT, varptr(sendTimeOut), intSize
		InternetSetOption hInet, INTERNET_OPTION_RECEIVE_TIMEOUT, varptr(receiveTimeOut), intSize
		InternetSetOption hInet, INTERNET_OPTION_CONNECT_RETRIES, varptr(connRetry), intSize
		//サーバへ接続
		hConnect = InternetConnect(hInet, serverName, INTERNET_DEFAULT_HTTPS_PORT, 0, 0, INTERNET_SERVICE_HTTP, 0, 0)
		logmes "1 InternetConnect"
		if (hConnect) {
			//リクエストの初期化
			hRequest = HttpOpenRequest(hConnect, method, apiURL, httpVer, 0, 0, requestFlag, 0)
			logmes "2 HttpOpenRequest"
			if (hRequest) {
				//データ送信準備
				if HttpSendRequestEx( hRequest, varptr(INTERNET_BUFFERS), 0, 0, 0) {
					logmes "3 HttpSendRequestEx"
					//リクエストボディの送信

					if HttpEndRequest( hRequest, 0, 0, 0){
						logmes "4 HttpEndRequest"

						ResponseBodySize = 0
						readTotalSize = 0
						readSize = 0

						HttpQueryInfo hRequest, HTTP_QUERY_STATUS_CODE | HTTP_QUERY_FLAG_NUMBER, varptr(statCode), varptr(intSize), 0

						//入手可能なデータ量を取得
						InternetQueryDataAvailable hRequest, varptr(ResponseBodySize), 0, 0
						logmes "ResponseBodySize :"+ResponseBodySize

						//バッファの初期化
						sdim readBuffer, BLOCK_SIZE+1
						sdim responseBody, ResponseBodySize+1
						repeat
							InternetReadFile hRequest, varptr(readBuffer), BLOCK_SIZE, varptr(readSize)

							if hProgress: sendmsg hProgress, $402, int(readTotalSize/4096) //4kByteで1メモリを想定
							//title@hsp strf("受信バイト数 %d/%dkByte %.2f%%", readTotalSize/1024, 53220, (100.0*readTotalSize/1024/53220))

							if (readSize = 0) : break
							if ((readTotalSize+readSize)>ResponseBodySize): memexpand responseBody, (readTotalSize+readSize+1): logmes "ResBody拡張 :"+(readTotalSize+readSize+1)
							memcpy responseBody, readBuffer, readSize, readTotalSize, 0
							readTotalSize += readSize
							await
						loop
						logmes "5 InternetReadFile"
					}
				}
				InternetCloseHandle hRequest
			}
			InternetCloseHandle hConnect
		}
		InternetCloseHandle hInet
	}

return statcode

#global

#if 0

#include "hsp3utf.as"
#include "../../src/sub/FunctionDefinition.hsp"
#undef LogOut
#define LogOut(%1) mes %1

	screen 0
	winobj "msctls_progress32", "", , $50000000, 640, 30
	hProgress = objinfo(stat, 2)
	sendmsg hProgress, PBM_SETRANGE, 0, MAKELPARAM(0,53220)
	logOut "ffmpegをダウンロードします"
	button "開始", *st
	stop
*st
	download "ffmpeg.zeranoe.com", "builds/win32/static/ffmpeg-20180502-e07b191-win32-static.zip", versionFile, hProgress
	//download "https://drive.google.com", "uc?export=download&id=0BxC9-Nilt2alT1JlVG9MNlE4OWM", versionFile
	if (stat == 200){
		logOut "取得成功"
		mes versionFile
	} else {
		logOut "取得失敗"
	}

#endif
