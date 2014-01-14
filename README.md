# cookie_monster

Ruby Gem to use browser cookies

## Overview

An instance of CookieMonster represents a browser's storage of cookies.  CookieMonster has a very rudimentary understanding of where the cookies are stored, and in what format.

## Why?

#### TL;DR
* Use it as part of a script to, say, use `wget`'s cookies.txt reader from whatever happens to be in Firefox
* Sheer laziness; why write code to log in to a site that your browser is already logged into?
* It makes these authentication things less painful:
	* Phone-based two-factor authentication
	* Captchas
	* RSA Keyfobs
	* OpenID / Other third party authentication

#### Translating cookies
Cookies.txt is used by many programs such as `wget`.  `wget` can crawl an entire site recursively, obeying a complex set of rules, using a single (albeit long) command.  There's often no reason to write your own spider in Ruby.  But what about logging in to the site initially?  It's easier if you use the cookies your browser already has and just duplicate its user agent.  It's easy to use this library in a shell script to dump the cookies to a file:

```bash
ruby -e 'require "cookie_monster";puts CookieMonster.new(browser: :firefox).cookies_txt' | tee cookies.txt # Season to taste
```

#### Testing
When doing integration / functional / acceptance testing, there may be components of the site that aren't easily testable.  Yet, those components may be required for testing of the rest of the site.  For example, your product may use RSA authentication, in which a user has a keyfob that prints out a pseudorandom number on an LCD which must be authenticated against RSA's servers.  Of course, you could create an interface in your automated acceptance testing routine that would prompt the user for the numbers.  I think that's a bit of a waste of time; why not just open the page in the browser?  If you're prompting a human, you mind as well just use the regular interface.  During authentication, a cookie will be set and reused for the rest of the testing, and likely after the test is completed.  Something similar could happen with two-factor authentication via Google if you're using their OpenID provider.

#### Scraping
Many sites allow the user agent to continue to be logged in indefinitely, or at least for a really long time.  If you have a cron job scheduled to scrape your favorite website, as we all do, then the same authentication hassles as above apply.

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
cookies_txt_str = monster.cookies_txt

# Export to YAML
cookies_yaml = monster.yaml
cookies_yaml = monster.yaml('/home/jhenson/cookies.yaml')

```

## Wanted Contributions

- Platform-specific DB locations (Windows / Mac / other Linux distros)
- More browsers (IE?)
