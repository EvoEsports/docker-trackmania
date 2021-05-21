#!/bin/bash

set -e

# we don't want to start the server with root permissions
if [ "$1" = './TrackmaniaServer' -a "$(id -u)" = '0' ]; then
	chown -R trackmania /server/TrackmaniaServer
	exec su-exec trackmania "$0" "$@"
fi

# we also want to have dedicated_cfg, game_settings, and noDaemon added, no matter what the user specifies
if [ "$1" = './TrackmaniaServer' ]; then
    set -- "$@" /dedicated_cfg=${DEDICATED_CFG:-dedicated_cfg.txt} /game_settings=MatchSettings/${GAME_SETTINGS:-default.txt} /noDaemon
fi

# also we need to populate the config
if [ "$1" = './TrackmaniaServer' ]; then
	# if no dedicated_cfg.txt is present, copy the defaults and create one
	[ ! -f /server/UserData/Config/dedicated_cfg.txt ] && cp /server/UserData/Config/dedicated_cfg.default.txt /server/UserData/Config/dedicated_cfg.txt

	# password escape workaround
	MASTER_PASSWORD=$(echo ${MASTER_PASSWORD} | sed -e 's/\$/\\\\$/g' -e 's/`/\\`/g')

	configs=()
	# required settings
	configs+=("'/dedicated/masterserver_account/login' -v \"${MASTER_LOGIN}\"")
	configs+=("'/dedicated/masterserver_account/password' -v \"${MASTER_PASSWORD}\"")
	configs+=("'/dedicated/system_config/server_port' -v \"2350\"")
	configs+=("'/dedicated/system_config/xmlrpc_port' -v \"5000\"")
	# optional settings
	if [ "$PLAYERS_MAX" ]; then configs+=("'/dedicated/server_options/max_players' -v \"${PLAYERS_MAX}\""); fi
	if [ "$PLAYERS_PASSWORD" ]; then configs+=("'/dedicated/server_options/password' -v \"${PLAYERS_PASSWORD}\""); fi
	if [ "$SPECTATORS_MAX" ]; then configs+=("'/dedicated/server_options/max_spectators' -v \"${SPECTATORS_MAX}\""); fi
	if [ "$SPECTATORS_PASSWORD" ]; then configs+=("'/dedicated/server_options/password_spectator' -v \"${SPECTATORS_PASSWORD}\""); fi
	if [ "$ALLOW_MAP_DOWNLOAD" ]; then configs+=("'/dedicated/server_options/allow_map_download' -v \"${ALLOW_MAP_DOWNLOAD}\""); fi
	if [ "$AUTOSAVE_REPLAYS" ]; then configs+=("'/dedicated/server_options/autosave_replays' -v \"${AUTOSAVE_REPLAYS}\""); fi
	if [ "$AUTOSAVE_VALIDATION_REPLAYS" ]; then configs+=("'/dedicated/server_options/autosave_validation_replays' -v \"${AUTOSAVE_VALIDATION_REPLAYS}\""); fi
	if [ "$CONNECTION_UPLOADRATE" ]; then configs+=("'/dedicated/system_config/connection_uploadrate' -v \"${CONNECTION_UPLOADRATE}\""); fi
	if [ "$CONNECTION_DOWNLOADRATE" ]; then configs+=("'/dedicated/system_config/connection_downloadrate' -v \"${CONNECTION_DOWNLOADRATE}\""); fi
	if [ "$WORKERTHREADCOUNT" ]; then configs+=("'/dedicated/system_config/workerthreadcount' -v \"${WORKERTHREADCOUNT}\""); fi
	if [ "$PACKETASSEMBLY_MULTITHREAD" ]; then configs+=("'/dedicated/system_config/packetassembly_multithread' -v \"${PACKETASSEMBLY_MULTITHREAD}\""); fi
	if [ "$FORCE_IP_ADDRESS" ]; then configs+=("'/dedicated/system_config/force_ip_address' -v \"${FORCE_IP_ADDRESS}\""); fi
	if [ "$XMLRPC_ALLOWREMOTE" ]; then configs+=("'/dedicated/system_config/xmlrpc_allowremote' -v \"${XMLRPC_ALLOWREMOTE}\""); fi
	if [ "$DISABLE_COHERENCE_CHECKS" ]; then configs+=("'/dedicated/system_config/disable_coherence_checks' -v \"${DISABLE_COHERENCE_CHECKS}\""); fi
	if [ "$DISABLE_REPLAY_RECORDING" ]; then configs+=("'/dedicated/system_config/disable_replay_recording' -v \"${DISABLE_REPLAY_RECORDING}\""); fi
	if [ "$SAVE_ALL_INDIVIDUAL_RUNS" ]; then configs+=("'/dedicated/system_config/save_all_individual_runs' -v \"${SAVE_ALL_INDIVIDUAL_RUNS}\""); fi

	# figure out if a server name is already set and use that one
	if [ -z "$(xml sel -t -v '/dedicated/server_options/name' /server/UserData/Config/dedicated_cfg.txt)" ]
	then
		echo "INFO: Server name not present in config, using '\"${SERVER_NAME:-YetAnotherDockerServer}\"' as servername!"
		configs+=("'/dedicated/server_options/name' -v \"${SERVER_NAME:-YetAnotherDockerServer}\"")
	fi

	# write config parameters into config file
	for (( i = 0; i < ${#configs[@]} ; i++ )); do
		eval xml ed -L -P -u ${configs[$i]} /server/UserData/Config/dedicated_cfg.txt
	done

	# finally populate the MatchSettings file
	[ ! -f /server/UserData/Maps/MatchSettings/default.txt ] && cp /server/UserData/Maps/MatchSettings/example.txt /server/UserData/Maps/MatchSettings/default.txt
fi

exec "$@"
