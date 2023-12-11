module test.testFileSharingTwo;

import server_for_testing;
import client;
import std.file;
import std.conv;
import core.thread;
import std.socket;
import std.zlib;

unittest {
    // Prepare test data
    string testFileNameA = "testfile.txt";
    string testContent = "Sample content for compression";
    std.file.write(testFileNameA, cast(ubyte[])testContent);

    // Compress file
    string compressedFileNameA = testFileNameA ~ ".zlib";
    TCPClient clientA = new TCPClient();
    clientA.compressFile(testFileNameA, compressedFileNameA);

    // Verify compression
    assert(std.file.exists(compressedFileNameA), "Compressed file not found");

    // Clean up
    std.file.remove(testFileNameA);
    std.file.remove(compressedFileNameA);
}