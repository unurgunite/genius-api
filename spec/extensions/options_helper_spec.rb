# frozen_string_literal: true

require 'extensions/extensions'

describe Object do
  describe '#options_helper' do
    subject(:helper) { described_class.new }

    let(:allowed_keys) { %i[sort per_page page] }

    context 'when options contain allowed keys' do
      it 'builds a query string from allowed options' do
        result = helper.options_helper({ sort: 'title', per_page: 10, page: 1 }, allowed_keys)
        expect(result).to eq('&sort=title&per_page=10&page=1')
      end
    end

    context 'when options contain disallowed keys' do
      it 'ignores disallowed keys' do
        result = helper.options_helper({ sort: 'title', foo: 'bar' }, allowed_keys)
        expect(result).to eq('&sort=title')
      end
    end

    context 'when options is empty' do
      it 'returns an empty string' do
        result = helper.options_helper({}, allowed_keys)
        expect(result).to eq('')
      end
    end
  end
end
