require 'spec_helper'

describe 'puppet_url' do
  let(:msg) { 'invalid puppet:// URL found' }

  context 'puppet:// url with mountpoint' do
    let(:code) { "'puppet:///mountpoint/foo'" }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'with fix disabled' do
    context 'puppet:// url without mountpoint' do
      let(:code) { "'puppet:///foo'" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(1)
      end
    end

    context 'puppet:// url without module name' do
      let(:code) { "'puppet://modules/foo'" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(1)
      end
    end
  end

  context 'with fix enabled' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    context 'puppet:// url without mountpoint' do
      let(:code) { "'puppet:///foo'" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(1)
      end

      it 'should insert mountpoint into the path' do
        expect(manifest).to eq("'puppet:///mountpoint/foo'")
      end
    end

    context 'puppet:// url without module name' do
      let(:code) { "'puppet://modules/foo'" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(1)
      end

      it 'should insert mountpoint into the path' do
        expect(manifest).to eq("'puppet:///modules/foo/bar'")
      end
    end
  end

  context 'double string wrapped puppet:// urls' do
    let(:code) { File.read('spec/fixtures/test/manifests/url_interpolation.pp') }

    it 'should detect several problems' do
      expect(problems).to have(4).problem
    end
  end
end
