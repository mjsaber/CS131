import sys,os
import datetime
import re
import time

from twisted.internet import reactor
from twisted.python import log
from twisted.protocols.basic import LineReceiver
from twisted.internet.protocol import Factory,Protocol
from twisted.internet.endpoints import TCP4ClientEndpoint
from twisted.internet.defer import Deferred

tweets = '{"results":[{"location":"Ever","profile_image_url":"http://a3.twimg.com/profile_images/524342107/avatar_normal.jpg","created_at":"Fri, 16 Nov 2012 07:38:34 +0000","from_user":"C_86","to_user_id":null,"text":"RT @ionmobile: @SteelCityHacker everywhere but nigeria // LMAO!","id":5704386230,"from_user_id":34011528,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://socialscope.net&quot; rel=&quot;nofollow&quot;&gt;SocialScope&lt;/a&gt;"},{"location":"Ever","profile_image_url":"http://a3.twimg.com/profile_images/524342107/avatar_normal.jpg","created_at":"Fri, 16 Nov 2012 07:37:16 +0000","from_user":"C_86","to_user_id":null,"text":"RT @ionmobile: 25 minutes left! RT Who will win????? Follow @ionmobile","id":5704370354,"from_user_id":34011528,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://socialscope.net&quot; rel=&quot;nofollow&quot;&gt;SocialScope&lt;/a&gt;"}],"max_id":5704386230,"since_id":5501341295,"refresh_url":"?since_id=5704386230&q=","next_page":"?page=2&max_id=5704386230&rpp=2&geocode=27.5916%2C86.564%2C100.0km&q=","results_per_page":2,"page":1,"completed_in":0.090181,"warning":"adjusted since_id to 5501341295 (2012-11-07 07:00:00 UTC), requested since_id was older than allowed -- since_id removed for pagination.","query":""}'

def writeLog(p, msg, factory):
	timeStr = datetime.datetime.now().strftime("%Y-%m-%d,%H:%M:%S.%f")
	factory.fp.write(timeStr + " " + msg)

def floodToPeers(p, line):
    p.sendLine(line)

def reconnect(p, host, port, peer, peerMessage, factory):
    endpoint = TCP4ClientEndpoint(reactor, host, port)
    d = endpoint.connect(factory)
    d.addCallback(floodToPeers, peerMessage)
    d.addCallback(writeLog, 'Connected to <' + peer + '>\n',factory)
    d.addErrback(reconnect, host, port, peer, peerMessage, factory)

class ServerProtocol(LineReceiver):

	def connectionMade(self):
		print "Got new client!"
		self.factory.clients.append(self)
		self.serverName = self.factory.name

	def connectionLost(self, reason):
		print "Lost a client!"
		self.factory.clients.remove(self)

	def lineReceived(self, line):
		# write input to log
		writeLog("suc","Message received: " + line +'\n',self.factory)
		
		args=line.strip().split()
		
		if len(args)== 0:
			return
		else:
			if args[0] == "IAMAT" and len(args) == 4:
			
				# parse the message
				client_ID = args[1]
				client_location = args[2]
				client_time = float(args[3])
				
				time_diff = time.time() - client_time
				time_str=""
				if time_diff > 0:
					time_str = "+" + repr(time_diff)
				else:
					time_str = repr(time_diff)
				response = "AT " + self.serverName + " " + time_str + " " +' '.join(args[1:])
				
				# add this info to the dictionary
				self.factory.users[client_ID] = (self.serverName, time_str, client_location, client_time)
				
				# write output to log				
				writeLog("suc","Message sent: " + response +'\n',self.factory)
				self.transport.write(response + "\n")

				for peer in self.factory.peers.keys():
					host,port = self.factory.peers[peer]
					writeLog('success', 'IAMAT: Flooding information to peer: <' + peer+'>\n', self.factory)
					reconnect('success', host, port, peer, response, self.factory)
					writeLog('success', 'IAMAT: Connecting to peer: <'+ peer + '> ' + host + ':' + str(port) + '\n', self.factory)

			elif args[0] == "WHATSAT" and len(args) == 4:
			
				client_ID = args[1]
				radius = int(args[2])
				bound = int(args[3])
				if bound > 100:
					bound = 100
					self.transport.write("Show at most 100 tweets\n")

				if self.factory.users.has_key(client_ID):
					server_name, time_str, location, saved_time = self.factory.users[client_ID]

					response = "AT " + server_name + " " + time_str + " " +client_ID+" "+location+" "+repr(saved_time)
					self.transport.write(response + "\n")
					self.transport.write(tweets+"\n")
					writeLog("suc","Received from <" + server_name +">: " + response+"\n", self.factory)
				else:
					self.transport.write("WHATSAT: No such client found\n")
				
			elif args[0] == "AT" and len(args) == 6:

				server_name,time_str,client_ID,location,client_time=args[1:]
				writeLog('suc', 'FROM <'+server_name+'>: Received user information for <'+ client_ID +'>\n', self.factory)

				isNew = True
				if self.factory.users.has_key(client_ID):
					saved_time = self.factory.users[client_ID][-1]
					if saved_time >= client_time:
						isNew = False
				if isNew:
					self.factory.users[client_ID] = (server_name, time_str, location, client_time)
					for peer in self.factory.peers.keys():
						host,port = self.factory.peers[peer]
						writeLog('success', 'AT: Flooding information to peer: <' + peer+'>\n', self.factory)
						response = "AT " + self.serverName + " "+' '.join(args[2:])
						reconnect('success', host, port, peer, response, self.factory)
						writeLog('success', 'AT: Connecting to peer: <'+ peer + '> ' + host + ':' + str(port) + '\n', self.factory)
							
			else:
				# unknown message received
				response = "? " + line + '\n'
				self.transport.write(response)					
			
class ServerProtocolFactory(Factory):
	protocol = ServerProtocol	
	def __init__(self,name, peers):
		self.name = name
		self.file = name + ".log"
		self.clients = []
		self.users = {}
		self.peers = peers

	def startFactory(self):
		self.fp = open(self.file, 'a')

	def stopFactory(self):
		self.fp.close()
