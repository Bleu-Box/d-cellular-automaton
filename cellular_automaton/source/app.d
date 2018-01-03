/* 
   A cellular automaton visualized with SDL2.
   When running this, pass the rule (0-255) you want it to show.
*/

import std.conv : to;
import std.bitmanip : BitArray;

import derelict.sdl2.sdl;

immutable int width = 1000;
immutable int height = 1000;

void main(string[] args) {
	import std.format : format;
	import std.string : toStringz;
	// get a rule number from arguments passed to `main'
	int rulenum = to!int(args[1]);
	// then turn it into a BitArray
	BitArray ruleset = BitArray([rulenum], 8);
	// set up SDL2 window and renderer
	SDL_Window* win;
	SDL_Renderer* renderer;
	const char* title = toStringz(format("Wolfram Rule #%d", rulenum));
	DerelictSDL2.load();
	SDL_Init(SDL_INIT_VIDEO);
	win = SDL_CreateWindow(title, 100, 100, width, height, 0);
	renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED);
	// initialize `cells' to all 0 (dead) except the middle cell
	int[width] cells;
	cells[cast(int)$/2] = 1;
	// rendering loop
	int y = 0;
	while(true) {	
		SDL_Event e;
		if(SDL_PollEvent(&e) && e.type == SDL_QUIT) break;
		// draw cells and make new row if screen isn't filled yet
		drawCells(renderer, cells, y);		
		SDL_RenderPresent(renderer);
	        if(y < height) updateCells(ruleset, cells);
		y++;
	}
	
	SDL_DestroyRenderer(renderer);
	SDL_DestroyWindow(win);	
}

// draws a white point for each live cell
void drawCells(SDL_Renderer* renderer, int[] cells, int y) {
	SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
		
	foreach(x, cell; cells) {
		if(cell == 1) SDL_RenderDrawPoint(renderer, x, y);
	}
}

// based on ruleset and neighbors, return a new cell value
int doRule(BitArray ruleset, int l, int me, int r) {
	import std.format : format;
	// the 3 cells can be turned into a base-10 number 
	// that is used to look up the middle cell's new value in the ruleset
	int i = to!int(format("%d%d%d", l, me, r), 2);
	return ruleset[i];
}

// update the cell array with `doRule'
void updateCells(BitArray ruleset, ref int[width] cells) {
	int[cells.length] oldCells;
        oldCells[] = cells;
	foreach(i, cell; oldCells) {
		// neighbors wrap around ends of array
		int l, r;
		if(i == 0) l = oldCells[$-1];
		else if(i == cells.length-1) r = oldCells[0];
		else {
			l = oldCells[i-1];
			r = oldCells[i+1];
		}

	        cells[i] = doRule(ruleset, l, cell, r);
	}
}
