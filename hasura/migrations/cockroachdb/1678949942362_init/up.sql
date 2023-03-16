-- Enumerations
CREATE TYPE IF NOT EXISTS s3_host AS ENUM ('s3.shamrock.systems', 's3.amazonaws.com');
CREATE TYPE IF NOT EXISTS s3_bucket AS ENUM ('torad-songs', 'torad-covers');
CREATE TYPE IF NOT EXISTS audio_encoding AS ENUM ('TLMC-v2.5-default', 'TLMC-v3.5-default');
CREATE TYPE IF NOT EXISTS audio_codec AS ENUM ('AAC', 'ALAC', 'AMR', 'FLAC', 'G.711', 'G.722', 'MP3', 'Opus', 'Vorbis');

-- Artists Table
CREATE TABLE IF NOT EXISTS artists
(
    id          UUID PRIMARY KEY                  DEFAULT gen_random_uuid(),
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    name        TEXT                     NOT NULL,
    description TEXT,
    is_active   BOOLEAN                  NOT NULL DEFAULT true
);

-- Albums Table
CREATE TABLE IF NOT EXISTS albums
(
    id              UUID PRIMARY KEY                  DEFAULT gen_random_uuid(),
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    name            TEXT                     NOT NULL,
    description     TEXT,
    s3_cover_host   s3_host,
    s3_cover_bucket s3_bucket,
    s3_cover_key    TEXT,
    is_active       BOOLEAN                  NOT NULL DEFAULT true
);

-- Song Table
CREATE TABLE IF NOT EXISTS songs
(
    id              UUID PRIMARY KEY                  DEFAULT gen_random_uuid(),
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    album_id        UUID REFERENCES albums (id) ON DELETE CASCADE,
    album_order     INTEGER                  NOT NULL,
    name            TEXT                     NOT NULL,
    s3_cover_host   s3_host,
    s3_cover_bucket s3_bucket,
    s3_cover_key    TEXT,
    is_active       BOOLEAN                  NOT NULL DEFAULT true
);

-- Encoding Table
CREATE TABLE IF NOT EXISTS audio_encodings
(
    id             UUID PRIMARY KEY                  DEFAULT gen_random_uuid(),
    created_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    song_id        UUID REFERENCES songs (id) ON DELETE CASCADE,
    s3_song_host   s3_host                  NOT NULL DEFAULT 's3.shamrock.systems',
    s3_song_bucket s3_bucket                NOT NULL DEFAULT 'torad-songs',
    s3_song_key    TEXT                     NOT NULL,
    audio_encoding audio_encoding           NOT NULL,
    audio_codec    audio_codec              NOT NULL,
    audio_bitrate  FLOAT                    NOT NULL, -- kilobits per second
    is_active      BOOLEAN                  NOT NULL DEFAULT true
);

-- Playlist Table
CREATE TABLE IF NOT EXISTS playlists
(
    id         UUID PRIMARY KEY                  DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    name       TEXT                     NOT NULL,
    owner_id   UUID                     NOT NULL, -- Keycloak user UUID (found in "sub")
    is_active  BOOLEAN                  NOT NULL DEFAULT true
);

-- Artist Album Linking Table
CREATE TABLE IF NOT EXISTS artist_albums
(
    artist_id UUID REFERENCES artists (id) ON DELETE CASCADE,
    album_id  UUID REFERENCES albums (id) ON DELETE CASCADE,
    PRIMARY KEY (artist_id, album_id)
);

-- Artist Song Linking Table
CREATE TABLE IF NOT EXISTS artist_songs
(
    artist_id UUID REFERENCES artists (id) ON DELETE CASCADE,
    song_id   UUID REFERENCES songs (id) ON DELETE CASCADE,
    PRIMARY KEY (artist_id, song_id)
);

-- Playlist Song Linking Table
CREATE TABLE IF NOT EXISTS playlist_songs
(
    playlist_id UUID REFERENCES playlists (id) ON DELETE CASCADE,
    song_id     UUID REFERENCES songs (id) ON DELETE CASCADE,
    PRIMARY KEY (playlist_id, song_id),
    position    INTEGER NOT NULL,
    -- Don't really care about the actual values of position, just that they are in order (ascending)
    CONSTRAINT playlist_position_unique UNIQUE (playlist_id, song_id, position)
);
