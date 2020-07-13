-- up
create table post (
  id integer primary key,
  account_id integer not null references account(id),
  body text not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table post