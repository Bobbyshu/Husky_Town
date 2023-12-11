module FinalProject.report.reporter;

// Run from FinalProject/finalproject/source folder
// rdmd ../../report/reporter.d "report.json" > report.html

import std.stdio;
import std.json;
import std.file;
import std.conv;
import std.algorithm;
import std.array;


void main(string[] args){
	import std.stdio;

	if(args.length < 2){
		immutable msg = "rdmd reporter.d \"report.json\" > report.html";
		writeln("Error-- usage is: ",msg);

	}

	// For your own debugging purposes, here are the arguments.

	//writeln(args[0]); // Executable location
	//writeln(args[1]); // First program argument

   	auto myFile = File(args[1], "r");
    // Parsing Json File
   	auto jsonFileContents = myFile.byLine.joiner("\n");

   	auto json = parseJSON(jsonFileContents);
   
    // Extract and print line and message from issues array
    auto issues = json["issues"].array;

	int count = 1;
    //Generating HTML File
	writeln("<html>");
	writeln("<head>");
	writeln("<title>HTML File</title>");
	writeln("</head>");
	writeln("<html>");
    foreach (issue; issues)
    {
        writeln("<h3>",count,". ", issue["line"].integer, " -- ", issue["message"], "</h3>");
		count++;
    }
	writeln("</body>");
	writeln("</html>");

}
