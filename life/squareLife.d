module life.squareLife;
import std.stdio;
import arsd.jsvar;
import std.algorithm.searching;

class squareLife{
	protected {
		ubyte[] t_grid;
		ubyte[] t_nextGrid;
		int t_width;
		int t_height;		
	}
	/**
	Constructor, creates a grid.
	Params:
		width = width of the grid.
		height = height of the grid.
		initialValue = the value to set all life cells to.
	*/
	this(int width = 5,	int height = 5, ubyte initialValue = 0){
		t_width = width;
		t_height = height;
		t_grid = new ubyte[](width * height);
		t_grid[0 .. $] = initialValue;
		t_nextGrid = new ubyte[](width * height);
		t_nextGrid[0 .. $] = initialValue;
	}
	/**
	Constructor, creates a grid.
	Params:
		width = width of the grid.
		height = height of the grid.
		initialValue = the value to set all life cells to.
		ruleset = the rules to store.
	*/
	this(int width = 5,	int height = 5, ubyte initialValue = 0, var ruleset){
		parseRules(ruleset);
		t_width = width;
		t_height = height;
		t_grid = new ubyte[](width * height);
		t_grid[0 .. $] = initialValue;
		t_nextGrid = new ubyte[](width * height);
		t_nextGrid[0 .. $] = initialValue;
	}
	
	protected{
		/**
		wraps a coordinate in a direction.
		Params:
			coord = x, y, or z or any other coordinate to wrap.
			dimension = the size of the axis to wrap around.
		*/
		int wrapCellCoord(int coord, int dimension){
			return ((coord+dimension) % dimension);
		}
		/**
		you know how this works.
		*/
		auto getAnyCell(V)(int x, int y, V[] grid, int width){
			return grid[y * width + x];
		}
	}
	/**
	gets a cell at a certain location.
	Params:
		x = the x location of the cell
		y = the y location of the cell
	*/
	ubyte getWrappedCell(int x, int y){
		return t_grid[wrapCellCoord(y,t_height) * t_width + wrapCellCoord(x, t_width)];
	}
	/**
	gets a cell at a certain location.
	Params:
		x = the x location of the cell
		y = the y location of the cell
	*/
	ubyte getCell(int x, int y){
		//write(x); write(" "); writeln(y);
		//writeln(y * t_width + x);
		return t_grid[y * t_width + x];
	}
	/**
	sets a cell at a certain location.
	Params:
		x = the x location of the cell
		y = the y location of the cell
		value = the value to set the cell to, 0 by default.
	*/
	void setCell(int x, int y, ubyte value = 0){
		t_grid[y * t_width + x] = value;
	}
	/**
	counts neighbors of a specified type within the range of a kernel.
	Params:
		x = cell x position to get neighbors of.
		y = cell y position to get neighbors of.
		kern_cent_x = 'center' x position of the kernel.
		kern_cent_y = 'center' y position of the kernel.
		kernel = the kernel to search with, true means "count this cell in calculation", false means "exclude this cell from calculation."
		value = the type of cell to count, counts 0 by default.
	*/
	int countNeighbors(int x, int y, int kern_cent_x, int kern_cent_y, bool[] kernel, int kern_width, ubyte value = 0){
		int m_number = 0;
		for (int f_x = 0; f_x < kern_width; f_x++){
			for (int f_y = 0; f_y < kern_width; f_y++){
				if(getAnyCell(f_y , f_x, kernel, kern_width) == true && getWrappedCell(x - kern_cent_x + f_x, y - kern_cent_y + f_y) == value){
				m_number+=1;
				}
			}
		}
		return m_number;
	}
	/**
	copies the nextgrid onto the current grid and clears the nextgrid for the next step.
	*/
	
	void shuffleOntoCurrent(){
		t_grid[0 .. $] = t_nextGrid[0 .. $];
		t_nextGrid = new ubyte[t_width * t_height];
	}
	/**
	prints the grid, that's all.
	*/
	void printGrid(){
	for(int i = 0; i < t_width; i++){
			writeln(t_grid[i*t_height .. (i+1)*t_height]);
		}
	}
	string[] t_cellNames;
	string[][] t_aToB;
	int[][] t_neighborsNeeded;
	string[][] t_neighborsTypes;
	bool[] t_kernelGrid;
	int[] t_kernelCenter;
	int[] t_kernelDimensions;
	/**
	sub in known values for search kernel.
	*/
	int countNeighbors(int x, int y, ubyte value){
		return countNeighbors(x, y, t_kernelCenter[0], t_kernelCenter[1], t_kernelGrid, t_kernelDimensions[0], value);
	}

	void parseRules(var ruleset){
		t_cellNames = ruleset["cell names"].get!(string[]);
		writeln(t_cellNames);
		
		t_aToB = ruleset["rules"]["transformations"]["a->b"].get!(string[][]);
		writeln(t_aToB);
		
		t_neighborsNeeded = ruleset["rules"]["transformations"]["nieghbors needed"].get!(int[][]);
		writeln(t_neighborsNeeded);
		
		t_neighborsTypes = ruleset["rules"]["transformations"]["neigbor types tracked"].get!(string[][]);
		
		foreach(byte kernCell; ruleset["rules"]["kernel"]["grid"].get!(byte[])){
			t_kernelGrid ~= cast(bool)kernCell;
		}
		writeln(t_kernelGrid);
		
		t_kernelCenter = ruleset["rules"]["kernel"]["center"].get!(int[]);
		writeln(t_kernelCenter);
		
		t_kernelDimensions = ruleset["rules"]["kernel"]["dimensions"].get!(int[]);
		writeln(t_kernelDimensions);
	}

	void step(){
		//for every cell in order from the front (direction shouldn't matter.)
		//(... shouldn't.)
		foreach(int location, ubyte cell ; t_grid){
			// There will always be a default of 0, so even if the rules don't handle something, a valid state will always be chosen.
			ubyte nextCell = 0;
			//for every cell type in order from the front
			nameloop:
			foreach(ubyte cellNameLoc, string cellName; t_cellNames){
				//for every transformation rule in order from the front.
				foreach(int tfLoc, string[] tf;t_aToB){
					//if the cellname and cell location don't match
					//or 
					//the cell name and the transformation start don't match
					if(cellNameLoc != cell || cellName != tf[0]){
						//skip to next iteration.
						continue;
					}
					//otherwise, if it's a 'for all cases' rule
					//(-1 is a for all cases rule.)
					if(t_neighborsNeeded[tfLoc][0] == -1){
						//transform.
						nextCell = cast(ubyte)countUntil(t_cellNames, tf[1]);
						continue;
					}
					//otherwise
					//count the neigbors
					int neighbors = 0;
					//count all neighbor types we need to track.
					foreach(string neigborType ; t_neighborsTypes[tfLoc]){
						neighbors += countNeighbors( location % t_width, location / t_width, cast(ubyte)countUntil(t_cellNames, neigborType));
					}
					//if we have the right amount of neigbors
					if(canFind(t_neighborsNeeded[tfLoc],neighbors)){
						//transform.
						nextCell = cast(ubyte)countUntil(t_cellNames, tf[1]);
						continue nameloop;
					}
				}
			}
			//set the cell location.
			t_nextGrid[location] = nextCell;
		}
		//update the current grid.
		shuffleOntoCurrent();
	}

}