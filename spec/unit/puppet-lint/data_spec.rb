require 'spec_helper'

describe PuppetLint::Data do
  subject(:data) { described_class }

  let(:lexer) { PuppetLint::Lexer.new }

  describe '.resource_indexes' do
    before(:each) do
      data.tokens = lexer.tokenise(manifest)
    end

    context 'basic function call' do
      let(:tokens) do
        [
          double('Token', type: :FUNCTION_NAME, prev_token: nil, prev_code_token: nil, next_code_token: nil),
          double('Token', type: :LPAREN, prev_token: nil, prev_code_token: nil, next_code_token: nil),
          double('Token', type: :RPAREN, prev_token: nil, prev_code_token: nil, next_code_token: nil)
        ]
      end
  
      it 'returns the correct function indexes' do
        result = data.function_indexes
        expect(result).to eq([
          {
            start: 0,
            end: 2,
            tokens: tokens[0..2]
          }
        ])
      end
    end

    context 'when a namespaced class name contains a single colon' do
      let(:manifest) { 'class foo:bar { }' }

      it 'raises a SyntaxError' do
        expect {
          data.resource_indexes
        }.to raise_error(PuppetLint::SyntaxError) { |error|
          expect(error.token).to eq(data.tokens[3])
        }
      end
    end

    context 'when typo in namespace separator makes parser look for resource' do
      let(:manifest) { '$testparam = $::module:;testparam' }

      it 'raises a SyntaxError' do
        expect {
          data.resource_indexes
        }.to raise_error(PuppetLint::SyntaxError) { |error|
          expect(error.token).to eq(data.tokens[5])
        }
      end
    end

    context 'when given a defaults declaration' do
      let(:manifest) { "Service { 'foo': }" }

      it 'returns an empty array' do
        expect(data.resource_indexes).to eq([])
      end
    end

    context 'when given a set of resource declarations' do
      let(:manifest) { <<-MANIFEST }
        service {
          'foo':
            ensure => running,
        }

        service {
          'bar':
            ensure => running;
          'foobar':
            ensure => stopped;
        }

        service { ['first', 'second']:
          ensure => running,
        }

        service { 'third':
          ensure => running,
        }
      MANIFEST

      it 'returns an array of resource indexes' do
        expect(data.resource_indexes.length).to eq(5)
      end
    end
  end

  describe '.insert' do
    let(:manifest) { '$x = $a' }
    let(:new_token) { PuppetLint::Lexer::Token.new(:PLUS, '+', 0, 0) }
    let(:original_tokens) { lexer.tokenise(manifest) }
    let(:tokens) { original_tokens.dup }

    before(:each) do
      data.tokens = tokens
      data.insert(2, new_token)
    end

    it 'adds token at the given index' do
      expect(data.tokens.map(&:to_manifest).join).to eq('$x += $a')
    end

    it 'sets the prev_token' do
      expect(new_token.prev_token).to eq(original_tokens[1])
    end

    it 'sets the prev_code_token' do
      expect(new_token.prev_code_token).to eq(original_tokens[0])
    end

    it 'sets the next_token' do
      expect(new_token.next_token).to eq(original_tokens[2])
    end

    it 'sets the next_code_token' do
      expect(new_token.next_code_token).to eq(original_tokens[2])
    end

    it 'updates the existing next_token' do
      expect(tokens[1].next_token).to eq(new_token)
    end

    it 'updates the existing next_code_token' do
      expect(tokens[0].next_code_token).to eq(new_token)
    end

    it 'updates the existing prev_token' do
      expect(tokens[3].prev_token).to eq(new_token)
    end

    it 'updates the existing prev_code_token' do
      expect(tokens[3].prev_code_token).to eq(new_token)
    end
  end

  describe '.delete' do
    let(:manifest) { '$x + = $a' }
    let(:token) { tokens[2] }
    let(:original_tokens) { lexer.tokenise(manifest) }
    let(:tokens) { original_tokens.dup }

    before(:each) do
      data.tokens = tokens
      data.delete(token)
    end

    it 'removes the token' do
      expect(data.tokens.map(&:to_manifest).join).to eq('$x  = $a')
    end

    it 'updates the existing next_token' do
      expect(tokens[1].next_token).to eq(original_tokens[3])
    end

    it 'updates the existing next_code_token' do
      expect(tokens[0].next_code_token).to eq(original_tokens[4])
    end

    it 'updates the existing prev_token' do
      expect(tokens[2].prev_token).to eq(original_tokens[1])
    end

    it 'updates the existing prev_code_token' do
      expect(tokens[3].prev_code_token).to eq(original_tokens[0])
    end
  end
end
