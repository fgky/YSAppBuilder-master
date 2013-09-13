# Deploy

Tested on Ubuntu 12.10 64bit.

Other platform please use https://github.com/linjunpop/cuisine to setup server. No promises™.

## Install essential tools

ssh to server as root

```bash
$ sudo apt-get install git
$ sudo apt-get install curl
$ sudo apt-get remove apache*
```

## Add deployer user

```bash
$ sudo adduser deployer
$ sudo adduser deployer sudo
```

ssh to server as deployer, open `~/.ssh/authorized_keys`, append public keys to this file.

## Create app on remote server

ssh to server, create `~/rails_apps/YSAppBuilder` folder.

## Install requirements

```bash
$ cap deploy:install
```

## Setup configurations

```bash
$ cap deploy:setup
```

## Initial deployment

```bash
$ cap deploy:cold
```

