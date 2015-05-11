require 'socket'
require 'thread'
require 'json'

Thread.abort_on_exception = true

$id = 2
$cats = [{ "id" => 1, "name" => "Markov" }, { "id" => 2, "name" => "Fluffy"}]

server = TCPServer.new(3000)
def handle_request(socket)
  Thread.new do
    line1 = socket.gets.chomp

    re = /^([^ ]+) ([^ ]+) HTTP\/1.1$/
    match_data = re.match(line1)

    verb = match_data[1]
    path = match_data[2]

    #"Resource" is cats: /cats, /cats/1
    cat_regex = /\/cats\/(\d+)/
    if [verb, path] == ["GET", "/cats"]
      #GET /cats
      #index action
      socket.puts $cats.to_json
    elsif verb == "GET" && cat_regex =~ path
      #GET /cats/1
      #show action
      socket.gets
      match_data2 = cat_regex.match(path)
      cat_id = Integer(match_data2[1])
      cat = $cats.find { |cat| cat[:id] == cat_id }
      socket.puts cat.to_json
    elsif verb == "DELETE" && cat_regex =~ path
      #DESTROY /cats/1
      #destroy action
      socket.gets
      match_data2 = cat_regex.match(path)
      cat_id = Integer(match_data2[1])
      $cats.reject! { |cat| cat[:id] == cat_id }
      socket.puts true.to_json
    elsif [verb, path] == ["POST", "/cats"]
      #CREATE /cats
      #create action
      header1 = socket.gets.chomp
      match_data2 = /Content-Length: (\d+)/.match(header1)
      content_length = Integer(match_data2[1])
      socket.gets.chomp #reads a blank line
      body_data = socket.gets.chomp
      cat = JSON.parse(body_data)
      cat[:id] = ($id += 1)
      $cats << cat
      socket.puts cat.to_json
    elsif verb == "PATCH" && path =~ cat_regex
      #PATCH /cats/1
      #update action
      header1 = socket.gets.chomp
      match_data2 = /Content-Length: (\d+)/.match(header1)
      content_length = Integer(match_data2[1])
      socket.gets.chomp #reads blank line

      body_data = socket.gets.chomp
      parsed_body_data = JSON.parse(body_data)

      match_data2 = cat_regex.match(path)
      cat_id = Integer(match_data2[1])

      cat = $cats.find { |cat| cat["id"] == cat_id }
      parsed_body_data.each do |(key, value)|
        cat[key] = value
      end
      socket.puts cat.to_json
    end
    socket.close
  end
  puts "Spawned worker thread"
end

while true
  socket = server.accept
  handle_request(socket)
end
