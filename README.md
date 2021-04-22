<p align="center">
  <img src="https://user-images.githubusercontent.com/4627720/115236133-493f3480-a11b-11eb-9dae-c2958d1bfbf1.png?raw=true" alt="Trackmania image" height="100"/>
</p>
<p align="center">
    <a href="https://hub.docker.com/r/evotm/trackmania">
        <img src="https://img.shields.io/docker/stars/evotm/trackmania?style=flat-square"
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
    <a href="https://discord.gg/4PKKesS">
        <img src="https://img.shields.io/discord/384138149686935562?style=flat-square"
            alt="chat on Discord"></a>
</p>
This unoffical Docker image provides a TrackMania Server with the version depending on the image version.


## Getting Started
### Examples
#### docker run
To start a TrackMania server where all data is stored in a named volume with docker run:
```shell
docker run \
  -e MASTER_LOGIN='YourMasterserverLogin' \
  -e MASTER_PASSWORD='YourMasterserverPassword' \
  -p 2350:2350/tcp \
  -p 2350:2350/udp \
  #-p 5000:5000/tcp \ # Be careful opening XMLRPC! Only if you really need to.
  -v UserData:/server/UserData \
  evotm/trackmania
```

To do the same with docker compose:
#### docker compose
```yaml
version: "3.8"
services:
  trackmania:
    image: evotm/trackmania
    ports:
      - 2350:2350/udp
      - 2350:2350/tcp
      #- 5000:5000/tcp # Be careful opening XMLRPC! Only if you really need to.
    environment:
      MASTER_LOGIN: "YourMasterserverLogin"
      MASTER_PASSWORD: "YourMasterserverPassword"
    volumes:
      - UserData:/server/UserData
```


### Environment Variables
#### Required
* `MASTER_LOGIN` - Your server login name. (e.g. 'yourcoolserverlogin')
* `MASTER_PASSWORD` - Your server login password you got from the Trackmania player page. (e.g. 'YbL=.jIa-vZvIx5B')
#### Optional
* `SERVER_NAME` - The server name. (e.g. 'A Trackmania Server')
  * :memo: Only used if no server name is already present inside the server config file.
* `PLAYERS_MAX` - Max amount of players the server can have. (number)
* `PLAYERS_PASSWORD` - The password the players have to enter upon joining the server. (e.g. 'SuperSecretPassword')
* `SPECTATORS_MAX` - Max amount of spectators a server can have. (number)
* `SPECTATORS_PASSWORD` - The password the spectators have to enther upon joining the server. (e.g. 'SuperSecretPassword')
* `ALLOW_MAP_DOWNLOAD` - If it's allowed for players to download the server maps. (True/False)
* `AUTOSAVE_REPLAYS` - If the server saves replays automatically. (True/False)
* `AUTOSAVE_VALIDATION_REPLAYS` - If the server saves validation replays automatically. (True/False)
* `CONNECTION_UPLOADRATE` - The maximal upload speed the server is able to use. (number)
* `CONNECTION_DOWNLOADRATE` - The maximal download speed the server is able to use. (number)
* `WORKERTHREADCOUNT` - The maximum amount of CPU Threads the server can run on. (number)
* `PACKETASSEMBLY_MULTITHREAD` If the server should use multithreading for packet assembly (True/False)
* `FORCE_IP_ADDRESS` - Usually the public IP of the server including the port. (e.g. '123.123.123.123:2350').
  * :memo: It should be set if the intention is to make the server public.
* `XMLRPC_ALLOWREMOTE` - If the server allows connections to XMLRPC. (True/False)
* `DISABLE_COHERENCE_CHECKS` - If the built-in anti-cheat is disabled. (True/False)
* `DISABLE_REPLAY_RECORDING` - If the replay recording is disabled. (True/False)
* `SAVE_ALL_INDIVIDUAL_RUNS` - If the server should save all individual runs. (True/False)
* `DEDICATED_CFG` - In case you created your own server config and want to use that one instead. (e.g. 'serverconfig.txt')
* `GAME_SETTINGS` - In case you created your own matchsettings and want to use that one instead. (e.g. 'matchsettings.txt')

### Volumes
There's only one volume mounted on /server/UserData inside the container, which allows to make the server data persistent.

#### Named volume
This one let's docker handle the path where the files will be stored.
using docker run:
```shell
-v UserData:/server/UserData
```
using docker compose:
```yaml
volumes:
  - UserData:/server/UserData
```

#### Bind mount
This one let's you specify the path where the files will be stored.
using docker run:
```shell
-v UserData:/server/UserData
```
using docker compose:
```yaml
volumes:
  - /path/on/your/host:/server/UserData
```
## Contributing
If you have any questions, issues, bugs or suggestions, don't hesitate open an [Issue](https://github.com/EvoTM/docker-trackmania/issues/new)! You can also join our [Discord](https://discord.gg/4PKKesS) for questions.

You may also help with development by creating a pull request.
