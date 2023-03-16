-- Playlist Song Linking Table
DROP TABLE IF EXISTS playlist_songs;

-- Artist Song Linking Table
DROP TABLE IF EXISTS artist_songs;

-- Artist Album Linking Table
DROP TABLE IF EXISTS artist_albums;

-- Playlist Table
DROP TABLE IF EXISTS playlists;

-- Encoding Table
DROP TABLE IF EXISTS audio_encodings;

-- Song Table
DROP TABLE IF EXISTS songs;

-- Albums Table
DROP TABLE IF EXISTS albums;

-- Artists Table
DROP TABLE IF EXISTS artists;

-- Enumerations
DROP TYPE IF EXISTS s3_host;
DROP TYPE IF EXISTS s3_bucket;
DROP TYPE IF EXISTS audio_encoding;
DROP TYPE IF EXISTS audio_codec;
