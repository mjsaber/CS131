"""The most basic chat protocol possible.

run me with twistd -y chatserver.py, and then connect with multiple
telnet clients to port 12450
"""
import sys
sys.path.insert(0, '..')
from twisted.application import service, internet
from BaseServer import *


TCP_PORT = 12454
SERVER_NAME = "Hill"
peers = {'Meeks':('localhost', 12451)}
factory = ServerProtocolFactory(SERVER_NAME, peers)

application = service.Application("twitterServer")
internet.TCPServer(TCP_PORT, factory).setServiceParent(application)

