class Lana
  include Cinch::Plugin

  listen_to :monitor_msg, :method => :send_msg

  match /lana/
      def execute(m)
      m.reply <<-LANA
NOOOOOOPE!
      LANA
    end
end

