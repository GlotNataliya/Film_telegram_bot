require 'telegram/bot'
require 'dotenv/load'
require "json"
require 'pry'

class MyBot
  def initialize
    @token = ENV["API_KEY"]
  end

  def run_telegram_bot
    file = File.read("lib/choose.json")
    parsed_file = JSON.parse(file)

    Telegram::Bot::Client.run(@token) do |bot|
      bot.listen do |message|
        case message
        when Telegram::Bot::Types::CallbackQuery
          title = parsed_file[message.data]["title"]
          values = parsed_file[message.data]["options"]

          res = values.map do |value|
            Telegram::Bot::Types::InlineKeyboardButton.new(text: value["text"], url: value["url"])
          end

          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [res].flatten.map(&method(:Array)))

          bot.api.send_message(chat_id: message.from.id, text: "Тема #{title}. Отличный выбор \u{1F44D}", reply_markup: markup)
        when Telegram::Bot::Types::Message
          case message.text
          when "/start"
            question = "Привет, #{message.from.first_name} \u{1F91D}! \n На какую тему ты хочешь посмотреть фильм? \n Выбирай ниже \u{1F447}"
            themes = [[
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "МЕДИЦИНА", callback_data: "medicine"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "ВЗАИМООТНОШЕНИЯ", callback_data: "relationship"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "СПОРТ", callback_data: "sport"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "СИЛЬНЫЕ ДУХОМ", callback_data: "willpower"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "ПРАВОСУДИЕ", callback_data: "justice"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "ПСИХОЛОГИЯ,ФИЛОСОФИЯ", callback_data: "psychology"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "ВОЙНА", callback_data: "war"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "НАУКА", callback_data: "science"),
              Telegram::Bot::Types::InlineKeyboardButton.new(text: "ДЛЯ ДУШИ(не на реальных событиях)", callback_data: "for_the_soul"),
            ]].flatten.map(&method(:Array))

            markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: themes)
            bot.api.send_message(chat_id: message.chat.id, text: question, reply_markup: markup)
          when "/stop"
            kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
            bot.api.send_message(chat_id: message.chat.id, text: "Жаль, что ты уходишь \u{1F622}. \nМне казалось, нам было весело вместе... \nНадеюсь, ты скоро вернёшься, и я увижу тебя снова \u{1F618} . \nПока \u{1F60A}", reply_markup: kb)
          when "/write_me"
            kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
            bot.api.send_message(chat_id: message.chat.id, text: "Ты знаешь интересный фильм и хочешь с ним поделиться? \nИли у тебя есть другие идеи? \nНапиши мне: an.chishevich@yandex.ru \u{1F60A}", reply_markup: kb)
          end
        end
      end
    end
  end
end
