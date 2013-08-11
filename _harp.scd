~harp = ~harp ? EM();

[
	"samples",
	"chord",
	"tremolo",
].do({ |item|
	(thisProcess.nowExecutingPath.dirname +/+ "harp" + item ++ ".scd").load;
});

~harp.loadBuffers( { "loadBuffers done".postln } );

/*
~harp.tremolo.start;
~harp.tremolo.end;

~harp.chord.start;
~harp.chord.end;
*/