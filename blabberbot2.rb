require 'socket'
require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'


MY_CHANNELS = ["#systems-bot-test","#systems-bot-test2"]
MY_LISTENING_IP = "0.0.0.0"
MY_LISTENING_PORT = 2001


require_relative "plugins/link_info"
require_relative "plugins/zabbix_trigger_info"
require_relative "plugins/tube_status"

class BlabberBot
  include Cinch::Plugin

  listen_to :monitor_msg, :method => :send_msg
 
  match /phrasing (.+)/
  def lookup(word)
    url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(word)}"
    CGI.unescape_html Nokogiri::HTML(open(url)).at("div.meaning").text.gsub(/\s+/, ' ') rescue nil
  end

  def execute(m, word)
    m.reply(lookup(word) || "No results found", true)
  end
end


bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = "testblabberbot"
    c.realname        = "load of old nonsense"
    c.user            = "speak to Mat"
    c.server          = "irc.example.com"
    c.port            = 6697
    c.ssl.use             = true
    c.channels        = MY_CHANNELS
    c.verbose         = false
    c.plugins.plugins = [BlabberBot,Cinch::LinkInfo,ZabbixTriggers,TubeStatus]
  end
end

def server(bot)
  print "Thread Start\n"
  server = TCPServer.new MY_LISTENING_IP, MY_LISTENING_PORT
  loop do
    Thread.start(server.accept) do |client|
      message = client.gets
      bot.handlers.dispatch(:monitor_msg, nil, message)
      client.puts "Ok\n"
      client.close
    end #Thread.Start
  end #loop
end

Thread.new { server(bot) }
bot.start
