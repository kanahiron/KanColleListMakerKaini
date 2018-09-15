#include "tCup_mod_utf.as"
#ifndef jParseMod
	#include "./lib/jParseMod.as"
#endif

#module
//============================================================
/*  [HDL symbol infomation]

%index
getAuthorizeAddress
アクセス許可を求めるURLを生成

%prm
()

%inst
ユーザにアクセス許可を求めるアドレスを生成し、戻り値として返します。

内部でTwitterと通信し、リクエストトークンを取得しています。リクエストトークンの取得に失敗した場合は、"Error"という文字列を返します。

%group
TwitterAPI操作関数

%*/
//------------------------------------------------------------
#defcfunc getAuthorizeAddress

	// アクセストークン取得
	sdim arguments
	arguments(0) = "oauth_callback=oob"
	execRestApi "oauth/request_token", arguments, METHOD_GET
	if stat != 200 : return "Error"
	// トークンの取り出し
	gaa_body = getResponseBody()
	;request_token
	TokenStart = instr(gaa_body, 0, "oauth_token=") + 12
	TokenEnd = instr(gaa_body, TokenStart, "&")
	requestToken = strmid(gaa_body, TokenStart, TokenEnd)
	;request_token_secret
	SecretStart = instr(gaa_body, 0, "oauth_token_secret=") + 19
	SecretEnd = instr(gaa_body, SecretStart, "&")
	requestSecret = strmid(gaa_body, SecretStart, SecretEnd)
	setRequestToken requestToken, requestSecret
return "https://api.twitter.com/oauth/authorize?oauth_token="+ requestToken
//============================================================

//============================================================
/*  [HDL symbol infomation]

%index
GetAccessToken
OAuthでAccessTokenとSecret取得

%prm
p1, p2, p3, p4
p1 = 変数        : Access Tokenを代入する変数
p2 = 変数        : Access Secretを代入する変数
p3 = 変数        : ユーザ情報を代入する変数
p4 = 文字列      : PINコード

%inst
TwitterAPI「oauth/access_token」を実行し、OAuth方式でAccess TokenとAccess Secretを取得します。

p1, p2にそれぞれAccess Token, Access Secretを代入する変数を指定してください。

p3には、ユーザ情報を代入する変数を指定してください。「ユーザID,ユーザ名」とカンマ区切りでユーザ情報が代入されます。

p4には、PINコードを指定してください。PINコードは、GetAuthorizeAdressで取得したURLにアクセスし、ユーザが「許可」ボタンを押したときに表示されます。詳しくは、リファレンスをご覧ください。

Access TokenとSecretは、一度取得すると何度も使用することができます（現在のTwitterの仕様では）。そのため、一度Access TokenとSecretを取得したら保存しておくことをおすすめします。
また、Access TokenとSecretはユーザ名とパスワードのようなものなので、暗号化して保存するなど管理には気をつけてください。OAuth/xAuthの詳しいことは、リファレンスをご覧ください。

%href
GetAuthorizeAdress
GetxAuthToken
SetAccessToken

%group
TwitterAPI操作命令

%*/
//------------------------------------------------------------
#deffunc publishAccessToken var p1, var p2, var p3, str p4
	sdim p1
	sdim p2
	sdim p3
	sdim arguments
	arguments(0) = "oauth_verifier=" + p4
	execRestApi "oauth/access_token", arguments, METHOD_POST
	statcode = stat

	response = "#####  HEADER  ######\n"+getResponseHeader()+"\n\n#####  BODY  #####\n"+getResponseBody()
	pat_body = getResponseBody()

	if statcode = 200  {
		//トークンの取り出し
		;request_token
		TokenStart = instr(pat_body, 0, "oauth_token=") + 12
		TokenEnd = instr(pat_body, TokenStart, "&")
		p1 = strmid(pat_body, TokenStart, TokenEnd)
		;request_token_secret
		TokenStart = instr(pat_body, 0, "oauth_token_secret=") + 19
		TokenEnd = instr(pat_body, TokenStart, "&")
		p2 = strmid(pat_body, TokenStart, TokenEnd)
		;User情報
		TokenStart = instr(pat_body, 0, "user_id=") + 8
		TokenEnd = instr(pat_body, TokenStart, "&")
		p3 = strmid(pat_body, TokenStart, TokenEnd) +","
		TokenStart = instr(pat_body, 0, "screen_name=") + 12
		TokenEnd = strlen(pat_body)
		p3 += strmid(pat_body, TokenStart, TokenEnd)
	}
return statcode
//============================================================

#deffunc getMentionsTimeline int count

	sdim arguments
	arguments(0) = "count="+ count
	execRestApi "statuses/mentions_timeline.json", arguments, METHOD_GET
return stat

#deffunc getUserTimeline str screen_name, int count

	sdim arguments
	arguments(0) = "screen_name="+ screen_name
	arguments(1) = "count="+ count
	execRestApi "statuses/user_timeline.json", arguments, METHOD_GET
return stat

#deffunc getHomeTimeline int count

	sdim arguments
	arguments(0) = "count="+ count
	execRestApi "statuses/home_timeline.json", arguments, METHOD_GET
return stat

#deffunc getRetweetsOfMe int count

	sdim arguments
	arguments(0) = "count="+ count
	execRestApi "statuses/retweets_of_me.json", arguments, METHOD_GET
return stat


#deffunc getRetweets str id

	sdim arguments
	execRestApi "statuses/retweets/"+id+".json", arguments, METHOD_GET
return stat


#deffunc showStatus str id

	sdim arguments
	execRestApi "statuses/show/"+id+".json", arguments, METHOD_GET
return stat



#deffunc destoryStatus str id

	sdim arguments
	execRestApi "statuses/destroy/"+id+".json", arguments, METHOD_POST
return stat

#deffunc retweetStatus str id

	sdim arguments
	execRestApi "statuses/retweet/"+id+".json", arguments, METHOD_POST
return stat

//============================================================
/*  [HDL symbol infomation]

%index
Tweet
ツイートする

%prm
p1, p2
p1 = 文字列      : ツイートする文字列
p2 = 文字列      : 返信(reply)対象のステータスID

%inst
TwitterAPI「statuses/update」を実行し、Twitterへ投稿します。結果はSetFormatType命令で指定したフォーマットで取得します。

p1にツイートする140字以内の文字列を指定してください。140字以上の場合、140字に丸めてからツイートされます。

p2に返信(reply)対象のステータスIDを指定することでどのステータスに対する返信かを明示できます。p2に空文字を指定するか省略した場合は、明示されません。
TwitterAPIの仕様上、存在しない、あるいはアクセス制限のかかっているステータスIDを指定した場合と、p1で指定した文字列に「@ユーザ名」が含まれない、あるいは@ユーザ名」で指定したユーザが存在しない場合は、無視されます。

TwitterAPIを実行した際のステータスコードはシステム変数statに代入されます。

API制限適用対象外のAPIを使用していますが、1日に1000回までという実行回数上限が設定されています(API以外からの投稿もカウント対象)。

%href
DelTweet
ReTweet

%group
TwitterAPI操作命令

%*/
//------------------------------------------------------------
#deffunc _Tweet str p1, str p2, str p3, str p4, str p5, str p6
	//POST
	sdim arguments,256
	tempIndex = 0
	arguments(0) = "status="+ form_encode(p1, 1)
	if p2 != "" : tempIndex++: arguments(tempIndex) = "in_reply_to_status_id="+ p2
	if p3 != "" : tempIndex++: arguments(tempIndex) = "media_ids="+ form_encode(p3, 1)
	if p4 != "" : tempIndex++: arguments(tempIndex) = p4
	if p5 != "" : tempIndex++: arguments(tempIndex) = p5
	if p6 != "" : tempIndex++: arguments(tempIndex) = p6

	execRestApi "statuses/update.json", arguments, METHOD_POST
	tempInt = stat
return tempInt
#define global Tweet(%1, %2="", %3="", %4="", %5="", %6="") _Tweet %1, %2, %3, %4, %5, %6
//============================================================

#define global media_upload(%1,%2,%3,%4=0) media_upload_ %1,%2,%3,%4
#deffunc media_upload_ array p1 ,int p3,var p2, int hProgress

	sdim p2,512
	sdim picname,1024

	repeat p3
		exist p1(cnt)
		if strsize <= 0:return 0

		if hProgress: sendmsg hProgress, $402, 0:wait 10
		picName = p1(cnt)
		execRestApi "media/upload.json", picName, METHOD_POST, hProgress
		if (stat != 200) :return 0

		newmod jObj, jParseMod, getResponseBody()
		p2 += GetVal@jParseMod(jObj, ".media_id_string") + ","
		delmod jObj
		wait 10
	loop
	p2 = strmid(p2, 0, strlen(p2)-1)
return 1

#global
