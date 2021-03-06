# 艦これ一覧めいかー改二 Ver0.19

「艦これ一覧めいかー改二」はフリーソフトです。<br>
「艦これ一覧めいかー改二」で作成された画像、動画は自由に利用することが出来ます。(「艦これ一覧めいかー改二で作成」などは不要です。)<br>
このソフトウェアを使用したことによって生じたすべての障害・損害・不具合等に関しては、kanahironは一切の責任を負いません。<br>
各自の責任においてご使用ください。<br>

## 概要
* __ボタン一発でスクリーンショットがとれる！__
* __数クリックでまとめ画像が作れる！！__
* __画像つきでツイートができる！！！__
* __動画も撮れる！！！！__

### 解説動画(但し艦これ一覧めいかー(無印))
- ニコニコ動画 http://www.nicovideo.jp/watch/sm28848287
- YouTube https://youtu.be/wMGTIcmFL00

## 簡単な使い方説明
1. 艦これを適当なブラウザで開きます
1. 艦これ一覧めいかー改二を起動し、「取得する」ボタンを押します
1. 「SSキャプチャ」ボタンやキーボードのAltキー+Zキーの同時押しでSSが撮れます
1. まとめ画像を作るにはモードを選び、適切なシーンでAlt+Zキーを押します
1. 適当に並び替えなどをし、「作成」ボタンで一覧まとめ画像が作れます

### SSキャプチャモード
余白のないきれいなSSをキャプチャすることが出来ます。<br>
キャプチャしたSSは「ScreenShots」フォルダに保存されます。<br>
座標取得済みでホットキーが有効の場合は、一覧めいかー改二のタイトルの頭に「\*」が付きます。<br>

* #### 座標取得
「取得する」ボタンで艦これがPCの画面に対しどこにあるかを認識します<br>
追跡が有効だと、艦これを表示しているブラウザの位置を動かしても問題なくキャプチャが出来ます
  * ##### 自動取得
  自動座標取得にチェックが入っていると自動取得になります<br>
 「取得する」ボタンを押すと艦これの画面が検索され、座標を取得します<br>
  __自動取得で取得できないシーン(ドロップ画面)などは手動取得を行ってください__
  * ##### 手動取得
  自動座標取得にチェックが入っていないと手動取得になります<br>
 「取得する」ボタンを押し、艦これの画面を完全に覆うようにドラッグします<br>
 * ##### 追跡について
追跡は、__ブラウザ内でスクロールを行ったりブラウザのサイズ/倍率変更が行われると自動的に解除__ されます(SSは失敗します)<br>
環境によって動作が変わり、自動的に利用可能な最良のものが選ばれます
    * 追跡中S
      * 追跡が有効で、かつ艦これの画面上に何かが重なっても映り込むことなくキャプチャできます<br>
	※ブラウザの相性により__毎回同じ画像になる__、__表示とは全く違った画像になる__、などの不具合が生じる可能性があります<br>
	その場合は「最高追跡レベル」のスライダーを「A」や「無し」に下げてご利用下さい
    * 追跡中A
      * 追跡が有効ですが、艦これの画面に重なっているものは映り込みます
    * XX, YY
      * 追跡は無効で、ただひたすらその座標からキャプチャをします
* #### 連続キャプチャ
デフォルトでは無効で、[オプション→キャプチャ・作成設定]から有効に出来ます<br>
オプションで設定した値×0.1秒の間隔で連続キャプチャをし、0を指定するとPCの出来る限りの速度になります<br>
連続キャプチャ中はホットキーによるキャプチャ以外の操作を行う事はできません<br>
保存先はデフォルトで「ScreenShots」フォルダ内に自動作成されたフォルダです<br>
* #### 動画キャプチャ
動画キャプチャ機能を使うにはffmpeg.exeと呼ばれる外部ソフトが必要です<br>
Ver0.13からffmpegのダウンロード機能が付きました。画面の指示に従って操作をしてください。<br>
<details><summary>手動でダウンロードする場合</summary>

  * [お気に入りの動画を携帯で見よう](http://blog.k-tai-douga.com/)などからダウンロードをしてください<br>
  * ダウンロードした「ffmpeg.exe」を「bin」フォルダに入れるか「[オプション→動画キャプチャ設定]」から選択してください<br>
  * ffmpegが読み込まれると「使用するオーディオデバイス」が表示されますので、選択してください<br><br>
</details>
  設定を終えると、SSキャプチャモードで動画キャプチャ「開始」ボタンが押せるようになります<br>
  ※動画キャプチャ中はホットキーによるキャプチャ以外の操作を行う事はできません<br>
  <strong>詳細は下の「動画キャプチャについて」をご覧ください</strong><br>
※一覧めいかー改二では動画付きツイートはできません<br>

### 一覧作成モード(まとめ画像の作成)
各モードに対応した画面でホットキーによるキャプチャか、スクリーンショットのドラッグ&ドロップで画像を並べられます<br>
セルに置いた画像はドラッグで移動、画面外へ出すと削除、<br>
右クリックのドラッグでは範囲指定ができ、__複数の画像を一度に移動__できます<br>
並べ終わったら作成ボタンを押して下さい<br>
* #### 艦娘一覧モード
 * 対応画面
   * __シーン：編成→変更__
     * 「編成」画面の「変更」を押した場面
   * __シーン：補給__
     * 「補給」画面

 実行ファイルと同じフォルダに「艦娘一覧_(日付).png」ができます
* #### 攻略編成モード
  * 対応画面
    * 「編成」画面の「詳細」を押した場面(オススメ)
    * 「改装」画面(補強増設が見えません)

 実行ファイルと同じフォルダに「攻略編成_(日付).png」ができます
 * 「自動追加の方法」はホットキーやメインウィンドウへのD&Dで自動追加した際にどう並べていくかを指定します
 * 「キャプチャ範囲」は画像のどの部分で一覧を作るかを指定します
 * 「艦隊区切り線」にチェックを入れると「自動追加の方法」に応じた区切り線が追加されます
 * 艦隊名はチェックが入っているものが作成時に追加されます


* #### その他一覧モード
 * 単純に画像を連結する__「直接連結」__
 * 2016春イベントから追加された基地航空隊に対応する__「基地航空隊」__
 * 所持装備の一覧を作れる__「装備一覧」__
 * 任意範囲で一覧を作れる__「任意範囲」__  
4つの入力欄は、読み込まれた画像を1200x720pxにリサイズした上で「左上座標x, 左上座標y  幅x高さ」です

### タイマーモード
Ver0.18時点では暫定実装です<br>
タイマーが終了すると「ピコーン」と鳴ります。それだけです。<br>
今後、wav再生機能や最前面表示など追加したいですね(他人事)

### オプション
たくさんあります  
設定を初期化する場合はListMaker2.iniファイルを消してください

### ツイッター投稿
各モードから「ツイートウィンドウを表示」にチェックを入れるとツイートウィンドウが開きます  
初めて利用する場合は認証が必要になりますので、指示に従ってください  
※Ctrl+Enterキーでツイートされます。誤爆に注意してください  
* #### 画像の添付
  メインウィンドウのSSキャプチャボタンやホットキーでスクショを撮ると右側に大きく表示されます  
  この状態で「↑」ボタンを押すことで、表示中の画像をツイートに画像を添付することができます  
  「撮」ボタンではスクショを撮りつつ自動で添付します  
  ツイートウィンドウに画像をD&Dしても添付できます
* #### 画像の選択
  「←」「→」ボタンを押すことで過去に撮影したスクショや作成した一覧画像を見ることができます  
* #### 順番と取り消し
  「↑」ボタンで添付の対象にすると、右上の4つの窓にサムネイルとツイートされる順番が表示されます  
  サムネイルをクリックすることで添付対象から外したり、順番を変えることができます
* #### ハッシュタグ
  最大で20文字まで入力できます ハッシュタグを表す「#」自身も入力してください  
  複数のハッシュタグを入れるときは半角スペースで区切ってください  
  文字数はカウントされていますが、スペースなどもカウントするので目安です  
  入力欄の左側にあるチェックでハッシュタグを入れる/入れないを切り替えることができます
* #### 範囲選択キャプチャ
    「」 、[] ボタンを押すと、艦これの画面とは別に自由にデスクトップ上のスクショを撮ることができます  
    「」は余白を自動で切り詰め、[]は選択したままのスクショを撮ります  


### 動画キャプチャについて
動画キャプチャにはPCにそれなりの性能が必要です<br>
タブレットPCなどでは録画された動画が極端にカクついたり、音声が入らない場合があります<br>
デスクトップやノートPCの場合、2015年以降に発売された極端な廉価モデルで無ければキャプチャ可能と思われます<br>
参考に、1200x720pxの艦これの画面を対象としたキャプチャ時のCPU負荷はCore i7 3770kで10%未満です<br>
ブラウザの拡大率を小さくすることで録画時の負荷を軽減できます
* #### フレームレートについて
Windows8以降では画面リフレッシュレートの半分を超えるフレームレートを指定すると極端にカクついてしまいます  
画面リフレッシュレートが60Hzの場合は30fpsを上限に指定してください
* #### 音声について
音声を録音する場合、PCのステレオミキサーと呼ばれる機能を有効にするか、外部ソフトを導入する必要があります<br>
 * __ステレオミキサーの場合__<br>
 ステミキは標準で無効になっていますので、[ゲーム実況wiki -
PCの音とマイクの音を同時に録音・配信するための方法](https://www18.atwiki.jp/live2ch/pages/151.html#id_28d0074b)を参照して有効にしてください<br>
__ステレオミキサーはPCに直接接続したスピーカー/イヤホンから音声を出力している場合のみ利用可能です__<br>
HDMI経由のディスプレイやそれに繋げたスピーカー、USB-DAC(USBヘッドセット)、サウンドボードを利用している場合は__ステレオミキサーで音声は録れません__<br>
※サウンドボード搭載のステレオミキサーも高確率で利用不可です<br>
ステレオミキサーでは音声が入らない、音ズレが大きい場合は以下の手順をお試し下さい<br><br>
 * __ステレオミキサー非搭載、またはうまくいかない場合(★超おすすめ★)__<br>
 「__on screen capture recorder to video free__」を利用します
  <details><summary>インストール方法</summary>

    [on screen capture recorder to video free](https://sourceforge.net/projects/screencapturer/files/)を開き、「Download latest version?」をクリックするとダウンロードが始まります<br>
 ダウンロードしたインストーラーをダブルクリックで開き、インストールして下さい<br>
 フランス語のソフトですが、最初の画面の「francais」を「English」に変えて、「OK」「Apply」「Next」「Finish」を適当に押していけばインストール出来ます<br>
 (本当にそのまま押していくとFinishのあとに英語の何かが開きますが閉じて下さい)<br>
 __一覧めいかーの動画キャプチャには、このソフト自体の設定は不要です__<br>

     <details><summary>Java何たらと表示が出てインストールが上手くいかない場合</summary>

     Javaのインストールが必要です<br>
 [Javaのダウンロード](https://java.com/ja/download/)からダウンロード、インストールしてください(このソフトではx86版を利用します)<br>
 </details></details><br>
 インストールが出来たら、「オプション→動画キャプチャ」の「使用するオーディオデバイス」で<br>
「virtual-audio-capturer」を選択してください<br><br>


* #### 「録画時のCPU負荷を軽減した動画キャプチャ」とは？
このオプションでは、ファイル容量と引き換えに処理を非常に軽くした動画キャプチャを行い、終了時に再度エンコードをかけて圧縮することで録画時の負荷を減らします<br>
よって、動画キャプチャ停止を押してから動画ができるまで録画時間の数倍の時間がかかることがあります<br>
この時間は「x264のプリセット」を変えることで調節できます<br>
また、十分な性能のあるPCならOFFでも問題はありません<br>
OFFでは標準のmediumは重めですので、faster以上をおすすめします<br>
※音声と動画の結合のため再エンコード自体は行われますが、非常に高速です


## 一覧めいかーのアップデート方法について
次の手順を行っていただくことで設定を引き継げ、スムーズに移行できます<br>
[アップデートについて - Twitter](https://twitter.com/KCLM2_dev/status/1132208021361135616)


## アイコンについて
一覧めいかー無印に引き続きゴジさまに描いていただきました<br>
艦これ一覧めいかー「改二」なので瑞鶴「改二」です　かわいい<br>
ゴジさまの [Twitter](https://twitter.com/gojikyuji) [Pixiv](https://www.pixiv.net/member.php?id=6089698)<br>


## マルウェアとしての誤検知について
このソフトウェアはHSPという言語で作成していますが、トロイの木馬として誤検知される事が多いという嫌な特徴があります<br>
作者のPCはESETで検疫されており、トロイの木馬以外で検出された場合でも、ウイルスに感染されたファイルを配布してしまっている可能性は限りなく低いと思われます(つまりほぼ誤検出です)<br>
特に、Norton、Windows Defenderでトロイの木馬と認識されてしまうようです<br>
__個別の除外設定を行い、アンチウイルスソフトのベンダまで報告を行っていただけると助かります__<br>

## 更新点<br>
* Ver0.19<br>
  * [更新]
    * 音声と動画の同期を更に強化
  * [修正]
    * 24.85日の連続起動で音声が入らなくなるバグ


* Ver0.18<br>
  * [追加]
    * タイマーモードの追加
  * [修正]
    * この説明書でMarkdownがちゃんと動いていない部分があったため修正


* Ver0.17.1<br>
  * [修正]
    * Ver0.17で内部バージョンが0.16になっていた


* Ver0.17<br>
  * [更新]
    * グリッドウィンドウのセルの数を増やし、切り替えられるようにした
    * 映り込み防止の処理変更


* Ver0.16<br>
  * [修正]
    * 稀に動画に音声が入らないバグ
    * 音声なしだと動画キャプチャが開始できないバグ


* Ver0.15<br>
  動画キャプチャ周りの更新だけですが、今回の音ズレ対処は自信があります(フラグではない)
  * [更新]
    * 音ズレ問題に対して更に対処
  * [修正]
    * ffmpegのプロセスが落ちた際に表示されるメッセージがおかしかった
    * 一覧めいかーが半角スペースを含んだパスに配置されているとffmpegのダウンロードでエラー12が出るバグ


* Ver0.14<br>
  * [更新]
    * Twitter認証を通した瞬間に設定値を保存するようにした
    * ffmpegのダウンロード画面でダウンロード中に操作を無効にするようにした
  * [修正]
    * 一覧めいかー"改二"になってからメモリを大量消費していた問題
    * Ver0.13の追加処理の一部取り消し(SS保存先フォルダに大量にファイルがあると起動に時間がかかる現象)
    * ツイートウィンドウの表示の微修正
    * ffmpegのダウンロードでbinフォルダがないとダウンロード中にエラー落ちする問題


* Ver0.13.1<br>
  * [修正]
    * 履歴ロードでカレントディレクトリが移動しその後の動作が不安定になる可能性


* Ver0.13<br>
  バグを直したり追加したり、少し機能の強化を行いました
  * [追加]
    * 動画キャプチャでffmpegが存在しない場合にダウンロードする機能
  * [更新]
    * ツイートウィンドウでCtrl+Enterキーでツイートされるようにした
    * SSキャプチャ画像の手動入力が有効な場合、起動時に座標復元を行うようにした
    * グリッドウィンドウで自動整列機能を暴発しにくいようにした
    * 艦隊名文字色、区切り線の色変更でパレットにデフォルト色を置いた
    * ffmpegの指定でffmpeg以外が指定されても暴走しにくいようにした
  * [修正]
    * (Yabumiなどの)外部ソフト連携機能が機能しなくなっていたバグ
    * Windows7, Vistaで高DPIが有効にならないバグ
    * SS保存先フォルダに巨大なファイルがあると起動時に落ちるバグ
    * SS保存先フォルダに大量にファイルがあると起動に時間がかかる現象
    * グリッドウィンドウでホットキーによるSS自動追加直後にクリックした座標がずれるバグ
    * 上記修正とは関係なくそもそもクリック座標がずれていたバグ
    * 艦隊名文字色、区切り線の色変更ボタンが動いていなかったバグ
    * 誤字修正(補間→補完)


* Ver0.12<br>
  更にバグを倒しつつツイート系の機能を強化しました
  * [追加]
    * ハッシュタグ自動付与機能を追加
  * [更新]
    * ツイートウィンドウのUI微修正
  * [修正]
    * Ver0.11が自身のことをVer0.10と勘違いしていたバグ
    * UIスケールを手動設定にしていた場合にツイートウィンドウの描画が小さくなるバグ
    * ツイートウィンドウのサムネイルのアスペクト比が間違っていたバグ
    * ツイートで落ちるバグ


* Ver0.11<br>
  ばぐをたくさんたおしました
  * [更新]
    * 最高追跡LvのデフォルトをSからAにした
  * [修正]
    * 攻略編成モードで番号が勝手に入るバグ
    * 一覧作成モードで一期のサイズに合わせるオプションを使うと正しく切り取られないバグ
    * ツイートウィンドウのサムネイルが真っ白になるバグ
    * 一覧作成時のみに映り込み防止するオプションの判定がおかしく映り込み防止されないバグ
  * ［既知のバグ]
    * ツイッターの認証時やツイート中にまれにエラーも出さずに落ちる


* Ver0.10<br>
  提督名が隠せるようになりました
  * [追加]
    * 一覧作成モードでのみ、映り込みを防止するオプション
    * 攻略編成モードで作成する艦隊の数を変えるオプション
  * [更新]
    * 提督名と司令部Lvを隠すオプションの有効化
    * TwitterAPIのKeyの更新
    * 追跡失敗時に出力されるメッセージの変更
  * [修正]
    * pngで保存された画像の内容がjpgのバグ
    * 追跡中に一覧作成モードで画像を追加した際に追跡が外れるとエラー落ちするバグ


* Ver0.9<br>
致命的なバグの修正です<br>
提督名はまだ隠せません<br>
  * [更新]
    * 動画キャプチャを60fpsまで対応(それなりの性能が必要です)
    * 動画キャプチャの音ズレ軽減策の暴発を軽減
  * [修正]
    * 範囲選択キャプチャを行うと以後キャプチャの保存が出来なくなるバグ
    * キャプチャ時確認の設定が読み込まれないバグ


* Ver0.8<br>
申し訳ないですが提督名はまだ隠せません<br>
  * [更新]
    * 動画キャプチャを8ではなく4の整数倍ピクセルで撮るようにした
  * [修正]
    * 座標取得時にエラー7で落ちるバグ
    * 攻略編成で背景補完用画像が正しく作成されていなかったバグ


* Ver0.7<br>
艦これ第二期の画面のサイズ変更に対応しました
* [追加]
  * 一覧作成モードで作成画像を艦これ第一期と同じサイズに縮小するオプション
  * 一覧作成モードで右クリックによる範囲選択と移動
  * キャプチャ時に一覧めいかーのウィンドウが映り込みのを防止するオプション
* [更新]
  * 動画キャプチャの音声と映像の同期を厳密に計算するようにした
  * 提督名と司令部Lvを隠すオプションの無効化
  * 一覧作成モードのウィンドウサイズを保存するようにした
* [修正]
  * 一覧作成モードのウィンドウのサイズがモードごとに初期化されていた
  * ツイートウィンドウからキャプチャした場合に自身を隠せていなかった


* Ver0.6<br>
  * [追加]
    * 「その他一覧作成」に「任意範囲」を追加
    * 動画キャプチャのエンコード中止で確認ダイアログを出すように
  * [修正]
    * 動画キャプチャのボタンを連打すると落ちたバグ
    * オプション画面でエンコードが終わると動画キャプチャ開始ボタンが中止のままになるバグ
    * ツイートで落ちるバグ(今後こそ)
    * 誤字修正
　
* Ver0.5<br>
  * [追加]
    * 動画キャプチャで音量の調節及び標準化できるように
    * 「提督名と司令部Lvを隠す」でモザイク処理ができるように
    * 撮影したSSを強制的に800x480pxにリサイズするオプション
  * [更新]
    * 作業取得時にサムネイルウィンドウに表示するように


* Ver0.4.1.1<br>
  * [修正]
    * 外部ソフト連携が機能していなかった不具合


* Ver0.4.1<br>
使用しているプログラミング言語のインタプリタのバグが修正されたので追従のためのアップデートです

* Ver0.4<br>
「致命的」なバグは無かったのでそのままVer0.4としてリリースです。間に合った！！！
  * [既知のバグ]
    * ツイート時にまれに落ちる


* Ver0.4(カリ)<br>
イベントで7人編成とか聞いてない💢
  * [追加]
    * 攻略編成に西村艦隊(7人編成)オプションを追加
    * 攻略編成で艦隊区切り線の色を変えられるように
    * 一覧作成時に画像が読み込まれていない場所に艦これの背景っぽい画像を当てるオプションの追加
    * サポートウィンドウを無効化するオプションの追加(デスクトップPCなどでは無効のほうがいいかもしれません)
  * [更新]
    * 従来の座標検出を再々実装
　[既知のバグ]
    * 動画キャプチャの開始ボタンを連打すると落ちる(ゾンビプロセスが残るのでおすすめしません)
    * サポートウィンドウがグリッドウィンドウにくっつくことがある


* Ver0.3<br>
長かったVer0.3Betaが終わりました
  * [修正]
    * ツイートウィンドウの表示がおかしい不具合
    * ツイート時に選択された画像がないとソフトが落ちる等の不具合
    * その他一覧→基地航空隊で自動追加の際にセル3,1にロードされなかった不具合


* Ver0.3Beta6<br>
Ver0.3Beta5の後にBetaを外すと言ったな　ア レ は 嘘 だ　＼ゥワアアァァーー／
  * [追加]
    * 一覧作成モードに[削除]ボタンを追加(グリッドウィンドウに読み込まれた画像がクリアされます)
    * 一覧作成モードにサポートウィンドウを追加(タブレットPCなどホットキーがしにくい環境向け)
    * 一覧作成モードでホットキーなどによる自動追加がされた時、自動で縦幅を調節する機能(幅の狭い一覧で縦に長くなるのは仕様です)
  * [更新]
    * 自動座標取得で任意の拡大率と場面で取得可能に(成功率は7割ほど)
    * 「他のゲームでも取得可能に(手動のみ)」オプションが事実上機能していなかったのでそのまま削除
  * [修正]
    * 本来操作が出来ない場面でもダブルクリックでウィンドウサイズを変えることで操作できてしまう不具合
    * その他一覧モードで装備一覧を選択したあとにオプションに行くと直接連結が選択される不具合
    * 追跡が有効な際でかつ終了時にそのウィンドウが存在しない場合に次回から起動できなくなる不具合
    * 装備一覧で改修値が見切れていた不具合


* Ver0.3Beta5<br>
このバージョンで発見されたバグが洗えたらBeta外します
  * [追加]
    * その他一覧モードに「装備一覧」が実装
    * 起動時に一覧めいかーの位置を復元する機能
    * 「動画キャプチャ」に時間による制限(自動停止)機能
    * 「連続キャプチャ」に時間/容量/枚数による制限(自動停止)機能
    * ffmpegのログを表示するウィンドウを実装(バグ報告用)　
  * [更新]
    * 艦娘一覧モードと攻略編成モードで切り取る位置を微調節(17/10/18メンテ対応)
　　従来と作成される画像のサイズが少し変わります
    * 起動時の艦これ座標復元機能を強化
    * UIの一部調節
    * ツイート中のプログレスバーが機敏に動くように(笑)
    * 艦娘一覧モードにあった縦幅制限機能がその他一覧モードでも有効に
    * 攻略編成モードに入る文字の高品質化
  * [修正]
    * メインウィンドウのダブルクリックによる縮小表示がVer0.3Beta2からできなかった不具合
    * 起動時にホットキー設定に失敗するとそれ以降有効にならない不具合(オプションから他画面の推移で有効になります)


* Ver0.3Beta4<br>
バグ修正が主です
  * [更新]
    * アップデート確認を高速化
    * エラー発生時に出るダイアログのメッセージの変更
  * [修正]
    * 動画キャプチャを停止しエンコードが開始した際にエラー19で落ちる不具合
    * 動画キャプチャ中にエラー発生が発生するとffmpegがゾンビプロセスになる不具合
    * 連続キャプチャ中にSSをキャプチャすると枚数と容量に加算される不具合
    * 画面切り替え時にウィンドウがちらつく不具合
    * オプションモードを開いている時に動画キャプチャのエンコードが終わると意図しない値が書き換わる不具合


* Ver0.3Beta3<br>
本当に申し訳ありません…
  * [修正]
    * 座標を自動取得しようとするとツイートウィンドウが家出する不具合


* Ver0.3Beta2<br>
Ver0.3Beta1に致命的なバグが有った為
  * [更新]
    * Ver0.3Beta1で保存されなかった保存ダイアログの設定が保存されるように
    * 座標の取得時や範囲選択キャプチャ時に自分自身を隠すように
  * [修正]
    * ツイート終了後にボタンが無効化されたままになる不具合
    * 余白詰め無しの範囲選択キャプチャで小さい範囲を選択すると関係ない警告が表示された不具合
    * SSキャプチャモードで保存ダイアログを出した際にログに関係ないファイル名が表示された不具合


* Ver0.3Beta1<br>
Ver0.2.9.6から更新点が溜まってきたため、途中で切り離したバージョンです
  * [更新]
    * メインウィンドウの縮小ボタン(「↑」ボタン)を廃止し、同様の機能はダブルクリックへ変更
    * 連続キャプチャで撮影秒数と保存された画像の容量をログに出力するように変更
    * 動画キャプチャの音ズレ問題に対して改良を入れた
    * 母港判定を強化　「提督名と司令部Lvを隠す」がより正確に動作するように
  * [追加]
    * 「提督名と司令部Lvを隠す」で司令部Lvは隠さないオプションを追加
    * SSキャプチャや一覧作成の保存時に保存ダイアログを出せるようになった
　　(オプション→キャプチャ設定の「確認」にチェックを入れる　この設定は現時点で保存されません)
    * 動画キャプチャで「マウスカーソルの非表示」「取り込み範囲枠の表示」設定を追加
  * [修正]
    * 起動時座標を復元した際に「座標を手動入力出来るようにする」エディットボックスに座標が反映されない不具合
    * 動画キャプチャ後のエンコードで、使用するffmpegにより予想終了時間が出ない不具合
    * 起動中にシャットダウンするとシャットダウンを妨げる不具合
    * オプションを開いた状態でツイートすると落ちる不具合
    * プロキシのある環境でバージョンチェックが出来ない不具合


* Ver0.2.9.6<br>
  * グリッドウィンドウにD&Dするとエラーが出ていたバグの修正


* Ver0.2.9.5<br>
  * YabumiUpLoaderの指定箇所に日本語を含むファイルパスを指定するとUPボタン押下時にエラー14で落ちるバグの修正
  * 起動時やツイートウィンドウの←→ボタン押下時にエラー13で落ちるバグの修正
  * 範囲選択キャプチャをした際にメインウィンドウのサムネイル表示がおかしかったバグの修正
  * 特定の動作でメインウィンドウのサイズがおかしくなるバグの修正


* Ver0.2.9.4<br>
  * ツイートウィンドウのプレビュー表示の高速化
  * ツイートウィンドウのサムネイルバグを修正
  * ツイートウィンドウにSSキャプチャ及び範囲指定キャプチャ機能の追加
  * ツイートウィンドウとメインウィンドウの最前列設定を独立、オプションの追加
  * 終了確認を無効に出来るようにオプションを追加


* Ver0.2.9.3<br>
  * 動画キャプチャ終了時に中間ファイルを削除しない不具合を修正


* Ver0.2.9.2<br>
  * モード切替時に落ちていた不具合を修正
  * 特定の動作で落ちる不具合を修正
  * 動画キャプチャに機能を追加


* Ver0.2.9.1<br>
  * 数え切れないバグの修正
  * 動画キャプチャ周りの動作を改善


* Ver0.2.9<br>
  * 動画キャプチャ機能を追加
  * 座標取得の進化
  * バグを修正(攻略編成モードの縦2横3で順番が違うなど)
  * バグの追加(数え切れない)
  * アイコンの差し替え


* Ver0.2.6<br>
  * デバッグログ機能の削除
  * その他色々(GitHub参照)
  * 動作の安定化


* Ver0.2.5(途中版)<br>
  * リファクタリング
  * デバッグログ機能の停止


* Ver0.2.4<br>
  * ファイルの存在確認を強化
  * jpgでTwitter投稿を有効にしている場合に余計なファイルを消していた可能性があるのを修正
  * デバッグログ出力を強化


* Ver0.2.3<br>
  * モード切り替えで落ちていたバグが消えた


* Ver0.2.2<br>
  * Windows10でUI拡大率が100%のときにタイトルバーの表示が崩れ移動できなくなることのあるバグの暫定対応として、ボタンやチェックボックスでない部分を掴んで移動できるようにした
  * デバッグログ出力機能を追加。一部の通信内容が入るのでkanahironに渡す場合パス付きアップローダーやzipを推奨します
  * 高DPI対応を強化　UI拡大率の自動設定ON,OFF及び前回の拡大率を保持


* Ver0.2.1<br>
  * ツイートウィンドウの表示がおかしいバグを修正


* Ver0.2<br>
  * タブレットPCや高解像度ディスプレイ環境のためのHighDPIに対応
  * 手動でのUIの拡大率の変更も可能
  * 攻略編成モードで色を変える場合にキャンセルしても灰色になってしまうのを修正
  * 保存名を自由に変えられるように(但しファイル名が重複した場合の処理を書いていないのをこのReadmeを書いている最中に思い出しました。)
  * モード切替やDPI変更時に落ちるバグを実装　結構厄介です。


* Ver0.1.2<br>
  * 艦これ一覧めいかー改二 Ver0.1.1がどこでも提督名を隠していたのを修正
　  * 提督名を隠す機能が任意倍率で可能に←地味に強い更新
  * 内部構造の変更　かなりエンバグを引き起こしそうなのでこれをDLした方、デバッグに努めていただきたいです
  * 手動取得モードでの確認方法の変更
  * あとは忘れた
  * 本来したかった更新はできていないです　申し訳ないです
  * ねむい
  * ぱんつ
  * 艦これ一覧めいかーVer2.6にあった幻のバージョンアップ確認機能を復活！！！

- - -
以下OpenHSPプロジェクトの著作表示など<br>
<br>
Copyright (C) 1997-2017, Onion Software/onitama.<br>
All rights reserved.<br>
<br>
ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に限り、再頒布および使用が許可されます。<br>
<br>
・ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含めること。<br>
・バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表示、本条件一覧、および下記免責条項を含めること。<br>
・書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、Onion Softwareの名前またはコントリビューターの名前を使用してはならない。<br>
<br>
本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューターも、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害について、一切責任を負わないものとします。
