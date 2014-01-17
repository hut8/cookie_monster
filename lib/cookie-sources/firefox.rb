
define :firefox do |b|
  # The schema from sqlite3
  # CREATE TABLE moz_cookies (id INTEGER PRIMARY KEY,
  #                           baseDomain TEXT,
  #                           appId INTEGER DEFAULT 0,
  #                           inBrowserElement INTEGER DEFAULT 0,
  #                           name TEXT,
  #                           value TEXT,
  #                           host TEXT,
  #                           path TEXT,
  #                           expiry INTEGER,
  #                           lastAccessed INTEGER,
  #                           creationTime INTEGER,
  #                           isSecure INTEGER,
  #                           isHttpOnly INTEGER,
  #                           CONSTRAINT moz_uniqueid UNIQUE (name, host, path, appId, inBrowserElement));
  # CREATE INDEX moz_basedomain ON moz_cookies (baseDomain, appId, inBrowserElement);
  b.default_db_path "~/.mozilla/**/cookies.sqlite"
  b.table 'moz_cookies'

  b.column :domain,    'baseDomain'
  b.column :expires,   'expiry'
  b.column :http_only, 'isHttpOnly'
  b.column :name,      'name'
  b.column :path,      'path'
  b.column :secure,    'isSecure'
  b.column :value,     'value'

  b.normalize :secure     { |v| v.to_bool }
  b.normalize :http_only  { |v| v.to_bool }
  b.normalize :expires    { |v| Time.at(v) }

end
