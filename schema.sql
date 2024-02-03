CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "public";

-- CORE ENTITIES --

CREATE TABLE "user" (
    "id" bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "name" character varying NOT NULL,
    "created_at" timestamp WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- tags are means of categorizing things in the site
-- tags can be added to just about anything
CREATE TABLE "tag" (
    "id" bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "name" character varying NOT NULL
);

-- a post is the central object of the site, and can be an image, video, or text
CREATE TABLE "post" (
    "id" bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "created_at" timestamp WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- a creator of art/media
CREATE TABLE "artist" (
    "id" bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "creator_id" bigint NOT NULL REFERENCES "user" ON DELETE SET NULL,
    "created_at" timestamp WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- a collection of posts
CREATE TABLE "pool" (
    "id" bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "name" character varying NOT NULL,
    "creator_id" bigint NOT NULL REFERENCES "user" ON DELETE SET NULL,
    "created_at" timestamp WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- COMPONENTS --

-- an artist might have multiple names/aliases
CREATE TABLE "artist_name" (
    "id" bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "artist_id" bigint NOT NULL REFERENCES "artist" ON DELETE CASCADE,
    "name" character varying NOT NULL,
    "created_at" timestamp WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- a link to the artist source (twitter, artstation, etc)
CREATE TABLE "artist_url" (
    "id" bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "artist_id" bigint NOT NULL REFERENCES "artist" ON DELETE CASCADE,
    "url" text NOT NULL,
    "created_at" timestamp WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- associates a post with an pool (a collection of posts, like an album)
CREATE TABLE "pool_post" (
    "pool_id" bigint NOT NULL REFERENCES "pool" ON DELETE CASCADE,
    "post_id" bigint NOT NULL REFERENCES "post" ON DELETE CASCADE,
    PRIMARY KEY ("pool_id", "post_id")
);

-- posts must be validated by a moderator before being visible to the public
CREATE TABLE "post_approval" (
    "user_id" bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    "post_id" bigint NOT NULL REFERENCES "post" ON DELETE CASCADE,
    "created_at" timestamp WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY ("user_id", "post_id")
);

-- posts can be disapproved by a moderator, which marks them for review
CREATE TABLE "post_disapproval" (
    "user_id" bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    "post_id" bigint NOT NULL REFERENCES "post" ON DELETE CASCADE,
    "message" text,
    "created_at" timestamp WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY ("user_id", "post_id")
);

-- a comment left by a user, which people can vote on
CREATE TABLE "post_comment" (
    "id" bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "post_id" bigint NOT NULL REFERENCES "post" ON DELETE CASCADE,
    "user_id" bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    "body" text NOT NULL,
    "created_at" timestamp WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- a weighted score on a comment (typically just -1, or 1, but could be more depending on the user type)
CREATE TABLE "post_comment_vote" (
    "post_comment_id" bigint NOT NULL REFERENCES "post_comment" ON DELETE CASCADE,
    "user_id" bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    "score" integer NOT NULL,
    "created_at" timestamp WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY ("post_comment_id", "user_id")
);

-- adds the post to the users favorites
CREATE TABLE "post_favorite" (
    "post_id" bigint NOT NULL REFERENCES "post" ON DELETE CASCADE,
    "user_id" bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    "created_at" timestamp WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    PRIMARY KEY ("post_id", "user_id")
);

-- links to a post image
CREATE TABLE "post_image" (
    "id" bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "post_id" bigint NOT NULL REFERENCES "post" ON DELETE CASCADE,
    "url" text NOT NULL,
);

-- tags are the heart of the site, and are used to categorize posts for easy searching
-- the post_tag table is a many-to-many relationship between posts and tags
CREATE TABLE "post_tag" (
    "id" bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    "post_id" bigint NOT NULL REFERENCES "post" ON DELETE CASCADE,
    "tag_id" bigint NOT NULL REFERENCES "tag" ON DELETE CASCADE,
    "user_id" bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    "created_at" timestamp WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- a weighted score on a post (typically just -1, or 1, but could be more depending on the user type)
CREATE TABLE "post_vote" (
    "post_id" bigint NOT NULL REFERENCES "post" ON DELETE CASCADE,
    "user_id" bigint NOT NULL REFERENCES "user" ON DELETE CASCADE,
    "score" integer NOT NULL,
    "created_at" timestamp WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY ("post_id", "user_id")
);

-- some tags mean the same thing, for example "cat" and "kitty"
CREATE TABLE "tag_alias" (
    "antecedent_tag_id" bigint NOT NULL REFERENCES "tag" ON DELETE CASCADE,
    "consequent_tag_id" bigint NOT NULL REFERENCES "tag" ON DELETE CASCADE,
    PRIMARY KEY ("antecedent_tag_id", "consequent_tag_id"),
    CHECK ("antecedent_tag_id" <> "consequent_tag_id")
);

-- some tags imply the same thing, like "animal" implies "cat"
CREATE TABLE "tag_implication" (
    "antecedent_tag_id" bigint NOT NULL REFERENCES "tag" ON DELETE CASCADE,
    "consequent_tag_id" bigint NOT NULL REFERENCES "tag" ON DELETE CASCADE,
    PRIMARY KEY ("antecedent_tag_id", "consequent_tag_id"),
    CHECK ("antecedent_tag_id" <> "consequent_tag_id")
);

-- GENERATED DATA --

-- generated data that is regenerated/cached when the source data changes
-- expensive joins should be done using views, and the views should be regenerated using triggers
CREATE OR REPLACE VIEW "post_status" AS
SELECT
    "post"."id",
    COUNT("post_approval"."user_id") AS "approvals",
    COUNT("post_disapproval"."user_id") AS "disapprovals",
    COUNT("post_favorite"."user_id") AS "favorites",
    COUNT("post_vote"."user_id") AS "score"
FROM "post"
LEFT JOIN "post_approval" ON "post_approval"."post_id" = "post"."id"
LEFT JOIN "post_disapproval" ON "post_disapproval"."post_id" = "post"."id"
LEFT JOIN "post_favorite" ON "post_favorite"."post_id" = "post"."id"
LEFT JOIN "post_vote" ON "post_vote"."post_id" = "post"."id"
GROUP BY "post"."id";