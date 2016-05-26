# Luigi on Docker

![Luigi death stare](luigi.jpg)


## Configuration

* `luigid` loads its configuration from `/etc/luigi/luigi.conf`
* `luigi` loads its configuration from `/etc/luigi/luigi.conf` and its 
logging configuration from `/etc/luigi/logging.conf`

Mount a directory containing a `luigi.conf` and `logging.conf` file(s) to
`/etc/luigi` to provide your own configuration(s).

```
docker run -v /your/directory:/etc/luigi \
           --name luigi \
           axiom/docker-luigi
```

### Defaults

```
# luigi.conf

[core]
logging_conf_file: /etc/luigi/logging.conf

[scheduler]
record_task_history: True
state-path: /luigi/state/luigi-state.pickle

[task_history]
db_connection: sqlite:////luigi/state/luigi-task-history.db
```

```
# logging.conf

[loggers]
keys=root

[handlers]
keys=console

[formatters]
keys=detail

[formatter_detail]
class=logging.Formatter
format=%(asctime)s %(name)-15s %(levelname)-8s %(message)s

[handler_console]
class=StreamHandler
args=(sys.stdout,)
formatter=detail

[logger_root]
level=INFO
handlers=console
```

## Persistent State

Mount a volume at `/luigi/state` for the `luigid` scheduler state to be persisted 
between restarts

```
docker run -v /your/state/directory:/luigi/state \
           --name luigi \
           axiom/docker-luigi
```


## Logs

The logs are pushed through syslog and accessible though `docker logs` as you would expect.
