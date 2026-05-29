module life.squareLife;
import std.stdio;

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
		write(x); write(" "); writeln(y);
		writeln(y * t_width + x);
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
	*/
	void printGrid(){
	for(int i = 0; i < t_width; i++){
			writeln(t_grid[i*t_height .. (i+1)*t_height]);
		}
	}
}