require 'spec_helper'

describe 'quoted_literal' do
  let(:msg) { 'quoted literal' }

  context 'with fix disabled' do
    context 'exec with logoutput' do
      context 'bare word true' do
        let(:code) { "exec { 'foo': logoutput => true }" }

        it 'does not detect any problems' do
          expect(problems.size).to eq(0)
        end
      end

      context 'variable value' do
        let(:code) { "exec { 'foo': logoutput => $something }" }

        it 'does not detect any problems' do
          expect(problems.size).to eq(0)
        end
      end

      context "string 'true'" do
        let(:code) { "exec { 'foo': logoutput => 'true' }" }

        it 'only detects a single problem' do
          expect(problems.size).to eq(1)
        end

        it 'creates a warning' do
          expect(problems).to contain_warning(msg).on_line(1).in_column(28)
        end
      end

      context "string 'bogus'" do
        let(:msg) { 'invalid value' }
        let(:code) { "exec { 'foo': logoutput => 'bogus' }" }

        it 'only detects a single problem' do
          expect(problems.size).to eq(1)
        end

        it 'creates an error' do
          expect(problems).to contain_error(msg).on_line(1).in_column(28)
        end
      end

      context 'bare word bogus' do
        let(:msg) { 'invalid value' }
        let(:code) { "exec { 'foo': logoutput => bogus }" }

        it 'only detects a single problem' do
          expect(problems.size).to eq(1)
        end

        it 'creates an error' do
          expect(problems).to contain_error(msg).on_line(1).in_column(28)
        end
      end
    end

    context 'file with ensure' do
      context "string 'present'" do
        let(:code) { "file { 'foo': ensure => 'present' }" }

        it 'only detects a single problem' do
          expect(problems.size).to eq(1)
        end

        it 'creates a warning' do
          expect(problems).to contain_warning(msg).on_line(1).in_column(25)
        end
      end

      context "string 'linked_file'" do
        let(:code) { "file { 'foo': ensure => 'linked_file' }" }

        it 'does not detect any problems' do
          expect(problems.size).to eq(0)
        end
      end

      context 'variable' do
        let(:code) { 'file { \'foo\': ensure => $something }' }

        it 'does not detect any problems' do
          expect(problems.size).to eq(0)
        end
      end

      context 'string "linked_$foo_file"' do
        let(:code) { 'file { \'foo\': ensure => "linked_$foo_file" }' }

        it 'does not detect any problems' do
          expect(problems.size).to eq(0)
        end
      end

      context 'bare word linked_file' do
        let(:msg) { 'non-literal value must be quoted' }
        let(:code) { "file { 'foo': ensure => linked_file }" }

        it 'only detects a single problem' do
          expect(problems.size).to eq(1)
        end

        it 'creates a warning' do
          expect(problems).to contain_warning(msg).on_line(1).in_column(25)
        end
      end
    end

    context 'multi body file bad ensure values' do
      let(:code) do
        <<-END
          file {
            '/tmp/foo1':
              ensure => 'absent';
            '/tmp/foo2':
              ensure => 'present';
            '/tmp/foo3':
              ensure => 'link';
          }
        END
      end

      it 'detects 3 problems' do
        expect(problems.size).to eq(3)
      end

      it 'creates three warnings' do
        expect(problems).to contain_warning(sprintf(msg)).on_line(3).in_column(25)
        expect(problems).to contain_warning(sprintf(msg)).on_line(5).in_column(25)
        expect(problems).to contain_warning(sprintf(msg)).on_line(7).in_column(25)
      end
    end
  end

  context 'with fix enabled' do
    before(:each) do
      PuppetLint.configuration.fix = true
    end

    after(:each) do
      PuppetLint.configuration.fix = false
    end

    context "exec with logoutput string 'true'" do
      let(:code) { "exec { 'foo': logoutput => 'true' }" }

      it 'only detects a single problem' do
        expect(problems.size).to eq(1)
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(28)
      end

      it 'unquotes the logoutput parameter' do
        expect(manifest).to eq("exec { 'foo': logoutput => true }")
      end
    end

    context "exec with logoutput string 'bogus'" do
      let(:code) { "exec { 'foo': logoutput => 'bogus' }" }

      it 'only detects a single problem' do
        expect(problems.size).to eq(1)
      end

      it 'does not change the manigest' do
        expect(manifest).to eq("exec { 'foo': logoutput => 'bogus' }")
      end
    end

    context "string 'present'" do
      let(:code) { "file { 'foo': ensure => 'present' }" }

      it 'only detects a single problem' do
        expect(problems.size).to eq(1)
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(25)
      end

      it 'unquotes the logoutput parameter' do
        expect(manifest).to eq("file { 'foo': ensure => present }")
      end
    end

    context 'bare word linked_file' do
      let(:msg) { 'non-literal value must be quoted' }
      let(:code) { "file { 'foo': ensure => linked_file }" }

      it 'only detects a single problem' do
        expect(problems.size).to eq(1)
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(25)
      end

      it 'unquotes the logoutput parameter' do
        expect(manifest).to eq("file { 'foo': ensure => 'linked_file' }")
      end
    end

    context 'multi body file bad ensure values' do
      let(:code) do
        <<-END
          file {
            '/tmp/foo1':
              ensure => 'absent';
            '/tmp/foo2':
              ensure => 'present';
            '/tmp/foo3':
              ensure => 'link';
          }
        END
      end

      let(:fixed) do
        <<-END
          file {
            '/tmp/foo1':
              ensure => absent;
            '/tmp/foo2':
              ensure => present;
            '/tmp/foo3':
              ensure => link;
          }
        END
      end

      it 'detects 3 problems' do
        expect(problems.size).to eq(3)
      end

      it 'fixes 3 problems' do
        expect(problems).to contain_fixed(msg).on_line(3).in_column(25)
        expect(problems).to contain_fixed(msg).on_line(5).in_column(25)
        expect(problems).to contain_fixed(msg).on_line(7).in_column(25)
      end

      it 'unquotes the ensure values' do
        expect(manifest).to eq(fixed)
      end
    end
  end
end
