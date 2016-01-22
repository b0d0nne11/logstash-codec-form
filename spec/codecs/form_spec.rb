# encoding: utf-8

require 'logstash/devutils/rspec/spec_helper'
require 'logstash/codecs/form'
require 'logstash/event'
require 'uri'

describe LogStash::Codecs::Form do

  subject do
    next LogStash::Codecs::Form.new
  end

  context '#encode' do
    let (:event) {LogStash::Event.new({'message' => 'hello world', 'host' => 'test'})}

    it 'should return an application/x-www-form-urlencoded formatted line' do
      expect(subject).to receive(:on_event).once.and_call_original
      subject.on_event do |e, d|
        insist {d} == "message=hello+world&host=test&%40version=1&%40timestamp=#{URI.encode_www_form_component(event.timestamp)}"
      end
      subject.encode(event)
    end
  end

  context '#decode' do
    it 'should return an event from an application/x-www-form-urlencoded string' do
      decoded = false
      subject.decode("message=hello+world&host=test") do |e|
        decoded = true
        insist { e.is_a?(LogStash::Event) }
        insist { e['message'] } == ['hello world']
      end
      insist { decoded } == true
    end
  end

end
