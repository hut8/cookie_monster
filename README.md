# cookie_monster

Ruby Gem to use browser cookies

## Overview

An instance of CookieMonster represents a browser's storage of
cookies.  CookieMonster has a very rudimentary understanding of where
the cookies are stored, and in what format.

## Dependencies

- sqlite3
- ruby 1.9+

## Example

```ruby

# Make a CookieMonster from your own browser's cookies
monster = CookieMonster.new(browser: :chrome)
# or perhaps it needs a bit of help to find it
monster = CookieMonster.new(database: '/home/jhenson/.strange-dir/Cookies', browser: :chrome)
# or from some YAML you made earlier
monster = CookieMonster.new(yaml: '/home/jhenson/cookies.yaml')

# Get all the cookies that could be read by/should be sent to www.lacecard.com
cookie_header_str = monster.cookie_str('www.lacecard.com')

# Export in the lingua franca of cookies (cookies.txt)
cookies_txt_str = monster.netscape

# Export to YAML
cookies_yaml = monster.yaml
cookies_yaml = monster.yaml('/home/jhenson/cookies.yaml')

```

## Wanted Contributions

- Platform-specific DB locations (Windows / Mac / other Linux distros)
