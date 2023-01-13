import socket
from xmlrpc.client import loads as xmlloads
from xmlrpc.client import dumps as xmldumps
from signal import signal, SIGPIPE, SIG_DFL

signal(SIGPIPE,SIG_DFL)

class GbxRemote():
    def __init__(self, host, port, user, password):
        self.connection_info = (host, port, user, password)

    def connect(self):
        try:
            host, port, user, password = self.connection_info
            self.handler = 0x80000000
            self.callback_enabled = False
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect((socket.gethostbyname(host), port))

            data = self.socket.recv(4)
            headerLength = data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24)

            header = self.socket.recv(headerLength)
            if not header.decode() == 'GBXRemote 2':
                print('Invalid header.')
                exit(0)

            self.callMethod('Authenticate', user, password)
            self.callMethod('SetApiVersion', '2013-04-16')
            self.callMethod('EnableCallbacks', False)
            return True
        except OSError as error:
            return False

    def _incHandler(self):
        self.handler += 1
        if self.handler > 0xFFFFFFFF:
            self.handler = 0x80000000

    def callMethod(self, method, *argv):
        handlerBytes = bytes([
            self.handler & 0xFF,
            (self.handler >> 8) & 0xFF,
            (self.handler >> 16) & 0xFF,
            (self.handler >> 24) & 0xFF])

        data = xmldumps(argv, method).encode('utf-8')
        packetLen = len(data)
        packet = bytes([
            packetLen & 0xFF,
            (packetLen >> 8) & 0xFF,
            (packetLen >> 16) & 0xFF,
            (packetLen >> 24) & 0xFF
        ])
        packet += handlerBytes
        packet += data

        self.socket.send(packet)

        header = self.socket.recv(8)
        size = header[0] | (header[1] << 8) | (header[2] << 16) | (header[3] << 24)
        responseHandler = header[4] | (header[5] << 8) | (header[6] << 16) | (header[7] << 24)
        if responseHandler != self.handler:
            print('Response handler does not match!')
            exit(0)

        response = self.socket.recv(size)
        while len(response) < size:
            response += self.socket.recv(size - len(response))
        params, func = xmlloads(response.decode('utf-8'))

        self._incHandler()
        if func is None:
            return params
        else:
            return (func, params)
