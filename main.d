module openDLife.main;

import arsd.nanovega;
import arsd.simpledisplay;
import std.stdio : writeln;
import life.squareLife;
import arsd.jsvar;
import std.file : readText;

void main(){

	var ruleset = var.fromJson(readText("ruleset/ruleset.json"));
	auto window = new NVGWindow(800, 600, ruleset["automata name"]);
	writeln(ruleset);
	writeln(ruleset["board dimensions"]);
	auto dims = ruleset["board dimensions"].get!(int[]);
	auto fullWidth = dims[0];
	auto fullHeight = dims[1];
	import std.random;
	auto rnd = Random(7);
	squareLife sq = new squareLife(dims[0], dims[1], 0);
	for(int i = 0; i< fullWidth * fullHeight; i++){
		sq.setCell(i / fullWidth, i %fullHeight, cast(ubyte)uniform(0, 2, rnd));
	}
	window.redrawNVGScene = delegate (nvg){
		for(int width = 0; width < fullWidth; width++){
			for(int height = 0; height < fullHeight; height++){
				auto colors  = ruleset["cell colors"].get!(string[]);
				nvg.beginPath();
				nvg.strokeColor = NVGColor.green;
				nvg.strokeWidth = 2;
				nvg.fillColor = nvgRGB(colors[sq.getCell(width, height)]);
				nvg.rect(width*10, height*10, 10, 10);
				nvg.fill();
				nvg.stroke();
			}
		}
	};
	
	window.eventLoop(0,
		delegate (KeyEvent event) {
			if (event == "*-Q" || event == "Escape") { window.close(); return; } // quit on Q, Ctrl+Q, and so on
		},
	);
	testSQ();
}
void testSQ(){
	squareLife sq = new squareLife();
	sq.setCell(0, 0, 1);
	sq.setCell(1, 0, 2);
	sq.setCell(1, 1, 1);
	sq.setCell(4, 4, 1);
	sq.printGrid();
	//wrapping test, offset places the top row and first column off the board.
	assert(sq.countNeighbors(1, 1, 1, 1, [true, true, true, //1, 1, 1
										  true, false, true,//1, 0, 1
										  true, true, true],//1, 1, 1
										  3, 1) == 1); //see if it only spots 1 of the two 1s.
	assert(sq.countNeighbors(0, 0, 1, 1, [true, true, true, //1, 1, 1
										  true, true, true, //1, 1, 1
										  true, true, true],//1, 1, 1
										  3, 1) == 3);
	assert(sq.countNeighbors(0, 0, 1, 1, [true, true, true, //1, 1, 1
										  true, false, true,//1, 0, 1
										  true, true, true],//1, 1, 1
										  3, 2) == 1);
	assert(sq.getCell(1, 0) == 2); //see if we're writing to the right places.
}