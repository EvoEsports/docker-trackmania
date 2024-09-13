#!/bin/bash

set -e

echo "[*] Evo Esports Trackmania Docker Image"

# we don't want to start the server with root permissions
if [ "$1" = './TrackmaniaServer' ] && [ "$(id -u)" = '0' ]; then
	chown -R trackmania /server/TrackmaniaServer
	exec su-exec trackmania "$0" "$@"
fi

if [ "$TM_DEDICATED_CFG" ]; then
	DC=$TM_DEDICATED_CFG
elif [ "$DEDICATED_CONFIG" ]; then
	DC=$DEDICATED_CONFIG
fi

if [ "$TM_GAME_SETTINGS" ]; then
	GS=$TM_GAME_SETTINGS
elif [ "$GAME_SETTINGS" ]; then
	GS=$GAME_SETTINGS
fi

# we also want to have dedicated_cfg, game_settings, and noDaemon added, no matter what the user specifies
if [ "$1" = './TrackmaniaServer' ]; then
    set -- "$@" /dedicated_cfg="${DC:-dedicated_cfg.txt}" /game_settings=MatchSettings/"${GS:-default.txt}" /noDaemon
fi

# also we need to populate the config
if [ "$1" = './TrackmaniaServer' ]; then
	if [ -z "$CONFIG_POPULATION_DISABLED" ]; then
		[ ! -f /server/UserData/Config/"${DC:-dedicated_cfg.txt}" ] && cp /server/UserData/Config/dedicated_cfg.default.txt /server/UserData/Config/"${DC:-dedicated_cfg.txt}"

		configs=()
		# required settings
		configs+=("'/dedicated/system_config/server_port' -v \"${TM_SYSTEM_SERVER_PORT:-2350}\"")
		configs+=("'/dedicated/system_config/xmlrpc_port' -v \"${TM_SYSTEM_XMLRPC_PORT:-5000}\"")
		#### deprecate soon
		if [ "$TM_MASTERSERVER_LOGIN" ]; then
			configs+=("'/dedicated/masterserver_account/login' -v \"${TM_MASTERSERVER_LOGIN}\"");
		elif [ "$MASTER_LOGIN" ]; then
			configs+=("'/dedicated/masterserver_account/login' -v \"${MASTER_LOGIN}\""); echo "[-] MASTER_LOGIN will be removed soon. Please use TM_MASTERSERVER_LOGIN instead.";
		fi

		if [ "$TM_MASTERSERVER_PASSWORD" ]; then
			# shellcheck disable=SC2016
			TM_MASTERSERVER_PASSWORD=$(echo "${TM_MASTERSERVER_PASSWORD}" | sed -e 's/\$/\\\$/g' -e 's/`/\\`/g');
			configs+=("'/dedicated/masterserver_account/password' -v \"${TM_MASTERSERVER_PASSWORD}\"");
		elif [ "$MASTER_PASSWORD" ]; then
			# shellcheck disable=SC2016
			MASTER_PASSWORD=$(echo "${MASTER_PASSWORD}" | sed -e 's/\$/\\\$/g' -e 's/`/\\`/g');
			configs+=("'/dedicated/masterserver_account/password' -v \"${MASTER_PASSWORD}\""); echo "[-] MASTER_PASSWORD will be removed soon. Please use TM_MASTERSERVER_PASSWORD instead.";
		fi

		if [ "$PLAYERS_MAX" ]; then configs+=("'/dedicated/server_options/max_players' -v \"${PLAYERS_MAX}\""); echo "[-] PLAYERS_MAX will be removed soon. Please use TM_SERVER_MAX_PLAYERS instead."; fi
		if [ "$PLAYERS_PASSWORD" ]; then configs+=("'/dedicated/server_options/password' -v \"${PLAYERS_PASSWORD}\""); echo "[-] PLAYERS_PASSWORD will be removed soon. Please use TM_SERVER_PASSWORD instead."; fi
		if [ "$SPECTATORS_MAX" ]; then configs+=("'/dedicated/server_options/max_spectators' -v \"${SPECTATORS_MAX}\""); echo "[-] SPECTATORS_MAX will be removed soon. Please use TM_SERVER_MAX_SPECTATORS instead."; fi
		if [ "$SPECTATORS_PASSWORD" ]; then configs+=("'/dedicated/server_options/password_spectator' -v \"${SPECTATORS_PASSWORD}\""); echo "[-] SPECTATORS_PASSWORD will be removed soon. Please use TM_SERVER_PASSWORD_SPECTATOR instead."; fi
		if [ "$ALLOW_MAP_DOWNLOAD" ]; then configs+=("'/dedicated/server_options/allow_map_download' -v \"${ALLOW_MAP_DOWNLOAD}\""); echo "[-] ALLOW_MAP_DOWNLOAD will be removed soon. Please use TM_SERVER_ALLOW_MAP_DOWNLOAD instead."; fi
		if [ "$AUTOSAVE_REPLAYS" ]; then configs+=("'/dedicated/server_options/autosave_replays' -v \"${AUTOSAVE_REPLAYS}\""); echo "[-] AUTOSAVE_REPLAYS will be removed soon. Please use TM_SERVER_AUTOSAVE_REPLAYS instead."; fi
		if [ "$AUTOSAVE_VALIDATION_REPLAYS" ]; then configs+=("'/dedicated/server_options/autosave_validation_replays' -v \"${AUTOSAVE_VALIDATION_REPLAYS}\""); echo "[-] AUTOSAVE_VALIDATION_REPLAYS will be removed soon. Please use TM_SERVER_AUTOSAVE_VALIDATION_REPLAYS instead."; fi
		if [ "$CONNECTION_UPLOADRATE" ]; then configs+=("'/dedicated/system_config/connection_uploadrate' -v \"${CONNECTION_UPLOADRATE}\""); echo "[-] CONNECTION_UPLOADRATE will be removed soon. Please use TM_SYSTEM_CONNECTION_UPLOADRATE instead."; fi
		if [ "$CONNECTION_DOWNLOADRATE" ]; then configs+=("'/dedicated/system_config/connection_downloadrate' -v \"${CONNECTION_DOWNLOADRATE}\""); echo "[-] CONNECTION_DOWNLOADRATE will be removed soon. Please use TM_SYSTEM_CONNECTION_DOWNLOADRATE instead."; fi
		if [ "$WORKERTHREADCOUNT" ]; then configs+=("'/dedicated/system_config/workerthreadcount' -v \"${WORKERTHREADCOUNT}\""); echo "[-] WORKERTHREADCOUNT will be removed soon. Please use TM_SYSTEM_WORKERTHREADCOUNT instead."; fi
		if [ "$PACKETASSEMBLY_MULTITHREAD" ]; then configs+=("'/dedicated/system_config/packetassembly_multithread' -v \"${PACKETASSEMBLY_MULTITHREAD}\""); echo "[-] PACKETASSEMBLY_MULTITHREAD will be removed soon. Please use TM_SYSTEM_PACKETASSEMBLY_MULTITHREAD instead."; fi
		if [ "$FORCE_IP_ADDRESS" ]; then configs+=("'/dedicated/system_config/force_ip_address' -v \"${FORCE_IP_ADDRESS}\""); echo "[-] FORCE_IP_ADDRESS will be removed soon. Please use TM_SYSTEM_FORCE_IP_ADDRESS instead."; fi
		if [ "$XMLRPC_ALLOWREMOTE" ]; then configs+=("'/dedicated/system_config/xmlrpc_allowremote' -v \"${XMLRPC_ALLOWREMOTE}\""); echo "[-] XMLRPC_ALLOWREMOTE will be removed soon. Please use TM_SYSTEM_XMLRPC_ALLOWREMOTE instead."; fi
		if [ "$DISABLE_COHERENCE_CHECKS" ]; then configs+=("'/dedicated/system_config/disable_coherence_checks' -v \"${DISABLE_COHERENCE_CHECKS}\""); echo "[-] DISABLE_COHERENCE_CHECKS will be removed soon. Please use TM_SYSTEM_DISABLE_COHERENCE_CHECKS instead."; fi
		if [ "$DISABLE_REPLAY_RECORDING" ]; then configs+=("'/dedicated/system_config/disable_replay_recording' -v \"${DISABLE_REPLAY_RECORDING}\""); echo "[-] DISABLE_REPLAY_RECORDING will be removed soon. Please use TM_SYSTEM_DISABLE_REPLAY_RECORDING instead."; fi
		if [ "$SAVE_ALL_INDIVIDUAL_RUNS" ]; then configs+=("'/dedicated/system_config/save_all_individual_runs' -v \"${SAVE_ALL_INDIVIDUAL_RUNS}\""); echo "[-] SAVE_ALL_INDIVIDUAL_RUNS will be removed soon. Please use TM_SYSTEM_SAVE_ALL_INDIVIDUAL_RUNS instead."; fi
		#### deprecate soon
		# /dedicated/authorization_levels/*
		if [ "$TM_AUTHORIZATION_SUPERADMIN_PASSWORD" ]; then configs+=("'/dedicated/authorization_levels/level[1]/password' -v \"${TM_AUTHORIZATION_SUPERADMIN_PASSWORD}\""); fi
		if [ "$TM_AUTHORIZATION_ADMIN_PASSWORD" ]; then configs+=("'/dedicated/authorization_levels/level[2]/password' -v \"${TM_AUTHORIZATION_ADMIN_PASSWORD}\""); fi
		if [ "$TM_AUTHORIZATION_USER_PASSWORD" ]; then configs+=("'/dedicated/authorization_levels/level[3]/password' -v \"${TM_AUTHORIZATION_USER_PASSWORD}\""); fi
		# /dedicated/server_options/*
		if [ "$TM_SERVER_COMMENT" ]; then configs+=("'/dedicated/server_options/login' -v \"${TM_SERVER_COMMENT}\""); fi
		if [ "$TM_SERVER_MAX_PLAYERS" ]; then configs+=("'/dedicated/server_options/max_players' -v \"${TM_SERVER_MAX_PLAYERS}\""); fi
		if [ "$TM_SERVER_PASSWORD" ]; then configs+=("'/dedicated/server_options/password' -v \"${TM_SERVER_PASSWORD}\""); fi
		if [ "$TM_SERVER_MAX_SPECTATORS" ]; then configs+=("'/dedicated/server_options/max_spectators' -v \"${TM_SERVER_MAX_SPECTATORS}\""); fi
		if [ "$TM_SERVER_PASSWORD_SPECTATOR" ]; then configs+=("'/dedicated/server_options/password_spectator' -v \"${TM_SERVER_PASSWORD_SPECTATOR}\""); fi
		if [ "$TM_SERVER_KEEP_PLAYER_SLOTS" ]; then configs+=("'/dedicated/server_options/keep_player_slots' -v \"${TM_SERVER_KEEP_PLAYER_SLOTS}\""); fi
		if [ "$TM_SERVER_CALLVOTE_TIMEOUT" ]; then configs+=("'/dedicated/server_options/callvote_timeout' -v \"${TM_SERVER_CALLVOTE_TIMEOUT}\""); fi
		if [ "$TM_SERVER_CALLVOTE_RATIO" ]; then configs+=("'/dedicated/server_options/callvote_ratio' -v \"${TM_SERVER_CALLVOTE_RATIO}\""); fi
		if [ "$TM_SERVER_ALLOW_MAP_DOWNLOAD" ]; then configs+=("'/dedicated/server_options/allow_map_download' -v \"${TM_SERVER_ALLOW_MAP_DOWNLOAD}\""); fi
		if [ "$TM_SERVER_AUTOSAVE_REPLAYS" ]; then configs+=("'/dedicated/server_options/autosave_replays' -v \"${TM_SERVER_AUTOSAVE_REPLAYS}\""); fi
		if [ "$TM_SERVER_AUTOSAVE_VALIDATION_REPLAYS" ]; then configs+=("'/dedicated/server_options/autosave_validation_replays' -v \"${TM_SERVER_AUTOSAVE_VALIDATION_REPLAYS}\""); fi
		if [ "$TM_SERVER_USE_CHANGING_VALIDATION_SEED" ]; then configs+=("'/dedicated/server_options/use_changing_validation_seed' -v \"${TM_SERVER_USE_CHANGING_VALIDATION_SEED}\""); fi
		if [ "$TM_SERVER_DISABLE_HORNS" ]; then configs+=("'/dedicated/server_options/disable_horns' -v \"${TM_SERVER_DISABLE_HORNS}\""); fi
		if [ "$TM_SERVER_DISABLE_PROFILE_SKINS" ]; then configs+=("'/dedicated/server_options/disable_profile_skins' -v \"${TM_SERVER_DISABLE_PROFILE_SKINS}\""); fi
		if [ "$TM_SERVER_CLIENTINPUTS_MAXLATENCY" ]; then configs+=("'/dedicated/server_options/clientinputs_maxlatency' -v \"${TM_SERVER_CLIENTINPUTS_MAXLATENCY}\""); fi
		# /dedicated/system_config/*
		if [ "$TM_SYSTEM_CONNECTION_UPLOADRATE" ]; then configs+=("'/dedicated/system_config/connection_uploadrate' -v \"${TM_SYSTEM_CONNECTION_UPLOADRATE}\""); fi
		if [ "$TM_SYSTEM_CONNECTION_DOWNLOADRATE" ]; then configs+=("'/dedicated/system_config/connection_downloadrate' -v \"${TM_SYSTEM_CONNECTION_DOWNLOADRATE}\""); fi
		if [ "$TM_SYSTEM_WORKERTHREADCOUNT" ]; then configs+=("'/dedicated/system_config/workerthreadcount' -v \"${TM_SYSTEM_WORKERTHREADCOUNT}\""); fi
		if [ "$TM_SYSTEM_PACKETASSEMBLY_MULTITHREAD" ]; then configs+=("'/dedicated/system_config/packetassembly_multithread' -v \"${TM_SYSTEM_PACKETASSEMBLY_MULTITHREAD}\""); fi
		if [ "$TM_SYSTEM_PACKETASSEMBLY_PACKETSPERFRAME" ]; then configs+=("'/dedicated/system_config/packetassembly_packetsperframe' -v \"${TM_SYSTEM_PACKETASSEMBLY_PACKETSPERFRAME}\""); fi
		if [ "$TM_SYSTEM_PACKETASSEMBLY_FULLPACKETSPERFRAME" ]; then configs+=("'/dedicated/system_config/packetassembly_fullpacketsperframe' -v \"${TM_SYSTEM_PACKETASSEMBLY_FULLPACKETSPERFRAME}\""); fi
		if [ "$TM_SYSTEM_DELAYEDVISUALS_S2C_SENDINGRATE" ]; then configs+=("'/dedicated/system_config/delayedvisuals_s2c_sendingrate' -v \"${TM_SYSTEM_DELAYEDVISUALS_S2C_SENDINGRATE}\""); fi
		if [ "$TM_SYSTEM_TRUSTCLIENTSIMU_C2S_SENDINGRATE" ]; then configs+=("'/dedicated/system_config/trustclientsimu_c2s_sendingrate' -v \"${TM_SYSTEM_TRUSTCLIENTSIMU_C2S_SENDINGRATE}\""); fi
		if [ "$TM_SYSTEM_FORCE_IP_ADDRESS" ]; then configs+=("'/dedicated/system_config/force_ip_address' -v \"${TM_SYSTEM_FORCE_IP_ADDRESS}\""); fi
		if [ "$TM_SYSTEM_BIND_IP_ADDRESS" ]; then configs+=("'/dedicated/system_config/bind_ip_address' -v \"${TM_SYSTEM_BIND_IP_ADDRESS}\""); fi
		if [ "$TM_SYSTEM_USE_NAT_UPNP" ]; then configs+=("'/dedicated/system_config/use_nat_upnp' -v \"${TM_SYSTEM_USE_NAT_UPNP}\""); fi
		if [ "$TM_SYSTEM_XMLRPC_ALLOWREMOTE" ]; then configs+=("'/dedicated/system_config/xmlrpc_allowremote' -v \"${TM_SYSTEM_XMLRPC_ALLOWREMOTE}\""); fi
		if [ "$TM_SYSTEM_BLACKLIST_URL" ]; then configs+=("'/dedicated/system_config/blacklist_url' -v \"${TM_SYSTEM_BLACKLIST_URL}\""); fi
		if [ "$TM_SYSTEM_GUESTLIST_FILENAME" ]; then configs+=("'/dedicated/system_config/guestlist_filename' -v \"${TM_SYSTEM_GUESTLIST_FILENAME}\""); fi
		if [ "$TM_SYSTEM_BLACKLIST_FILENAME" ]; then configs+=("'/dedicated/system_config/blacklist_filename' -v \"${TM_SYSTEM_BLACKLIST_FILENAME}\""); fi
		if [ "$TM_SYSTEM_DISABLE_COHERENCE_CHECKS" ]; then configs+=("'/dedicated/system_config/disable_coherence_checks' -v \"${TM_SYSTEM_DISABLE_COHERENCE_CHECKS}\""); fi
		if [ "$TM_SYSTEM_DISABLE_REPLAY_RECORDING" ]; then configs+=("'/dedicated/system_config/disable_replay_recording' -v \"${TM_SYSTEM_DISABLE_REPLAY_RECORDING}\""); fi
		if [ "$TM_SYSTEM_SAVE_ALL_INDIVIDUAL_RUNS" ]; then configs+=("'/dedicated/system_config/save_all_individual_runs' -v \"${TM_SYSTEM_SAVE_ALL_INDIVIDUAL_RUNS}\""); fi
		if [ "$TM_SYSTEM_USE_PROXY" ]; then configs+=("'/dedicated/system_config/use_proxy' -v \"${TM_SYSTEM_USE_PROXY}\""); fi
		if [ "$TM_SYSTEM_PROXY_URL" ]; then configs+=("'/dedicated/system_config/proxy_url' -v \"${TM_SYSTEM_PROXY_URL}\""); fi

		# If TM_SERVER_NAME_OVERWRITE is set, overwrite the server name on each restart of the container. If unset, only set the name if empty in config file.
		hostname=$(uname -n)
		if [ "$TM_SERVER_NAME_OVERWRITE" = true ]; then
			if [ "$TM_SERVER_NAME" ]; then
				echo "[-] Server name not present in config, using \"${TM_SERVER_NAME:-Docker TrackMania Server ${hostname}}\" as servername!"
				configs+=("'/dedicated/server_options/name' -v \"${TM_SERVER_NAME:-Docker TrackMania Server ${hostname}}\"")
			elif [ "$SERVER_NAME" ]; then
			    echo "SERVER_NAME will be removed soon. Please use TM_SERVER_NAME"
				echo "[-] Server name not present in config, using \"${SERVER_NAME:-Docker TrackMania Server ${hostname}}\" as servername!"
				configs+=("'/dedicated/server_options/name' -v \"${SERVER_NAME:-Docker TrackMania Server ${hostname}}\"")
			fi
		else
			if [ -z "$(xml sel -t -v '/dedicated/server_options/name' /server/UserData/Config/"${DC:-dedicated_cfg.txt}")" ]; then
				if [ "$TM_SERVER_NAME" ]; then
					echo "[-] Server name not present in config, using \"${TM_SERVER_NAME:-Docker TrackMania Server ${hostname}}\" as servername!"
					configs+=("'/dedicated/server_options/name' -v \"${TM_SERVER_NAME:-Docker TrackMania Server ${hostname}}\"")
				elif [ "$SERVER_NAME" ]; then
				    echo "SERVER_NAME will be removed soon. Please use TM_SERVER_NAME"
					echo "[-] Server name not present in config, using \"${SERVER_NAME:-Docker TrackMania Server ${hostname}}\" as servername!"
					configs+=("'/dedicated/server_options/name' -v \"${SERVER_NAME:-Docker TrackMania Server ${hostname}}\"")
				fi
			fi
		fi

		# write config parameters into config file
		for (( i = 0; i < ${#configs[@]} ; i++ )); do
			eval xml ed -L -P -u "${configs[$i]}" /server/UserData/Config/"${DC:-dedicated_cfg.txt}"
		done

		# write voteratios
		if [ "$TM_SERVER_CALLVOTE_RATIOS" ]; then
		    IFS=' ' read -r -a voteratio_array <<< "$TM_SERVER_CALLVOTE_RATIOS"

		    for voteratio in "${voteratio_array[@]}"; do
		        command="${voteratio%%:*}"
		        ratio="${voteratio#*:}"

		        xmlstarlet ed -L -P \
		            -u "/dedicated/server_options/callvote_ratios/voteratio[@command='${command}']/@ratio" -v "${ratio}" \
		            -s "/dedicated/server_options/callvote_ratios[not(voteratio[@command='${command}'])]" -t elem -n "voteratio" -v "" \
		            -i "/dedicated/server_options/callvote_ratios/voteratio[not(@command)]" -t attr -n "command" -v "${command}" \
		            -i "/dedicated/server_options/callvote_ratios/voteratio[@command='${command}' and not(@ratio)]" -t attr -n "ratio" -v "${ratio}" \
		            /server/UserData/Config/"${DC:-dedicated_cfg.txt}"
		    done

		    filter_expr=""
		    for voteratio in "${voteratio_array[@]}"; do
		        command="${voteratio%%:*}"
		        filter_expr+="not(@command='${command}') and "
		    done

		    filter_expr="${filter_expr% and }"
		    xmlstarlet ed -L -P \
		        -d "/dedicated/server_options/callvote_ratios/voteratio[${filter_expr}]" \
		        /server/UserData/Config/"${DC:-dedicated_cfg.txt}"
		fi

		# finally populate the MatchSettings file
		[ ! -f /server/UserData/Maps/MatchSettings/default.txt ] && cp /server/UserData/Maps/MatchSettings/example.txt /server/UserData/Maps/MatchSettings/default.txt
	else
		echo "[!] Config population disabled, ignoring most environment variables passed through Docker."
	fi
fi

# fire up the promehteus exporter
if [ "$PROMETHEUS_ENABLE" = true ]; then
    echo "[+] Using Prometheus exporter."
    /usr/local/bin/trackmania_exporter &
fi

# fire up the actual TM server
exec "$@"