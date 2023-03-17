FROM docker.io/library/busybox:1-musl

WORKDIR /torad
COPY hasura/ .

CMD "cp /torad/hasura/migrations /mnt && cp /torad/hasura/metadata /mnt"
