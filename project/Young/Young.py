import sys
sys.path.insert(0, '..')

from twisted.application import service, internet
from BaseServer import *

TCP_PORT = 12452
SERVER_NAME = "Young"
peers = {'Gasol':('localhost', 12450),'Farmar':('localhost', 12453) }
factory = ServerProtocolFactory(SERVER_NAME, peers)

application = service.Application("twitterServer")
internet.TCPServer(TCP_PORT, factory).setServiceParent(application)