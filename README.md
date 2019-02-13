# Luigi on Docker

In addition to supporting the `sqlite` task history backend, this container includes all of the dependencies to use the `mysql` and `postgresql` backends.

![Luigi death stare](luigi.jpg)

## Versions

[All available images](https://hub.docker.com/r/axiom/docker-luigi/tags)

### alpine

Uses `pip` to install `luigi` and dependencies

* `axiom/docker-luigi:latest-alpine` (2.8.3)
* `axiom/docker-luigi:{version}-alpine`

### baseimage (ubuntu xenial)

Uses `conda` to install `luigi` and dependencies

* `axiom/docker-luigi:latest` (2.8.3)
* `axiom/docker-luigi:{version}`

## Exposed Volumes

#### `/etc/luigi/`

Both `luigi` and `luigid` load their configuration from `/etc/luigi/`.

* Configuration: `/etc/luigi/luigi.conf`
* Logging: `/etc/luigi/logging.conf`

Mount a directory containing a `luigi.conf` and `logging.conf` file(s) to
`/etc/luigi` to provide your own configuration(s).

```
docker run \
    -v /your/directory:/etc/luigi \
   axiom/docker-luigi
```

Or mount a single configuration file:

```
docker run \
    -v /your/directory/logging.conf:/etc/luigi/logging.conf \
   axiom/docker-luigi
```

The default can be found in the `luigi.conf` and `logging.conf` files in this
repository. Be aware that these specify the paths to the logging configration
and the state persistence database. If you change these values in `luigi.conf`
the examples in this document will not work!


#### `/luigi/state`

Mount a volume at `/luigi/state` for the `luigid` **state to be persisted**
between restarts. Example below uses a named docker volume to persist the state:

```
docker run \
    -v luigistate:/luigi/state \
    axiom/docker-luigi
```
