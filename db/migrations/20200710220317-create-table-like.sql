-- up
create table like (
  id integer primary key,
  account_id integer not null references account(id),
  post_id integer not null references post(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  unique(account_id, post_id)
)

-- down
drop table like
