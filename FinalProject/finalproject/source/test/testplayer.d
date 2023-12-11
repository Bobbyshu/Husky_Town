module test.testplayer;

import std.stdio;
import std.string;

import sprite;
import tilemap;
import player;
import client;

import bindbc.sdl;

import std.conv: to;
import core.thread.osthread;

@("Check the location of the player in the tilemap")
unittest {
    // Create a tile for the testing 
    SDL_Window* window = SDL_CreateWindow("D SDL Tilemap Example",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        1088,
                                        704, 
                                        SDL_WINDOW_SHOWN);

    SDL_Renderer* renderer = null;
    renderer = SDL_CreateRenderer(window,-1,SDL_RENDERER_ACCELERATED);

    TileSet ts = TileSet(renderer, "././assets/kenney_roguelike-modern-city/Tilemap/tilemap_packed.bmp", 16,37,28);
    DrawableTileMap floorLayer = DrawableTileMap(ts, 1);
    DrawableTileMap buildingLayer = DrawableTileMap(ts, 2);
    DrawableTileMap decorationLayer = DrawableTileMap(ts, 3);

    Player player = Player(renderer, "./assets/characters/character1.bmp");

    player.MoveRight();

    player.Render(renderer);

    assert(player.GetX() == 26);
}


@("Check the player for object collison")
unittest {
    // Create a tile for the testing 
    SDL_Window* window = SDL_CreateWindow("D SDL Tilemap Example",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        1088,
                                        704, 
                                        SDL_WINDOW_SHOWN);

    SDL_Renderer* renderer = null;
    renderer = SDL_CreateRenderer(window,-1,SDL_RENDERER_ACCELERATED);

    TileSet ts = TileSet(renderer, "././assets/kenney_roguelike-modern-city/Tilemap/tilemap_packed.bmp", 16,37,28);
    DrawableTileMap floorLayer = DrawableTileMap(ts, 1);
    DrawableTileMap buildingLayer = DrawableTileMap(ts, 2);
    DrawableTileMap decorationLayer = DrawableTileMap(ts, 3);

    Player player = Player(renderer, "./assets/characters/character1.bmp");

    int zoomFactor = 2;

    floorLayer.Render(renderer,zoomFactor);
    buildingLayer.Render(renderer, zoomFactor);
    decorationLayer.Render(renderer, zoomFactor);
    player.Render(renderer);

    player.MoveUp();

    //player is able to move from his initial position    
    assert(floorLayer.canMove(player.GetY()+16,player.GetY(), player.GetX(), player.GetY(), zoomFactor) == true);
    
    player.MoveUp();
    player.MoveRight();
    player.MoveRight();
    // Player encountered an obstacle then he/she cannot move
    assert(floorLayer.canMove(player.GetY()+16,player.GetY(), player.GetX(), player.GetY(), zoomFactor) == false);
}

@("Check the player not moving out of the screen")
unittest {
    // Create a tile for the testing 
    SDL_Window* window = SDL_CreateWindow("D SDL Tilemap Example",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        1088,
                                        704, 
                                        SDL_WINDOW_SHOWN);

    SDL_Renderer* renderer = null;
    renderer = SDL_CreateRenderer(window,-1,SDL_RENDERER_ACCELERATED);

    TileSet ts = TileSet(renderer, "././assets/kenney_roguelike-modern-city/Tilemap/tilemap_packed.bmp", 16,37,28);
    DrawableTileMap floorLayer = DrawableTileMap(ts, 1);
    DrawableTileMap buildingLayer = DrawableTileMap(ts, 2);
    DrawableTileMap decorationLayer = DrawableTileMap(ts, 3);

    Player player = Player(renderer, "./assets/characters/character1.bmp");

    int zoomFactor = 2;

    floorLayer.Render(renderer,zoomFactor);
    buildingLayer.Render(renderer, zoomFactor);
    decorationLayer.Render(renderer, zoomFactor);
    player.Render(renderer);

    player.MoveUp();

    //Player is able to moving inside the screen initial position    
    writeln(floorLayer.canMove(player.GetY()-16,player.GetY(), player.GetX(), player.GetY(), zoomFactor) == true);
    
    player.MoveUp();
    player.MoveLeft();
    
    // Player restricted to move out of the screen
    assert(floorLayer.canMove(player.GetY()-16,player.GetY(), player.GetX(), player.GetY(), zoomFactor) == false);

}