~harp = ~harp ? EM();

~harp.path = thisProcess.nowExecutingPath.dirname;

~harp.names = [ 'tremolo', 'chord' ];

[
	"samples",
	"chord",
	"tremolo",
	"gui",
	"nanoKontrol",
].do({ |item|
	(~harp.path +/+ "harp" + item ++ ".scd").load;
});

~harp.loadBuffers( { "loadBuffers done".postln } );

~harp.makeWindow( );

~harp.nanoKONTROL.fillGUI;

/*
~harp.tremolo.start;
~harp.tremolo.end;

~harp.chord.start;
~harp.chord.end;
*/