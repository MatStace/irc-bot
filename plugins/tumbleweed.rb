class Tumbleweed
  include Cinch::Plugin

  listen_to :monitor_msg, :method => :send_msg

  match /tumbleweed/
      def execute(m)
      m.reply <<-WEED
.....@....@..@.........@....@.@....@...................
      WEED
    end
end

