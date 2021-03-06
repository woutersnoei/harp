~harp = ~harp ? EM();

~harp.path = thisProcess.nowExecutingPath.dirname;

(
~harp.names = [ 
	'tremolo', 'plong', 'hamel', 'schuif', 'fast_fx', 'drone', 'clicks',
	'live_squeek', 'live_echos', 'live_holdpeak', 'live_sample', 'panfocus', 'scenes'
];
);

([
	"samples",
] ++ ~harp.names ++ [
	"inputRouter",
	"verb",
	"gui",
	"nanoKontrol",
]).do({ |item|
	(~harp.path +/+ "harp" + item ++ ".scd").load;
});

~harp.loadBuffers( { 
	"loadBuffers done".postln; 
	q.verb.prepare({ q.verb.views.power.valueAction = 1; }); 
} );

~harp.makeWindow( );

~harp.nanoKONTROL.fillGUI;

/*
~harp.tremolo.start;
~harp.tremolo.end;

~harp.chord.start;
~harp.chord.end;
*/