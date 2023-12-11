module test.testNetwork;

// import client : TCPClient;
import unit_threaded;
// import std.socket;
import std.conv;
import server_for_testing;

/// extract some functions from our TCPClient
class TestClient {
    private MockSocket _mockSocket;
    private bool _isConnected = false;

    this(MockSocket mockSocket) {
        _mockSocket = mockSocket;
    }

    void connect(string ip, ushort port) {
        try {
            _mockSocket.connect();
            _isConnected = true;
        } catch (Exception e) {
        }
    }

    void disconnect() {
        _mockSocket.close();
        _isConnected = false;
    }

    bool isConnected() {
        return _isConnected;
    }
}

// mock the socket
class MockSocket {
    private bool _isConnected = false;
    private ubyte[] _receivedData;
    private ubyte[] _sentData;

    void connect() {
        _isConnected = true;
    }

    void close() {
        _isConnected = false;
    }

    size_t send(in ubyte[] data) {
        if (!_isConnected) {
            throw new Exception("Socket not connected");
        }
        _sentData = data.dup;
        return data.length;
    }

    size_t receive(ref ubyte[] buffer) {
        if (!_isConnected) {
            throw new Exception("Socket not connected");
        }
        buffer = _receivedData.dup;
        return _receivedData.length;
    }

    void setReceivedData(ubyte[] data) {
        _receivedData = data;
    }

    bool isConnected() {
        return _isConnected;
    }

    ubyte[] getSentData() {
        return _sentData;
    }
}


@("Test client initialized or not")
unittest {
    auto mockSocket = new MockSocket();
    TestClient testClient = new TestClient(mockSocket);

    testClient.connect("127.0.0.1", 8080);
    assert(testClient.isConnected(), "TestClient should be connected");

    testClient.disconnect();
    assert(!testClient.isConnected(), "TestClient should be disconnected");
}

@("Test multiple client connections")
unittest {
    // test 3 clients join
    const size_t numberOfClients = 3;
    size_t connectedClients = 0;

    auto mockSocket = new MockSocket();
    TestClient[] clients;

    for (size_t i = 0; i < numberOfClients; ++i) {
        TestClient testClient = new TestClient(mockSocket);
        testClient.connect("127.0.0.1", 8080);
        clients ~= testClient;

        if (testClient.isConnected()) {
            ++connectedClients;
        }
    }

    // Check whether all clients are connected
    assert(connectedClients == numberOfClients, 
           "Number of connected clients should match " ~ to!string(numberOfClients));

    // Optionally disconnect all clients
    foreach (client; clients) {
        client.disconnect();
        assert(!client.isConnected(), "Client should be disconnected");
    }
}

@("Test GET IP")
unittest {
    auto ip = GetIP();
    assert(ip.length > 0, "GetIP should return a non-empty string");
}