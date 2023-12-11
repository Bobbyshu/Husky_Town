/**
 * Client module for a multi-threaded chat application.
 *
 * This module defines the TCPClient class, which is responsible for establishing
 * and maintaining a connection to the server, handling user input, and processing
 * incoming data from the server. The client can send messages and files, as well
 * as receive updates on XY coordinates from the server.
 */
module client;

// @file chat/client.d
//
// After starting server (rdmd server.d)
// then start as many clients as you like with "rdmd client.d"
//
import std.socket;
import std.stdio;
import core.thread.osthread;
import std.conv;
import std.string;
import std.datetime;
import std.zlib;
import std.file;
import std.algorithm;
import core.stdc.string;
import std.ascii;

import Packet : Packet;

/// The purpose of the TCPClient class is to 
/// connect to a server, send messages and text files.
/**
 * TCPClient is responsible for handling the client-side logic of the chat application.
 *
 * This class manages the connection to the server for sending and receiving messages
 * and files. It also handles separate connections for XY coordinate updates. Each
 * client runs in its own thread and interacts with the server independently.
 */
class TCPClient{

    bool awaitingSavePath = false;
    string receivedFileName; // To store the name of the received file
    string receivedFileData; // To store the data of the received file
    public bool clientRunning = false;

    /// The client socket connected to a server
		Socket mSocket;
		Socket mSocketForXY;
		string username;
		int xCord;
		int yCord;
		int[][string] map;
	
        /**
        * Constructs a new TCPClient instance.
        *
        * This constructor initializes the client's sockets and sets up the connection
        * parameters for communicating with the server.
        */
		this(){
				writeln("Starting client...attempt to create socket");
				// Create a socket for connecting to a server
				// Note: AddressFamily.INET tells us we are using IPv4 Internet protocol
				// Note: SOCK_STREAM (SocketType.STREAM) creates a TCP Socket
				//       If you want UDPClient and UDPServer use 'SOCK_DGRAM' (SocketType.DGRAM)
				mSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
				mSocketForXY = new Socket(AddressFamily.INET, SocketType.STREAM);
		}

		/// Destructor 
        /**
        * Destructor to clean up resources.
        *
        * Closes the sockets used for communication with the server.
        */
		~this(){
				// Close the socket
				mSocket.close();
				mSocketForXY.close();
		}

		// Purpose here is to run the client thread to constantly send data to the server.
		// This is your 'main' application code.
		// 
		// In order to make life a little easier, I will also spin up a new thread that constantly
		// receives data from the server.
        /**
        * Starts the client, establishing connections to the server for message and coordinate communication.
        *
        * This method initiates the client by asking the user to input the IP address, message port, and coordinate port.
        * It then connects to the server on these ports and starts separate threads for receiving data from the server
        * and processing incoming packets. The method also handles user input for sending messages or commands.
        */
		void run(){
            while (true) {
                try {
                    writeln("Preparing to run client");
                    // writeln("(me)",mSocket.localAddress(),"<---->",mSocket.remoteAddress(),"(server)");
                    // Buffer of data to send out
                    // Choose '80' bytes of information to be sent/received
                    // strip for avoid Unexpected '\n'
                    writeln("Please input IP address: ");
                    auto ip = strip(readln());

                    writeln("Please input message port: ");
                    auto message_port = strip(readln());

                    writeln("Please input coordinate port: ");
                    auto coordinate_port = strip(readln());

                    writeln("Please username(less than 10 characters): ");
                    username = strip(readln());

                    // Socket needs an 'endpoint', so we determine where we
                    // are going to connect to.
                    // NOTE: It's possible the port number is in use if you are not
                    //       able to connect. Try another one.
                    mSocket.connect(new InternetAddress(ip, to!ushort(message_port)));
                    writeln("Connected to server at ", ip, ":", message_port);

                    char[1024] buffer;
                    auto received_message_from_chat = mSocket.receive(buffer);
                    writeln("(incoming from chat server) ", buffer[0 .. received_message_from_chat]);

                    mSocketForXY.connect(new InternetAddress(ip, to!ushort(coordinate_port)));

                    writeln("Connecting to XY coordinate");

                    char[1024] coordinateBuffer;
                    auto received_message_from_coordinate = mSocketForXY.receive(coordinateBuffer);
                    writeln("(incoming from chat server) ", coordinateBuffer[0 .. received_message_from_coordinate]);

                    writeln("Client conncted to server");	
                    break;
                } catch (SocketOSException e) {
                    writeln("Server is closing now or you input wrong port number");
                    writeln(e.message);
                    writeln("Please try again");
                    writeln();
                } catch (Exception e) {
                    writeln("Exception happening: ", e.message);
                    writeln("Please try again");
                    writeln();
                }
            }
            
            clientRunning = true;
            // Spin up the new thread that will just take in data from the server
            new Thread({
                    receiveDataFromServer();
            }).start();

            new Thread({
                    receivePacketFromServer();
            }).start();
        
            writeln("Is client running: " ~ clientRunning);

            bool first = true;
            while(clientRunning){
                    // writeln("Please input x coordinate of starting point");
                    // xCord = to!int(strip(readln()));

                    // writeln("Please input y coordinate of starting point");
                    // yCord = to!int(strip(readln()));

                    // map[username] = [xCord, yCord];
                    // sendPacket(xCord, yCord);
                    // write(">");
                    if (first) {
                        writeln("You can start chatting by input message or send file by input -s path/to/your/text/file: ");
                        first = false;
                    }
                    auto line = readln();
                    if(line.length > 0) {
                        handleUserInput(to!string(line));
                    }
            }
		}


    /**
    * Handles user input to process chat messages or file-related commands.
    * 
    * Params:
    *     input = The string input received from the user.
    */
    void handleUserInput(string input) {
        if (awaitingSavePath) {
            try {
                if (input.startsWith("-r ")) {
                    string savePath = input[3..$].strip();
                    savePath = buildFullPath(savePath, receivedFileName);
                    std.file.write(savePath, cast(ubyte[])receivedFileData); // Write the byte array to file
                    writeln("File saved at: ", savePath);
                    awaitingSavePath = false;
                } else {
                    writeln("File reception skipped.");
                    awaitingSavePath = false;
                }
            } catch (std.file.FileException e) {
                writeln("Receive file path not found. Failed to receive file: ", e.msg);
                awaitingSavePath = false;
                // Optionally, reset received file data here
            }
            return; // Skip sending this input as a chat message
        }

        if (input.startsWith("-s ")) {
            string filePath = input[3..$].strip();
            writeln("Sending file: ", filePath);
            if (!std.file.exists(filePath)) {
                writeln("File does not exist: ", filePath);
                return;
            }
            compressAndSendFile(filePath);
        } 
        else {
            writeln("(You send a message): ", input);
            auto timeStamp = Clock.currTime().toISOExtString();
            auto message = to!string(username ~ ":\n" ~ "(" ~ timeStamp ~ ") " ~ input);
            mSocket.send(message);
        }
    }        

    /**
    * Continuously receives data from the server.
    * 
    * Listens to the server and handles incoming messages or file start signals.
    */
    void receiveDataFromServer() {
        while (true) {
            char[1024] buffer;
            uint bytesRead = to!uint(mSocket.receive(buffer));
            if (bytesRead > 0) {
                // Manually build the string from printable characters
                string fromServer = buildCleanString(buffer[0 .. bytesRead]);

                if (fromServer.startsWith("FILE_START")) {
                    receiveFile(mSocket, fromServer);
                } else {
                    writeln("===========================================");
                    writeln("(from server)", fromServer);
                    writeln("===========================================");
                }
            }
        }
    }
	
    /**
    * Extracts a valid string from a character array, stopping at the first null character.
    * 
    * Params:
    *     arr = The character array to extract the string from.
    * 
    * Returns:
    *     A valid, clean string extracted from the character array.
    */
    string extractValidString(char[] arr) {
            int idx = 0;
            foreach (i, val; arr) {
                    if (val == '\0') {
                            break;
                    }
                    idx++;
            }
            return to!string(arr[0 .. idx]).strip();
    }

    /**
    * Builds a clean string from a character array, including only printable characters.
    * 
    * Params:
    *     data = The character array to process.
    * 
    * Returns:
    *     A string built from the printable characters of the array.
    */
    string buildCleanString(char[] data) {
        string result;
        foreach (char c; data) {
            // Check if the character is printable (ASCII 32 to 126)
            // and newline (ASCII 10)
            if ((c >= 32 && c <= 126) || c == 10) {
                result ~= c;
            } else {
                // Stop adding characters when encountering a non-printable character
                break;
            }
        }
        return result.strip();
    }    

    /**
    * Extracts the file name from a given file path.
    * 
    * Params:
    *     filePath = The full path of the file.
    * 
    * Returns:
    *     The base name of the file from the given path.
    */
    string extractFileName(string filePath) {
        import std.path : baseName;
        return baseName(filePath);
    }

    /**
    * Reads a line of data from a socket.
    * 
    * Params:
    *     socket = The socket to read the data from.
    * 
    * Returns:
    *     A string representing the data read from the socket.
    */
    string readLine(Socket socket) {
        char[1024] buffer;
        auto bytesRead = socket.receive(buffer);
        // writeln("readLine is: ", to!string(buffer[0 .. bytesRead]).strip());
        return to!string(buffer[0 .. bytesRead]).strip();
    }    

    /**
    * Compresses a file and writes the compressed data to an output file.
    * 
    * Params:
    *     inputFile  = The file path of the file to compress.
    *     outputFile = The file path where the compressed data should be written.
    */
    void compressFile(string inputFile, string outputFile) {
        auto data = cast(ubyte[])std.file.read(inputFile); // Read the entire file as ubyte[]
        auto compressed = compress(data); // Compress the data
        std.file.write(outputFile, compressed); // Write the compressed data to output file
    }

    /**
    * Sends a file over a socket, optionally indicating if the file is compressed.
    * 
    * Params:
    *     socket       = The socket to send the file through.
    *     filePath     = The path of the file to send.
    *     isCompressed = Flag indicating whether the file is compressed.
    */
    void sendFile(Socket socket, string filePath, bool isCompressed) {
        try {
            string fileName = extractFileName(filePath);
            auto fileData = cast(ubyte[])std.file.read(filePath); // Read file data as ubyte[]
            ulong fileSize = fileData.length;
            string header = "FILE_TRANSFER|" ~ fileName ~ "|" ~ fileSize.to!string ~ "|" ~ (isCompressed ? "compressed" : "uncompressed") ~ "\n";

            // Send the header first
            socket.send(header);

            // Then send the file data
            socket.send(fileData);

            writeln("File sent successfully.");
        } catch (std.file.FileException e) {
            writeln("File path not found, please try again: ", e.msg);
        }
    }

    /**
    * Compresses a file and sends it over a socket.
    * 
    * Params:
    *     filePath = The path of the file to compress and send.
    */
    void compressAndSendFile(string filePath) {
        try {
            string compressedFilePath = filePath ~ ".zlib"; // Example compressed file name
            compressFile(filePath, compressedFilePath); // Compress the file
            sendFile(mSocket, compressedFilePath, true); // Indicate that file is compressed
        } catch (std.file.FileException e) {
            writeln("File path not found, please try again: ", e.msg);
        }
    }
    
    /**
    * Receives a file from a socket based on the provided header information.
    * 
    * Params:
    *     socket     = The socket to receive the file from.
    *     headerInfo = The header information for the file being received.
    */
    void receiveFile(Socket socket, string headerInfo) {
        writeln("Preparing to receive file...");

        writeln("header: ", headerInfo);
        auto parts = headerInfo.split('|');
        writeln("parts", parts);
        if (parts.length < 2) return; // Check for valid header

        receivedFileName = parts[1];
        uint fileSize = to!uint(parts[2]); // Change to uint
        writeln("File Name: ", receivedFileName);
        writeln("File Size: ", fileSize);

        ubyte[] fileContent = new ubyte[fileSize];
        uint totalBytesRead = 0; // Change to uint
        while (totalBytesRead < fileSize) {
            auto bytesRead = socket.receive(fileContent[totalBytesRead .. $]);
            if (bytesRead <= 0) break;
            totalBytesRead += bytesRead;
        }
        receivedFileData = cast(string) fileContent; // Convert the byte array to string

        awaitingSavePath = true;
        writeln("Received file: ", receivedFileName);
        writeln("Please start with -r and enter the path to save the file (leave blank to skip): ");
    }       

		// function for sending packet to port 50002
    /**
    * Sends XY coordinate packet to the server.
    *
    * Params:
    *     x = The x-coordinate to send.
    *     y = The y-coordinate to send.
    */
    void sendPacket(int x, int y, int characternum) {
            Packet p;
            p.x = x;
            p.y = y;
            p.characternum = characternum;
            foreach (i; 0 .. p.name.length) {
                    p.name[i] = '\0';
            }

            // copy username to p.name
            auto len = username.length < p.name.length ? username.length : p.name.length - 1;
            strncpy(p.name.ptr, username.ptr, len);
            p.name[len] = '\0';

            auto packetBytes = p.GetPacketAsBytes();
            mSocketForXY.send(packetBytes);
    }

    /**
    * Builds the full path for a file based on a directory path and file name.
    * 
    * Params:
    *     path     = The directory path.
    *     fileName = The name of the file.
    * 
    * Returns:
    *     The full path constructed from the directory path and file name.
    */
    string buildFullPath(string path, string fileName) {
        // Add logic here to build the full path using 'path' and 'fileName'
        return path ~ "/" ~ fileName; // Example logic, adjust as needed
    }

    // Thread for process Packet
    /**
    * Continuously receives packets from the server and processes them.
    *
    * This method runs in a separate thread and listens for incoming packets
    * containing XY coordinates. It updates the client's internal map with
    * the received data.
    */
    void receivePacketFromServer(){
            while(true) {
                try {
                    char[1024] bufferForXY;
                    auto receivedLength = mSocketForXY.receive(bufferForXY);
                    if (receivedLength <= 0 || receivedLength > bufferForXY.length) {
                        writeln("Invalid data received or server has been closed");
                        break;
                    }
                    auto fromServerForXY = bufferForXY[0 .. receivedLength];

                    //writeln("Receiving the data length " ~ to!string(fromServerForXY.length));

                    if(fromServerForXY.length > 0) {
                            Packet p = Packet.fromCharArray(fromServerForXY);
                            // check data
                            // writeln("Received Packet - x: ", p.x, ", y: ", p.y, ", name: ", p.name);
                            string name = extractValidString(p.name);
                            
                            if (!(name == "iend(from" || !(all!isAlphaNum(name) || p.x == 0 || p.y == 0))) {
                                // writeln("name: " ~ name);
                                map[name] = [p.x, p.y, p.characternum];
                            } 
                            
                            //writeln("Map length "~ to!string(map.length));
                         
                            // foreach(key, value; map) {
                            //        writeln("User: ", key, ", Coords: [", value[0], ", ", value[1], "]");
                            // }
                    }
                } catch (Exception e) {
                    writeln("An error occurred while receiving data: ", e.toString());
                    break;
                }
            }
    } 

    /**
    * Retrieves the client's current map of usernames to coordinates.
    *
    * Returns:
    *     An associative array mapping usernames to their XY coordinates.
    */
    int[][string] getMap(){
        return map;
    }

    /**
    * Retrieves the username of the client.
    *
    * Returns:
    *     The username of the client.
    */
    string getUserName() {
        return username;
    }   
}

// Entry point to client
// void main(){
//  	TCPClient client = new TCPClient();
//  	client.run();
// }