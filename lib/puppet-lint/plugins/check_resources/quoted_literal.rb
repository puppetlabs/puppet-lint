# Public: Check tokens of parameters, and verify that when the value is from a
# specific list of alternatives for the parameter, it is not quoted.
class OpenSet < Set
end

BOOLYESNO = Set['true', 'false', 'yes', 'no']
BOOL = Set['true', 'false']
SIMPLE_TYPES = Set[:STRING, :SSTRING, :NAME]
ALL_STRING_TYPES = Set[:STRING, :SSTRING, :REGEX, :DQPRE]
LITERAL_PARAMETERS_BY_RESOURCE = {
  'exec' => {
    'logoutput' => Set['true', 'false', 'on_failure'],
    'provider' => Set['posix', 'shell', 'windows']
  },
  'file' => {
    'ensure' => OpenSet['present', 'absent', 'file', 'directory', 'link'],
    'backup' => OpenSet['false'],
    'checksum' => Set[
      'sha256',
      'sha256lite',
      'md5',
      'md5lite',
      'sha1',
      'sha1lite',
      'sha512',
      'sha384',
      'sha224',
      'mtime',
      'ctime',
    ],
    'force' => BOOLYESNO,
    'links' => Set['follow', 'manage'],
    'provider' => Set['posix', 'windows'],
    'purge' => BOOLYESNO,
    'recurse' => Set['false', 'remote', 'true'],
    'replace' => BOOLYESNO,
    'selinux_ignore_defaults' => BOOL,
    'show_diff' => BOOLYESNO,
    'source_permissions' => Set['use', 'use_when_creating', 'ignore'],
    'sourceselect' => Set['first', 'all']
  },
  'filebucket' => {
    'path' => OpenSet['false']
  },
  'group' => {
    'ensure' => Set['present', 'absent'],
    'allowdupe' => BOOLYESNO,
    'attribute_membership' => Set['inclusive', 'minimum'],
    'auth_membership' => BOOLYESNO,
    'forcelocal' => BOOLYESNO,
    'provider' => Set['aix', 'directoryservice', 'groupadd', 'ldap', 'pw', 'windows_adsi'],
    'system' => BOOLYESNO
  },
  'notify' => {
    'withpath' => BOOL
  },
  'package' => {
    'provider' => Set[
      'aix',
      'appdmg',
      'apple',
      'apt',
      'aptitude',
      'aptrpm',
      'blastwave',
      'dnf',
      'dnfmodule',
      'dpkg',
      'fink',
      'freebsd',
      'gem',
      'hpux',
      'macports',
      'nim',
      'openbsd',
      'opkg',
      'pacman',
      'pip2',
      'pip3',
      'pip',
      'pkg',
      'pkgdmg',
      'pkgin',
      'pkgng',
      'pkgutil',
      'portage',
      'ports',
      'portupgrade',
      'puppet_gem',
      'puppetserver_gem',
      'rpm',
      'rug',
      'sun',
      'sunfreeware',
      'tdnf',
      'up2date',
      'urpmi',
      'windows',
      'yum',
      'zypper',
    ],
    'ensure' => OpenSet['present', 'installed', 'absent', 'purged', 'disabled', 'latest'],
    'allow_virtual' => BOOLYESNO,
    'allowcdrom' => BOOL,
    'configfiles' => Set['keep', 'replace'],
    'enable_only' => BOOLYESNO,
    'install_only' => BOOLYESNO,
    'mark' => Set['hold', 'none'],
    'reinstall_on_refresh' => BOOL
  },
  'resources' => {
    'purge' => BOOLYESNO,
    'unless_system_user' => OpenSet['true', 'false']
  },
  'schedule' => {
    'period' => Set['hourly', 'daily', 'weekly', 'monthly', 'never'],
    'periodmatch' => Set['number', 'distance']
  },
  'service' => {
    'ensure' => Set['stopped', 'false', 'running', 'true'],
    'enable' => Set['true', 'false', 'manual', 'mask', 'delayed'],
    'hasrestart' => BOOL,
    'hasstatus' => BOOL,
    'provider' => Set[
      'base',
      'bsd',
      'daemontools',
      'debian',
      'freebsd',
      'gentoo',
      'init',
      'launchd',
      'openbsd',
      'openrc',
      'openwrt',
      'rcng',
      'redhat',
      'runit',
      'service',
      'smf',
      'src',
      'systemd',
      'upstart',
      'windows',
    ]
  },
  'tidy' => {
    'backup' => OpenSet['false'],
    'recurse' => OpenSet['true', 'false', 'inf'],
    'rmdirs' => BOOLYESNO,
    'type' => Set['atime', 'mtime', 'ctime']
  },
  'user' => {
    'ensure' => Set['present', 'absent', 'role'],
    'allowdupe' => BOOLYESNO,
    'attribute_membership' => Set['inclusive', 'minimum'],
    'auth_membership' => Set['inclusive', 'minimum'],
    'expiry' => OpenSet['absent'],
    'forcelocal' => BOOLYESNO,
    'key_membership' => Set['inclusive', 'minimum'],
    'managehome' => BOOLYESNO,
    'membership' => Set['inclusive', 'minimum'],
    'profile_membership' => Set['inclusive', 'minimum'],
    'provider' => Set[
      'aix',
      'directoryservice',
      'hpuxuseradd',
      'ldap',
      'openbsd',
      'pw',
      'user_role_add',
      'useradd',
      'windows_adsi',
    ],
    'purge_ssh_keys' => OpenSet['true', 'false'],
    'role_membership' => Set['inclusive', 'minimum'],
    'system' => BOOLYESNO
  }
}.freeze

PuppetLint.new_check(:quoted_literal) do
  def check
    resource_indexes.each do |resource|
      next unless LITERAL_PARAMETERS_BY_RESOURCE.key?(resource[:type].value)

      literal_parameters = LITERAL_PARAMETERS_BY_RESOURCE[resource[:type].value]
      resource[:param_tokens].each do |param_token|
        next unless literal_parameters.key?(param_token.value)

        value_token = param_token.next_code_token.next_code_token
        parameter_values = literal_parameters[param_token.value]
        if parameter_values.include?(value_token.value)
          if ALL_STRING_TYPES.include?(value_token.type)
            notify(
              :warning,
              message: 'quoted literal',
              line: value_token.line,
              column: value_token.column,
              token: value_token,
            )
          end
        elsif parameter_values.is_a?(OpenSet)
          if value_token.type == :NAME
            notify(
              :warning,
              message: 'non-literal value must be quoted',
              line: value_token.line,
              column: value_token.column,
              token: value_token,
            )
          end
        elsif SIMPLE_TYPES.include?(value_token.type)
          notify(
            :error,
            message: 'invalid value',
            line: value_token.line,
            column: value_token.column,
            token: value_token,
          )
        end
      end
    end
  end

  def fix(problem)
    if problem[:message] == 'quoted literal'
      problem[:token].type = :NAME if (problem[:token].type == :STRING) || (problem[:token].type == :SSTRING)
    elsif problem[:message] == 'non-literal value must be quoted'
      problem[:token].type = :SSTRING
    end
  end
end
