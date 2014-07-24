"""The most basic chat protocol possible.

run me with twistd -y chatserver.py, and then connect with multiple
telnet clients to port 12450
"""
import sys
sys.path.insert(0, '..')
from twisted.application import service, internet
from BaseServer import *


TCP_PORT = 12450
SERVER_NAME = "Gasol"
peers = {'Meeks':('localhost', 12451),'Young':('localhost', 12452) }
factory = ServerProtocolFactory(SERVER_NAME, peers)

application = service.Application("twitterServer")
internet.TCPServer(TCP_PORT, factory).setServiceParent(application)

