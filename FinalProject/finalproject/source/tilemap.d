/**
 * Module for handling tilemap-related functionality in a game application.
 *
 * This module defines the `DrawableTileMap` and `TileSet` structs, which are used for
 * managing and rendering tilemaps in the game. These structs provide functionality
 * for loading tilesets, creating tilemaps, and rendering them using SDL.
 */
module tilemap;

// Load the SDL2 library
import bindbc.sdl;

/// DrawableTilemap is responsible for drawing 
/// the actual tiles for the tilemap data structure
/**
 * A struct for managing and rendering drawable tilemaps.
 *
 * This struct allows for the creation and manipulation of tilemaps, including
 * setting up different layers (floor, building, decoration), and rendering the
 * tilemap to the screen.
 */
struct DrawableTileMap{
    const int mMapXSize = 34;
    const int mMapYSize = 34;
 
    // Tile map with tiles
    TileSet mTileSet;

    // Static array for now for simplicity}
    int [mMapXSize][mMapYSize] mTiles;

    bool [][] checkObstable;

    // Set the tileset
    /**
     * Initializes the DrawableTileMap with a specific TileSet and layer type.
     * Different layers like floor, building, and decoration can be initialized.
     * 
     * Params:
     *   t = The TileSet to be used for the tilemap.
     *   layerType = An integer indicating the type of layer to set up (1 for floor, 2 for building, etc.).
     */
    this(TileSet t, int layerType){
        // Set our tilemap
        mTileSet = t;

        switch (layerType) {
            case 1:
                setupFloorLayer();
                break;
            case 2:
                setupBuildingLayer();
                break;
            case 3:
                setupDecorationLayer();
                break;
            default:
                break;
        }

        checkObstable = [
            [true, true, true, true, true, true, false, false, false, true, false, false, false, true, false, true, true, true, true, true, true],
            [true, true, true, true, true, true, false, true, false, false, false, false, false, false, false, true, true, true, true, true, true],
            [true, true, true, true, true, true, false, false, false, false, false, false, false, false, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, false, false, false, false, false, false, true, false, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, true, false, false, false, false, true, false, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, true, false, false, false, false, true, false, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, false, false, false, false, false, false, false, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, false, false, false, false, false, false, false, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, false, false, false, false, false, false, false, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, false, false, false, false, false, false, false, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
            [true, true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false],
            [true, true, true, true, true, true, false, true, false, false, true, false, false, false, true, false, false, false, true, false, false],
            [true, true, true, true, true, true, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false],
            [true, true, true, true, true, true, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false],
            [true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
            [true, true, true, true, true, true, false, true, false, false, false, false, false, false, true, false, false, false, false, false, false],
            [true, true, true, true, true, true, false, false, false, false, true, false, false, false, false, false, true, true, true, true, true],
            [false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, true, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, false],
            [false, false, false, false, false, false, true, true, false, false, false, false, false, false, false, false, true, false, false, true, true],
            [false, false, false, false, false, false, true, true, false, false, false, false, false, false, false, false, true, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false],
            [false, false, false, true, true, true, false, true, false, false, false, false, false, false, true, false, true, false, false, false, false],
            [false, true, true, true, true, true, true, false, false, false, false, false, false, true, false, false, false, true, false, true, true, true],
            [false, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, true, false, true, true, true],
            [false, true, true, true, true, true, true, true, false, false, true, false, false, false, false, false, true, false, true, true, true],
            [false, true, true, true, true, true, true, true, false, false, true, false, false, false, true, true, true, true, true, true, true],
            [false, true, true, true, true, true, true, true, false, false, true, false, false, false, true, true, true, true, true, true, true],
            [false, true, true, true, true, true, true, true, false, false, false, false, false, false, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, false, false, false, true, false, false, false, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
        ]; 

        // for (int r = 0; r < mMapXSize; r++) {
        //     for (int c = 0; c < mMapYSize; c++) {
        //         checkObstable[r][c] = false;
        //     }
        // }

        
    }

    /**
     * Sets up the floor layer of the tilemap.
     * This method initializes the tiles array with indices for the floor layer.
     */
    void setupFloorLayer() {
        // Set all tiles to 'default' tile
        for(int y=0; y < mMapYSize; y++){
            for(int x=0; x < mMapXSize; x++){
                if (y == 9 && x > 0 && x < 5) {
                    mTiles[x][y] = 747;
                }
                else if (y == 10 && x > 0 && x < 19) {
                    mTiles[x][y] = 747;
                }
                else if ( y == 9 && x > 12 && x < 19) {
                    mTiles[x][y] = 747;
                }
                else if ( y == 8 && x > 12 && x < 19) {
                    mTiles[x][y] = 741;
                }
                else if (y == 9 && x > 4 && x < 13) {
                    mTiles[x][y] = 741;
                }
                else if (y == 8 && x < 5) {
                    mTiles[x][y] = 741;
                }
                else if (x == 0 && y > 8 && y < 11) {
                    mTiles[x][y] = 746;
                }
                else if (y == 11 && x < 20) {
                    mTiles[x][y] = 821;
                }
                else if (x == 19 && y < 11) {
                    mTiles[x][y] = 747;
                }
                else if (x == 19 && y > 0 && y < 5) {
                    mTiles[x][y] = 748;
                }
                else if (x == 20 && y < 11) {
                    mTiles[x][y] = 748;
                }
                else if (x == 20 && y > 0 && y < 5) {
                    mTiles[x][y] = 714;
                }
                else if (x == 21 && y < 12) {
                    mTiles[x][y] = 714;
                }
                else if (x == 22 && y < 12) {
                    mTiles[x][y] = 749;
                }
                else if (x == 23 && y < 12) {
                    mTiles[x][y] = 714;
                }
                else if (y == 0 && x > 23 && x < 34) {
                    mTiles[x][y] = 712;
                }
                else if (y == 1 && x > 23 && x < 34) {
                    mTiles[x][y] = 714;
                }
                else if (y == 2 && x > 24 && x < 34) {
                    mTiles[x][y] = 710;
                }
                else if (x > 26 && x < 34 && y == 9) {
                    mTiles[x][y] = 741;
                } 
                else if (y > 2 && y < 11 && x > 24 && x < 34) {
                    mTiles[x][y] = 747;
                }
                else if (x == 24 && y > 2 && y < 11) {
                    mTiles[x][y] = 746;
                }
                else if ( x > 24 && x < 34 && y == 11) {
                    mTiles[x][y] = 821;
                }
                //Bottom part code
                else if( (y == 12 || y ==14) && ((x >= 0 && x < 19) || (x > 19 && x < 25) || (x > 25 && x < 34))){
                    mTiles[x][y] = 714;
                }
                else if( ( y == 13 ) && ((x >= 0 && x < 19) || (x > 19 && x < 25) || (x > 26 && x < 34))){
                    mTiles[x][y] = 712;
                }
                else if( ( y >11 && y < 15) && (x == 19 || x == 25 )){
                    mTiles[x][y] = 825;
                }
                else if( ( x == 14 || x == 16 ) && ((y > 14 && y < 19) || (y > 19 && y < 22))){
                    mTiles[x][y] = 714;
                }
                else if( ( x == 15) && ((y > 14 && y < 19) || (y > 19 && y < 22))){
                    mTiles[x][y] = 749;
                }
                else if(x > 13 && x < 17 && (y == 19)){
                    mTiles[x][y] = 828;
                }
                else if( ( x < 13 && x >= 0) && y == 15){
                    mTiles[x][y] = 710;
                }
                else if( ( x == 11 || x == 12 ) && (y > 15 && y < 22)){
                    mTiles[x][y] = 747;
                }
                else if( ( x == 13 ) && (y > 15 && y < 22)){
                    mTiles[x][y] = 748;
                }
                else if( ( x >=0 && x < 3) && y == 16){
                    mTiles[x][y] = 821;
                }
                else if ((x >17 && x < 34) && (y > 15 && y < 18)){
                    mTiles[x][y] = 747;
                }
                else if ((x == 17) && (y > 15 && y < 22)){
                    mTiles[x][y] = 746;
                }
                else if ((x > 17 && x < 34) && (y == 15)){
                    mTiles[x][y] = 710;
                }
                else if ((x > 19 && x < 23) && (y > 18 && y < 22)){
                    mTiles[x][y] = 888;
                }
                else if ((x > 23 && x < 30) && (y > 18 && y < 21)){
                    mTiles[x][y] = 888;
                }
                else if (y == 21 && (x > 23 && x < 26)){
                    mTiles[x][y] = 981;
                }
                else if ((x == 19) && (y > 18 && y < 22)){
                    mTiles[x][y] = 69;
                }
                else if ((y == 18) && (x > 19 && x < 23)){
                    mTiles[x][y] = 33;
                }
                else if ((y == 18) && (x > 23 && x < 30)){
                    mTiles[x][y] = 33;
                }
                else {
                    mTiles[x][y] = 973;
                }

            }
        }
            mTiles[24][2] = 709;
            mTiles[20][11] = 822;
            mTiles[20][1] = 714;
            mTiles[20][2] = 713;
            mTiles[20][3] = 750;
            mTiles[20][4] = 714;
            mTiles[24][11] = 820;
            //Bottom part code
            mTiles[13][15] = 711;
            mTiles[17][15] = 709;
            mTiles[18][18] = 207;
            mTiles[18][19] = 244;
            mTiles[18][20] = 244;
            mTiles[18][21] = 281;
            mTiles[23][18] = 1018;
            mTiles[23][19] = 1014;
            mTiles[23][20] = 944;
            mTiles[23][21] = 942;
            mTiles[1][17] = 1008;
            mTiles[26][13] = 714;
            mTiles[26][21] = 888;
            
    }

    /**
     * Sets up the building layer of the tilemap.
     * This method initializes the tiles array with indices for the building layer.
     */
    void setupBuildingLayer() {
        for(int y=0; y < mMapYSize; y++){
            for(int x=0; x < mMapXSize; x++){
                if (x < 2 &&y == 0) {
                    mTiles[x][y] = 756;
                }
                else if (x < 4 && y == 1) {
                    mTiles[x][y] = 2;
                }
                else if (x < 4 && y == 2) {
                    mTiles[x][y] = 6;
                }
                else if (x < 4 && y == 3) {
                    mTiles[x][y] = 39;
                }
                else if (x < 4 && y == 4) {
                    mTiles[x][y] = 187;
                }
                else if (x < 4 && y == 6) {
                    mTiles[x][y] = 187;
                }
                else if (x < 4 && y == 5) {
                    mTiles[x][y] = 261;
                }
                else if (x < 4 && y == 7) {
                    mTiles[x][y] = 298;
                }
                else if (x == 4 && y > 3 && y < 7) {
                    mTiles[x][y] = 188;
                }
                else if (x > 5 && x < 12 && y == 0) {
                    mTiles[x][y] = 14;
                }
                else if (x > 5 && x < 12 && y == 1) {
                    mTiles[x][y] = 47;
                }
                else if (x == 5 && y > 1 && y < 8) {
                    mTiles[x][y] = 349;
                }
                //Bottom Part Code
                else if ((x == 6 || x == 8 || x == 9 || x == 11) && y > 1 && y < 8) {
                    mTiles[x][y] = 350;
                }
                else if ((x == 7 || x == 10) && y > 1 && y < 8) {
                    mTiles[x][y] = 239;
                }
                else if (x == 12 && y > 1 && y < 8) {
                    mTiles[x][y] = 351;
                }
                else if (y == 8 && (x == 6 || x == 8 || x == 9 || x == 11)) {
                    mTiles[x][y] = 384;
                }
                else if (y == 8 && (x == 7 || x == 10)) {
                    mTiles[x][y] = 310;
                }
                else if (x == 13 && y < 3) {
                    mTiles[x][y] = 19;
                }
                else if (x > 13 && x < 18 && y < 3) {
                    mTiles[x][y] = 22;
                }
                else if ( x > 13 && x < 18 && y == 3) {
                    mTiles[x][y] = 55;
                }
                else if (x == 18 && y < 3) {
                    mTiles[x][y] = 56;
                }
                else if (x == 13 && y > 3 && y < 7) {
                    mTiles[x][y] = 190;
                }
                else if (x > 13 && x < 18 && y > 3 && y < 7) {
                    mTiles[x][y] = 191;
                }
                else if (x == 18 && y > 3 && y < 7) {
                    mTiles[x][y] =  192;
                }
                else if (y == 7 && x > 13 && x < 18) {
                    mTiles[x][y] = 302;
                }
                else if (x == 26 && y > 4 && y < 7) {
                    mTiles[x][y] = 576;
                }
                else if (y == 3 && x > 27 && x < 32) {
                    mTiles[x][y] = 2;
                }
                else if (y == 4 && x > 27 && x < 32) {
                    mTiles[x][y] = 39;
                }
                else if ((y == 5 || y == 7) && x > 27 && x < 32) {
                    mTiles[x][y] = 187;
                }
                else if (y == 6 && x > 27 && x < 32) {
                    mTiles[x][y] = 261;
                }
                else if (y == 8 && x > 27 && x < 32) {
                    mTiles[x][y] = 298;
                }
                else if (x == 33 && y > 0 && y < 7) {
                    mTiles[x][y] = 349;
                }
                //Bottom Part code
                else if ( ( x >=0 && x < 2) && y == 18) {
                    mTiles[x][y] = 18;
                }
                else if ( x == 2 && (y > 18 && y < 22)) {
                    mTiles[x][y] = 56;
                }
                else if ( (x == 0 || x == 1) && (y > 18 && y < 22)) {
                    mTiles[x][y] = 22;
                }
                else if (x==3 && (y > 16 && y < 19)){
                    mTiles[x][y] = 11;
                }
                else if (y==16 && (x > 3 && x < 10)){
                    mTiles[x][y] = 10;
                }
                else if (y==19 && (x > 3 && x < 10)){
                    mTiles[x][y] = 47;
                }
                else if (x==10 && (y > 16 && y < 19)){
                    mTiles[x][y] = 48;
                }
                else if (x==3 && (y > 18 && y < 22)){
                    mTiles[x][y] = 190;
                }
                else if (x==10 && (y > 18 && y < 22)){
                    mTiles[x][y] = 192;
                }
                else if ((x >3 && x < 10) && (y > 19 && y < 22)){
                    mTiles[x][y] = 191;
                }
                else if ((x >3 && x < 10) && (y > 16 && y < 19)){
                    mTiles[x][y] = 14;
                }
                else if ((x > 30 && x < 34) && (y == 16)){
                    mTiles[x][y] = 18;
                }
                else if ((y > 16 && y < 20) && (x == 30)){
                    mTiles[x][y] = 19;
                }
                else if ((x > 30 && x < 34) && (y == 20)){
                    mTiles[x][y] = 55;
                }
                else if ((x > 30 && x < 34) && y == 21){
                    mTiles[x][y] = 191;
                }
                else if ((x > 30 && x < 34) && (y > 16 && y < 20)){
                    mTiles[x][y] = 22;
                }
                else {
                    mTiles[x][y] = -1;
                }
                
            }
        }

        mTiles[2][0] = 759;
        mTiles[4][1] = 1;
        mTiles[4][2] = 40;
        mTiles[4][3] = 38;
        mTiles[4][5] = 262;
        mTiles[4][7] = 299;
        mTiles[5][0] = 11;
        mTiles[12][0] = 48;
        mTiles[5][1] = 45;
        mTiles[12][1] = 46;
        mTiles[5][8] = 383;
        mTiles[12][8] = 385;
        mTiles[8][0] = 51;
        mTiles[11][0] = 51;
        mTiles[13][3] = 53;
        mTiles[18][3] = 54;
        mTiles[13][7] = 301;
        mTiles[18][7] = 303;
        mTiles[26][4] = 539;
        mTiles[26][7] = 613;
        mTiles[27][3] = 0;
        mTiles[27][4] = 37;
        mTiles[27][5] = 186;
        mTiles[27][6] = 260;
        mTiles[27][7] = 186;
        mTiles[27][8] = 297;
        mTiles[32][3] = 1;
        mTiles[32][4] = 38;
        mTiles[32][5] = 188;
        mTiles[32][6] = 262;
        mTiles[32][7] = 188;
        mTiles[32][8] = 299;
        mTiles[33][0] = 53;
        mTiles[33][7] = 198;
        mTiles[33][8] = 352;
        //Bottom Part Code
        mTiles[2][18] = 17;
        mTiles[3][16] = 8;
        mTiles[10][16] = 9;
        mTiles[3][19] = 45;
        mTiles[10][19] = 46;
        mTiles[30][16] = 16;
        mTiles[30][21] = 190;
        mTiles[30][20] = 53;
        mTiles[19][18] = 32;
    }

    /**
     * Sets up the decoration layer of the tilemap.
     * This method initializes the tiles array with indices for the decoration layer.
     */
    void setupDecorationLayer() {
        for(int y=0; y < mMapYSize; y++){
            for(int x=0; x < mMapXSize; x++){
                if ((x == 1 || x == 3) && y == 5) {
                    mTiles[x][y] = 618;
                }
                else if ((x == 1 || x == 3) && y == 7) {
                    mTiles[x][y] = 982;
                }
                else if (x > 13 && x < 18 && y == 5) {
                    mTiles[x][y] = 728;
                }
                else if ( x > 27 && x < 32 && y == 5) {
                    mTiles[x][y] = 617;
                }
                else if ( x > 27 && x < 32 && y == 7) {
                    mTiles[x][y] = 431;
                }
                else if ( ((x == 5 || x ==7 || x ==9 ) && y == 21) || (x == 4 && y == 17)) {
                    mTiles[x][y] = 730;
                }
                else if (((x == 1 || x==13 || x==27 ) && y == 14) || (x==17 && y ==15)) {
                    mTiles[x][y] = 634;
                }
                else if (((x == 1 || x == 13 || x==27 ) && y == 15) || (x==17 && y==16)) {
                    mTiles[x][y] = 671;
                }
                else if ( (x == 1 || x==27 ) && y == 13) {
                    mTiles[x][y] = 633;
                }
                else {
                    mTiles[x][y] = -1;
                }
                
            }
        }

        mTiles[1][2] = 544;
        mTiles[8][6] = 294;
        mTiles[9][6] = 295;
        mTiles[8][7] = 911;
        mTiles[9][7] = 912;
        mTiles[8][8] = 948;
        mTiles[9][8] = 949;
        mTiles[6][0] = 546;
        mTiles[14][1] = 544;
        mTiles[17][1] = 544;
        mTiles[18][4] = 545;
        mTiles[15][7] = 878;
        mTiles[16][7] = 879;
        mTiles[15][6] = 216;
        mTiles[16][6] = 218;
        mTiles[19][8] = 554;
        mTiles[19][9] = 591;
        mTiles[1][11] = 497;
        mTiles[5][9] = 678;
        mTiles[6][9] = 643;
        mTiles[12][9] = 572;
        mTiles[13][9] = 573;
        mTiles[17][9] = 289;
        mTiles[26][5] = 532;
        mTiles[31][3] = 546;
        mTiles[28][6] = 327;
        mTiles[29][6] = 328;
        mTiles[30][6] = 365;
        mTiles[31][6] = 366;
        mTiles[27][7] = 430;
        mTiles[32][7] = 432;
        mTiles[27][8] = 465;
        mTiles[32][8] = 466;
        mTiles[28][8] = 1021;
        mTiles[30][8] = 457;
        mTiles[31][8] = 459;
        mTiles[29][9] = 675;
        mTiles[30][9] = 676;
        mTiles[31][9] = 677;
        mTiles[32][9] = 679;
        mTiles[2][8] = 401;
        mTiles[2][9] = 475;
        mTiles[20][5] = 600;
        mTiles[20][6] = 674;
        mTiles[19][1] = 500;
        mTiles[19][3] = 500;
        mTiles[18][9] = 558;
        mTiles[18][10] = 634;
        mTiles[18][11] = 671;
        mTiles[29][1] = 601;
        mTiles[30][1] = 602;
        mTiles[29][2] = 673;
        mTiles[26][8] = 406;
        mTiles[26][9] = 480;
        mTiles[29][20] = 645;
        mTiles[28][20] = 646;
        mTiles[27][20] = 644;
        mTiles[27][21] = 686;
        mTiles[13][20] = 475;
        mTiles[13][19] = 401;
        mTiles[28][18] = 438;
        mTiles[28][17] = 401;
        mTiles[20][18] = 438;
        mTiles[20][17] = 401;
        mTiles[20][19] = 70;
        mTiles[19][21] = 401;
        mTiles[26][21] = 401;
        mTiles[25][20] = 438;
        mTiles[25][19] = 401;
        mTiles[13][12] = 956;
        mTiles[14][12] = 957;
        mTiles[15][12] = 958;
        mTiles[13][11] = 919;
        mTiles[14][11] = 920;
        mTiles[15][11] = 921;
        mTiles[4][13] = 626;
        mTiles[5][13] = 627;
        mTiles[6][13] = 628;
        mTiles[4][14] = 663;
        mTiles[5][14] = 664;
        mTiles[6][14] = 665;
        mTiles[29][11] = 771;
        mTiles[30][11] = 772;
        mTiles[31][11] = 773;
        mTiles[29][12] = 808;
        mTiles[30][12] = 809;
        mTiles[31][12] = 810;
        mTiles[32][11] = 623;
        mTiles[33][11] = 624;
        mTiles[32][12] = 660;
        mTiles[33][12] = 661;
        mTiles[21][8] = 699;
        mTiles[22][8] = 700;
        mTiles[21][9] = 736;
        mTiles[22][9] = 737;
        mTiles[21][21] = 109;
        mTiles[2][18] = 543;
        mTiles[0][21] = 543;
        mTiles[31][17] = 616;
        mTiles[29][21] = 532;
        mTiles[20][15] = 533;
        mTiles[25][18] = 497;
        mTiles[0][15] = 567;
        mTiles[13][13] = 555;
        mTiles[17][14] = 557;
        mTiles[26][15] = 552;
        mTiles[26][16] = 589;
        mTiles[24][15] = 554;
        mTiles[24][16] = 591;
    }
 
    /**
     * Renders the tilemap on the screen.
     * Iterates through the tile indices and draws each tile at its respective position.
     * 
     * Params:
     *   renderer = The SDL_Renderer used for rendering.
     *   zoomFactor = The factor by which the tile size is multiplied for rendering.
     */
    void Render(SDL_Renderer* renderer, int zoomFactor=1){
        for(int y=0; y < mMapYSize; y++){
            for(int x=0; x < mMapXSize; x++){
                if (mTiles[x][y] != -1) { // Check for transparency
                    mTileSet.RenderTile(renderer, mTiles[x][y], x, y, zoomFactor);
                }
            }
        }
    }

    // Specify a position local coorindate on the window
    /**
     * Returns the tile index at a given position on the screen.
     * Useful for identifying which tile is under the cursor or a game object.
     * 
     * Params:
     *   localX = The x-coordinate on the screen.
     *   localY = The y-coordinate on the screen.
     *   zoomFactor = The factor by which the tile size has been multiplied.
     * 
     * Returns:
     *   The index of the tile at the specified position or -1 if out of bounds.
     */
    int GetTileAt(int localX, int localY, int zoomFactor=1){
        int x = localX / (mTileSet.mTileSize * zoomFactor);
        int y = localY / (mTileSet.mTileSize * zoomFactor);

        import std.stdio;
        import std.conv: to;
        writeln("Y value: " ~ to!string(y));
        writeln("Y value * mMapYSize: " ~ to!string(mTileSet.mTileSize));
        writeln("Y value * zoom " ~to!string(mTileSet.mTileSize * zoomFactor));
        writeln("localY: " ~ to!string(localY));
        writeln("mMapYSize: " ~ to!string(mMapYSize));

        if(x < 0 || y < 0 || x> mMapXSize-1 || y > mMapYSize-1 ){
            // TODO: Perhaps log error?
            // Maybe throw an exception -- think if this is possible!
            // You decide the proper mechanism!
            return -1;
        }

        return mTiles[x][y]; 
    }

    // Function to check if the character can move to another location
    /**
     * Determines if movement to a specific position on the tilemap is possible.
     * Used for collision detection or pathfinding logic.
     * 
     * Params:
     *   nextLocalX = The x-coordinate of the next position.
     *   nextLocalY = The y-coordinate of the next position.
     *   currentLocalX = The current x-coordinate of the object.
     *   currentLocalY = The current y-coordinate of the object.
     *   zoomFactor = The factor by which the tile size has been multiplied.
     * 
     * Returns:
     *   true if movement is possible, false otherwise.
     */
    bool canMove(int nextLocalX, int nextLocalY, int currentLocalX, int currentLocalY, int zoomFactor=1) {
        import std.stdio;
        import std.conv: to;

        int nextX = nextLocalX / (mTileSet.mTileSize * zoomFactor);
        int nextY = nextLocalY / (mTileSet.mTileSize * zoomFactor);

        int currentX = currentLocalX / (mTileSet.mTileSize * zoomFactor);
        int currentY = currentLocalY / (mTileSet.mTileSize * zoomFactor);

        if (nextX == currentX && nextY == currentY) {
            return true;
        }

            if(nextX < 0 || nextY < 0 || nextX > mMapXSize-1 || nextY > mMapYSize-1 || nextY > 20 || checkObstable[nextX][nextY]){
            // TODO: Perhaps log error?
            // Maybe throw an exception -- think if this is possible!
            // You decide the proper mechanism!
            return false;
        }

        //checkObstable[currentX][currentY] = false;
        //checkObstable[nextX][nextY] = true;

        return true;
    }
}


/// Tilemap struct for loading a tilemap
/// and rendering tiles
/**
 * A struct for managing a tileset.
 *
 * This struct is responsible for loading a tileset image, and provides
 * functionality for rendering individual tiles and the entire tileset.
 */
struct TileSet{

        // Rectangle storing a specific tile at an index
		SDL_Rect[] mRectTiles;
        // The full texture loaded onto the GPU of the entire
        // tile map.
		SDL_Texture* mTexture;
        // Tile dimensions (assumed to be square)
        int mTileSize;
        // Number of tiles in the tilemap in the x-dimension
        int mXTiles;
        // Number of tiles in the tilemap in the y-dimension
        int mYTiles;

        /// Constructor
        /**
        * Initializes the TileSet with a texture from a given file path.
        * The texture is loaded and divided into tiles based on specified dimensions.
        * 
        * Params:
        *   renderer = The SDL_Renderer used for loading textures.
        *   filepath = The file path to the tileset image.
        *   tileSize = The size (width and height) of each tile.
        *   xTiles = The number of tiles horizontally in the tileset.
        *   yTiles = The number of tiles vertically in the tileset.
        */
		this(SDL_Renderer* renderer, string filepath, int tileSize, int xTiles, int yTiles){
            mTileSize = tileSize;
            mXTiles   = xTiles;
            mYTiles   = yTiles;

			// Load the bitmap surface
			SDL_Surface* myTestImage   = SDL_LoadBMP(filepath.ptr);
			// Create a texture from the surface
			mTexture = SDL_CreateTextureFromSurface(renderer,myTestImage);
			// Done with the bitmap surface pixels after we create the texture, we have
			// effectively updated memory to GPU texture.
			SDL_FreeSurface(myTestImage);

            // Populate a series of rectangles with individual tiles
            for(int y = 0; y < yTiles; y++){
                for(int x =0; x < xTiles; x++){
                    SDL_Rect rect;
			        rect.x = x*tileSize;
        			rect.y = y*tileSize;
		        	rect.w = tileSize;
        			rect.h = tileSize;

                    mRectTiles ~= rect;
                }
            }
		}

        /// Little helper function that displays
        /// all of the tiles one after the other in an 
        /// animation. This is just a quick way to preview
        /// the tile
        /**
        * Displays all tiles from the tileset in a sequence for preview.
        * The tiles are rendered in order, allowing for quick visual inspection of the entire tileset.
        * 
        * Params:
        *   renderer = The SDL_Renderer used for rendering.
        *   x = The x-coordinate on the screen where the preview starts.
        *   y = The y-coordinate on the screen where the preview starts.
        *   zoomFactor = The factor by which the tile size is multiplied for rendering.
        */
        void ViewTiles(SDL_Renderer* renderer, int x, int y, int zoomFactor=1){
            import std.stdio;

			static int tilenum =0;

            if(tilenum > mRectTiles.length-1){
				tilenum =0;
			}

            // Just a little helper for you to debug
            // You can omit this as necessary
            writeln("Showing tile number: ",tilenum);

            // Select a specific tile from our
            // tiemap texture, by offsetting correcting
            // into the tilemap
			SDL_Rect selection;
            selection = mRectTiles[tilenum];

            // Draw a preview of the actual tile
            SDL_Rect rect;
            rect.x = x;
            rect.y = y;
            rect.w = mTileSize * zoomFactor;
            rect.h = mTileSize * zoomFactor;

    	    SDL_RenderCopy(renderer,mTexture,&selection,&rect);
			tilenum++;
        }


        /// This is a handy helper function to tell you
        /// which tile your mouse is over.
        /**
        * Highlights the tile currently under the mouse cursor.
        * Useful for selecting or inspecting individual tiles in the tileset.
        * 
        * Params:
        *   renderer = The SDL_Renderer used for rendering.
        */
        void TileSetSelector(SDL_Renderer* renderer){
            import std.stdio;
            
            int mouseX,mouseY;
            int mask = SDL_GetMouseState(&mouseX, &mouseY);

            int xTileSelected = mouseX / mTileSize;
            int yTileSelected = mouseY / mTileSize;
            int tilenum = yTileSelected * mXTiles + xTileSelected;
            if(tilenum > mRectTiles.length-1){
                return;
            }

            writeln("mouse  : ",mouseX,",",mouseY);
            writeln("tile   : ",xTileSelected,",",yTileSelected);
            writeln("tilenum: ",tilenum);

            SDL_SetRenderDrawColor(renderer, 255, 255, 255,255);

            // Tile to draw out on
            SDL_Rect rect = mRectTiles[tilenum];

            // Copy tile to our renderer
            // Note: We need a rectangle that's the exact dimensions of the
            //       image in order for it to render appropriately.
            SDL_Rect tilemap;
            tilemap.x = 0;
            tilemap.y = 0;
            tilemap.w = mXTiles * mTileSize;
            tilemap.h = mYTiles * mTileSize;
    	    SDL_RenderCopy(renderer,mTexture,null,&tilemap);
            // Draw a rectangle
            SDL_RenderDrawRect(renderer, &rect);

        }

        /// Draw a specific tile from our tilemap
        /**
        * Renders a specific tile from the tileset at a given position.
        * 
        * Params:
        *   renderer = The SDL_Renderer used for rendering.
        *   tile = The index of the tile to render.
        *   x = The x-coordinate on the tilemap where the tile is to be rendered.
        *   y = The y-coordinate on the tilemap where the tile is to be rendered.
        *   zoomFactor = The factor by which the tile size is multiplied for rendering.
        */
		void RenderTile(SDL_Renderer* renderer, int tile, int x, int y, int zoomFactor=1){
            if(tile > mRectTiles.length-1){
                // NOTE: Could use 'logger' here to log an error
                return;
            }

            // Select a specific tile from our
            // tiemap texture, by offsetting correcting
            // into the tilemap
			SDL_Rect selection = mRectTiles[tile];

            // Tile to draw out on
            SDL_Rect rect;
            rect.x = mTileSize * x * zoomFactor;
            rect.y = mTileSize * y * zoomFactor;
            rect.w = mTileSize * zoomFactor;
            rect.h = mTileSize * zoomFactor;
 
            // Copy tile to our renderer
    	    SDL_RenderCopy(renderer,mTexture,&selection,&rect);
		}
}

