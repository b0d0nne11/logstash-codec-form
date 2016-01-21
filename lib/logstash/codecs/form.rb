# encoding: utf-8
require 'logstash/codecs/base'
require 'logstash/codecs/line'
require 'uri'

class LogStash::Codecs::Form < LogStash::Codecs::Base

  # This codec will encode or decode an event using the
  # application/x-www-form-urlencoded format. It was originally intended to be
  # used with the http input plugin to read values submitted via HTTP form
  # submissions.
  #
  # https://www.w3.org/TR/2013/CR-html5-20130806/forms.html#url-encoded-form-data
  #
  # Usage:
  # [source,ruby]
  #     input{
  #       http {
  #         additional_codecs => {"application/x-www-form-urlencoded"=>"form"}
  #       }
  #     }
  # or
  # [source,ruby]
  #     output {
  #       http {
  #         codec => "form"
  #         content_type => "application/x-www-form-urlencoded"
  #       }
  #     }
  config_name 'form'

  private
  def parse(line)
    event = {}
    keypairs = URI.decode_www_form(line['message'])
    keypairs.each do |keypair|
      if event.has_key? keypair[0]
        event[keypair[0]] << keypair[1]
      else
        event[keypair[0]] = [keypair[1]]
      end
    end
    return event
  end

  private
  def dump(event)
    URI.encode_www_form(event.to_hash) + NL
  end

  public
  def register
    @lines = LogStash::Codecs::Line.new
    @lines.charset = 'UTF-8'
  end

  public
  def decode(payload)
    @lines.decode(payload) do |line|
      yield LogStash::Event.new(parse(line))
    end
  end

  public
  def encode(event)
    @on_event.call(event, dump(event))
  end

end
