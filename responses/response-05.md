# Response 5

Highlight Comments with Exceptional Community Response

## Prompt:

```
Find all comments on posts that have received a net score of 5 or more (total upvotes minus downvotes) in the last month.
Include the comment's body, the net score, the post ID it belongs to, and the name of the user who posted the comment. 
Sort by net score in descending order.
Limit to 5 comments.
```

## Generated Query:

```sql
SELECT
    "post_comment"."body",
    (SUM(CASE WHEN "post_vote"."score" > 0 THEN 1 ELSE 0 END) - SUM(CASE WHEN "post_vote"."score" < 0 THEN 1 ELSE 0 END)) AS net_score,
    "post_comment"."post_id",
    "user"."name"
FROM "post_comment"
INNER JOIN "user" ON "post_comment"."user_id" = "user"."id"
INNER JOIN "post_vote" ON "post_comment"."post_id" = "post_vote"."post_id"
WHERE "post_comment"."created_at" > NOW() - INTERVAL '1 MONTH'
GROUP BY "post_comment"."id", "user"."name"
HAVING
    (SUM(CASE WHEN "post_vote"."score" > 0 THEN 1 ELSE 0 END) - SUM(CASE WHEN "post_vote"."score" < 0 THEN 1 ELSE 0 END)) >= 5
ORDER BY net_score DESC
LIMIT 5
```

## Friendly Response:

```
Here's a list of the top 5 most popular comments from the last month, ranked by the net number of likes they've received (likes minus dislikes):

1. Comment by Deon Turner on post #144 received a net score of 6 likes. The comment is:
"Enim iure porro. Quia vel optio. Error similique earum."

2. Dr. Maurice Huels commented on post #804 and got a net score of 5 likes. The comment reads:
"Consequatur id voluptatem. Adipisci quo nesciunt. Magni illo ab."

3. Cruz Conn Jr. made a comment on post #3143 which also got a net score of 5 likes. His comment was:
"Est velit tenetur. Consectetur perspiciatis ut. Sed repudiandae qui."

4. On post #1792, Terrilyn Miller's comment received 5 likes as well. The comment says:
"Facere cumque mollitia. Iste excepturi illo. Consequatur quam id."

5. Lastly, Hilma Hudson's comment on post #1558 got a net score of 5 likes. It reads:
"Sed sint et. Id dolorum accusantium. Laboriosam at voluptas."

These comments stood out in the past month for their popularity, engaging various users in discussions and earning their appreciation.
```
