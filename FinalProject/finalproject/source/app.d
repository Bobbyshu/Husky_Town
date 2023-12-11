/// Run with: 'dub'
/**
 * Main module for a tile-based game application.
 *
 * This module includes the main functionality for running a tile-based game.
 * It sets up the game window and renderer, loads assets, handles user input,
 * and manages the game loop. The game features a player character that can
 * move around in a tile-based environment, and network functionality to
 * communicate with a server for multiplayer support.
 */
module app;

// Import D standard libraries
import std.stdio;
import std.string;
import std.random;

//import setup_sdl;
import sprite;
import tilemap;
import player;
import client;

// Load the SDL2 library
import bindbc.sdl;

import std.conv: to;
import core.thread.osthread;
import core.stdc.stdlib;


interface Command{
    void Execute();
    void Undo();
}

class MoveSprite : Command {
    override void Execute(){}
    override void Undo() {}
}


// Entry point to program
/**
 * Represents the main entry point of the application.
 *
 * This function initializes the SDL window and renderer, loads tilesets and player
 * sprites, and enters the main game loop. Within the loop, it handles user input,
 * updates the game state, and renders the game world. It also manages network
 * communication for multiplayer functionality.
 */
void main() {
    writeln("Arrowkeys to move, hold 'space' key for tile map selctor demo"); 
    // Create an SDL window
    SDL_Window* window = SDL_CreateWindow("D SDL Tilemap Example",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        1088,
                                        704, 
                                        SDL_WINDOW_SHOWN);
    // Create a hardware accelerated renderer
    SDL_Renderer* renderer = null;
    renderer = SDL_CreateRenderer(window,-1,SDL_RENDERER_ACCELERATED);

    // Load our tiles from an image
    TileSet ts = TileSet(renderer, "./assets/kenney_roguelike-modern-city/Tilemap/tilemap_packed.bmp", 16,37,28);
    DrawableTileMap floorLayer = DrawableTileMap(ts, 1);
    DrawableTileMap buildingLayer = DrawableTileMap(ts, 2);
    DrawableTileMap decorationLayer = DrawableTileMap(ts, 3);

    // Player Hash Map
    Player[string] playerHashMap; 

    // Added new Thread to initialize network
    Random random = Random(unpredictableSeed());

    // Generate a random integer in the range [min, max]
    int charnum = uniform(1, 6); 

    //int charnum = 1;
    Player player = Player(renderer, "./assets/characters/character"~to!string(charnum)~".bmp");


    // Infinite loop for our application
    bool gameIsRunning = true;

    // How 'zoomed' in are we
    int zoomFactor = 2;

    // Added new Thread to initialize network
    TCPClient client = new TCPClient();

    new Thread({
        client.run();
    }).start();
    // Main application loop

    int[][string] map;
    bool[string] isRendered;

    while(gameIsRunning){
        SDL_Event event;
        
        // (1) Handle Input
        // Start our event loop
        while(SDL_PollEvent(&event)){
            // Handle each specific event
            if(event.type == SDL_QUIT){
                gameIsRunning= false;
                exit(0);
            }
        }

        map = client.getMap();

        // Get Keyboard input
        const ubyte* keyboard = SDL_GetKeyboardState(null);
        
        int playerX = player.GetX();
        int playerY = player.GetY();

        // Check if it's legal to move a direction
        // TODO: Consider moving this into a function
        //       e.g. 'legal move'

        if(keyboard[SDL_SCANCODE_LEFT] && floorLayer.canMove(playerX-16,playerY, playerX, playerY, zoomFactor)){ 
            player.MoveLeft();
        }

        if(keyboard[SDL_SCANCODE_RIGHT] && floorLayer.canMove(playerX+16,playerY, playerX, playerY, zoomFactor)){
            player.MoveRight();
        }

        if(keyboard[SDL_SCANCODE_UP] && floorLayer.canMove(playerX,playerY-16, playerX, playerY, zoomFactor)){
            player.MoveUp();
        }

        if(keyboard[SDL_SCANCODE_DOWN] && floorLayer.canMove(playerX,playerY+16, playerX, playerY, zoomFactor)){
            player.MoveDown();
        }

        client.sendPacket(player.GetX(), player.GetY(), charnum);

        // (2) Handle Updates

        // (3) Clear and Draw the Screen
        // Gives us a clear "canvas"
        SDL_SetRenderDrawColor(renderer,100,190,255,SDL_ALPHA_OPAQUE);
        SDL_RenderClear(renderer);

        // NOTE: The draw order here is very important
        //       We follow the 'painters algorithm' in 2D
        //       meaning that we draw the background first,
        //       and then our objects on top.

        // Render out DrawableTileMap
        floorLayer.Render(renderer,zoomFactor);
        buildingLayer.Render(renderer, zoomFactor);
        decorationLayer.Render(renderer, zoomFactor);

        foreach(name, coords; map) {
            auto value = name in isRendered;

            if (value !is null && !isRendered[name]) {
                write("Name from map" ~ name ~ " coords " ~ to!string(coords));
            } else if (value is null) {
                playerHashMap[name] = Player(renderer, "./assets/characters/character"~to!string(coords[2])~".bmp");
                isRendered[name] = true;
            }
            if ((name != client.getUserName()) && !(coords[0] == -1 || coords[1] == -1)) {
                playerHashMap[name].Move(coords[0], coords[1]);
                playerHashMap[name].Render(renderer);
            }
        }

        player.Render(renderer);
       
        // Draw the tile preview just so we can see all the different tiles in the tile map
        // ts.ViewTiles(renderer,480,400,8);

        if(keyboard[SDL_SCANCODE_SPACE]){
            ts.TileSetSelector(renderer);
        }

        // Little frame capping hack so we don't run too fast
        SDL_Delay(125);

        // Finally show what we've drawn
        // (i.e. anything where we have called SDL_RenderCopy will be in memory and presnted here)
        SDL_RenderPresent(renderer);
    }

    SDL_DestroyWindow(window);
}
