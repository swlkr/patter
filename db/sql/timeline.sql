/* db/timeline.sql */

select
  post.id,
  post.body,
  post.created_at,
  account.name,
  account.display_name,
  account.photo_url
from
  post
join
  account on account.id = post.account_id
order by
  post.created_at desc
limit
  10
