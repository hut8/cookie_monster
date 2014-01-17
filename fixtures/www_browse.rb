
define :www_browse do |b|
  b.default_db_paths fixture_file("cookies.sqlite")
  b.table 'moz_cookies'

  b.column :domain,    'baseDomain'
  b.column :expires,   'expiry'
  b.column :http_only, 'isHttpOnly'
  b.column :name,      'name'
  b.column :path,      'path'
  b.column :secure,    'isSecure'
  b.column :value,     'value'

  b.normalize (:secure)     { |v| v.to_bool }
  b.normalize (:http_only)  { |v| v.to_bool }
  b.normalize (:expires)    { |v| Time.at(v) }
end
