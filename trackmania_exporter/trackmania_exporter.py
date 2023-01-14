import prometheus_client
from prometheus_client import Gauge
from gbx import GbxRemote
import time
import os

# connect to xmlrpc
gbxremote = GbxRemote(host='127.0.0.1', port=5000, user='SuperAdmin', password=os.environ.get('PROMETHEUS_SUPERADMIN_PASSWORD', 'SuperAdmin'))

gbxconnected = False
while not gbxconnected:
    try:
        time.sleep(1)
        if gbxremote.connect():
            print('GBX connection established.')
            gbxconnected = True
        else:
            print('GBX connection refused or not ready yet.')
    except Exception as e:
        pass

# we don't need python internal metrics
prometheus_client.REGISTRY.unregister(prometheus_client.GC_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PLATFORM_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PROCESS_COLLECTOR)

# register trackmania metrics
TRACKMANIA_PLAYER_COUNT = Gauge('trackmania_player_count', 'Current player count by type.', ['type'])
TRACKMANIA_MODERATION_COUNT = Gauge('trackmania_moderation_count', 'Current players count being moderated by type.', ['type'])
TRACKMANIA_PLAYER_COUNT_MEAN = Gauge('trackmania_player_count_mean', 'The mean value of the player count.')
TRACKMANIA_SERVER_UPTIME = Gauge('trackmania_server_uptime', 'Time since the TrackMania server has started in seconds.')
TRACKMANIA_CONNECTION_COUNT = Gauge('trackmania_connection_count', 'Total connections made to the TrackMania server.')
TRACKMANIA_CONNECTION_TIME_MEAN = Gauge('trackmania_connection_time_mean', 'The mean value of the connection time in ms.')
TRACKMANIA_NET_RATE_RECV = Gauge('trackmania_net_rate_recv', 'Connection rate inbound in kbps.')
TRACKMANIA_NET_RATE_SEND = Gauge('trackmania_net_rate_send', 'Connection rate outbound in kbps.')
TRACKMANIA_MAPS_COUNT = Gauge('trackmania_maps_count', 'Amount of maps the server currently has loaded.')
TRACKMANIA_PLAYER_MAX = Gauge('trackmania_player_max', 'Max configured amount of players the server can hold.', ['type'])

# update function, to be called every 10 seconds
def update():
    response0 = gbxremote.callMethod('GetPlayerList', -1, 0)
    response1 = gbxremote.callMethod('GetBanList', -1, 0)
    response2 = gbxremote.callMethod('GetBlackList', -1, 0)
    response3 = gbxremote.callMethod('GetGuestList', -1, 0)
    response4 = gbxremote.callMethod('GetIgnoreList', -1, 0)
    response5 = gbxremote.callMethod('GetNetworkStats')
    response6 = gbxremote.callMethod('GetMapList', -1, 0)
    response7 = gbxremote.callMethod('GetMaxPlayers')
    response8 = gbxremote.callMethod('GetMaxSpectators')

    spectators = 0
    drivers = 0
    for player in list(response0[0]):
        flags = player['Flags']
        specStatus = player['SpectatorStatus']

        if (((flags >> 5) & 1) == 1):
            continue

        if (specStatus & 1):
            spectators += 1
        else:
            drivers += 1

    TRACKMANIA_PLAYER_COUNT.labels('online').set(spectators + drivers)
    TRACKMANIA_PLAYER_COUNT.labels('spectating').set(spectators)
    TRACKMANIA_PLAYER_COUNT.labels('driving').set(drivers)

    TRACKMANIA_MODERATION_COUNT.labels('banned').set(len(response1[0]))
    TRACKMANIA_MODERATION_COUNT.labels('blacklisted').set(len(response2[0]))
    TRACKMANIA_MODERATION_COUNT.labels('guestlisted').set(len(response3[0]))
    TRACKMANIA_MODERATION_COUNT.labels('ignored').set(len(response4[0]))

    TRACKMANIA_PLAYER_COUNT_MEAN.set(response5[0]['MeanNbrPlayer'])
    TRACKMANIA_SERVER_UPTIME.set(response5[0]['Uptime'])
    TRACKMANIA_CONNECTION_COUNT.set(response5[0]['NbrConnection'])
    TRACKMANIA_CONNECTION_TIME_MEAN.set(response5[0]['MeanConnectionTime'])
    TRACKMANIA_NET_RATE_RECV.set(response5[0]['RecvNetRate'])
    TRACKMANIA_NET_RATE_SEND.set(response5[0]['SendNetRate'])

    TRACKMANIA_MAPS_COUNT.set(len(response6[0]))
    TRACKMANIA_PLAYER_MAX.labels('players').set(response7[0]['CurrentValue'])
    TRACKMANIA_PLAYER_MAX.labels('spectators').set(response8[0]['CurrentValue'])

if __name__ == '__main__':
    prometheus_client.start_http_server(int(os.environ.get('PROMETHEUS_PORT', '9000')))
    # update loop
    while True:
        update()
        time.sleep(int(os.environ.get('PROMETHEUS_INTERVAL', '15')))
