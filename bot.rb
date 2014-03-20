require 'socket'
require 'cinch'

MY_CHANNEL = "#channel"
MY_LISTENING_IP = "0.0.0.0"
MY_LISTENING_PORT = 2000
require_relative "plugins/zabbix_trigger_info"

class MonitorBot
  include Cinch::Plugin

  listen_to :monitor_msg, :method => :send_msg

  def send_msg(m, msg)
     Channel(MY_CHANNEL).send "#{msg}"
  end

end

bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = "zabbixbot"
    c.realname        = "zabbix disaster alerts"
    c.user            = "speak to Mat"
    c.server          = "irc.example.com"
    c.port            = 6697
    c.ssl.use             = true
    c.channels        = [MY_CHANNEL]
    c.verbose         = false
    c.plugins.plugins = [MonitorBot,ZabbixTriggers]
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
