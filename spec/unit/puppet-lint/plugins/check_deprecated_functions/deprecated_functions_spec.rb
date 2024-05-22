require 'spec_helper'

describe 'deprecated_functions' do
  context 'standard' do
    context 'code containing one deprecated function' do
      let(:code) { "strip()" }

      it 'should create a warning' do
        expect(problems.size).to eq(1)
      end
    end

    context 'code containing two deprecated functions' do
      let(:code) { "strip() rstrip()" }

      it 'should create a warning' do
        expect(problems.size).to eq(2)
      end
    end

    context 'code containing one deprecated underscore function' do
      let(:code) { "is_array()" }

      it 'should create a warning' do
        expect(problems.size).to eq(1)
      end
    end

    context 'code with no deprecated functions' do
      let(:code) { 'port()' }
  
      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end
  end
end
