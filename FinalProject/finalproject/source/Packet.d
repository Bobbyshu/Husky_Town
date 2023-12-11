// @file Packet.d
/**
 * Provides the definition and functionality for a network packet.
 *
 * This file defines the `Packet` struct used for network communication. The `Packet`
 * struct includes methods for serializing and deserializing packet data, which is
 * essential for sending and receiving information across a network. It's crucial
 * to consider the endianness of the target machine when dealing with packet data.
 */
module Packet;
import core.stdc.string;

// NOTE: Consider the endianness of the target machine when you 
//       send packets. If you are sending packets to different
//       operating systems with different hardware, the
//       bytes may be flipped!
//       A test you can do is to when you send a packet to a
//       operating system is send a 'known' value to the operating system
//       i.e. some number. If that number is expected (e.g. 12345678), then
//       the byte order need not be flipped.
/**
 * Represents a network packet with fixed-size data fields.
 *
 * This struct is used to pack data into a fixed-size format for transmission
 * over a network. It includes methods for serializing the packet into a byte array
 * and deserializing it back into a `Packet` struct.
 */
struct Packet{
    // NOTE: Packets usually consist of a 'header'
    //   	 that otherwise tells us some information
    //  	 about the packet. Maybe the first byte
    // 	 	 indicates the format of the information.
    // 		 Maybe the next byte(s) indicate the length
    // 		 of the message. This way the server and
    // 		 client know how much information to work
    // 		 with.
    // For this example, I have a 'fixed-size' Packet
    // for simplicity -- effectively cramming every
    // piece of information I can think of.

    int x;
    int y;
    int characternum;
    char[10] name;

    /// Purpose of this function is to pack a bunch of
    /// bytes into an array for 'serialization' or otherwise
    /// ability to send back and forth across a server, or for
    /// otherwise saving to disk.	
    /**
     * Serializes the packet's data into a byte array.
     *
     * Returns:
     *     An array of bytes representing the serialized packet.
     */
    char[Packet.sizeof] GetPacketAsBytes(){
        char[Packet.sizeof] payload;
        size_t idx = 0;
        import std.stdio;
        // writeln("x is:",x);
        // writeln("y is:",y);
        // writeln("name is:", name);

        // serialize
        memmove(&payload[idx], &x, x.sizeof);
        idx += x.sizeof;
        memmove(&payload[idx], &y, y.sizeof);
        idx += y.sizeof;
        memmove(&payload[idx], &characternum, characternum.sizeof);
        idx += characternum.sizeof;
        memmove(&payload[idx], &name[0], name.sizeof);

        return payload;
    }

    // deserialization
    /**
     * Deserializes an array of bytes back into a `Packet`.
     *
     * Params:
     *     arr = The array of bytes to deserialize.
     *
     * Returns:
     *     A `Packet` struct containing the deserialized data.
     */
    static Packet fromCharArray(char[] arr) {
        Packet p;
        size_t idx = 0;

        // copy x
        p.x = *cast(int*)arr[idx .. idx + int.sizeof].ptr;
        idx += int.sizeof;

        // copy y
        p.y = *cast(int*)arr[idx .. idx + int.sizeof].ptr;
        idx += int.sizeof;

        p.characternum = *cast(int*)arr[idx .. idx + int.sizeof].ptr;
        idx += int.sizeof;

        // copy name
        foreach(i; 0 .. p.name.length) {
            p.name[i] = arr[idx + i];
        }

        return p;
    }
}