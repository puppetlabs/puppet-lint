require 'spec_helper'

class DummyCheckPlugin < PuppetLint::CheckPlugin
  def check
    # Since we're calling `tokens` from a `check` method, we should get our own Array object.
    # If we add an extra token to it, PuppetLint::Data.tokens should remain unchanged.
    tokens << :extra_token
  end

  def fix
    tokens << :fix_token
  end
end

describe PuppetLint::CheckPlugin do
  before(:each) do
    PuppetLint::Data.tokens = [:token1, :token2, :token3]
  end

  it 'returns a duplicate of the token array when called from check' do
    plugin = DummyCheckPlugin.new

    plugin.check

    # Verify that the global token array remains unchanged.
    expect(PuppetLint::Data.tokens).to eq([:token1, :token2, :token3])
  end

  it 'other methods can modify the tokens array' do
    plugin = DummyCheckPlugin.new

    plugin.fix

    expect(PuppetLint::Data.tokens).to eq([:token1, :token2, :token3, :fix_token])
  end
end
