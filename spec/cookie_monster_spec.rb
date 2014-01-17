require 'spec_helper'
require 'cookie_monster'

describe CookieMonster do
  subject { CookieMonster.new({ browser: :www_browse,
                                descriptors: [fixture_file('')]
                              }) }

  it "can load descriptors" do
    subject
  end

  context "without a browser" do
    it 'cannot be constructed without a browser' do
      expect { CookieMonster.new() }.to raise_error(CookieMonsterError)
    end
  end
end
