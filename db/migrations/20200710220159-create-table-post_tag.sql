-- up
create table post_tag (
  id integer primary key,
  post_id integer not null references post(id),
  tag_id integer not null references tag(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table post_tag