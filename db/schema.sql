CREATE TABLE schema_migrations (version text primary key)
CREATE TABLE account (
  id integer primary key,
  name text unique not null,
  display_name text,
  photo_url text,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE post (
  id integer primary key,
  account_id integer not null references account(id),
  body text not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE tag (
  id integer primary key,
  name text unique not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE post_tag (
  id integer primary key,
  post_id integer not null references post(id),
  tag_id integer not null references tag(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE follow (
  id integer primary key,
  follower_id integer not null references account(id),
  followed_id integer not null references account(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  unique(follower_id, followed_id)
)
CREATE TABLE like (
  id integer primary key,
  account_id integer not null references account(id),
  post_id integer not null references post(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  unique(account_id, post_id)
)
CREATE TABLE mention (
  id integer primary key,
  post_id integer not null references post(id),
  account_id integer not null references account(id),
  name text not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE reply (
  id integer primary key,
  post_id integer not null references post(id),
  account_id integer not null references account(id),
  body text not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)