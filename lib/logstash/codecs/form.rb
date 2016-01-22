# encoding: utf-8
require 'logstash/codecs/base'
require 'logstash/util/charset'
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

  # The character encoding used in this codec. Defaults to "UTF-8".
  config :charset, validate: ::Encoding.name_list, default: "UTF-8"

  private
  def parse(payload)
    event = {}
    keypairs = URI.decode_www_form payload
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
    URI.encode_www_form event.to_hash
  end

  public
  def register
    @converter = LogStash::Util::Charset.new @charset
    @converter.logger = @logger
  end

  public
  def decode(payload)
    payload = @converter.convert payload
    begin
      yield LogStash::Event.new(parse(payload))
    rescue StandardError => e
      @logger.warn(
        "An unexpected error occurred",
        message: e.message,
        backtrace: e.backtrace,
        input: payload
      )
      yield LogStash::Event.new(
        "message" => payload,
        "tags" => ["_formparsefailure"]
      )
    end
  end

  public
  def encode(event)
    @on_event.call(event, dump(event))
  end

end
