-- up
create table retweet (
  id integer primary key,
  post_id integer not null references post(id),
  account_id integer not null references account(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  unique(post_id, account_id)
)

-- down
drop table retweet
