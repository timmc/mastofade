# Mastofade

Fade your Mastodon avatar from one image to another over
time. (Because I felt like it, that's why.)

## Requirements

- imagemagick installed (calls `composite`)
- OAuth application with write permissions registered in account
  (see Development tab in Mastodon settings)
- Ability to schedule the script to run periodically (e.g. cron)

## Usage

Call with path to config file as first argument.

### Configuration

Config file is a shell script that is expected to set the following
variables:

- `MF_SERVER` - instance domain e.g. botsin.space
- `MF_USER_ID` - either numeric ID or username on instance (just used
  for tmpfile management)
- `MF_OLD_AVATAR` - CWD-relative path to initial avatar image
- `MF_NEW_AVATAR` - CWD-relative path to final avatar image
- `MF_TOKEN` - Access token with write permissions to account

Remember to set permissions to 0600 or similar to protect the access
token.

### Cron job

Here's the crontab I have in `/etc/cron.d/mastofade` on my Debian 8
server, for reference:

```
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Run real account once per day
07 00 * * * timmc /home/timmc/mastofade/fade.sh /home/timmc/mastofade/main-acct.cfg >> /home/timmc/log/mastofade-prod.log 2>&1
```

This runs at 7 minutes after midnight UTC (arbitrary time).

Incidentally,
[this thread](https://askubuntu.com/questions/23009/why-crontab-scripts-are-not-working)
was great for fixing my cron config. (Don't forget the trailing
newline!)

## License

Seriously? OK, I'll use the WTFPL:

```
                   Version 2, December 2004

Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

Everyone is permitted to copy and distribute verbatim or modified
copies of this license document, and changing it is allowed as long
as the name is changed.

           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

 0. You just DO WHAT THE FUCK YOU WANT TO.
```
