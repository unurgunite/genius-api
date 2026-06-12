# frozen_string_literal: true

require 'genius/api'

describe Genius::Annotations do
  describe '.annotations' do
    context 'with GET verb' do
      let(:token) { 'a' * 64 }
      let(:annotation_id) { 10_225_840 }
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }
      let(:response_body) { { 'meta' => { 'status' => 200 } }.to_json }

      before { allow(HTTParty).to receive(:get).and_return(mock_response) }

      it 'sends a GET request' do
        described_class.annotations(id: annotation_id, action: nil, token: token, http_verb: 'get')
        expect(HTTParty).to have_received(:get).with(
          "https://api.genius.com/annotations/#{annotation_id}?access_token=#{token}"
        )
      end

      it 'returns parsed JSON' do
        result = described_class.annotations(id: annotation_id, action: nil, token: token, http_verb: 'get')
        expect(result).to be_a(Hash)
      end
    end

    context 'with POST verb' do
      let(:token) { 'a' * 64 }
      let(:annotation_id) { 10_225_840 }
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }
      let(:response_body) { { 'meta' => { 'status' => 200 } }.to_json }

      before do
        allow(Genius::Errors).to receive(:validate_token)
        allow(HTTParty).to receive(:post).and_return(mock_response)
      end

      it 'sends a POST request' do
        described_class.annotations(
          id: annotation_id, action: nil, token: token, http_verb: 'post',
          options: { markdown: 'test', raw_annotatable_url: 'https://example.com' }
        )
        expect(HTTParty).to have_received(:post)
      end
    end

    context 'with PUT verb and no action' do
      let(:token) { 'a' * 64 }
      let(:annotation_id) { 10_225_840 }
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }
      let(:response_body) { { 'meta' => { 'status' => 200 } }.to_json }

      before do
        allow(Genius::Errors).to receive(:validate_token)
        allow(HTTParty).to receive(:put).and_return(mock_response)
      end

      it 'sends a PUT request' do
        described_class.annotations(id: annotation_id, action: nil, token: token, http_verb: 'put')
        expect(HTTParty).to have_received(:put)
      end
    end

    context 'with PUT verb and upvote action' do
      let(:token) { 'a' * 64 }
      let(:annotation_id) { 10_225_840 }
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }
      let(:response_body) { { 'meta' => { 'status' => 200 } }.to_json }

      before do
        allow(Genius::Errors).to receive(:validate_token)
        allow(HTTParty).to receive(:put).and_return(mock_response)
      end

      it 'sends a PUT request to the upvote endpoint' do
        described_class.annotations(id: annotation_id, action: 'upvote', token: token, http_verb: 'put')
        expect(HTTParty).to have_received(:put).with(
          "https://api.genius.com/annotations/#{annotation_id}/upvote?access_token=#{token}"
        )
      end
    end

    context 'with PUT verb and downvote action' do
      let(:token) { 'a' * 64 }
      let(:annotation_id) { 10_225_840 }
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }
      let(:response_body) { { 'meta' => { 'status' => 200 } }.to_json }

      before do
        allow(Genius::Errors).to receive(:validate_token)
        allow(HTTParty).to receive(:put).and_return(mock_response)
      end

      it 'sends a PUT request to the downvote endpoint' do
        described_class.annotations(id: annotation_id, action: 'downvote', token: token, http_verb: 'put')
        expect(HTTParty).to have_received(:put).with(
          "https://api.genius.com/annotations/#{annotation_id}/downvote?access_token=#{token}"
        )
      end
    end

    context 'with PUT verb and unvote action' do
      let(:token) { 'a' * 64 }
      let(:annotation_id) { 10_225_840 }
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }
      let(:response_body) { { 'meta' => { 'status' => 200 } }.to_json }

      before do
        allow(Genius::Errors).to receive(:validate_token)
        allow(HTTParty).to receive(:put).and_return(mock_response)
      end

      it 'sends a PUT request to the unvote endpoint' do
        described_class.annotations(id: annotation_id, action: 'unvote', token: token, http_verb: 'put')
        expect(HTTParty).to have_received(:put).with(
          "https://api.genius.com/annotations/#{annotation_id}/unvote?access_token=#{token}"
        )
      end
    end

    context 'with PUT verb and invalid action' do
      let(:token) { 'a' * 64 }
      let(:annotation_id) { 10_225_840 }

      before { allow(Genius::Errors).to receive(:validate_token) }

      it 'raises ArgumentError' do
        expect do
          described_class.annotations(id: annotation_id, action: 'invalid', token: token, http_verb: 'put')
        end.to raise_error(ArgumentError)
      end
    end

    context 'with DELETE verb' do
      let(:token) { 'a' * 64 }
      let(:annotation_id) { 10_225_840 }
      let(:mock_response) { instance_double(HTTParty::Response, body: response_body) }
      let(:response_body) { { 'meta' => { 'status' => 200 } }.to_json }

      before do
        allow(Genius::Errors).to receive(:validate_token)
        allow(HTTParty).to receive(:delete).and_return(mock_response)
      end

      it 'sends a DELETE request' do
        described_class.annotations(id: annotation_id, action: nil, token: token, http_verb: 'delete')
        expect(HTTParty).to have_received(:delete).with(
          "https://api.genius.com/annotations/#{annotation_id}?access_token=#{token}"
        )
      end
    end

    context 'with non-PUT verb and action' do
      let(:token) { 'a' * 64 }
      let(:annotation_id) { 10_225_840 }

      before { allow(Genius::Errors).to receive(:validate_token) }

      it 'raises ArgumentError' do
        expect do
          described_class.annotations(id: annotation_id, action: 'upvote', token: token, http_verb: 'get')
        end.to raise_error(ArgumentError, /only PUT accepts/)
      end
    end
  end

  describe '.post_payload' do
    let(:post_options) do
      {
        markdown: 'hello **world!**',
        raw_annotatable_url: 'https://example.com',
        fragment: 'test',
        before_html: '<p>',
        after_html: '</p>',
        canonical_url: 'https://example.com/canonical',
        og_url: 'https://example.com/og',
        title: 'Test Page'
      }
    end

    it 'builds a JSON payload from options' do
      payload = described_class.send(:post_payload, options: post_options)
      parsed = JSON.parse(payload)
      expect(parsed.dig('annotation', 'body', 'markdown')).to eq('hello **world!**')
    end

    it 'includes referent url in the payload' do
      payload = described_class.send(:post_payload, options: post_options)
      parsed = JSON.parse(payload)
      expect(parsed.dig('referent', 'raw_annotatable_url')).to eq('https://example.com')
    end

    it 'includes web page title in the payload' do
      payload = described_class.send(:post_payload, options: post_options)
      parsed = JSON.parse(payload)
      expect(parsed.dig('web_page', 'title')).to eq('Test Page')
    end
  end
end
