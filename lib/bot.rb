require "telegram/bot"
require "json"

class MyBot
  def initialize
    file = File.read("lib/choose.json")
    choose = JSON.parse(file)
    Telegram::Bot::Client.run(ENV['API_KEY']) do |bot|
      bot.listen do |message|
        case message
        when Telegram::Bot::Types::CallbackQuery
          title = choose[message.data]["title"]
          value = choose[message.data]["options"]
          res = value.map do |hash|
            Telegram::Bot::Types::InlineKeyboardButton.new(text: hash["text"], url: hash["url"])
          end
          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: res)

          bot.api.send_message(chat_id: message.from.id, text: "Тема #{title}. Отличный выбор \u{1F44D}", reply_markup: markup)
        when Telegram::Bot::Types::Message
          case message.text
          when "/start"
            question = "Привет, #{message.from.first_name} \u{1F91D}! \n На какую тему ты хочешь посмотреть фильм? \n Выбирай ниже \u{1F447}"
            kb = [
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "МЕДИЦИНА", callback_data: "medicine"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "ВЗАИМООТНОШЕНИЯ", callback_data: "relationship"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "СПОРТ", callback_data: "sport"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "СИЛЬНЫЕ ДУХОМ", callback_data: "willpower"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "ПРАВОСУДИЕ", callback_data: "justice"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "ПСИХОЛОГИЯ,ФИЛОСОФИЯ", callback_data: "psychology"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "ВОЙНА", callback_data: "war"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "НАУКА", callback_data: "science"),
            ]
            answers = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
            bot.api.send_message(chat_id: message.chat.id, text: question, reply_markup: answers)
          when "/stop"
            kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
            bot.api.send_message(chat_id: message.chat.id, text: "Жаль, что ты уходишь \u{1F622}. \n Мне казалось нам было весело вместе... \n Надеюсь, ты скоро вернёшься. И я увижу тебя снова \u{1F618} . \n Пока \u{1F60A}", reply_markup: kb)
          end
        end
      end
    end
  end
end
