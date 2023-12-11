module test.testFileSharing;

import server_for_testing;
import client;
import std.file;
import std.conv;
import core.thread;
import std.socket;
import std.zlib;

unittest {
    // Prepare mock data
    string testFileNameC = "testfile.txt";
    string fileContentC = "Test content for transmission";
    std.file.write(testFileNameC, cast(ubyte[])fileContentC);

    // Simulate client and server
    TCPClient mockClientC = new TCPClient();
    TCPServer mockServerC = new TCPServer();
    string receivedFileNameC;
    ubyte[] receivedDataC;

    // Mock function to simulate file transmission
    void simulateFileTransferC(string fileNameC, ubyte[] dataC) {
        receivedFileNameC = mockClientC.extractFileName(fileNameC);
        receivedDataC = dataC;
    }

    // Perform simulated file transfer
    void[] rawFileDataC = std.file.read(testFileNameC);
    ubyte[] fileDataC = cast(ubyte[])rawFileDataC;

    simulateFileTransferC(testFileNameC, fileDataC);

    // Verify transmission
    assert(receivedFileNameC == testFileNameC, "File name mismatch");
    assert(cast(string) receivedDataC == fileContentC, "File content mismatch");

    // Clean up
    std.file.remove(testFileNameC);
}
