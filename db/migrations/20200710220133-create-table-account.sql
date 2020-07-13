-- up
create table account (
  id integer primary key,
  name text unique not null,
  display_name text,
  photo_url text,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table account
