from tornado.ioloop     import IOLoop
from tornado.web        import Application
from tornado.websocket  import WebSocketHandler
from tornado.httpserver import HTTPServer
from tornado.netutil    import bind_sockets
from logging            import getLogger, CRITICAL

class EchoApp( Application ):
    def __init__(self):
        Application.__init__( self, [("/", WSHandler)] )

class WSHandler( WebSocketHandler ):
    def allow_draft76( self ):
        return False

    def on_message( self, message ):
        self.write_message( message, binary=True )

if __name__ == "__main__":
    getLogger().setLevel( CRITICAL )

    server  = HTTPServer( EchoApp() )
    sockets = bind_sockets( 8000, backlog=768 )

    print "Tornado (1 worker)"

    server.add_sockets( sockets )
    IOLoop.instance().start()
