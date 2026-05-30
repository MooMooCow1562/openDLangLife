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
	squareLife sq = new squareLife(dims[0], dims[1], 0, ruleset);
	
	sq.setCell(1, 1, 1);
	sq.setCell(2, 1, 1);
	sq.setCell(2, 2, 1);
	sq.setCell(0, 2, 1);
	sq.setCell(2, 3, 1);
	
	
	window.redrawNVGScene = delegate (nvg){
		for(int width = 0; width < fullWidth; width++){
			for(int height = 0; height < fullHeight; height++){
				auto colors  = ruleset["cell colors"].get!(string[]);
				nvg.beginPath();
				nvg.fillColor = nvgRGB(colors[sq.getCell(width, height)]);
				nvg.rect(width*10, height*10, 10, 10);
				nvg.fill();
			}
		}
	};
	
	window.eventLoop(1, delegate(){
		sq.step();
		window.redrawNVGSceneNow();
	});

	window.eventLoop(0,
		delegate (KeyEvent event) {
			if (event == "*-Q" || event == "Escape") { window.close(); return; } // quit on Q, Ctrl+Q, and so on
		},
	);
}