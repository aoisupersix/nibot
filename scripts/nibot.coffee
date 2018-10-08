# Description:
#   helps you to make curl command.
#
# Commands:
#   hubot gen-nippo - building nippo template in coversation with bot.

Conversation = require('hubot-conversation');

class Nippo
    date = ""
    name = ""
    oneThing = ""
    plansToday = ""
    doingToday = ""
    comment = ""
    plansTomorrow = ""

    generate: () -> 
        """
        #{@date}　#{@name}
        ■今日のひとこと 
        #{@oneThing}

        ■今日やる予定だったこと
        #{@plansToday}

        ■今日やったこと
        #{@doingToday}

        ■困ったこと・学んだこと・共有したいこと
        #{@comment}

        ■明日やる予定のこと
        #{@plansTomorrow}
        """

module.exports = (robot) ->
    conversation = new Conversation(robot)

    # コマンド本体
    robot.respond /ni-gen/i, (res) ->

        # 対話形式の有効時間（放置されるとタイムアウトする）
        dialog = conversation.startDialog res, 300000; # timeout = 5min
        dialog.timeout = (res) ->
            res.emote('タイムアウトです。もう一度`ni-gen`を入力してやり直してください。')

        get_date res, dialog
        get_name res, dialog

        res.reply("""
        〜〜〜日報ジェネレータ〜〜〜
        #{p.name}さん
        #{p.date}の日報を#nippoチャンネルに投稿します。
        メッセージに従って日報を入力して下さい。
        〜〜〜〜
        """)

        # 対話形式スタート
        input_oneThing res, dialog
        #input_url res, dialog

    # 
    # 以下、対話式ダイアログです
    # 
    p = new Nippo

    # 入力値のトリムに使います
    trim_input = (str) -> str.replace(/nibot /, '')

    #日付
    get_date = (res, dialog) ->
        d = new Date()
        year  = d.getFullYear()     # 年（西暦）
        month = d.getMonth() + 1    # 月
        date  = d.getDate()         # 日
        p.date = "#{year}年#{month}月#{date}日"

    #名前
    get_name = (res, dialog) ->
        p.name = res.message.user.real_name

    #一言の入力
    input_oneThing = (res, dialog) ->
        res.send '「今日のひとこと」を入力してください。▼ '
        dialog.addChoice /(.*)/, (res2) ->
            p.oneThing = trim_input res2.match[1]
            input_plansToday res2, dialog
            #show_result res2, dialog

    #今日やる予定だったことの入力
    input_plansToday = (res, dialog) ->
        res.send '「今日やる予定だったこと」を入力してください。▼'
        dialog.addChoice /(.+)/, (res2) ->
            p.plansToday = trim_input res2.match[1]
            input_doingToday res2, dialog

    #今日やったことの入力
    input_doingToday = (res, dialog) ->
        res.send '「今日やったこと」を入力してください。▼'
        dialog.addChoice /(.+)/, (res2) ->
            p.doingToday = trim_input res2.match[1]
            input_comment res2, dialog

    #コメントの入力
    input_comment = (res, dialog) ->
        res.send '「困ったこと・学んだこと・共有したいこと」を入力してください。▼'
        dialog.addChoice /(.+)/, (res2) ->
            p.comment = trim_input res2.match[1]
            input_plansTomorrow res2, dialog
    
    #明日やる予定のことの入力
    input_plansTomorrow = (res, dialog) ->
        res.send '「明日やる予定のこと」を入力してください。▼'
        dialog.addChoice /(.+)/, (res2) ->
            p.plansTomorrow = trim_input res2.match[1]
            show_result res2, dialog

    # 結果表示
    show_result = (res, dialog) ->

        envelope = {
            room: 'CBGG0ANU8',
        }
        postData = {
            text: p.generate()
            as_user: false,
            username: res.message.user.real_name,
            icon_url: res.message.user.slack.profile.image_original
        }
        robot.send(envelope, postData)
        #res.reply p.generate()
        res.reply "投稿が完了しました"