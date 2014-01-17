require 'spec_helper'
require 'cookie_monster'

describe CookieMonster do
  subject { CookieMonster.new(browser: :www_browse,
                              descriptor_globs: [fixture_file('*.rb')]) }

  it "can load descriptors" do
    subject
  end

  context "without a browser" do
    it 'cannot be constructed' do
      expect { CookieMonster.new() }.to raise_error(CookieMonsterError)
    end
  end
end
