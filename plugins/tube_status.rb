require "tube/status"

class TubeStatus
  include Cinch::Plugin

  listen_to :monitor_msg, :method => :send_msg

  match(/tube broken/, method: :broken)

  def broken(m)

    status = Tube::Status.new

    broken_lines = status.lines.select {|line| line.problem?}
    line_names = String.new
    line_names = broken_lines.collect {|line| line.name}


    result = String.new
    result = "Currently Broken Tube Lines: "
    hostHash = Hash.new
#    result = Hash.new
#    hostsHash = response["hosts"]
    line_names.each do|line|
 
      result = result + "#{line}, "

    end
    m.reply(result  || "No results found", true)

  rescue => e
    error "#{e.class.name}: #{e.message}"
  end

  match(/tube line (\S+)/, method: :linedeets)
  def linedeets(m, chosen_line)
    status = Tube::Status.new
    line_message = String.new
    line_message = status.lines.detect {|line| line.id == :"#{chosen_line}".downcase}.message

    m.reply(line_message  || "No results found", true)
  end
end

