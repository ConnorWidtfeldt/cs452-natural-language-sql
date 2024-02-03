# Response 6

Analyze Feedback on Disapproved Posts

## Prompt:

Retrieve the top 10 posts disapproved in the last week, including the post ID, the reason for disapproval (message), and the date of disapproval.
Sort the results by the number of times the post has been disapproved, in descending order.

## Generated Query:

```sql
SELECT
    "post_id",
    "message",
    "created_at"
FROM "post_disapproval"
WHERE "created_at" > CURRENT_DATE - INTERVAL '1 week'
GROUP BY
    "post_id",
    "message",
    "created_at"
ORDER BY COUNT("post_id") DESC
LIMIT 10
```

## Friendly Response:


Here is the list of the top 10 posts that were disapproved in the last week. The list includes details such as the post's ID, the reason it was flagged by the moderators, and the exact date and time when the disapproval was recorded. The posts are ranked based on how many times they were disapproved, starting with the most disapproved post.

```
┌─────────┬────────────────────────┬──────────────────────────────┐
│ Post ID │ Reason for Disapproval │ Date and Time of Disapproval │
├─────────┼────────────────────────┼──────────────────────────────┤
│ 4849    │ DMCA                   │ February 1, 2024, 2:29 AM    │
│ 1122    │ Incorrect artist       │ February 1, 2024, 9:49 AM    │
│ 3008    │ Incorrect artist       │ February 1, 2024, 3:51 AM    │
│ 3639    │ Explicit content       │ January 31, 2024, 2:43 PM    │
│ 2864    │ Other                  │ January 29, 2024, 4:46 AM    │
│ 2187    │ DMCA                   │ January 30, 2024, 11:43 AM   │
│ 3785    │ Explicit content       │ January 30, 2024, 11:12 PM   │
│ 2774    │ Incorrect description  │ January 29, 2024, 12:16 AM   │
│ 39      │ Incorrect description  │ January 31, 2024, 10:25 PM   │
│ 3859    │ Bad tags               │ January 28, 2024, 3:26 AM    │
└─────────┴────────────────────────┴──────────────────────────────┘
```

This table highlights the variety of reasons why posts get disapproved, ranging from copyright infringement (DMCA) and mislabeling the content artist, to posts containing explicit content. Each disapproval is actioned promptly to ensure the quality and appropriateness of content shared within the community.
