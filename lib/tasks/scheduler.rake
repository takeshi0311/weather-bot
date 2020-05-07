namespace :greet do
desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
  require 'line/bot'  # gem 'line-bot-api'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'

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

  client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }

  使用したxmlデータ（毎日朝6時更新）：以下URLを入力すれば見ることができます。
  url  = "https://www.drk7.jp/weather/xml/23.xml"
  # xmlデータをパース（利用しやすいように整形）
  xml  = open( url ).read.toutf8
  doc = REXML::Document.new(xml)
  # パスの共通部分を変数化（area[2]は「愛知県西部地域」を指定している）
  # xpath = 'weatherforecast/pref/area[2]/info/rainfallchance/'
  xpath = 'weatherforecast/pref/area[2]/'
  website        = "https://www.jma.go.jp/jp/week/329.html"
  weatherchange = ["一時", "時々", "後", "のち", "後一時", "後時々"]
  weather        = doc.elements[xpath + 'info[1]/weather'].text
  morning        = doc.elements[xpath + 'info[1]/rainfallchance/period[2]'].text.to_i
  moonning       = doc.elements[xpath + 'info[1]/rainfallchance/period[3]'].text.to_i
  evening        = doc.elements[xpath + 'info[1]/rainfallchance/period[4]'].text.to_i
  maxtemperature = doc.elements[xpath + 'info[1]/temperature/range[1]'].text.to_i
  mintemperature = doc.elements[xpath + 'info[1]/temperature/range[2]'].text.to_i
  if weather == "晴れ"
    imgurl        = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcS7HQA6bcOaK5FlAjC8-iEOuM7Ad6KgUuSAlm_R_R_0HoRpimk9&usqp=CAU"
    iconurl1      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
    iconurl2      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
    iconurl3      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
    bottomcomment = "今日は晴れです！　　　　　いい天気です。　　　　　　今日も頑張っていきましょう！！"
    weathertext   = "今日は#{weather}です。"
  elsif weather == "くもり"
    imgurl        = "https://www.imgstyle.info/files/thumb_0e4e0045d7ba40177a86b889d700c29c.jpg"
    iconurl1      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
    iconurl2      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
    iconurl3      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
    bottomcomment = "今日はくもりです。雨が降る可能性もありますので折りたたみ傘があると安心です！　今日も一日頑張りましょう！"
    weathertext   = "今日は#{weather}です。"
  elsif weather == "雨"
    imgurl        = "https://pure-life.biz/wp-content/uploads/2019/04/1113098.png"
    iconurl1      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
    iconurl2      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
    iconurl3      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
    bottomcomment = "今日は雨が降りそうです。　傘を忘れないで下さい！　　今日も一日頑張りましょう！"
    weathertext   = "今日は#{weather}です。"
  else
    matchstring = weatherchange.find { |t| weather.include?(t) }
    weathercombination = weather.split(matchstring)
      if weathercombination[0] == "晴れ" && weathercombination[1] == "くもり"
          imgurl        = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcThoh8dTaGHeBQbzhj5FhkRuD6aBade-0cvppsH75fMYYKPRGb_&usqp=CAU"
          iconurl1      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
          iconurl2      = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXKbLJX8i5eWVaivnyU0ZOc7I1-mrOwm6MFS2N52qVGsJ73kNN&usqp=CAU"
          iconurl3      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
          bottomcomment = "今日は#{weather}です。　今日も1日頑張って行きましょう！"
          weathertext   = "今日は#{weather}です。"
      elsif weathercombination[0] == "晴れ" && weathercombination[1] == "雨"
          imgurl        = "https://weather.jldn-info.jp/Weather/img/weekly-weather-icon-012-sun-rny.png"
          iconurl1      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
          iconurl2      = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXKbLJX8i5eWVaivnyU0ZOc7I1-mrOwm6MFS2N52qVGsJ73kNN&usqp=CAU"
          iconurl3      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
          bottomcomment = "今日は#{weather}です。　　今日は雨が降りそうだから傘を忘れないでね！　　　　　今日も1日頑張って行きましょう！"
          weathertext   = "今日は#{weather}です。"
      elsif weathercombination[0] == "くもり" && weathercombination[1] == "晴れ"
          imgurl        = "https://weathernews.auone.jp/au/img/telop/210.png"
          iconurl1      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
          iconurl2      = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXKbLJX8i5eWVaivnyU0ZOc7I1-mrOwm6MFS2N52qVGsJ73kNN&usqp=CAU"
          iconurl3      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
          bottomcomment = "今日は#{weather}です。　今日は午後から晴れる予報です！今日も1日頑張って行きましょう！"
          weathertext   = "今日は#{weather}です。"
      elsif weathercombination[0] == "くもり" && weathercombination[1] == "雨"
          imgurl        = "https://weather.jldn-info.jp/Weather/img/weekly-weather-icon-022-cld-rny.png"
          iconurl1      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
          iconurl2      = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXKbLJX8i5eWVaivnyU0ZOc7I1-mrOwm6MFS2N52qVGsJ73kNN&usqp=CAU"
          iconurl3      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
          bottomcomment = "今日は#{weather}です。　今日は雨が降りそうなので傘を忘れないで下さい！　　　今日も1日頑張って行きましょう！"
          weathertext   = "今日は#{weather}です。"
      elsif weathercombination[0] == "雨" && weathercombination[1] == "晴れ"
          imgurl        = "https://pbs.twimg.com/profile_images/877491396931764226/sWoT1gWx_400x400.jpg"
          iconurl1      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
          iconurl2      = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXKbLJX8i5eWVaivnyU0ZOc7I1-mrOwm6MFS2N52qVGsJ73kNN&usqp=CAU"
          iconurl3      = "https://www.photolibrary.jp/mhd4/img252/450-20120524224023194686.jpg"
          bottomcomment = "今日は#{weather}です。傘を忘れずに持って行って下さい！後に雨は上がるでしょう！今日も1日頑張って行きましょう！"
          weathertext   = "今日は#{weather}です。"
      elsif weathercombination[0] == "雨" && weathercombination[1] == "くもり"
          imgurl        = "https://weathernews.auone.jp/au/img/telop/313.png"
          iconurl1      = "https://www.cjs.ne.jp/umeda/blog/wp-content/uploads/2018/05/ame.png"
          iconurl2      = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXKbLJX8i5eWVaivnyU0ZOc7I1-mrOwm6MFS2N52qVGsJ73kNN&usqp=CAU"
          iconurl3      = "https://i.pinimg.com/originals/5c/cc/7b/5ccc7b3eac3830853c4c55e95124ae95.png"
          bottomcomment = "今日は#{weather}です。傘を忘れずに持って行って下さい！後に雨は上がるでしょう！今日も1日頑張って行きましょう！"
          weathertext   = "今日は#{weather}です。"
      end
  end

  user_ids = User.all.pluck(:line_id)

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
    response = client.multicast(user_ids, message)
  end
  "OK"
end