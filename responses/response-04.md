# Response 4

Track User Engagement with Art Posts

## Prompt:

```
For a specific user (Cathy Graham), show the number of posts they've voted on, favorited, and commented on within the last year.
Provide a summary of their engagement across these activities.
```

## Generated Query:

```sql
SELECT
    "user"."name",
    COUNT(DISTINCT "pv"."post_id") AS "posts_voted_on",
    COUNT(DISTINCT "pf"."post_id") AS "posts_favorited",
    COUNT(DISTINCT "pc"."post_id") AS "posts_commented_on"
FROM "user"
LEFT JOIN "post_vote" "pv" ON "user"."id" = "pv"."user_id" AND "pv"."created_at" > CURRENT_DATE - INTERVAL '1 YEAR'
LEFT JOIN "post_favorite" "pf" ON "user"."id" = "pf"."user_id" AND "pf"."created_at" > CURRENT_DATE - INTERVAL '1 YEAR'
LEFT JOIN "post_comment" "pc" ON "user"."id" = "pc"."user_id" AND "pc"."created_at" > CURRENT_DATE - INTERVAL '1 YEAR'
WHERE "user"."name" = 'Cathy Graham'
GROUP BY "user"."name"
```

## Friendly Response:

```
Cathy Graham has been quite active on the platform over the last year. Here's a summary of her engagement:

- She voted on 81 posts, showing her interest in various content by either upvoting or downvoting them.
- Cathy added 73 posts to her favorites, indicating these posts were particularly meaningful or enjoyable to her.
- She also shared her thoughts on 80 posts by commenting on them, contributing to discussions and sharing insights.

Overall, Cathy's involvement across voting, favoriting, and commenting showcases her active participation and engagement with the content on the platform.
```
