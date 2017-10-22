rbu - **r**olling **b**ack**u**p
----

[![CircleCI](https://img.shields.io/circleci/project/github/blockloop/rbu.svg)]()
[![Docker Pulls](https://img.shields.io/docker/pulls/blockloop/rbu.svg)]()

`rbu` is a small shell script I created to backup files on a rolling basis (similar to syslog). `rbu` takes an input file and copies it to `<filename>.1`. If `<filename>.1` already exists then it moves `<filename>.1` to `<filename>.2`.  It repeats this process untill a maximum number of backups (`MAX_BACKUPS` or `-m`) is reached. Once the max is reached it continues rolling the files but no longer creates new files.

## Docker

```bash
docker run --rm -it blockloop/rbu -m 10 sqlite.db
```

## Usage

```
Usage:
 rbu parameters file
 rbu [-d output_dir] [-m max_backups] <file>

Options:
 -d <dir>  The directory to write backups.
           Default: dirname of <file>
           Optionally use OUT_DIR environment variable
 -m <num>  Maximum number of backups to retain
           Default: 5
           Optionally use MAX_BACKUPS environment variable

 -h        display this help and exit

```

