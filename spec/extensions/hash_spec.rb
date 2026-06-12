# frozen_string_literal: true

require 'extensions/deep_find'

describe Hash do
  describe '#deep_find' do
    context 'with basic lookup' do
      subject(:hash) do
        {
          key1: 'value1',
          key2: {
            nested_key: 'nested_value',
            key3: {
              deep_key: 'deep_value'
            }
          }
        }
      end

      it 'finds a value at the top level' do
        expect(hash.deep_find(:key1)).to eq('value1')
      end

      it 'finds a value at a nested level' do
        expect(hash.deep_find(:nested_key)).to eq('nested_value')
      end

      it 'finds a value at a deep level' do
        expect(hash.deep_find(:deep_key)).to eq('deep_value')
      end

      it 'returns nil for missing keys' do
        expect(hash.deep_find(:nonexistent)).to be_nil
      end
    end

    context 'with array containing hashes' do
      subject(:hash) do
        {
          items: [
            { id: 1, name: 'foo' },
            { id: 2, name: 'bar' }
          ]
        }
      end

      it 'finds values inside arrays of hashes' do
        expect(hash.deep_find(:name)).to contain_exactly('foo', 'bar')
      end
    end

    context 'with nil values' do
      it 'returns nil' do
        expect({ a: nil }.deep_find(:a)).to be_nil
      end
    end

    context 'with array' do
      subject(:hash) { { key: [{ nested: 'value' }] } }

      it 'returns match for nil target' do
        expect(hash.deep_find(:nested)).to eq('value')
      end
    end

    context 'with integer key' do
      subject(:hash) { { 1 => 'one', 2 => 'two' } }

      it 'finds integer keys' do
        expect(hash.deep_find(1)).to eq('one')
      end
    end

    context 'with empty hash' do
      it 'returns nil' do
        expect({}.deep_find(:anything)).to be_nil
      end
    end

    context 'with empty array' do
      it 'returns nil' do
        expect({ items: [] }.deep_find(:anything)).to be_nil
      end
    end
  end
end
