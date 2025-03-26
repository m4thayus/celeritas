# frozen_string_literal: true

require "rails_helper"

shared_examples "a json request and response" do |method|
  let(:req) do
    {
      headers: {
        "Content-Type" => "application/json"
      }
    }
  end

  let(:resp) do
    {
      headers: {
        "Content-Type" => "application/json"
      }
    }
  end

  before do
    req[:body] = body if body.present?
  end

  context "when successful" do
    before do
      resp[:status] = 200
      resp[:body] = JSON.generate({
        key: {
          nested_key: "test value"
        }
      })
    end

    it "has a parsed and symbolized body" do
      stub_request(method, uri).with(**req).and_return(**resp)
      expect(subject.body.dig(:key, :nested_key)).to eq("test value")
    end
  end

  context "with invalid json" do
    before do
      resp[:status] = 200
      resp[:body] = "{ not valid json"
    end

    it do
      stub_request(method, uri).with(**req).and_return(**resp)
      expect { subject }.to raise_error(Faraday::ParsingError)
    end
  end
end

RSpec.describe FaradayConnection::JSON do
  let(:client) do
    klass = Class.new(described_class) do
      base -> { URI("https://host.test/") }
    end
    klass.new
  end

  describe "#create" do
    subject do
      client.create("/create", **payload)
    end

    let(:payload) do
      { data: "request" }
    end

    it_behaves_like "a json request and response", :post do
      let(:uri) { client.base + "/create" } # rubocop:disable Style/StringConcatenation
      let(:body) { JSON.generate(payload) }
    end
  end

  describe "#update" do
    subject do
      client.update("/update", **payload)
    end

    let(:payload) do
      { data: "request" }
    end

    it_behaves_like "a json request and response", :patch do
      let(:uri) { client.base + "/update" } # rubocop:disable Style/StringConcatenation
      let(:body) { JSON.generate(payload) }
    end
  end
end
