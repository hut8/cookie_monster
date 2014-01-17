require 'spec_helper'
require 'cookie_monster'

describe CookieMonster do
  subject { CookieMonster.new(browser: :www_browse,
                              descriptor_globs: [fixture_file('*.rb')]) }

  it "can load descriptors" do
    subject
  end

  it "tracks loaded descriptors" do
    expect(subject.loaded_browsers).to eq([:www_browse])
  end

  context "PEBKAC parameters" do
    it "cannot be constructed with no browser" do
      expect { CookieMonster.new() }.to raise_error(CookieMonsterError)
    end

    it "fails to find non-existent descriptors" do
      expect do
        CookieMonster.new(browser: :www_browse,
                          descriptor_globs: [fixture_file('does-not-exist')])
      end.to raise_error(CookieMonsterError)
    end
  end

  describe "Serialization methods" do
    it "serializes http cookies correctly" do
      subject.http
      pending
    end
  end

end
