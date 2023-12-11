/**
 * Module for initializing and terminating the SDL library.
 *
 * This module handles the setup and teardown of the SDL library for the application.
 * It includes shared static constructors and destructors to manage the lifecycle
 * of the SDL library, ensuring it is correctly loaded and unloaded.
 */
module setup_sdl; 

import std.stdio;
import std.string;

// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

// global variable for sdl;
const SDLSupport ret;

/// At the module level we perform any initialization before our program
/// executes. Effectively, what I want to do here is make sure that the SDL
/// library successfully initializes.
/**
 * Shared static constructor for the module.
 *
 * This constructor attempts to load the SDL library appropriate for the operating system.
 * It checks for errors in loading the library and initializes SDL. If SDL cannot be loaded
 * or initialized, it logs appropriate error messages.
 */
shared static this(){
		// Load the SDL libraries from bindbc-sdl
		// on the appropriate operating system
    version(Windows){
    		writeln("Searching for SDL on Windows");
				ret = loadSDL("SDL2.dll");
		}
  	version(OSX){
      	writeln("Searching for SDL on Mac");
        ret = loadSDL();
    }
    version(linux){ 
      	writeln("Searching for SDL on Linux");
				ret = loadSDL();
		}

		// Error if SDL cannot be loaded
    if(ret != sdlSupport){
        writeln("error loading SDL library");    
        foreach( info; loader.errors){
            writeln(info.error,':', info.message);
        }
    }
    if(ret == SDLSupport.noLibrary){
        writeln("error no library found");    
    }
    if(ret == SDLSupport.badLibrary){
        writeln("Eror badLibrary, missing symbols, perhaps an older or very new version of SDL is causing the problem?");
    }

    // Initialize SDL
    if(SDL_Init(SDL_INIT_EVERYTHING) !=0){
        writeln("SDL_Init: ", fromStringz(SDL_GetError()));
    }
}

/// At the module level, when we terminate, we make sure to 
/// terminate SDL, which is initialized at the start of the application.
/**
 * Shared static destructor for the module.
 *
 * This destructor ensures that SDL is properly terminated when the application exits.
 * It calls SDL_Quit to clean up any resources used by SDL.
 */
shared static ~this(){
    // Quit the SDL Application 
    SDL_Quit();
	writeln("Ending sdl_setup --good bye!");
}
