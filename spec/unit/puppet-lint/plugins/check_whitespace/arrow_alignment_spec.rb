# frozen_string_literal: true

require 'spec_helper'

describe 'arrow_alignment' do
  let(:msg) { 'indentation of => is not properly aligned (expected in column %d, but found it in column %d)' }

  context 'with fix disabled' do
    context 'selectors inside a resource' do
      let(:code) do
        <<-CODE
          file { 'foo':
            ensure  => $ensure,
            require => $ensure ? {
              present => Class['tomcat::install'],
              absent  => undef;
            },
            foo     => bar,
          }
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'selectors in the middle of a resource' do
      let(:code) do
        <<-CODE
          file { 'foo':
            ensure => $ensure ? {
              present => directory,
              absent  => undef,
            },
            owner  => 'tomcat6',
          }
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'selector inside a resource' do
      let(:code) do
        <<-CODE
          ensure => $ensure ? {
            present => directory,
            absent  => undef,
          },
          owner  => 'foo4',
          group  => 'foo4',
          mode   => '0755',
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'nested hashes with correct indentation' do
      let(:code) do
        <<-CODE
          class { 'lvs::base':
            virtualeservers => {
              '192.168.2.13' => {
                vport        => '11025',
                service      => 'smtp',
                scheduler    => 'wlc',
                protocol     => 'tcp',
                checktype    => 'external',
                checkcommand => '/path/to/checkscript',
                real_servers => {
                  'server01' => {
                    real_server => '192.168.2.14',
                    real_port   => '25',
                    forwarding  => 'masq',
                  },
                  'server02' => {
                    real_server => '192.168.2.15',
                    real_port   => '25',
                    forwarding  => 'masq',
                  }
                }
              }
            }
          }
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'single resource with a misaligned =>' do
      let(:code) do
        <<-CODE
          file { '/tmp/foo':
            foo => 1,
            bar => 2,
            gronk => 3,
            baz  => 4,
            meh => 5,
          }
        CODE
      end

      it 'detects four problems' do
        expect(problems.size).to eq(4)
      end

      it 'creates four warnings' do
        expect(problems).to contain_warning(msg % [19, 17]).on_line(2).in_column(17)
        expect(problems).to contain_warning(msg % [19, 17]).on_line(3).in_column(17)
        expect(problems).to contain_warning(msg % [19, 18]).on_line(5).in_column(18)
        expect(problems).to contain_warning(msg % [19, 17]).on_line(6).in_column(17)
      end
    end

    context 'single resource with a misaligned => and semicolon at the end' do
      let(:code) do
        <<-CODE
          file { '/tmp/bar':
            foo => 1,
            bar => 2,
            gronk => 3,
            baz  => 4,
            meh => 5;
          }
        CODE
      end

      it 'detects four problems' do
        expect(problems.size).to eq(4)
      end

      it 'creates four warnings' do
        expect(problems).to contain_warning(msg % [19, 17]).on_line(2).in_column(17)
        expect(problems).to contain_warning(msg % [19, 17]).on_line(3).in_column(17)
        expect(problems).to contain_warning(msg % [19, 18]).on_line(5).in_column(18)
        expect(problems).to contain_warning(msg % [19, 17]).on_line(6).in_column(17)
      end
    end

    context 'complex resource with a misaligned =>' do
      let(:code) do
        <<-CODE
          file { '/tmp/foo':
            foo => 1,
            bar  => $baz ? {
              gronk => 2,
              meh => 3,
            },
            meep => 4,
            bah => 5,
          }
        CODE
      end

      it 'detects three problems' do
        expect(problems.size).to eq(3)
      end

      it 'creates three warnings' do
        expect(problems).to contain_warning(msg % [18, 17]).on_line(2).in_column(17)
        expect(problems).to contain_warning(msg % [21, 19]).on_line(5).in_column(19)
        expect(problems).to contain_warning(msg % [18, 17]).on_line(8).in_column(17)
      end
    end

    context 'multi-resource with a misaligned =>' do
      let(:code) do
        <<-CODE
          file {
            '/tmp/foo': ;
            '/tmp/bar':
              foo => 'bar';
            '/tmp/baz':
              gronk => 'bah',
              meh => 'no'
          }
        CODE
      end

      it 'only detects a single problem' do
        expect(problems.size).to eq(1)
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg % [21, 19]).on_line(7).in_column(19)
      end
    end

    context 'multi-resource with a misaligned => and semicolons' do
      let(:code) do
        <<-CODE
          file {
            '/tmp/foo':
              ensure => 'directory',
              owner => 'root',
              mode => '0755';
            '/tmp/bar':
              ensure => 'directory';
            '/tmp/baz':
              ensure => 'directory',
              owner => 'root',
              mode => '0755';
          }
        CODE
      end

      it 'only detects a single problem' do
        expect(problems.size).to eq(4)
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg % [22, 21]).on_line(4).in_column(21)
        expect(problems).to contain_warning(msg % [22, 20]).on_line(5).in_column(20)
        expect(problems).to contain_warning(msg % [22, 21]).on_line(10).in_column(21)
        expect(problems).to contain_warning(msg % [22, 20]).on_line(11).in_column(20)
      end
    end

    context 'multiple single line resources' do
      let(:code) do
        <<-CODE
          file { 'foo': ensure => file }
          package { 'bar': ensure => present }
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'resource with unaligned => in commented line' do
      let(:code) do
        <<-CODE
          file { 'foo':
            ensure => directory,
            # purge => true,
          }
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'single line resource spread out on multiple lines' do
      let(:code) do
        <<-CODE
          file {
            'foo': ensure => present,
          }
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'multiline resource with a single line of params' do
      let(:code) do
        <<-CODE
          mymodule::do_thing { 'some thing':
            whatever => { foo => 'bar', one => 'two' },
          }
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'resource with aligned => too far out' do
      let(:code) do
        <<-CODE
          file { '/tmp/foo':
            ensure  => file,
            mode    => '0444',
          }
        CODE
      end

      it 'detects 2 problems' do
        expect(problems.size).to eq(2)
      end

      it 'creates 2 warnings' do
        expect(problems).to contain_warning(msg % [20, 21]).on_line(2).in_column(21)
        expect(problems).to contain_warning(msg % [20, 21]).on_line(3).in_column(21)
      end
    end

    context 'resource with multiple params where one is an empty hash' do
      let(:code) do
        <<-CODE
          foo { 'foo':
            a => true,
            b => {
            }
          }
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'multiline resource with multiple params on a line' do
      let(:code) do
        <<-CODE
          user { 'test':
            a => 'foo', bb => 'bar',
            ccc => 'baz',
          }
        CODE
      end

      it 'detects 2 problems' do
        expect(problems.size).to eq(2)
      end

      it 'creates 2 warnings' do
        expect(problems).to contain_warning(msg % [17, 15]).on_line(2).in_column(15)
        expect(problems).to contain_warning(msg % [17, 28]).on_line(2).in_column(28)
      end
    end

    context 'resource param containing a single-element same-line hash' do
      let(:code) do
        <<-CODE
          foo { 'foo':
            a => true,
            b => { 'a' => 'b' }
          }
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'multiline hash with opening brace on same line as first pair' do
      let(:code) do
        <<-CODE
          foo { 'foo':
            bar => [
              { aa => bb,
                c  => d},
            ],
          }
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'unaligned multiline hash with opening brace on the same line as the first pair' do
      let(:code) do
        <<-CODE
          foo { 'foo':
            bar => [
              { aa => bb,
                c => d},
            ],
          }
        CODE
      end

      it 'detects one problem' do
        expect(problems.size).to eq(1)
      end

      it 'creates one warning' do
        expect(problems).to contain_warning(msg % [20, 19]).on_line(4).in_column(19)
      end
    end

    context 'hash with strings containing variables as keys properly aligned' do
      let(:code) do
        <<-CODE
          foo { foo:
            param => {
              a         => 1
              "${aoeu}" => 2,
              b         => 3,
            },
          }
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'hash with strings containing variables as keys incorrectly aligned' do
      let(:code) do
        <<-CODE
          foo { foo:
            param => {
              a => 1
              "${aoeu}" => 2,
              b     => 3,
            },
          }
        CODE
      end

      it 'detects 2 problems' do
        expect(problems.size).to eq(2)
      end

      it 'creates 2 warnings' do
        expect(problems).to contain_warning(msg % [25, 17]).on_line(3).in_column(17)
        expect(problems).to contain_warning(msg % [25, 21]).on_line(5).in_column(21)
      end
    end

    context 'complex data structure with different indentation levels at the same depth' do
      let(:code) do
        <<-CODE
          class { 'some_class':
            config_hash => {
              'a_hash'   => {
                'foo' => 'bar',
              },
              'an_array' => [
                {
                  foo => 'bar',
                  bar => 'baz',
                },
              ],
            },
          }
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'where the top level of the block has no parameters' do
      let(:code) do
        <<-CODE
          case $facts['os']['family'] {
            'RedHat': {
              $datadir = $::operatingsystem ? {
                'Amazon' => pick($datadir, 'value'),
                default  => pick($datadir, 'value'),
              }
            }
          }
        CODE
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end

    context 'with misaligned hash' do
      let(:code) do
        <<~CODE
          $x = {
            present => directory,
            absent   => undef,
          },
        CODE
      end

      it 'detects one problem' do
        expect(problems.size).to eq(1)
      end

      it 'creates 1 warning' do
        expect(problems).to contain_warning(msg % [11, 12]).on_line(3).in_column(12)
      end
    end

    context 'with misaligned selector' do
      let(:code) do
        <<~CODE
          $x = $y ? {
            'a' => 1,
            default => 3,
          }
        CODE
      end

      it 'detects one problem' do
        expect(problems.size).to eq(1)
      end

      it 'creates 1 warning' do
        expect(problems).to contain_warning(msg % [11, 7]).on_line(2).in_column(7)
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

    context 'single resource with a misaligned =>' do
      let(:code) do
        <<-CODE
          file { '/tmp/foo':
            foo => 1,
            bar => 2,
            gronk => 3,
            baz  => 4,
            meh => 5,
          }
        CODE
      end

      let(:fixed) do
        <<-CODE
          file { '/tmp/foo':
            foo   => 1,
            bar   => 2,
            gronk => 3,
            baz   => 4,
            meh   => 5,
          }
        CODE
      end

      it 'detects four problems' do
        expect(problems.size).to eq(4)
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg % [19, 17]).on_line(2).in_column(17)
        expect(problems).to contain_fixed(msg % [19, 17]).on_line(3).in_column(17)
        expect(problems).to contain_fixed(msg % [19, 18]).on_line(5).in_column(18)
        expect(problems).to contain_fixed(msg % [19, 17]).on_line(6).in_column(17)
      end

      it 'aligns the arrows' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'complex resource with a misaligned =>' do
      let(:code) do
        <<-CODE
          file { '/tmp/foo':
            foo => 1,
            bar  => $baz ? {
              gronk => 2,
              meh => 3,
            },
            meep => 4,
            bah => 5,
          }
        CODE
      end

      let(:fixed) do
        <<-CODE
          file { '/tmp/foo':
            foo  => 1,
            bar  => $baz ? {
              gronk => 2,
              meh   => 3,
            },
            meep => 4,
            bah  => 5,
          }
        CODE
      end

      it 'detects three problems' do
        expect(problems.size).to eq(3)
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg % [18, 17]).on_line(2).in_column(17)
        expect(problems).to contain_fixed(msg % [21, 19]).on_line(5).in_column(19)
        expect(problems).to contain_fixed(msg % [18, 17]).on_line(8).in_column(17)
      end

      it 'aligns the arrows' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'multi-resource with a misaligned =>' do
      let(:code) do
        <<-CODE
          file {
            '/tmp/foo': ;
            '/tmp/bar':
              foo => 'bar';
            '/tmp/baz':
              gronk => 'bah',
              meh => 'no'
          }
        CODE
      end

      let(:fixed) do
        <<-CODE
          file {
            '/tmp/foo': ;
            '/tmp/bar':
              foo => 'bar';
            '/tmp/baz':
              gronk => 'bah',
              meh   => 'no'
          }
        CODE
      end

      it 'only detects a single problem' do
        expect(problems.size).to eq(1)
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg % [21, 19]).on_line(7).in_column(19)
      end

      it 'aligns the arrows' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'resource with aligned => too far out' do
      let(:code) do
        <<-CODE
          file { '/tmp/foo':
            ensure  => file,
            mode    => '0444',
          }
        CODE
      end

      let(:fixed) do
        <<-CODE
          file { '/tmp/foo':
            ensure => file,
            mode   => '0444',
          }
        CODE
      end

      it 'detects 2 problems' do
        expect(problems.size).to eq(2)
      end

      it 'creates 2 warnings' do
        expect(problems).to contain_fixed(msg % [20, 21]).on_line(2).in_column(21)
        expect(problems).to contain_fixed(msg % [20, 21]).on_line(3).in_column(21)
      end

      it 'realigns the arrows with the minimum whitespace' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'resource with unaligned => and no whitespace between param and =>' do
      let(:code) do
        <<-CODE
          user { 'test':
            param1 => 'foo',
            param2=> 'bar',
          }
        CODE
      end

      let(:fixed) do
        <<-CODE
          user { 'test':
            param1 => 'foo',
            param2 => 'bar',
          }
        CODE
      end

      it 'detects 1 problem' do
        expect(problems.size).to eq(1)
      end

      it 'fixes the problem' do
        expect(problems).to contain_fixed(msg % [20, 19]).on_line(3).in_column(19)
      end

      it 'adds whitespace between the param and the arrow' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'multiline resource with multiple params on a line' do
      let(:code) do
        <<-CODE
          user { 'test':
            a => 'foo', bb => 'bar',
            ccc => 'baz',
          }
        CODE
      end

      let(:fixed) do
        <<-CODE
          user { 'test':
            a   => 'foo',
            bb  => 'bar',
            ccc => 'baz',
          }
        CODE
      end

      it 'detects 2 problems' do
        expect(problems.size).to eq(2)
      end

      it 'fixes 2 problems' do
        expect(problems).to contain_fixed(msg % [17, 15]).on_line(2).in_column(15)
        expect(problems).to contain_fixed(msg % [17, 28]).on_line(2).in_column(28)
      end

      it 'moves the extra param onto its own line and realign' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'multiline resource with multiple params on a line, extra one longer' do
      let(:code) do
        <<-CODE
          user { 'test':
            a => 'foo', bbccc => 'bar',
            ccc => 'baz',
          }
        CODE
      end

      let(:fixed) do
        <<-CODE
          user { 'test':
            a     => 'foo',
            bbccc => 'bar',
            ccc   => 'baz',
          }
        CODE
      end

      it 'detects 2 problems' do
        expect(problems.size).to eq(3)
      end

      it 'fixes 2 problems' do
        expect(problems).to contain_fixed(msg % [19, 15]).on_line(2).in_column(15)
        expect(problems).to contain_fixed(msg % [19, 31]).on_line(2).in_column(31)
        expect(problems).to contain_fixed(msg % [19, 17]).on_line(3).in_column(17)
      end

      it 'moves the extra param onto its own line and realign' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'hash with strings containing variables as keys incorrectly aligned' do
      let(:code) do
        <<-CODE
          foo { foo:
            param => {
              a => 1
              "${aoeu}" => 2,
              b     => 3,
            },
          }
        CODE
      end

      let(:fixed) do
        <<-CODE
          foo { foo:
            param => {
              a         => 1
              "${aoeu}" => 2,
              b         => 3,
            },
          }
        CODE
      end

      it 'detects 2 problems' do
        expect(problems.size).to eq(2)
      end

      it 'fixes 2 problems' do
        expect(problems).to contain_fixed(msg % [25, 17]).on_line(3).in_column(17)
        expect(problems).to contain_fixed(msg % [25, 21]).on_line(5).in_column(21)
      end

      it 'aligns the hash rockets' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'complex data structure with different indentation levels at the same depth' do
      let(:code) do
        <<-CODE
          class { 'some_class':
            config_hash => {
              'a_hash'   => {
                'foo' => 'bar',
              },
              'an_array' => [
                {
                  foo => 'bar',
                  bar  => 'baz',
                },
              ],
            },
          }
        CODE
      end

      let(:fixed) do
        <<-CODE
          class { 'some_class':
            config_hash => {
              'a_hash'   => {
                'foo' => 'bar',
              },
              'an_array' => [
                {
                  foo => 'bar',
                  bar => 'baz',
                },
              ],
            },
          }
        CODE
      end

      it 'detects 1 problem' do
        expect(problems.size).to eq(1)
      end

      it 'fixes 1 problem' do
        expect(problems).to contain_fixed(msg % [23, 24]).on_line(9).in_column(24)
      end

      it 'aligns the hash rockets' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'complex data structure with multiple token keys' do
      let(:code) do
        <<-CODE.gsub(%r{^ {10}}, '')
          class example (
            $external_ip_base,
          ) {

            bar { 'xxxxxxxxx':
              inputs => {
                'ny' => {
                  "${external_ip_base}.16:443 ${a} ${b} ${c}" => 'foo',
                  'veryveryverylongstring8:443'=> 'foo',
                  'simple'=> 'foo',
                  '3'=> :foo,
                  :baz=> :qux,
                  3=> 3,
                },
              },
            }
          }
        CODE
      end

      let(:fixed) do
        <<-CODE.gsub(%r{^ {10}}, '')
          class example (
            $external_ip_base,
          ) {

            bar { 'xxxxxxxxx':
              inputs => {
                'ny' => {
                  "${external_ip_base}.16:443 ${a} ${b} ${c}" => 'foo',
                  'veryveryverylongstring8:443'               => 'foo',
                  'simple'                                    => 'foo',
                  '3'                                         => :foo,
                  :baz                                        => :qux,
                  3                                           => 3,
                },
              },
            }
          }
        CODE
      end

      it 'detects 5 problems' do
        expect(problems.size).to eq(5)
      end

      it 'fixes 5 problems' do
        expect(problems).to contain_fixed(msg % [53, 38]).on_line(9).in_column(38)
        expect(problems).to contain_fixed(msg % [53, 17]).on_line(10).in_column(17)
        expect(problems).to contain_fixed(msg % [53, 12]).on_line(11).in_column(12)
        expect(problems).to contain_fixed(msg % [53, 13]).on_line(12).in_column(13)
        expect(problems).to contain_fixed(msg % [53, 10]).on_line(13).in_column(10)
      end

      it 'realigns the arrows' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'realignment of resource with an inline single line hash' do
      let(:code) do
        <<-CODE.gsub(%r{^ {10}}, '')
          class { 'puppetdb':
            database                => 'embedded',
            #database                => 'postgres',
            #postgres_version        => '9.3',
            java_args               => { '-Xmx' => '512m', '-Xms' => '256m' },
            listen_address          => $::ipaddress_eth0,
            listen_port             => 4998,
            ssl_listen_address      => $::ipaddress_eth0,
            ssl_listen_port         => 4999,
            open_listen_port        => false,
            open_ssl_listen_port    => false;
          }
        CODE
      end

      let(:fixed) do
        <<-CODE.gsub(%r{^ {10}}, '')
          class { 'puppetdb':
            database             => 'embedded',
            #database                => 'postgres',
            #postgres_version        => '9.3',
            java_args            => { '-Xmx' => '512m', '-Xms' => '256m' },
            listen_address       => $::ipaddress_eth0,
            listen_port          => 4998,
            ssl_listen_address   => $::ipaddress_eth0,
            ssl_listen_port      => 4999,
            open_listen_port     => false,
            open_ssl_listen_port => false;
          }
        CODE
      end

      it 'detects 8 problems' do
        expect(problems.size).to eq(8)
      end

      it 'fixes 8 problems' do
        expect(problems).to contain_fixed(msg % [24, 27]).on_line(2).in_column(27)
        expect(problems).to contain_fixed(msg % [24, 27]).on_line(5).in_column(27)
        expect(problems).to contain_fixed(msg % [24, 27]).on_line(6).in_column(27)
        expect(problems).to contain_fixed(msg % [24, 27]).on_line(7).in_column(27)
        expect(problems).to contain_fixed(msg % [24, 27]).on_line(8).in_column(27)
        expect(problems).to contain_fixed(msg % [24, 27]).on_line(9).in_column(27)
        expect(problems).to contain_fixed(msg % [24, 27]).on_line(10).in_column(27)
        expect(problems).to contain_fixed(msg % [24, 27]).on_line(11).in_column(27)
      end

      it 'realigns the arrows' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'negative argument' do
      let(:code) do
        <<-CODE
          res { 'a':
            x => { 'a' => '',
              'ab' => '',
            }
          }
        CODE
      end

      # TODO: This is not the desired behaviour, but adjusting the check to
      # properly format the hashes will need to wait until a major version
      # bump.
      let(:fixed) do
        <<-CODE
          res { 'a':
            x => { 'a' => '',
              'ab'     => '',
            }
          }
        CODE
      end

      it 'detects a problem' do
        expect(problems.size).to eq(1)
      end

      it 'fixes the problems' do
        expect(problems).to contain_fixed(msg % [24, 20]).on_line(3).in_column(20)
      end

      it 'realigns the arrows' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'with misaligned hash' do
      let(:code) do
        <<~CODE
          $x = {
            present => directory,
            absent   => undef,
          },
        CODE
      end

      let(:fixed) do
        <<~CODE
          $x = {
            present => directory,
            absent  => undef,
          },
        CODE
      end

      it 'detects one problem' do
        expect(problems.size).to eq(1)
      end

      it 'fixes the problems' do
        expect(problems).to contain_fixed(msg % [11, 12]).on_line(3).in_column(12)
      end

      it 'realigns the arrows' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'with misaligned selector' do
      let(:code) do
        <<~CODE
          $x = $y ? {
            'a' => 1,
            default => 3,
          }
        CODE
      end

      let(:fixed) do
        <<~CODE
          $x = $y ? {
            'a'     => 1,
            default => 3,
          }
        CODE
      end

      it 'detects one problem' do
        expect(problems.size).to eq(1)
      end

      it 'fixes the problems' do
        expect(problems).to contain_fixed(msg % [11, 7]).on_line(2).in_column(7)
      end

      it 'realigns the arrows' do
        expect(manifest).to eq(fixed)
      end
    end
  end
end
