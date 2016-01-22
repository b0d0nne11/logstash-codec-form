Gem::Specification.new do |s|
  s.name            = 'logstash-codec-form'
  s.version         = '1.0.0'
  s.licenses        = ['Apache License (2.0)']
  s.summary         = "Read or write events in a application/x-www-form-urlencoded format."
  s.description     = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program."
  s.authors         = ["Brendan ODonnell"]
  s.email           = 'brendan@b0d0nne11.com'
  s.homepage        = "https://github.com/b0d0nne11/logstash-codec-form"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','*.gemspec','*.md','Gemfile','LICENSE','NOTICE.TXT']

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "codec" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.0.0.beta2", "< 3.0.0"

  s.add_development_dependency 'logstash-devutils'
end
