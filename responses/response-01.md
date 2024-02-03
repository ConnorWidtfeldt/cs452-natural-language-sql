# Response 1

Find the Most Popular Artists of the Month

## Prompt:

Get a list of artist whose posts have received the most favorites in the past month. 
Get the name of each artist, not their ID.
Include the total number of favorites for each artist and sort them in descending order.
Limit to the top 5 artists.

## Generated Query:

```sql
SELECT
    "artist_name"."name",
    COUNT("post_favorite"."post_id") AS "total_favorites"
FROM "artist"
INNER JOIN "artist_name" ON "artist"."id" = "artist_name"."artist_id"
INNER JOIN "post" ON "post"."id" = "artist"."creator_id"
INNER JOIN "post_favorite" ON "post_favorite"."post_id" = "post"."id"
WHERE "post_favorite"."created_at" > CURRENT_DATE - INTERVAL '1 month'
GROUP BY "artist_name"."name"
ORDER BY "total_favorites" DESC
LIMIT 5
```

## Friendly Response:

The list below showcases artists whose artworks have been most favored by viewers in the past month. Each artist's name is followed by the total number of times their artworks were marked as favorites. These artists have stood out for their remarkable contributions and have been ranked according to the popularity of their works, with the artist receiving the most favorites at the top.

Warhol - 96 favorites
Diego Rivera - 93 favorites
Dali - 91 favorites
Da Vinci - 83 favorites
Monet - 79 favorites

This list highlights the top 5 artists who have captivated the audience with their art, making a significant impact in the past month.
