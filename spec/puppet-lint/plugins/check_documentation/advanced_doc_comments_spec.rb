require 'spec_helper'

describe 'advanced_doc_comments' do
  describe 'Missing summary' do
    before do
      PuppetLint.configuration.check_config = Hash[
        :advanced_doc_comments => 'spec/puppet-lint/plugins/check_documentation/advanced_doc_comments_rules.json'
      ]
    end

    after do
      PuppetLint.configuration.check_config = Hash[]
    end

    let(:code) do
      <<-END
        # foo
        class test {}
      END
    end

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems)
        .to contain_warning('Advanced doc comments rule summary-exists failed on class')
        .on_line(2)
        .in_column(9)
    end
  end

  describe 'Missing parameter documentation' do
    before do
      PuppetLint.configuration.check_config = Hash[
        :advanced_doc_comments => 'spec/puppet-lint/plugins/check_documentation/advanced_doc_comments_rules.json'
      ]
    end

    after do
      PuppetLint.configuration.check_config = Hash[]
    end

    let(:code) do
      <<-END
        # @summary
        #   foo
        class test ($param) {}
      END
    end

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems)
        .to contain_warning('Advanced doc comments rule params-are-documented failed on class')
        .on_line(3)
        .in_column(9)
    end
  end

  describe 'Missing configuration' do
    let(:code) do
      <<-END
        # @summary
        #   foo
        class test ($param) {}
      END
    end

    it 'should skip the check' do
      expect(problems).to have(0).problem
    end
  end
end
