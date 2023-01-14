<p align="center">
  <img src="https://user-images.githubusercontent.com/4627720/115236133-493f3480-a11b-11eb-9dae-c2958d1bfbf1.png?raw=true" alt="Trackmania image" height="100"/>
</p>
<p align="center">
    <a href="https://hub.docker.com/r/evotm/trackmania">
        <img src="https://img.shields.io/docker/stars/evotm/trackmania?&style=flat-square"
            alt="docker stars"></a>
    <a href="https://hub.docker.com/r/evotm/trackmania">
        <img src="https://img.shields.io/docker/pulls/evotm/trackmania?style=flat-square"
            alt="docker pulls"></a>
    <a href="https://hub.docker.com/r/evotm/trackmania">
        <img src="https://img.shields.io/docker/v/evotm/trackmania?style=flat-square"
            alt="docker image version"></a>
    <a href="https://hub.docker.com/r/evotm/trackmania">
        <img src="https://img.shields.io/docker/image-size/evotm/trackmania?style=flat-square"
            alt="docker image size"></a>
    <a href="https://discord.gg/evotm">
        <img src="https://img.shields.io/discord/384138149686935562?color=%235865F2&label=discord&logo=discord&logoColor=%23ffffff&style=flat-square"
            alt="chat on Discord"></a>
</p>
This image will start a TrackMania (2020) server. The image version indicates the server version and the -r0 prefix is the image release version which will increase if there are changes made to the image itself but the server version stays the same.

## Table of Contents
- [Table of Contents](#table-of-contents)
- [How to use this image](#how-to-use-this-image)
  - [... with 'docker run'](#-with-docker-run)
  - [... with 'docker compose'](#-with-docker-compose)
- [Environment Variables](#environment-variables)
- [Features](#features)
  - [Prometheus Exporter](#prometheus-exporter)
- [Contributing](#contributing)


## How to use this image
### ... with 'docker run'
To start a TrackMania server with `docker run`:
```shell
docker run \
  -e MASTER_LOGIN='YourMasterserverLogin' \
  -e MASTER_PASSWORD='YourMasterserverPassword' \
  -p 2350:2350/tcp \
  -p 2350:2350/udp \
  #-p 5000:5000/tcp \ # Be careful opening XMLRPC! Only if you really need to.
  #-p 9000:9000/tcp \ # For the prometheus exporter. Usually not needed, only if Prometheus is running not on the same host.
  -v UserData:/server/UserData \
  evotm/trackmania:latest
```

### ... with 'docker compose'
To do the same with `docker compose`:
```yaml
version: "3.8"
services:
  trackmania:
    image: evotm/trackmania:latest
    ports:
      - 2350:2350/udp
      - 2350:2350/tcp
      #- 5000:5000/tcp # Be careful opening XMLRPC! Only if you know what you're doing.
      #- 9000:9000/tcp # For the prometheus exporter. Usually not needed at all.
    environment:
      MASTER_LOGIN: "YourMasterserverLogin"
      MASTER_PASSWORD: "YourMasterserverPassword"
    volumes:
      - UserData:/server/UserData
volumes:
  UserData:
```
In both cases, the server will launch and be bound to port 2350 TCP & UDP. Port 5000 (XMLRPC) & 9000 (Prometheus metrics) won't usually be forwarded to the host, because apps who need it (e.g. server controllers) are supposed to run in the same stack.
You need to provide server credentials you can register [here](https://players.trackmania.com/server/dedicated), and put the login into the `MASTER_LOGIN` variable, and the password into the `MASTER_PASSWORD` variable.
The server only needs one volume to store your user data (e.g. maps, configs), which is mounted to /server/UserData. You can also use bind mounts.

## Environment Variables
| **Environment Variable**         | **Description**                                                                                                               | **Default Value**[^1]    | **Required** |
|----------------------------------|-------------------------------------------------------------------------------------------------------------------------------|--------------------------|:------------:|
| `MASTER_LOGIN`                   | Your server login name. (e.g. 'yourcoolserverlogin')                                                                          |                          |       ✔      |
| `MASTER_PASSWORD`                | Your server login password you got from the Trackmania player page.                                                           |                          |       ✔      |
| `SERVER_NAME`                    | The server name. (Only used once if there's no server name already set in the server config file.)                            | Docker TrackMania Server |              |
| `PLAYERS_MAX`                    | Max amount of players the server can have.                                                                                    | 32                       |              |
| `PLAYERS_PASSWORD`               | The password the players have to enter upon joining the server.                                                               |                          |              |
| `SPECTATORS_MAX`                 | Max amount of spectators a server can have.                                                                                   | 32                       |              |
| `SPECTATORS_PASSWORD`            | The password the spectators have to enther upon joining the server.                                                           |                          |              |
| `ALLOW_MAP_DOWNLOAD`             | If it's allowed for players to download the server maps.                                                                      | False                    |              |
| `AUTOSAVE_REPLAYS`               | If the server saves replays automatically.                                                                                    | False                    |              |
| `AUTOSAVE_VALIDATION_REPLAYS`    | If the server saves validation replays automatically.                                                                         | False                    |              |
| `CONNECTION_UPLOADRATE`          | The maximal upload speed the server is able to use.                                                                           | 102400                   |              |
| `CONNECTION_DOWNLOADRATE`        | The maximal download speed the server is able to use.                                                                         | 102400                   |              |
| `WORKERTHREADCOUNT`              | The maximum amount of CPU Threads the server can run on.                                                                      | 2                        |              |
| `PACKETASSEMBLY_MULTITHREAD`     | If the server should use multithreading for packet assembly.                                                                  | True                     |              |
| `FORCE_IP_ADDRESS`               | Usually the public IP of the server including the port. (e.g. 127.0.0.1:2350)[^2]                                             |                          |              |
| `XMLRPC_ALLOWREMOTE`             | Controls if the server allows external connections to XMLRPC.                                                                 | True[^3]                 |              |
| `DISABLE_COHERENCE_CHECKS`       | If the built-in anti-cheat is disabled.                                                                                       | False                    |              |
| `DISABLE_REPLAY_RECORDING`       | If the replay recording is disabled.                                                                                          | False                    |              |
| `SAVE_ALL_INDIVIDUAL_RUNS`       | If the server should save all individual runs.                                                                                | False                    |              |
| `DEDICATED_CFG`                  | In case you created your own server config and want to use that one instead.                                                  | dedicated_cfg.txt        |              |
| `GAME_SETTINGS`                  | In case you created your own matchsettings and want to use that one instead.                                                  | default.txt              |              |
| `PROMETHEUS_ENABLE`              | Enable the Prometheus Trackmania exporter.                                                                                    | False                    |              |
| `PROMETHEUS_PORT`                | The port the Prometheus Trackmania exporter will listen on.                                                                   | 9000                     |              |
| `PROMETHEUS_SUPERADMIN_PASSWORD` | The SuperAdmin password the Prometheus exporter needs in case it got changed.                                                 | SuperAdmin               |              |
| `PROMETHEUS_INTERVAL`            | The interval the prometheus exporter gets the metrics from the TrackMania server.                                             | 15                       |              |
[^1]: Default value of this docker image. Does not represent the defaults by the TrackMania server provided by Ubisoft Nadeo.
[^2]: If left unset, the TrackMania server will report the Docker internal IP address to the masterserver, which will prevent people from connecting to it.
[^3]: `True` here doesn't mean anyone can connect to the XMLRPC interface. It just allows connections from other containers to be made to it, for example from server controllers like EvoSC or PyPlanet.


## Features
### Prometheus Exporter
The image contains a small (~6MB) prometheus exporter. It can be enabled through the `PROMETHEUS_ENABLE` variable. The container will then expose metrics about the TrackMania server on port 9000.

Example output:
```
# HELP trackmania_player_count Current player count by type.
# TYPE trackmania_player_count gauge
trackmania_player_count{type="online"} 8.0
trackmania_player_count{type="spectating"} 0.0
trackmania_player_count{type="driving"} 8.0
# HELP trackmania_moderation_count Current players count being moderated by type.
# TYPE trackmania_moderation_count gauge
trackmania_moderation_count{type="banned"} 1.0
trackmania_moderation_count{type="blacklisted"} 1.0
trackmania_moderation_count{type="guestlisted"} 0.0
trackmania_moderation_count{type="ignored"} 0.0
# HELP trackmania_player_count_mean The mean value of the player count.
# TYPE trackmania_player_count_mean gauge
trackmania_player_count_mean 6.0
# HELP trackmania_server_uptime Time since the TrackMania server has started in seconds.
# TYPE trackmania_server_uptime gauge
trackmania_server_uptime 459307.0
# HELP trackmania_connection_count Total connections made to the TrackMania server.
# TYPE trackmania_connection_count gauge
trackmania_connection_count 1397.0
# HELP trackmania_connection_time_mean The mean value of the connection time in ms.
# TYPE trackmania_connection_time_mean gauge
trackmania_connection_time_mean 2041.0
# HELP trackmania_net_rate_recv Connection rate inbound in kbps.
# TYPE trackmania_net_rate_recv gauge
trackmania_net_rate_recv 137.0
# HELP trackmania_net_rate_send Connection rate outbound in kbps.
# TYPE trackmania_net_rate_send gauge
trackmania_net_rate_send 76.0
# HELP trackmania_maps_count Amount of maps the server currently has loaded.
# TYPE trackmania_maps_count gauge
trackmania_maps_count 99.0
# HELP trackmania_player_max Max configured amount of players the server can hold.
# TYPE trackmania_player_max gauge
trackmania_player_max{type="players"} 150.0
trackmania_player_max{type="spectators"} 32.0
```
## Contributing
If you have any questions, issues, bugs or suggestions, don't hesitate and open an [Issue](https://github.com/EvoTM/docker-trackmania/issues/new)! You can also join our [Discord](https://discord.gg/evotm) for questions.

You may also help with development by creating a pull request.
