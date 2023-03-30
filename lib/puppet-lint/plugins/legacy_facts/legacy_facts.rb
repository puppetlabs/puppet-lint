# Public: A puppet-lint custom check to detect legacy facts.
#
# This check will optionally convert from legacy facts like $::operatingsystem
# or legacy hashed facts like $facts['operatingsystem'] to the
# new structured facts like $facts['os']['name'].
#
# This plugin was adopted in to puppet-lint from https://github.com/mmckinst/puppet-lint-legacy_facts-check
# Thanks to @mmckinst, @seanmil, @rodjek, @baurmatt, @bart2 and @joshcooper for the original work.
PuppetLint.new_check(:legacy_facts) do
  LEGACY_FACTS_VAR_TYPES = Set[:VARIABLE, :UNENC_VARIABLE]

  # These facts that can't be converted to new facts.
  UNCONVERTIBLE_FACTS = ['memoryfree_mb', 'memorysize_mb', 'swapfree_mb',
                         'swapsize_mb', 'blockdevices', 'interfaces', 'zones',
                         'sshfp_dsa', 'sshfp_ecdsa', 'sshfp_ed25519',
                         'sshfp_rsa'].freeze

  # These facts will depend on how a system is set up and can't just be
  # enumerated like the EASY_FACTS below.
  #
  # For example a server might have two block devices named 'sda' and 'sdb' so
  # there would be a $blockdevice_sda_vendor and $blockdevice_sdb_vendor fact
  # for each device. Or it could have 26 block devices going all the way up to
  # 'sdz'. There is no way to know what the possibilities are so we have to use
  # a regex to match them.
  REGEX_FACTS = [%r{^blockdevice_(?<devicename>.*)_(?<attribute>model|size|vendor)$},
                 %r{^(?<attribute>ipaddress|ipaddress6|macaddress|mtu|netmask|netmask6|network|network6)_(?<interface>.*)$},
                 %r{^processor(?<id>[0-9]+)$},
                 %r{^sp_(?<name>.*)$},
                 %r{^ssh(?<algorithm>dsa|ecdsa|ed25519|rsa)key$},
                 %r{^ldom_(?<name>.*)$},
                 %r{^zone_(?<name>.*)_(?<attribute>brand|iptype|name|uuid|id|path|status)$}].freeze

  # These facts have a one to one correlation between a legacy fact and a new
  # structured fact.
  EASY_FACTS = {
    'architecture'                => "os']['architecture",
    'augeasversion'               => "augeas']['version",
    'bios_release_date'           => "dmi']['bios']['release_date",
    'bios_vendor'                 => "dmi']['bios']['vendor",
    'bios_version'                => "dmi']['bios']['version",
    'boardassettag'               => "dmi']['board']['asset_tag",
    'boardmanufacturer'           => "dmi']['board']['manufacturer",
    'boardproductname'            => "dmi']['board']['product",
    'boardserialnumber'           => "dmi']['board']['serial_number",
    'chassisassettag'             => "dmi']['chassis']['asset_tag",
    'chassistype'                 => "dmi']['chassis']['type",
    'domain'                      => "networking']['domain",
    'fqdn'                        => "networking']['fqdn",
    'gid'                         => "identity']['group",
    'hardwareisa'                 => "processors']['isa",
    'hardwaremodel'               => "os']['hardware",
    'hostname'                    => "networking']['hostname",
    'id'                          => "identity']['user",
    'ipaddress'                   => "networking']['ip",
    'ipaddress6'                  => "networking']['ip6",
    'lsbdistcodename'             => "os']['distro']['codename",
    'lsbdistdescription'          => "os']['distro']['description",
    'lsbdistid'                   => "os']['distro']['id",
    'lsbdistrelease'              => "os']['distro']['release']['full",
    'lsbmajdistrelease'           => "os']['distro']['release']['major",
    'lsbminordistrelease'         => "os']['distro']['release']['minor",
    'lsbrelease'                  => "os']['distro']['release']['specification",
    'macaddress'                  => "networking']['mac",
    'macosx_buildversion'         => "os']['macosx']['build",
    'macosx_productname'          => "os']['macosx']['product",
    'macosx_productversion'       => "os']['macosx']['version']['full",
    'macosx_productversion_major' => "os']['macosx']['version']['major",
    'macosx_productversion_minor' => "os']['macosx']['version']['minor",
    'manufacturer'                => "dmi']['manufacturer",
    'memoryfree'                  => "memory']['system']['available",
    'memorysize'                  => "memory']['system']['total",
    'netmask'                     => "networking']['netmask",
    'netmask6'                    => "networking']['netmask6",
    'network'                     => "networking']['network",
    'network6'                    => "networking']['network6",
    'operatingsystem'             => "os']['name",
    'operatingsystemmajrelease'   => "os']['release']['major",
    'operatingsystemrelease'      => "os']['release']['full",
    'osfamily'                    => "os']['family",
    'physicalprocessorcount'      => "processors']['physicalcount",
    'processorcount'              => "processors']['count",
    'productname'                 => "dmi']['product']['name",
    'rubyplatform'                => "ruby']['platform",
    'rubysitedir'                 => "ruby']['sitedir",
    'rubyversion'                 => "ruby']['version",
    'selinux'                     => "os']['selinux']['enabled",
    'selinux_config_mode'         => "os']['selinux']['config_mode",
    'selinux_config_policy'       => "os']['selinux']['config_policy",
    'selinux_current_mode'        => "os']['selinux']['current_mode",
    'selinux_enforced'            => "os']['selinux']['enforced",
    'selinux_policyversion'       => "os']['selinux']['policy_version",
    'serialnumber'                => "dmi']['product']['serial_number",
    'swapencrypted'               => "memory']['swap']['encrypted",
    'swapfree'                    => "memory']['swap']['available",
    'swapsize'                    => "memory']['swap']['total",
    'system32'                    => "os']['windows']['system32",
    'uptime'                      => "system_uptime']['uptime",
    'uptime_days'                 => "system_uptime']['days",
    'uptime_hours'                => "system_uptime']['hours",
    'uptime_seconds'              => "system_uptime']['seconds",
    'uuid'                        => "dmi']['product']['uuid",
    'xendomains'                  => "xen']['domains",
    'zonename'                    => "solaris_zones']['current",
  }.freeze

  # A list of valid hash key token types
  HASH_KEY_TYPES = Set[
    :STRING,  # Double quoted string
    :SSTRING, # Single quoted string
    :NAME,    # Unquoted single word
  ].freeze

  def check
    tokens.select { |x| LEGACY_FACTS_VAR_TYPES.include?(x.type) }.each do |token|
      fact_name = ''

      # This matches legacy facts defined in the fact hash that use the top scope
      # fact assignment.
      if token.value.start_with?('::facts[')
        fact_name = token.value.match(%r{::facts\['(.*)'\]})[1]

      # This matches legacy facts defined in the fact hash.
      elsif token.value.start_with?("facts['")
        fact_name = token.value.match(%r{facts\['(.*)'\]})[1]

      # This matches using legacy facts in a the new structured fact. For
      # example this would match 'uuid' in $facts['uuid'] so it can be converted
      # to facts['dmi']['product']['uuid']"
      elsif token.value == 'facts'
        fact_name = hash_key_for(token)

      # Now we can get rid of top scopes. We don't need to
      # preserve it because it won't work with the new structured facts.
      elsif token.value.start_with?('::')
        fact_name = token.value.sub(%r{^::}, '')
      end

      next unless EASY_FACTS.include?(fact_name) || UNCONVERTIBLE_FACTS.include?(fact_name) || fact_name.match(Regexp.union(REGEX_FACTS))
      notify :warning, {
        message: "legacy fact '#{fact_name}'",
        line: token.line,
        column: token.column,
        token: token,
        fact_name: fact_name,
      }
    end
  end

  # If the variable is using the $facts hash represented internally by multiple
  # tokens, this helper simplifies accessing the hash key.
  def hash_key_for(token)
    lbrack_token = token.next_code_token
    return '' unless lbrack_token && lbrack_token.type == :LBRACK

    key_token = lbrack_token.next_code_token
    return '' unless key_token && HASH_KEY_TYPES.include?(key_token.type)

    key_token.value
  end

  def fix(problem)
    fact_name = problem[:fact_name]

    # Check if the variable is using the $facts hash represented internally by
    # multiple tokens and remove the tokens for the old legacy key if so.
    if problem[:token].value == 'facts'
      loop do
        t = problem[:token].next_token
        remove_token(t)
        break if t.type == :RBRACK
      end
    end

    if EASY_FACTS.include?(fact_name)
      problem[:token].value = EASY_FACTS[fact_name]
    elsif fact_name.match(Regexp.union(REGEX_FACTS))
      if (m = fact_name.match(%r{^blockdevice_(?<devicename>.*)_(?<attribute>model|size|vendor)$}))
        problem[:token].value = "disks']['" << m['devicename'] << "']['" << m['attribute']
      elsif (m = fact_name.match(%r{^(?<attribute>ipaddress|ipaddress6|macaddress|mtu|netmask|netmask6|network|network6)_(?<interface>.*)$}))
        problem[:token].value = "networking']['interfaces']['" << m['interface'] << "']['" << m['attribute'].sub('address', '')
      elsif (m = fact_name.match(%r{^processor(?<id>[0-9]+)$}))
        problem[:token].value = "processors']['models']['" << m['id']
      elsif (m = fact_name.match(%r{^sp_(?<name>.*)$}))
        problem[:token].value = "system_profiler']['" << m['name']
      elsif (m = fact_name.match(%r{^ssh(?<algorithm>dsa|ecdsa|ed25519|rsa)key$}))
        problem[:token].value = "ssh']['" << m['algorithm'] << "']['key"
      elsif (m = fact_name.match(%r{^ldom_(?<name>.*)$}))
        problem[:token].value = "ldom']['" << m['name']
      elsif (m = fact_name.match(%r{^zone_(?<name>.*)_(?<attribute>brand|iptype|name|uuid|id|path|status)$}))
        problem[:token].value = "solaris_zones']['zones']['" << m['name'] << "']['" << m['attribute']
      end
    end
  end
end
