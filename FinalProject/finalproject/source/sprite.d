/**
 * Module for handling sprite-related functionality in a game application.
 *
 * This module defines the `Sprite` struct, which encapsulates the details of a sprite,
 * such as its texture, position, and animation state. It provides functionality for
 * rendering the sprite on the screen.
 */
module sprite;

// Load the SDL2 library
import bindbc.sdl;

/// Store state for sprites and very simple animation
/**
 * Enumeration for sprite states.
 *
 * Defines the possible states a sprite can be in, such as idle or walking,
 * which can be used to control sprite animations.
 */
enum STATE{IDLE, WALK};

enum DIRECTION{LEFT, RIGHT, UP, DOWN};

/// Sprite that holds a texture and position
/**
 * Represents a game sprite.
 *
 * This struct contains the details of a sprite, including its texture, position,
 * and current state. It provides methods for rendering the sprite using SDL.
 */
struct Sprite{

        int mXPos=10;
        int mYPos=250;
		SDL_Rect mRectangle;
		SDL_Texture* mTexture;
        int mFrame;
		int direct = 0;

        STATE mState;
		DIRECTION mDir;

	/**
     * Constructor for the Sprite struct.
     *
     * Params:
     *     renderer = The SDL renderer used for rendering the sprite.
     *     filepath = The file path of the sprite's image.
     */
		this(SDL_Renderer* renderer, string filepath){
			// Load the bitmap surface
			SDL_Surface* myTestImage   = SDL_LoadBMP(filepath.ptr);
			// Create a texture from the surface
			mTexture = SDL_CreateTextureFromSurface(renderer,myTestImage);
			// Done with the bitmap surface pixels after we create the texture, we have
			// effectively updated memory to GPU texture.
			SDL_FreeSurface(myTestImage);

			// Rectangle is where we will represent the shape
			mRectangle.x = mXPos;
			mRectangle.y = mYPos;
			mRectangle.w = 64;
			mRectangle.h = 64;
		}

		/**
		* Renders the sprite on the screen.
		*
		* Params:
		*     renderer = The SDL renderer used for rendering the sprite.
		*/
		void Render(SDL_Renderer* renderer){

			SDL_Rect selection;
			selection.x = 64*mFrame;
			selection.y = direct;
			selection.w = 64;
			selection.h = 64;

			mRectangle.x = mXPos;
			mRectangle.y = mYPos;

    	    SDL_RenderCopy(renderer,mTexture,&selection,&mRectangle);

            if(mState == STATE.WALK){
			    mFrame++;
                if(mFrame > 2){
                    mFrame =0;
                }
            }

			
		    if(mDir == DIRECTION.DOWN){
				direct = 0;
			}
			else if(mDir == DIRECTION.UP){
				direct = 192;
			}
			else if(mDir == DIRECTION.LEFT){
				direct = 64;
			}
			else if(mDir == DIRECTION.RIGHT){
				direct = 128;
			}
		}


		// /**
		// * Remove the sprite from the tilemap
		// * Params:
     	// * renderer = The SDL renderer used for rendering the sprite.
     	// */
		// void RemoveSprite(SDL_Renderer* renderer) {
		// 	SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
		// 	SDL_RenderFillRect(renderer, mRectangle);
		// 	SDL_RenderPresent(renderer);
		// }
}

