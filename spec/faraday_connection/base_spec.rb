# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "a faraday connection" do |method|
  let(:resp) { {} }

  context "with a 2xx status code" do
    before do
      resp[:status] = 200
    end

    it do
      stub_request(method, uri).and_return(**resp)
      expect(subject).to be_a_success
    end
  end

  context "with a 4xx status code" do
    before do
      resp[:status] = 400
    end

    it do
      stub_request(method, uri).and_return(**resp)
      expect { subject }.to raise_error(Faraday::ClientError)
    end
  end

  context "with a 5xx status code" do
    before do
      resp[:status] = 500
    end

    it do
      stub_request(method, uri).and_return(**resp)
      expect { subject }.to raise_error(Faraday::ServerError)
    end
  end

  context "when timed out" do
    it do
      stub_request(method, uri).to_raise(Timeout::Error)
      expect { subject }.to raise_error(Faraday::TimeoutError)
    end
  end

  context "with ssl error" do
    it do
      stub_request(method, uri).to_raise(OpenSSL::SSL::SSLError)
      expect { subject }.to raise_error(Faraday::SSLError)
    end
  end

  context "with a connection failure" do
    it do
      stub_request(method, uri).to_raise(Net::HTTPHeaderSyntaxError)
      expect { subject }.to raise_error(Faraday::ConnectionFailed)
    end
  end

  context "with an unexpected failure" do
    it do
      stub_request(method, uri).to_raise(EOFError)
      expect { subject }.to raise_error(Faraday::Error)
    end
  end
end

RSpec.describe FaradayConnection::Base do
  let(:client) do
    klass = Class.new(described_class) do
      base -> { URI("https://host.test/") }
    end
    klass.new
  end

  describe "#index" do
    subject do
      client.index("/index")
    end

    it_behaves_like "a faraday connection", :get do
      let(:uri) { client.base + "/index" } # rubocop:disable Style/StringConcatenation
    end
  end

  describe "#show" do
    subject do
      client.show("/show")
    end

    it_behaves_like "a faraday connection", :get do
      let(:uri) { client.base + "/show" } # rubocop:disable Style/StringConcatenation
    end
  end

  describe "#create" do
    subject do
      client.create("/create")
    end

    it_behaves_like "a faraday connection", :post do
      let(:uri) { client.base + "/create" } # rubocop:disable Style/StringConcatenation
    end
  end

  describe "#update" do
    subject do
      client.update("/update")
    end

    it_behaves_like "a faraday connection", :patch do
      let(:uri) { client.base + "/update" } # rubocop:disable Style/StringConcatenation
    end
  end

  describe "#delete" do
    subject do
      client.destroy("/destroy")
    end

    it_behaves_like "a faraday connection", :delete do
      let(:uri) { client.base + "/destroy" } # rubocop:disable Style/StringConcatenation
    end
  end
end
