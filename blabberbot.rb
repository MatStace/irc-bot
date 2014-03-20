require 'socket'
require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'


MY_CHANNELS = ["#channel01 key","#channel02","#channel03"]
MY_LISTENING_IP = "0.0.0.0"
MY_LISTENING_PORT = 2001


require_relative "plugins/link_info"
require_relative "plugins/zabbix_trigger_info"
require_relative "plugins/tube_status"
require_relative "plugins/tumbleweed"
require_relative "plugins/lana"

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


class Help
  include Cinch::Plugin

  listen_to :monitor_msg, :method => :send_msg

  match /help/
      def execute(m)
      m.reply <<-HELP
Tube:
   
!tube broken
 - list all tube lines with current problems
!tube line foo
 - get the detailed status about tube line foo (NB, must be a real tube line, eg '!tube line circle'
  
  
Link Info
 - no commands, this plugin posts the contents of the <title></title> tag for any posted URIs
  
Zabbix triggers
!zabbix triggers
 - show all current triggers in the problem state on zabbix2
   
Urban Dictionary Lookup
!phrasing
 - do an urban dictionary lookup for the given phrase, and return the first result (if any). Probably NSFW
  
Tumbleweed
!tumbleweed
 - return a one line ascii representation of tubleweed. It's not big, it's not clever, it's just a one line response
  
      HELP
    end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = "blabberbot"
    c.realname        = "load of old nonsense"
    c.user            = "speak to Mat"
    c.server          = "irc.example.com"
    c.port            = 6697
    c.ssl.use             = true
    c.channels        = MY_CHANNELS
    c.verbose         = false
    c.plugins.plugins = [BlabberBot,Cinch::LinkInfo,TubeStatus,Help,Tumbleweed,Lana]
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
