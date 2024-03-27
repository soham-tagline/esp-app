# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EspAdapter::Mailchimp do
  let(:mock_response) { File.read('./spec/fixtures/mailchimp/unauthorised.json') }

  describe '#lists' do
    context 'when valid API key is used' do
      let(:mock_response) { File.read('./spec/fixtures/mailchimp/lists.json') }
      let(:api_response) { EspAdapter::Mailchimp.new('TEST-us21').lists }

      it 'returns a hash with lists successfully' do
        stub_request(:get, 'https://us21.api.mailchimp.com/3.0/lists')
          .to_return(status: 200, body: mock_response, headers: {})

        expect(api_response).to be_kind_of(Hash)
        expect(api_response).to have_key('lists')
      end
    end

    context 'when invalid API key is used' do
      it 'raises an error with message' do
        stub_request(:get, 'https://us21.api.mailchimp.com/3.0/lists')
          .to_return(status: 401, body: mock_response, headers: {})

        expect { EspAdapter::Mailchimp.new('TEST-us21').lists }.to raise_error(EspAdapter::UnauthorizedError)
      end
    end
  end

  describe '#list_metrics' do
    context 'when valid API key is used' do
      let(:api_response) { EspAdapter::Mailchimp.new('TEST-us21').list_metrics('a354d4c865') }
      let(:mock_response) { File.read('./spec/fixtures/mailchimp/list_metrics.json') }

      it 'returns a hash with the specified list ID' do
        stub_request(:get, 'https://us21.api.mailchimp.com/3.0/lists/a354d4c865')
          .to_return(status: 200, body: mock_response, headers: {})

        expect(api_response).to be_kind_of(Hash)
        expect(api_response['id']).to eq('a354d4c865')
      end
    end

    context 'when invalid API key is used' do
      it 'raises an UnauthorizedError' do
        stub_request(:get, 'https://us21.api.mailchimp.com/3.0/lists/abc123')
          .to_return(status: 401, body: mock_response, headers: {})

        expect do
          EspAdapter::Mailchimp.new('TEST-us21').list_metrics('abc123')
        end.to raise_error(EspAdapter::UnauthorizedError)
      end
    end

    context 'when the requested list metrics resource is not found' do
      let(:mock_response) { File.read('./spec/fixtures/mailchimp/resource_not_found.json') }

      it 'raises a ResourceNotFound error' do
        stub_request(:get, 'https://us21.api.mailchimp.com/3.0/lists/test123')
          .to_return(status: 404, body: mock_response, headers: {})

        expect do
          EspAdapter::Mailchimp.new('TEST-us21').list_metrics('test123')
        end.to raise_error(EspAdapter::ResourceNotFound)
      end
    end
  end

  describe 'private methods' do
    let(:api_key) { 'your_mailchimp_api_key' }
    let(:mailchimp) { described_class.new('TEST-us21') }
    let(:config) { { timeout: 60, write_timeout: 60 } }

    describe '#set_config' do
      it 'sets server, timeout, and open_timeout from config' do
        mailchimp.send(:set_config, config:)

        expect(mailchimp.instance_variable_get(:@timeout)).to eq 60
        expect(mailchimp.instance_variable_get(:@open_timeout)).to eq 60
      end
    end

    describe '#get_server_from_api_key' do
      context 'when API key is valid' do
        let(:server) { mailchimp.send(:get_server_from_api_key, 'TEST-us21') }

        it 'extracts server from the API key' do
          expect(server).to eq 'us21'
        end
      end

      context 'when API key is invalid' do
        let(:server) { mailchimp.send(:get_server_from_api_key, 'invalid_key') }

        it 'returns an empty string for an invalid API key format' do
          expect(server).to eq 'invalid-server'
        end
      end
    end

    describe '#encoded_basic_token' do
      let(:token) { mailchimp.send(:encoded_basic_token, 'TEST-us21') }

      it 'generates base64 encoded token for basic auth' do
        expect(token).to eq 'dXNlcjpURVNULXVzMjE='
      end
    end

    describe '#url' do
      let(:url) { mailchimp.send(:url) }

      it 'replaces the host with API key server' do
        expect(url).to eq 'https://us21.api.mailchimp.com/3.0'
      end
    end
  end
end
