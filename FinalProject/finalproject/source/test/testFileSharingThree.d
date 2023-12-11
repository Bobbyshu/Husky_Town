module test.testFileSharingThree;

import server_for_testing;
import client;
import std.file;
import std.conv;
import core.thread;
import std.socket;
import std.zlib;

unittest {
    // Prepare test data and compress it
    string originalContent = "Sample content for decompression";
    string testFileNameB = "testfile.txt";
    std.file.write(testFileNameB, cast(ubyte[])originalContent);
    string compressedFileNameB = testFileNameB ~ ".zlib";
    TCPClient clientB = new TCPClient();
    clientB.compressFile(testFileNameB, compressedFileNameB);

    // Read compressed data and cast to ubyte[]
    void[] rawCompressedDataB = std.file.read(compressedFileNameB);
    ubyte[] compressedDataB = cast(ubyte[])rawCompressedDataB;

    // Decompress and verify content
    void[] decompressedRawDataB = uncompress(compressedDataB);
    ubyte[] decompressedDataB = cast(ubyte[])decompressedRawDataB;
    string decompressedContentB = cast(string) decompressedDataB;
    assert(decompressedContentB == originalContent, "Decompressed content does not match original");

    // Clean up
    std.file.remove(testFileNameB);
    std.file.remove(compressedFileNameB);
}