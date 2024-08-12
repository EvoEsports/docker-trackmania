<p align="center">
  <img src="https://user-images.githubusercontent.com/4627720/115236133-493f3480-a11b-11eb-9dae-c2958d1bfbf1.png?raw=true" alt="Trackmania image" height="100"/>
</p>
<p align="center">
    <a href="https://hub.docker.com/r/evoesports/trackmania">
        <img src="https://img.shields.io/docker/stars/evoesports/trackmania?&style=flat-square&color=%231D63ED&logo=docker&logoColor=%23ffffff"
            alt="docker stars"></a>
    <a href="https://hub.docker.com/r/evoesports/trackmania">
        <img src="https://img.shields.io/docker/pulls/evoesports/trackmania?style=flat-square&color=%231D63ED&logo=docker&logoColor=%23ffffff"
            alt="docker pulls"></a>
    <a href="https://hub.docker.com/r/evoesports/trackmania">
        <img src="https://img.shields.io/docker/v/evoesports/trackmania?style=flat-square&color=%231D63ED&logo=docker&logoColor=%23ffffff"
            alt="docker image version"></a>
    <a href="https://hub.docker.com/r/evoesports/trackmania">
        <img src="https://img.shields.io/docker/image-size/evoesports/trackmania?style=flat-square&color=%231D63ED&logo=docker&logoColor=%23ffffff"
            alt="docker image size"></a>
    <a href="https://discord.gg/evoesports">
        <img src="https://img.shields.io/discord/384138149686935562?color=%235865F2&label=discord&logo=discord&logoColor=%23ffffff&style=flat-square"
            alt="chat on Discord"></a>
    <a href="https://evoesports.gg/">
        <img src="https://custom-icon-badges.demolab.com/badge/-Made%20by%20Evo-blue?style=flat-square&logo=evoesports-p&logoColor=%23FF0058&color=%23222222"
            alt="evo website"></a>
</p>

This Docker image provides an easy and efficient way to deploy a Trackmania game server. It allows for quick setup, customizable configurations, and supports persistent storage to retain server data across restarts. With this image, you can effortlessly manage your Trackmania server using Docker’s containerization benefits.

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
  -e TM_MASTERSERVER_LOGIN='YourMasterserverLogin' \
  -e TM_MASTERSERVER_PASSWORD='YourMasterserverPassword' \
  -p 2350:2350/tcp \
  -p 2350:2350/udp \
  #-p 5000:5000/tcp \ # Be careful opening XMLRPC! Only if you really need to.
  #-p 9000:9000/tcp \ # For the prometheus exporter.
  -v UserData:/server/UserData \
  evoesports/trackmania:latest
```

### ... with 'docker compose'
Here is the `compose.yml`:
```yaml
services:
  trackmania:
    image: evoesports/trackmania:latest
    ports:
      - 2350:2350/udp
      - 2350:2350/tcp
      #- 5000:5000/tcp # Be careful opening XMLRPC! Only if you know what you're doing.
      #- 9000:9000/tcp # For the prometheus exporter.
    environment:
      TM_MASTERSERVER_LOGIN: "YourMasterserverLogin"
      TM_MASTERSERVER_PASSWORD: "YourMasterserverPassword"
    volumes:
      - UserData:/server/UserData
volumes:
  UserData:
```
In both cases, the server will launch and be bound to port 2350 TCP & UDP. Port 5000 (XMLRPC) & 9000 (Prometheus metrics) won't usually be forwarded to the host, because apps who need it (e.g. server controllers) are supposed to run in the same stack.
You need to provide server credentials you can register [here](https://players.trackmania.com/server/dedicated), and put the login into the `TM_MASTERSERVER_LOGIN` variable, and the password into the `TM_MASTERSERVER_PASSWORD` variable.
The server only needs one volume to store your user data (e.g. maps, configs), which is mounted to /server/UserData. You can also use bind mounts.

## Environment Variables
Below is a list of all possible environment variables that can be set through Docker.
| **Environment Variable**                         | **Description**                                                                                                                             | **Default Value**[^1]    |
|--------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|--------------------------|
| `TM_AUTHORIZATION_SUPERADMIN_PASSWORD`           | Sets the password for the SuperAdmin access level, granting the highest level of permissions.                                               | SuperAdmin               |
| `TM_AUTHORIZATION_ADMIN_PASSWORD`                | Sets the password for the Admin access level, granting intermediate-level permissions.                                                      | Admin                    |
| `TM_AUTHORIZATION_USER_PASSWORD`                 | Sets the password for the User access level, granting basic user permissions.                                                               | User                     |
| `TM_MASTERSERVER_LOGIN`                          | The login name for the server account on the Trackmania master server (e.g., 'yourcoolserverlogin'). If not specified, the server starts in LAN mode. |                          |
| `TM_MASTERSERVER_PASSWORD`                       | The password associated with the server's master server account, obtained from the Trackmania player page.                                  |                          |
| `TM_SERVER_NAME`                                 | The display name of the server as seen by players. Only used if no server name is set in the server config file.                            | Docker TrackMania Server |
| `TM_SERVER_COMMENT`                              | A description or comment about the server, shown to players in server listings.                                                             |                          |
| `TM_SERVER_MAX_PLAYERS`                          | The maximum number of players that can join the server simultaneously.                                                                      | 32                       |
| `TM_SERVER_PASSWORD`                             | Password required for players to join the server, if set.                                                                                   |                          |
| `TM_SERVER_MAX_SPECTATORS`                       | The maximum number of spectators that can watch the server's matches.                                                                       | 32                       |
| `TM_SERVER_PASSWORD_SPECTATOR`                   | Password required for spectators to join the server, if set.                                                                                |                          |
| `TM_SERVER_KEEP_PLAYER_SLOTS`                    | If `True`, keeps a player's slot and records/points when they switch to spectator mode.                                                     | False                    |
| `TM_SERVER_CALLVOTE_TIMEOUT`                     | Duration in milliseconds before a callvote expires if no decision is reached.                                                               | 60000                    |
| `TM_SERVER_CALLVOTE_RATIO`                       | The minimum percentage of 'Yes' votes needed for a callvote to pass.                                                                        | 0.5                      |
| `TM_SERVER_CALLVOTE_RATIOS`                      | Specify a list of ratios. For example `Ban:-1 Kick:-1`                                                                                      |                          |
| `TM_SERVER_ALLOW_MAP_DOWNLOAD`                   | If `True`, allows players to download maps directly from the server.                                                                        | False                    |
| `TM_SERVER_AUTOSAVE_REPLAYS`                     | If `True`, the server will automatically save replays of each match.                                                                        | False                    |
| `TM_SERVER_AUTOSAVE_VALIDATION_REPLAYS`          | If `True`, the server will automatically save replays used for map validation.                                                              | False                    |
| `TM_SERVER_USE_CHANGING_VALIDATION_SEED`         | If `True`, uses a dynamic seed for server-side validation checks to enhance security.                                                       | False                    |
| `TM_SERVER_DISABLE_PROFILE_SKINS`                | If `True`, disables the use of custom player skins, enforcing default skins for all players.                                                | False                    |
| `TM_SERVER_CLIENTINPUTS_MAXLATENCY`              | Sets the maximum latency (in milliseconds) allowed for client inputs before the server simulates physics without new inputs. If the server doesn’t receive inputs within this time frame due to lag, it assumes the player's inputs remain unchanged or maintains their last known position. This setting directly impacts players with high ping, as exceeding this value can disrupt their gameplay or lead to inaccurate physics calculations. [^2]                                                     | 200                      |
| `TM_SYSTEM_CONNECTION_UPLOADRATE`                | The maximum upload speed (in bytes per second) the server can utilize.                                                                      | 102400                   |
| `TM_SYSTEM_CONNECTION_DOWNLOADRATE`              | The maximum download speed (in bytes per second) the server can utilize.                                                                    | 102400                   |
| `TM_SYSTEM_WORKERTHREADCOUNT`                    | Specifies the number of CPU threads that the server can use to perform its tasks.[^2]                                                       | 2                        |
| `TM_SYSTEM_PACKETASSEMBLY_MULTITHREAD`           | If `True`, enables the server to assemble data packets using multiple threads for improved performance.[^2]                                 | True                     |
| `TM_SYSTEM_PACKETASSEMBLY_PACKETSPERFRAME`       | This setting determines how many smaller "heartbeat" packets the server sends per frame, containing only essential network information and player inputs. These packets are less costly for the server to send but offer limited benefits in improving gameplay performance. The impact of this setting can vary depending on the server’s configuration and network conditions, so it’s recommended to experiment with different values to find the optimal balance for your specific situation.[^2]                                     | 60                       |
| `TM_SYSTEM_PACKETASSEMBLY_FULLPACKETSPERFRAME`   | This setting defines how many full data packets the server prepares and sends to clients per frame. Each packet includes game mode options, checkpoint times, and other relevant data. Preparing these packets is resource-intensive because the server must analyze all changes since the last packet and decide what information to send to each player. If the setting is too low, it can create a "virtual ping," as players might experience an artificial delay in receiving updates. Therefore, it’s essential to balance this setting to optimize server performance and client experience without overloading the server.[^2]                            | 30                       |
| `TM_SYSTEM_DELAYEDVISUALS_S2C_SENDINGRATE`       | This setting determines the frequency at which the server sends player position data to all clients when CrudeExtrapolation is enabled. Adjusting this rate affects the visual display of opponents in the game. While a higher rate can make player movements appear smoother, it can also increase the server's bandwidth usage. If performance issues arise or optimization is needed, consider lowering this rate first, as the visual display of opponents is less critical than gameplay mechanics.[^2]                             | 32                       |
| `TM_SYSTEM_TRUSTCLIENTSIMU_C2S_SENDINGRATE`      | This setting controls how often clients send their physics simulation results and inputs to the server. A higher rate ensures smoother physics calculations by reducing the wait time for player inputs, leading to a more responsive game experience. However, this comes at the cost of increased server bandwidth usage and higher client CPU demand due to packet compression. A balance must be struck to optimize both gameplay quality and resource usage, as beyond a certain point, further increasing the rate yields minimal gameplay benefits while significantly increasing resource consumption.[^2]                      | 64                       |
| `TM_SYSTEM_FORCE_IP_ADDRESS`                     | Forces the server to bind to a specific IP address and port (e.g., `127.0.0.1:2350`).[^3]                                                   |                          |
| `TM_SYSTEM_BIND_IP_ADDRESS`                      | Specifies the IP address that the server should bind to for incoming connections.                                                           |                          |
| `TM_SYSTEM_USE_NAT_UPNP`                         | If `True`, allows the server to use NAT traversal via UPnP for better connectivity in complex network setups.                               |                          |
| `TM_SYSTEM_XMLRPC_ALLOWREMOTE`                   | If `True`, permits the server to accept external connections via XML-RPC for remote management and integration.                             | False[^4]                |
| `TM_SYSTEM_BLACKLIST_URL`                        | URL pointing to a remote blacklist of banned players, which the server uses to enforce bans.                                                |                          |
| `TM_SYSTEM_GUESTLIST_FILENAME`                   | The filename of the guest list, which contains users who are allowed special access or privileges on the server.                            |                          |
| `TM_SYSTEM_BLACKLIST_FILENAME`                   | The filename of the blacklist, containing the names of players who are banned from the server.                                              |                          |
| `TM_SYSTEM_DISABLE_COHERENCE_CHECKS`             | If `True`, disables the built-in anti-cheat measures, allowing more flexibility but less security.                                          | False                    |
| `TM_SYSTEM_DISABLE_REPLAY_RECORDING`             | If `True`, disables the recording of replays, potentially improving performance but losing gameplay records.                                | False                    |
| `TM_SYSTEM_SAVE_ALL_INDIVIDUAL_RUNS`             | If `True`, saves the replay of each individual player's run, useful for detailed analysis and reviews.                                      | False                    |
| `TM_DEDICATED_CFG`                               | Specifies a custom server configuration file to use instead of the default settings.                                                        | dedicated_cfg.txt        |
| `TM_GAME_SETTINGS`                               | Specifies a custom match settings file to use, allowing detailed control over game rules and behavior.                                      | default.txt              |
| `PROMETHEUS_ENABLE`                              | If `True`, enables the Prometheus exporter for monitoring the server, providing performance metrics and stats.                              | False                    |
| `PROMETHEUS_PORT`                                | The network port on which the Prometheus exporter listens for requests, used for gathering server metrics.                                  | 9000                     |
| `PROMETHEUS_SUPERADMIN_PASSWORD`                 | The SuperAdmin password required by the Prometheus exporter to authenticate and access the server metrics if the default was changed.       | SuperAdmin               |
| `PROMETHEUS_INTERVAL`                            | The frequency, in seconds, at which the Prometheus exporter collects metrics from the Trackmania server.                                    | 15                       |
[^1]: Default values are specific to this Docker image setup and may differ from those provided by the official TrackMania server from Ubisoft Nadeo.
[^2]: More information to this can be gathered from the Trackmania Wiki page about the [Dedicated Config](https://wiki.trackmania.io/en/dedicated-server/Usage/DedicatedConfig).
[^3]: If not set, the TrackMania server may report its internal Docker IP address to the master server, which can prevent external users from connecting to it.
[^4]: Setting this to `True` allows only other Docker containers, such as server controllers like EvoSC or PyPlanet, to connect to the XML-RPC interface, not public external connections.

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
