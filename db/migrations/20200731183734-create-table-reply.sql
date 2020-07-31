-- up
create table reply (
  id integer primary key,
  post_id integer not null references post(id),
  account_id integer not null references account(id),
  body text not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table reply
