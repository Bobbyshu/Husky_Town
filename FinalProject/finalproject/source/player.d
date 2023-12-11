/**
 * Module containing the Player struct used in a game application.
 *
 * This module defines the `Player` struct which represents a player in the game.
 * It includes methods for moving the player and rendering the player's sprite
 * on the screen.
 */
module player;

// Load the SDL2 library
import bindbc.sdl;
import sprite;

/**
 * Represents a player in the game.
 *
 * This struct encapsulates the player's sprite and provides functionality for
 * moving the player in different directions, as well as rendering the player on
 * the screen.
 */
struct Player{
    // Load our sprite
    Sprite mSprite;
    string name;

    /**
     * Constructor for the Player struct.
     *
     * Params:
     *     renderer = The SDL renderer to use for rendering the sprite.
     *     filepath = The file path of the sprite image.
     */
    this(SDL_Renderer* renderer, string filepath){
        mSprite = Sprite(renderer,filepath);
    }

    /**
     * Gets the player's current x-coordinate.
     *
     * Returns:
     *     The x-coordinate of the player.
     */
    int GetX(){
        return mSprite.mXPos;
    }
    /**
     * Gets the player's current y-coordinate.
     *
     * Returns:
     *     The y-coordinate of the player.
     */
    int GetY(){
        return mSprite.mYPos;
    }
    /**
     * Moves the player up by a fixed amount.
     */
    void MoveUp(){
        mSprite.mYPos -=16;
        mSprite.mState = STATE.WALK;
        mSprite.mDir = DIRECTION.UP;
    }
    /**
     * Moves the player down by a fixed amount.
     */
    void MoveDown(){
        mSprite.mYPos +=16;
        mSprite.mState = STATE.WALK;
        mSprite.mDir = DIRECTION.DOWN;
    }
    /**
     * Moves the player left by a fixed amount.
     */
    void MoveLeft(){
        mSprite.mXPos -=16;
        mSprite.mState = STATE.WALK;
        mSprite.mDir = DIRECTION.LEFT;
    }
    /**
     * Moves the player right by a fixed amount.
     */
    void MoveRight(){
        mSprite.mXPos +=16;
        mSprite.mState = STATE.WALK;
        mSprite.mDir = DIRECTION.RIGHT;
    }
    /**
     * Moves the player to a specific position.
     *
     * Params:
     *     xPos = The x-coordinate to move the player to.
     *     yPos = The y-coordinate to move the player to.
     */
    void Move(int xPos, int yPos) {
        if (xPos != mSprite.mXPos || yPos != mSprite.mYPos) {
            if( xPos != mSprite.mXPos && xPos > mSprite.mXPos){
                mSprite.mDir = DIRECTION.RIGHT;
            }else if(xPos != mSprite.mXPos && xPos < mSprite.mXPos){
                mSprite.mDir = DIRECTION.LEFT;
            }else if(yPos != mSprite.mYPos && yPos < mSprite.mYPos){
                mSprite.mDir = DIRECTION.UP;
            }else if(yPos != mSprite.mYPos && yPos > mSprite.mYPos){
                mSprite.mDir = DIRECTION.DOWN;
            }
            mSprite.mXPos = xPos;
            mSprite.mYPos = yPos;
            mSprite.mState = STATE.WALK;
        } else {
            mSprite.mState = STATE.IDLE;
        }
    }
    /**
     * Renders the player's sprite on the screen.
     *
     * Params:
     *     renderer = The SDL renderer to use for rendering the sprite.
     */
    void Render(SDL_Renderer* renderer){
        mSprite.Render(renderer);
        mSprite.mState = STATE.IDLE;
    }
}
