rbu - **r**olling **b**ack**u**p
----

[![CircleCI](https://img.shields.io/circleci/project/github/blockloop/rbu.svg)](https://circleci.com/gh/blockloop/rbu)
[![Docker Pulls](https://img.shields.io/docker/pulls/blockloop/rbu.svg)](https://hub.docker.com/r/blockloop/rbu/)

`rbu` is a small shell script I created to backup files on a rolling basis (similar to syslog). `rbu` takes an input file and copies it to `<filename>.1`. If `<filename>.1` already exists then it moves `<filename>.1` to `<filename>.2`.  It repeats this process untill a maximum number of backups (`MAX_BACKUPS` or `-m`) is reached. Once the max is reached it continues rolling the files.

By default `rbu` will not backup the file if the previous backup identically matches the current. This is to prevent numerous of the same backup. If you would like `rbu` to backup the file _no matter what_ then you can supply the `-a` flag.

## Install

Save [rbu](rbu) somewhere in your `$PATH`.

```
curl -LJ -o /usr/local/bin/rbu https://raw.githubusercontent.com/blockloop/rbu/master/rbu
chmod +x /usr/local/bin/rbu
```

## Docker

```bash
docker run --rm -it blockloop/rbu -m 10 sqlite.db
```

## Usage

```
Usage:
 rbu parameters file
 rbu [-d output_dir] [-m max_backups] [-a] <file>

Options:
 -d <dir>  The directory to write backups.
           Default: dirname of <file>
           Optionally use OUT_DIR environment variable
 -m <num>  Maximum number of backups to retain
           Default: 5
           Optionally use MAX_BACKUPS environment variable
 -a        Always perform backup regardless of change.
           Default: false
           Optionally use ALWAYS_BACKUP environment variable

 -h        display this help and exit
```

