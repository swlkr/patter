-- up
create table follow (
  id integer primary key,
  follower_id integer not null references account(id),
  followed_id integer not null references account(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  unique(follower_id, followed_id)
)

-- down
drop table follow
