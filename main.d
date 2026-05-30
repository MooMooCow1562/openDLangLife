module openDLife.main;

import arsd.nanovega;
import arsd.simpledisplay;
import std.stdio : writeln;
import life.squareLife;
import arsd.jsvar;
import std.array;
import std.file;

void main(){
	//get our ruleset.
	auto files = dirEntries("ruleset", "*.json", SpanMode.shallow).array;
	var ruleset = var.fromJson(readText(files[0]));
	//name our automata window (and make it)
	auto window = new NVGWindow(800, 600, ruleset["automata name"]);
	//get our dimensions.
	auto dims = ruleset["board dimensions"].get!(int[]);
	auto fullWidth = dims[0];
	auto fullHeight = dims[1];
	//initialize our life automata.
	squareLife sq = new squareLife(dims[0], dims[1], 0, ruleset);
	//random fill!	
	import std.random;
	auto rnd = Random(5);
	for(int i = 0; i< fullWidth * fullHeight; i++){
		if(i%3 != 0){
			sq.setCell(i % fullWidth, i / fullWidth, cast(ubyte)uniform(0, (ruleset["cell names"].get!(string[])).length, rnd));
		}
	}
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
	
	window.eventLoop(50, delegate(){
		sq.step();
		window.redrawNVGSceneNow();
	});

	window.eventLoop(0,
		delegate (KeyEvent event) {
			if (event == "*-Q" || event == "Escape") { window.close(); return; } // quit on Q, Ctrl+Q, and so on
		},
	);
}