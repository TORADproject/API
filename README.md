# TORAD API

The TORAD API is based on Hasura. Metadata for Hasura is stored on a Postgres database. Data for TORAD is stored on a
CockroachDB database.

## Tools

- [Install the Hasura CLI](https://hasura.io/docs/latest/hasura-cli/install-hasura-cli/)
- Get something that can bring up `compose.yaml` files (`docker-compose`,  `docker compose`, `podman-compose`)

# Development

## To get a development server running:

1. Bring up the `compose.yaml` file (keep running)
2. `cd hasura`
3. `hasura console` (keep running)

## To create a(n) SQL migration:

1. Make sure the development server is running (`compose.yaml`, `hasura console`)
2. `hasura migrate create <migration-name>`
3. Write queries in newly created `up.sql` and `down.sql`
4. `hasura migrate apply` (applies to running dev server)

# Database Schema

```mermaid
classDiagram
direction BT
class albums {
   timestamp with time zone created_at
   timestamp with time zone updated_at
   text name
   text description
   s3_host s3_cover_host
   s3_bucket s3_cover_bucket
   text s3_cover_key
   boolean is_active
   uuid id
}
class artist_albums {
   uuid artist_id
   uuid album_id
}
class artist_songs {
   uuid artist_id
   uuid song_id
}
class artists {
   timestamp with time zone created_at
   timestamp with time zone updated_at
   text name
   text description
   boolean is_active
   uuid id
}
class audio_encodings {
   timestamp with time zone created_at
   timestamp with time zone updated_at
   uuid song_id
   s3_host s3_song_host
   s3_bucket s3_song_bucket
   text s3_song_key
   audio_encoding audio_encoding
   audio_codec audio_codec
   double precision audio_bitrate
   boolean is_active
   uuid id
}
class playlist_songs {
   bigint position
   uuid playlist_id
   uuid song_id
}
class playlists {
   timestamp with time zone created_at
   timestamp with time zone updated_at
   text name
   uuid owner_id
   boolean is_active
   uuid id
}
class songs {
   timestamp with time zone created_at
   timestamp with time zone updated_at
   uuid album_id
   bigint album_order
   text name
   s3_host s3_cover_host
   s3_bucket s3_cover_bucket
   text s3_cover_key
   boolean is_active
   uuid id
}

artist_albums  -->  albums : album_id>id
artist_albums  -->  artists : artist_id>id
artist_songs  -->  artists : artist_id>id
artist_songs  -->  songs : song_id>id
audio_encodings  -->  songs : song_id>id
playlist_songs  -->  playlists : playlist_id>id
playlist_songs  -->  songs : song_id>id
songs  -->  albums : album_id>id
```

# Container Image

Images are automatically built by Github Actions on each new Git tag push.

`cr.srock.cc/torad/api-config`

The image copies the `hasura/migrations` and `hasura/metadata` to `/mnt`, creating `/mnt/migrations`
and `/mnt/metadata`. Create volume mounts in those locations as appropriate.

It's expected that this container is deployed in the same pod as
a `docker.io/hasura/graphql-engine:<version>.cli-migrations-v3` container as an init container. That way the Hasura
container may mount the same container volumes, allowing it to be configured automatically.