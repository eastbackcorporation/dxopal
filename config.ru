# config.ru for local development
require 'tempfile'
require 'opal'

opal_server = Opal::Server.new{|s|
  # Let javascript_include_tag to serve compiled version of opal/dxopal.rb
  s.append_path 'opal'
  s.main = 'dxopal.rb'
  # Serve static files
  s.public_root = __dir__
  # Just serve static ./index.html
  s.use_index = false
}

Dir["examples/*"].reject{|x| x =~ /_vendor/}.each do |proj|
  # Compile dxopal.js dynamically to avoid manual recompiling
  map "/#{proj}/index.html" do
    index = Opal::Server::Index.new(nil, opal_server)
    s = File.read("#{proj}/index.html")
            .gsub(%r{<script (.*)dxopal.js"></script>}){
              index.javascript_include_tag(opal_server.main) +
              "<script type='text/javascript' src='../../vendor/matter.js'></script>"
            }
    run lambda{|env| [200, {}, [s]] }
  end
end

run lambda{|env|
  if env["PATH_INFO"] == '/'
    [301, {"Location" => '/index.html'}, [""]]
  else
    opal_server.call(env)
  end
}
