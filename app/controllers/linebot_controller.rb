class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      return head :bad_request
    end
    events = client.parse_events_from(body)
    events.each { |event|
      case event
        # メッセージが送信された場合の対応（機能①）
      when Line::Bot::Event::Message
        case event.type
          # ユーザーからテキスト形式のメッセージが送られて来た場合
        when Line::Bot::Event::MessageType::Text
          # event.message['text']：ユーザーから送られたメッセージ
          input = event.message['text']
          # url  = "https://www.drk7.jp/weather/xml/23.xml"
          url  = "https://www.drk7.jp/weather/xml/01.xml"
          xml  = open( url ).read.toutf8
          doc = REXML::Document.new(xml)
          # xpath = 'weatherforecast/pref/area[2]/'
          xpath = 'weatherforecast/pref/area[1]/'
          # 当日朝のメッセージの送信の下限値は20％としているが、明日・明後日雨が降るかどうかの下限値は30％としている
          # imgurl         = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcS7HQA6bcOaK5FlAjC8-iEOuM7Ad6KgUuSAlm_R_R_0HoRpimk9&usqp=CAU"
          # website        = "https://www.jma.go.jp/jp/week/329.html"
          # weathertext    = "本日は雨のちくもりです。"
          # iconurl1       = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
          # iconurl2       = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
          # iconurl3       = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
          # morning        = 30
          # moonning       = 40
          # evening        = 60
          # maxtemperature = 25
          # mintemperature = 16
          # bottomcomment  = "今日は晴れです！　　　　　いい天気です。　　　　　　今日も頑張っていきましょう！！"
          # min_per = 30
          case input
            # 「明日」or「あした」というワードが含まれる場合
          when /.*(明日|あした).*/
            # info[2]：明日の天気
            weather        = doc.elements[xpath + 'info[2]/weather'].text
            website        = "https://www.jma.go.jp/jp/week/329.html"
            morning        = doc.elements[xpath + 'info[2]/rainfallchance/period[2]'].text.to_i
            moonning       = doc.elements[xpath + 'info[2]/rainfallchance/period[3]'].text.to_i
            evening        = doc.elements[xpath + 'info[2]/rainfallchance/period[4]'].text.to_i
            maxtemperature = doc.elements[xpath + 'info[2]/temperature/range[1]'].text.to_i
            mintemperature = doc.elements[xpath + 'info[2]/temperature/range[2]'].text.to_i
            weatherchange = ["一時", "時々", "後", "のち", "後一時", "後時々"]
            # if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
            if weather == "晴れ"
              imgurl        = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcS7HQA6bcOaK5FlAjC8-iEOuM7Ad6KgUuSAlm_R_R_0HoRpimk9&usqp=CAU"
              iconurl1      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
              iconurl2      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
              iconurl3      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
              bottomcomment = "明日は晴れです！　　　　　いい天気です。　　　　　　明日も頑張っていきましょう！！"
              weathertext   = "明日は#{weather}です。"
              # push =
              #   "明日の天気だよね。\n明日は雨が降りそうだよ(>_<)\n今のところ降水確率はこんな感じだよ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            elsif weather == "くもり"
              imgurl        = "https://www.imgstyle.info/files/thumb_0e4e0045d7ba40177a86b889d700c29c.jpg"
              iconurl1      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
              iconurl2      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
              iconurl3      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
              bottomcomment = "明日はくもりです。雨が降る可能性もありますので折りたたみ傘があると安心です！　明日も一日頑張りましょう！"
              weathertext   = "明日は#{weather}です。"
            elsif weather == "雨"
              imgurl        = "https://pure-life.biz/wp-content/uploads/2019/04/1113098.png"
              iconurl1      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
              iconurl2      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
              iconurl3      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
              bottomcomment = "明日は雨が降りそうです。　傘を忘れないで下さい！　　明日も一日頑張りましょう！"
              weathertext   = "明日は#{weather}です。"
            # elsif weatherchange.any? { |t| weather.include?(t) }
            else
              matchstring = weatherchange.find { |t| weather.include?(t) }
              weathercombination = weather.split(matchstring)
                if weathercombination[0] == "晴れ" && weathercombination[1] == "くもり"
                    imgurl        = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcThoh8dTaGHeBQbzhj5FhkRuD6aBade-0cvppsH75fMYYKPRGb_&usqp=CAU"
                    iconurl1      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
                    iconurl2      = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXKbLJX8i5eWVaivnyU0ZOc7I1-mrOwm6MFS2N52qVGsJ73kNN&usqp=CAU"
                    iconurl3      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
                    bottomcomment = "明日は#{weather}です。　明日も1日頑張って行きましょう！"
                    weathertext   = "明日は#{weather}です。"
                elsif weathercombination[0] == "晴れ" && weathercombination[1] == "雨"
                    imgurl        = "https://weather.jldn-info.jp/Weather/img/weekly-weather-icon-012-sun-rny.png"
                    iconurl1      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
                    iconurl2      = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXKbLJX8i5eWVaivnyU0ZOc7I1-mrOwm6MFS2N52qVGsJ73kNN&usqp=CAU"
                    iconurl3      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
                    bottomcomment = "明日は#{weather}です。　　明日は雨が降りそうだから傘を忘れないでね！　　　　　明日も1日頑張って行きましょう！"
                    weathertext   = "明日は#{weather}です。"
                elsif weathercombination[0] == "くもり" && weathercombination[1] == "晴れ"
                    imgurl        = "https://weathernews.auone.jp/au/img/telop/210.png"
                    iconurl1      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
                    iconurl2      = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXKbLJX8i5eWVaivnyU0ZOc7I1-mrOwm6MFS2N52qVGsJ73kNN&usqp=CAU"
                    iconurl3      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
                    bottomcomment = "明日は#{weather}です。　明日は午後から晴れる予報です！明日も1日頑張って行きましょう！"
                    weathertext   = "明日は#{weather}です。"
                elsif weathercombination[0] == "くもり" && weathercombination[1] == "雨"
                    imgurl        = "https://weather.jldn-info.jp/Weather/img/weekly-weather-icon-022-cld-rny.png"
                    iconurl1      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
                    iconurl2      = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXKbLJX8i5eWVaivnyU0ZOc7I1-mrOwm6MFS2N52qVGsJ73kNN&usqp=CAU"
                    iconurl3      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
                    bottomcomment = "明日は#{weather}です。　明日は雨が降りそうなので傘を忘れないで下さい！　　　明日も1日頑張って行きましょう！"
                    weathertext   = "明日は#{weather}です。"
                elsif weathercombination[0] == "雨" && weathercombination[1] == "晴れ"
                    imgurl        = "https://pbs.twimg.com/profile_images/877491396931764226/sWoT1gWx_400x400.jpg"
                    iconurl1      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
                    iconurl2      = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXKbLJX8i5eWVaivnyU0ZOc7I1-mrOwm6MFS2N52qVGsJ73kNN&usqp=CAU"
                    iconurl3      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
                    bottomcomment = "明日は#{weather}です。傘を忘れずに持って行って下さい！後に雨は上がるでしょう！明日も1日頑張って行きましょう！"
                    weathertext   = "明日は#{weather}です。"
                elsif weathercombination[0] == "雨" && weathercombination[1] == "くもり"
                    imgurl        = "https://weathernews.auone.jp/au/img/telop/313.png"
                    iconurl1      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
                    iconurl2      = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXKbLJX8i5eWVaivnyU0ZOc7I1-mrOwm6MFS2N52qVGsJ73kNN&usqp=CAU"
                    iconurl3      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
                    bottomcomment = "明日は#{weather}です。傘を忘れずに持って行って下さい！後に雨は上がるでしょう！明日も1日頑張って行きましょう！"
                    weathertext   = "明日は#{weather}です。"
                end
              # push =
              #   "明日の天気？\n明日は雨が降らない予定だよ(^^)\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            end
          when /.*(明後日|あさって).*/
            per06to12 = doc.elements[xpath + 'info[3]/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info[3]/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info[3]/rainfallchance/period[4]l'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =
                "明後日の天気だよね。\n何かあるのかな？\n明後日は雨が降りそう…\n当日の朝に雨が降りそうだったら教えるからね！"
            else
              push =
                "明後日の天気？\n気が早いねー！何かあるのかな。\n明後日は雨は降らない予定だよ(^^)\nまた当日の朝の最新の天気予報で雨が降りそうだったら教えるからね！"
            end
          when /.*(かわいい|可愛い|カワイイ|きれい|綺麗|キレイ|素敵|ステキ|すてき|面白い|おもしろい|ありがと|すごい|スゴイ|スゴい|好き|頑張|がんば|ガンバ).*/
            push =
              "ありがとう！！！\n優しい言葉をかけてくれるあなたはとても素敵です(^^)"
          when /.*(こんにちは|こんばんは|初めまして|はじめまして|おはよう).*/
            push =
              "こんにちは。\n声をかけてくれてありがとう\n今日があなたにとっていい日になりますように(^^)"
          else
            per06to12 = doc.elements[xpath + 'info/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info/rainfallchance/period[4]l'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              word =
                ["雨だけど元気出していこうね！",
                 "雨に負けずファイト！！",
                 "雨だけどああたの明るさでみんなを元気にしてあげて(^^)"].sample
              push =
                "今日の天気？\n今日は雨が降りそうだから傘があった方が安心だよ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\n#{word}"
            else
              word =
                ["天気もいいから一駅歩いてみるのはどう？(^^)",
                 "今日会う人のいいところを見つけて是非その人に教えてあげて(^^)",
                 "素晴らしい一日になりますように(^^)",
                 "雨が降っちゃったらごめんね(><)"].sample
              push =
                "今日の天気？\n今日は雨は降らなさそうだよ。\n#{word}"
            end
          end
          # テキスト以外（画像等）のメッセージが送られた場合
        else
          push = "テキスト以外はわからないよ〜(；；)"
        end
        # message = {
        #   type: 'text',
        #   text: push
        # }
        message = {
          "type": 'flex',
          "altText": 'This is a Flex Message',
          "contents":
          {
            "type": 'carousel',
            "contents": [ 
              create_message(imgurl, website, weathertext, iconurl1, iconurl2, iconurl3, morning, moonning, evening, maxtemperature, mintemperature, bottomcomment)
            ]
          }
        }
        client.reply_message(event['replyToken'], message)
        # LINEお友達追された場合（機能②）
      when Line::Bot::Event::Follow
        # 登録したユーザーのidをユーザーテーブルに格納
        line_id = event['source']['userId']
        User.create(line_id: line_id)
        # LINEお友達解除された場合（機能③）
      when Line::Bot::Event::Unfollow
        # お友達解除したユーザーのデータをユーザーテーブルから削除
        line_id = event['source']['userId']
        User.find_by(line_id: line_id).destroy
      end
    }
    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def create_message(imgurl, website, weathertext, iconurl1, iconurl2, iconurl3, morning, moonning, evening, maxtemperature, mintemperature, bottomcomment)
    {
      "type": "bubble",
      "hero": {
        "type": "image",
        "size": "full",
        "aspectRatio": "20:13",
        "aspectMode": "cover",
        "action": {
          "type": "uri",
          "uri": website
        },
        "url": imgurl
      },
      "body": {
        "type": "box",
        "layout": "vertical",
        "contents": [
          {
            "type": "text",
            "text": weathertext,
            "weight": "bold",
            "size": "lg"
          },
          {
            "type": "box",
            "layout": "baseline",
            "margin": "md",
            "contents": [
              {
                "type": "icon",
                "size": "sm",
                "url": iconurl1
              },
              {
                "type": "icon",
                "size": "sm",
                "url": iconurl2
              },
              {
                "type": "icon",
                "size": "sm",
                "url": iconurl3
              }
            ]
          },
          {
            "type": "box",
            "layout": "vertical",
            "margin": "lg",
            "spacing": "sm",
            "contents": [
              {
                "type": "box",
                "layout": "baseline",
                "spacing": "sm",
                "contents": [
                  {
                    "type": "text",
                    "text": "降水確率",
                    "color": "#aaaaaa",
                    "size": "xs",
                    "flex": 1,
                    "margin": "none"
                  },
                  {
                    "type": "text",
                    "text": "朝:#{morning}%　昼:#{moonning}%　夜:#{evening}%",
                    "wrap": true,
                    "color": "#666666",
                    "size": "xs",
                    "flex": 3
                  }
                ]
              },
              {
                "type": "box",
                "layout": "baseline",
                "contents": [
                  {
                    "type": "text",
                    "text": "気温",
                    "color": "#aaaaaa",
                    "flex": 1,
                    "margin": "none",
                    "size": "xs"
                  },
                  {
                    "type": "text",
                    "text": "最高：#{maxtemperature}℃　最低：#{mintemperature}℃",
                    "flex": 3,
                    "color": "#666666",
                    "size": "xs"
                  }
                ]
              },
              {
                "type": "box",
                "layout": "baseline",
                "spacing": "sm",
                "contents": [
                  {
                    "type": "text",
                    "text": "コメント",
                    "color": "#aaaaaa",
                    "size": "xs",
                    "flex": 2
                  },
                  {
                    "type": "text",
                    "wrap": true,
                    "color": "#666666",
                    "size": "sm",
                    "flex": 6,
                    "text": bottomcomment
                  }
                ]
              }
            ]
          }
        ]
      },
      "footer": {
        "type": "box",
        "layout": "vertical",
        "spacing": "sm",
        "contents": [
          {
            "type": "button",
            "style": "link",
            "height": "sm",
            "action": {
              "type": "uri",
              "label": "WEBSITE",
              "uri": website
            }
          },
          {
            "type": "spacer",
            "size": "sm"
          }
        ],
        "flex": 0
      }
    }
  end

end
