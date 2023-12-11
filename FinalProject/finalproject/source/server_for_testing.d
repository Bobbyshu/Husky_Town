module server_for_testing;

/**
 * This module represents a multi-threaded chat server.
 *
 * The server supports multiple client connections and handles
 * both text messages and file transfers. It also manages XY coordinates
 * for client positions in a game-like environment.
 */

// @file multithreaded_chat/server.d
//
// Start server first: rdmd server.d
import std.socket;
import std.stdio;
import core.thread.osthread;
import std.conv;
import std.algorithm;
import std.array;
import std.file;
import std.string;
import std.zlib;
import core.stdc.string;
import Packet : Packet;
import std.ascii;

// NOTE: Error checking code omitted.
//       Likely should put this in a try/catch/finally block
//       and handle SocketException.
//       Can also check if 'r' is empty.
/**
 * Fetches the local IP address by connecting to an external server.
 *
 * Returns:
 *     A string representing the local IP address.
 */
char[] GetIP(){
    auto r = getAddress("8.8.8.8",53);
    auto sockfd = new Socket(AddressFamily.INET,  SocketType.STREAM);
    
    // Connect to the google server
    const char[] address = r[0].toAddrString().dup;
    ushort port = to!ushort(r[0].toPortString());
    sockfd.connect(new InternetAddress(address,port));

    // Obtain local sockets name and address
    auto ip = sockfd.localAddress.toAddrString().dup;
    // writeln(sockfd.hostName);
    // writeln("Our ip address    : ",sockfd.localAddress);
    // writeln("the remote address: ",sockfd.remoteAddress);

    // Close our socket
    sockfd.close();
    return ip;
}

/// The purpose of the TCPServer is to accept
/// multiple client connections. 
/// Every client that connects will have its own thread
/// for the server to broadcast information to each client.
/**
 * Represents a TCP server that handles client connections for chat
 * and XY coordinate updates.
 *
 * The server listens on two ports: one for chat messages and another
 * for XY coordinate data. Each client connection is handled in a separate
 * thread.
 */
class TCPServer{

    /// The listening socket is responsible for handling new client connections.
    Socket mListeningSocket;
    Socket mListeningSocketForXY;
    
    /// Stores the clients that are currently connected to the server.
    Socket[] mClientsConnectedToServer;
    Socket[] mClientSocketForXY;

    /// Stores all of the data on the server. Ideally, we'll 
    /// use this to broadcast out to clients connected.
    char[1024][] mServerData;
    
    /// Keeps track of the last message that was broadcast out to each client.
    uint[] mCurrentMessageToSend;
    /// Constructor
    /// By default I have choosen localhost and a port that is likely to
    /// be free.
    // Associative array to store client data
    int[][string] map;
    
    /**
     * Constructs a new TCPServer instance.
     *
     * Params:
     *     host = Hostname for the server (default: "localhost").
     *     port = Port number for chat messages (default: 50001).
     *     portForXY = Port number for XY coordinate data (default: 50002).
     *     maxConnectionsBacklog = Maximum number of queued connections (default: 100).
     */
    this(string host = "localhost", ushort port=50001, ushort portForXY=50002, ushort maxConnectionsBacklog=100){
        writeln("Starting server...");
        host = to!string(GetIP());
        writeln("Server address: ", host, ":", port);
        writeln("Pakcet Server address: ", host, ":", portForXY);
        // Note: AddressFamily.INET tells us we are using IPv4 Internet protocol
        // Note: SOCK_STREAM (SocketType.STREAM) creates a TCP Socket
        //       If you want UDPClient and UDPServer use 'SOCK_DGRAM' (SocketType.DGRAM)
        mListeningSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
        
        // Set the hostname and port for the socket
        // NOTE: It's possible the port number is in use if you are not able
        //  	 to connect. Try another one.
        // When we 'bind' we are assigning an address with a port to a socket.
        mListeningSocket.bind(new InternetAddress(host,port));
        
        // 'listen' means that a socket can 'accept' connections from another socket.
        // Allow 4 connections to be queued up in the 'backlog'
        mListeningSocket.listen(maxConnectionsBacklog);

        // initialize socket for xy
        mListeningSocketForXY = new Socket(AddressFamily.INET, SocketType.STREAM);
        mListeningSocketForXY.bind(new InternetAddress(host, portForXY));
        mListeningSocketForXY.listen(maxConnectionsBacklog);
    }

    /**
     * Destructor to clean up resources.
     */
    /// Destructor
    ~this(){
        // Close our server listening socket
        // TODO: If it was never opened, no need to call close
        mListeningSocket.close();
        mListeningSocketForXY.close();
    }

    /**
     * Listens for incoming chat message connections and handles them.
     */
    private void spawnListenMessageSocket() {
        while (true) {
            writeln("Waiting to accept more connections");
            auto newClientSocket = mListeningSocket.accept();

            writeln("Hey, a new client joined!");

            writeln("(me)",newClientSocket.localAddress()," <----> ",newClientSocket.remoteAddress(),"(client)");

            mClientsConnectedToServer ~= newClientSocket;

            mCurrentMessageToSend ~= 0;

            writeln("Friends on server = ", mClientsConnectedToServer.length);

            newClientSocket.send("Hello friend(from chat server)\0");

            new Thread({
                clientLoop(newClientSocket);
            }).start();
        }
    }

    /**
     * Listens for incoming XY coordinate connections and handles them.
     */
    private void spawnListenPlayerCoordinateSocket() {
        while (true) {
            writeln("Waiting to accept XY connections");
            auto newClientSocketForXY = mListeningSocketForXY.accept();

            writeln("New XY client joined!");

            writeln("(me)",newClientSocketForXY.localAddress(),"<---->",newClientSocketForXY.remoteAddress(),"(client)");

            mClientSocketForXY ~= newClientSocketForXY;

            mCurrentMessageToSend ~= 0;

            writeln("Friends on server = ", mClientsConnectedToServer.length);

            newClientSocketForXY.send(" XY SERVER! \0");

            writeln("Map length" ~ to!string(map.length));

            //xyClientLoop(newClientSocketForXY);

            new Thread({
                xyClientLoop(newClientSocketForXY);
            }).start();
        }
    }

    /// Call this after the server has been created
    /// to start running the server
    /**
     * Starts the server and begins listening for client connections.
     */
    void run(){

        new Thread({
            spawnListenMessageSocket();
        }).start();

        new Thread({
            spawnListenPlayerCoordinateSocket();
        }).start();
    }

    // Function to spawn from a new thread for the client.
    // The purpose is to listen for data sent from the client 
    // and then rebroadcast that information to all other clients.
    // NOTE: passing 'clientSocket' by value so it should be a copy of 
    //       the connection.
    /**
     * Handles the communication loop for a connected chat client. Function to spawn from a new thread for the client.
     * The purpose is to listen for data sent from the client 
     * and then rebroadcast that information to all other clients.
     *
     * Params:
     *     clientSocket = The socket associated with the connected client.
     */
    void clientLoop(Socket clientSocket){
        writeln("\t Starting clientLoop:(me)", clientSocket.localAddress(), "<---->", clientSocket.remoteAddress(), "(client)");
        
        bool runThreadLoop = true;

        while(runThreadLoop){
            if(!clientSocket.isAlive){
                runThreadLoop = false;
                break;
            }

            char[1024] buffer;
            auto receivedBytes = clientSocket.receive(buffer);
            writeln("Received some data (bytes): ", receivedBytes);

            if (receivedBytes <= 0) {
                writeln("A client disconnected or error occurred.");
                runThreadLoop = false;
                break;
            }

            // Check if it's a FILE_TRANSFER message
            string receivedData = to!string(buffer[0 .. receivedBytes]);
            writeln("Data received from client: ", receivedData);

            if (receivedData.startsWith("FILE_TRANSFER")) {
                writeln("Received FILE_TRANSFER data: ", receivedData);
                auto parts = split(receivedData, '|');
                if (parts.length >= 4) {
                    string fileName = parts[1];
                    ulong fileSize = to!ulong(parts[2]);
                    bool isCompressed = parts[3].strip() == "compressed";
                    writeln("File Name: ", fileName);
                    writeln("File Size: ", fileSize);
                    writeln("Is Compressed: ", isCompressed);

                    //clientSocket.send("FILE_START|" ~ fileName ~ "|" ~ fileSize.to!string ~ "\n");

                    // Now read the file data based on fileSize
                    ubyte[] fileData = new ubyte[fileSize];
                    ulong totalBytesRead = 0;
                    while (totalBytesRead < fileSize) {
                        auto bytesRead = clientSocket.receive(fileData[totalBytesRead .. $]);
                        if (bytesRead <= 0) break;
                        totalBytesRead += bytesRead;
                    }

                    forwardFileToAllClients(clientSocket, fileName, fileData, isCompressed);
                    // Process the received file data
                    // forwardFileToRecipient(fileData, isCompressed);
                }
            } 
            else {
                // Handle regular messages
                mServerData ~= buffer;
                broadcastToAllClients();
            }
        }
        writeln("Exiting client loop for: ", clientSocket.remoteAddress());
    }
    
    // same logic for chatting
    /**
     * Handles the communication loop for a connected XY client.
     *
     * Params:
     *     clientSocket = The socket associated with the connected XY client.
     */
    void xyClientLoop(Socket clientSocket) {
        writeln("\t Starting XY clientLoop:(me)",clientSocket.localAddress(),"<---->",clientSocket.remoteAddress(),"(client)");
        bool runThreadLoop = true;
        while (runThreadLoop) {
            writeln("Is client alive : " ~to!string(clientSocket.isAlive));

            if(!clientSocket.isAlive){
                runThreadLoop=false;
                break;
            }

            clientSocket.send("Hello friend(from XY server)\0");

            char[1024] buffer;
            auto receivedBytes = clientSocket.receive(buffer);

            writeln("receivedBytes: " ~ to!string(receivedBytes));

            if (receivedBytes <= 0) {
                writeln("XY client disconnected or error occurred.");
                runThreadLoop = false;
                break;
            }

            // Unpack Packet
            Packet p = Packet.fromCharArray(buffer[0 .. receivedBytes]);
            writeln("Received XY Packet - x: ", p.x, ", y: ", p.y, ", name: ", p.name);

            // update x and y in hashmap
            string name = to!string(p.name);
            map[name] = [p.x, p.y];
            p.x = map[name][0];
            p.y = map[name][1];
            writeln("Map Length "~to!string(map.length));
            // writeln() for check map
            foreach(name, coords; map) {
                writeln("User: ", name, ", Coords: [", coords[0], ", ", coords[1], "]");
                Packet p_send;
                p_send.x = coords[0];
                p_send.y = coords[1];
                strncpy(p_send.name.ptr, name.ptr, p_send.name.length);
                p_send.name[p_send.name.length - 1] = '\0';

                auto packetBytes = p_send.GetPacketAsBytes();

                writeln("Number of clients: " ~  to!string(mClientSocketForXY.length));

                //clientSocket.send(packetBytes);

                foreach(idx, socket; mClientSocketForXY) {
                    if (clientSocket != socket) {
                        writeln("sending data to client " ~ to!string(idx));
                        socket.send(packetBytes);
                    }

                }
            }
        }
    }

    /// The purpose of this function is to broadcast
    /// messages to all of the clients that are currently
    /// connected.
    /**
     * Broadcasts chat messages to all connected clients.
     */
    void broadcastToAllClients(){
        writeln("Broadcasting to : ", mClientsConnectedToServer.length);
        foreach(idx,serverToClient; mClientsConnectedToServer){
            // Send whatever the latest data was to all the 
            // clients.
            while(mCurrentMessageToSend[idx] <= mServerData.length-1){
                char[1024] msg = mServerData[mCurrentMessageToSend[idx]];
                serverToClient.send(msg[0 .. 1024]);
                writeln("server to client msg: ", msg);	
                // Important to increment the message only after sending
                // the previous message to as many clients as exist.
                mCurrentMessageToSend[idx]++;
            }
        }
    }

    /**
     * Extracts the file size from a file transfer header.
     *
     * Params:
     *     header = The header string containing file transfer information.
     *
     * Returns:
     *     The size of the file as an ulong.
     */
    ulong extractFileSize(string header) {
        // Split the header on '|'
        auto parts = header.split('|');
        if (parts.length < 4) {
            writeln("Invalid header format.");
            return 0;
        }

        // The third part should be the file size
        string fileSizeStr = parts[2].strip(); // Strip to remove any unwanted characters
        try {
            return to!ulong(fileSizeStr);
        } catch (Exception e) {
            writeln("Error parsing file size: ", e.msg);
            return 0;
        }
    }

    /**
     * Forwards a file to all connected clients except the sender.
     *
     * Params:
     *     senderSocket = The socket of the client who sent the file.
     *     fileName = The name of the file being transferred.
     *     fileData = The binary data of the file.
     *     isCompressed = Indicates whether the file data is compressed.
     */
    void forwardFileToAllClients(Socket senderSocket, string fileName, ubyte[] fileData, bool isCompressed) {
        ubyte[] dataToSend;

        if (isCompressed) {
            try {
                dataToSend = cast(ubyte[])uncompress(fileData); // Decompress the data
            } catch (Exception e) {
                writeln("Error decompressing file: ", e.msg);
                return; // Handle error appropriately
            }
        } else {
            dataToSend = fileData; // If not compressed, use the original data
        }

        foreach (clientSocket; mClientsConnectedToServer) {
            if (clientSocket != senderSocket) { // Optionally skip the sender
                // Send file start message with file name and size
                clientSocket.send("FILE_START|" ~ fileName ~ "|" ~ dataToSend.length.to!string ~ "|");

                // Send the decompressed (or original) data to the client
                clientSocket.send(cast(void[]) dataToSend); // Ensure the data is sent as raw bytes
            }
        }
    }        
}