#!/bin/bash
set -eu

# we don't want to start the server with root permissions
if [ "$1" = './TrackmaniaServer' -a "$(id -u)" = '0' ]; then
	chown -R trackmania /server/TrackmaniaServer
	exec su-exec trackmania "$0" "$@"
fi

# we also want to have dedicated_cfg, game_settings, and noDaemon added, no matter what the user specifies
if [ "$1" = './TrackmaniaServer' ]; then
    set -- "$@" /dedicated_cfg=${DEDICATED_CFG:-config.txt} /game_settings=MatchSettings/${GAME_SETTINGS:-default.txt} /noDaemon
fi

# also we need to populate the config
if [ "$1" = './TrackmaniaServer' ]; then
	# if no config.txt is present, copy the defaults and create one
	[ ! -f /server/UserData/Config/config.txt ] && cp /server/UserData/Config/dedicated_cfg.default.txt /server/UserData/Config/config.txt

	params=()
	params+=(-u '/dedicated/masterserver_account/login' -v "$MASTER_LOGIN")
	params+=(-u '/dedicated/masterserver_account/password' -v "$MASTER_PASSWORD")
	params+=(-u '/dedicated/system_config/server_port' -v "2350")
	params+=(-u '/dedicated/system_config/xmlrpc_port' -v "5000")

	# figure out if a server name is already set and use that one
	serverName=$(xml sel -t -v '/dedicated/server_options/name' /server/UserData/Config/config.txt)
	[[ -z $serverName ]] && params+=(-u '/dedicated/server_options/name' -v "$SERVER_NAME")

	# now populate it with docker envs and make sure the default ports are set
	xml ed -P ${params[@]} /server/UserData/Config/config.txt > /server/UserData/Config/config.txt.tmp
	mv /server/UserData/Config/config.txt.tmp /server/UserData/Config/config.txt
	# finally populate the MatchSettings file
	[ ! -f /server/UserData/Maps/MatchSettings/default.txt ] && cp /server/UserData/Maps/MatchSettings/example.txt /server/UserData/Maps/MatchSettings/default.txt
fi

exec "$@"