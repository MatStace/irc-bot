require "zabbixapi"
require "json"

class ZabbixTriggers
  include Cinch::Plugin

  listen_to :monitor_msg, :method => :send_msg

  match /zabbix triggers/

  def execute(m)
    zbx = ZabbixApi.connect(
      :url => 'http://zabbix.server.example.com/api_jsonrpc.php',
      :user => 'username',
      :password => 'password'
    ) 

    response = zbx.query(
      :method => "trigger.get",
      :params => {
         :output => ["triggerid", "description", "priority", "hostname"],
         :filter => { :value => 1},
         :sortfield => "priority",
         :sortorder => "DESC",
         :expandData => "TRUE",
         :monitored => "TRUE"

      }
    )

    result = String.new
    hostHash = Hash.new
#    result = Hash.new
#    hostsHash = response["hosts"]
    response.each do|hosts|
      case hosts["priority"]
      when "0"
        result = result + "[\x02\x0314Not classified\x03\x02] "
      when "1"
        result = result + "[\x02\x0303Information\x03\x02] "
      when "2"
        result = result + "[\x02\x0308Warning\x03\x02] "
      when "3"
        result = result + "[\x02\x0306Average\x03\x02] "
      when "4"
        result = result + "[\x02\x0313High\x03\x02] "
      when "5"
        result = result + "[\x02\x0304Disaster\x03\x02] "
      else
        result = result + "[unknown zabbix priority] "
      end
 
      humanTime = Time.at("#{hosts["lastchange"]}".to_i).to_datetime
      result = result + "#{hosts["host"]} : #{hosts["description"]} ( since #{humanTime} )\n"

    end
    m.reply(result  || "No results found", true)

  rescue => e
    error "#{e.class.name}: #{e.message}"
  end



end

