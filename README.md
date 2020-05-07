# README

# Name（takeshi0311/weather-bot)
weather-botは自分が住んでいる愛知県西部地域の天気予報を知らせてくれる天気予報botとなっています。
「今日」と打てば今日の天気、「明日」と打てば明日の天気、「明後日」と打てば明後日の天気を気象庁のサイトからデータを取得し、
ユーザーに返してくれます。
また毎朝決まった時間に「今日」の天気を自動でユーザーに配信してくれます。
 
気象庁のサイト
https://www.drk7.jp/weather/

愛知県西部の気象XMLデータ
https://www.drk7.jp/weather/xml/23.xml

# DEMO
下記リンクにデモ動画を載せています。<br>
一度ご覧ください。<br>
 https://gyazo.com/d70668ec5da702dba14a0320affa0307
 
# Features
 今回は下記の2つのことを意識して開発を行いました。<br>
 ①視覚的に天気わかるようにLINEのメッセージのフォーマットを独自に作成。<br>
 ②「晴れ」、「雨」、「くもり」だけでなく「晴れのちくもり」や「くもり時々雨」など全ての場合の天気を正確にユーザーに伝えるために、天気によってメッセージを変えるように条件分岐させた。

各天気に合わせたメッセージ一覧はいかになります。
 
 
# Installation
 上記、LINEbotを使うには以下のQRコードを読み取り、友達追加をしてください。
 友達追加後、「今日」、「明日」、「明後日」のどれかを打ち天気情報を見てみてください。<br><br>
 <img border="0" src="https://github.com/takeshi0311/weather-bot/blob/master/images/%E5%A4%A9%E6%B0%97%E4%BA%88%E5%A0%B1botQR.png" width="128" height="128" alt="QRコード">
 
# Note
 
文字を入力してからbotが返信するまで時間がかかることがあります。
 
# Author
 
* 作成者：スズキタケシ
* E-mail：takeshi.c.suzuki@gmail.com
 
