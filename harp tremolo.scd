~harp = ~harp ? EM();

~harp.tremolo = ~harp.tremolo ? EM();

~harp.tremolo.loadBuffers = { |evt, action|
	evt.buffers = Buffer.readDir(
		thisProcess.nowExecutingPath.dirname +/+ "samples/tremolo", 
		nil, "aif", action: action
	);
};

/*
~harp.tremolo.loadBuffers
*/

~harp.tremolo.specs = EM();

[
	\amp, 0.1, \amp.asSpec
].clump(3).do({ |item|
	var key, default, spec;
	#key, default, spec = item;
	~harp.tremolo[ key ] = default;
	~harp.tremolo[ key.asSetter ] = { |evt, value|
		evt[ key ] = value ? default;
		evt.sn.set( key, evt[ key ] );
	};
	~harp.tremolo.specs[ key ] = spec;
});

(
SynthDef( "harp_crawling_10", { |amp = 0.1, gate = 1|
	var trigger;
	var sigs;
	var bufs, n = 10;
	var env;
	bufs = \bufs.kr(0!n);
	env = Env.asr(0.2,1,0.2).kr(2, gate);
	trigger = TDuty.kr( Dwhite(6,14) );
	sigs =  PlayBuf.ar( 1, bufs, 
			TIRand.kr( -4.dup(bufs.size), 4, trigger )
			.round.midiratio * (
				TIRand.kr( -2, 9, trigger ).midiratio * TWChoose.kr( trigger, [-1,1],[0.1,0.9] )
			),
		startPos: Rand(0, BufFrames.kr(bufs)), loop: true );
	sigs = BLowCut.ar(sigs, LFDNoise3.kr(0.2.dup(sigs.size)).exprange( 20, 3000 ), 3 );
	sigs = BHiCut.ar(sigs, LFDNoise3.kr(0.1.dup(sigs.size)).exprange( 500, 20000 ), 3 );
	sigs = sigs.collect({ |sig|
		RoundPan.ar( 2, sig, LFDNoise3.kr(0.1) );
	}).sum;
	Out.ar(0, sigs * amp * env );
}).load(s);
);


~harp.tremolo.start = { |evt|
	~harp.tremolo.end;
	evt.sn = Synth( "harp_crawling_10", [ 
		\bufs, (evt.buffers!2).flatten(1), 
		\amp, evt.amp ? 0.1 
	] );
};

~harp.tremolo.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
};


/*

~harp.tremolo.start;

~harp.tremolo.amp = 0.1;

*/

/*
(
~srw.record;
z = Synth( "harp_crawling_10", [ \bufs, (x!2).flatten(1), \amp, 1 ] );
)

z.release;
~srw.stop;

0.5/0.45

y = x.collect({ |buf|
	Buffer.alloc( s, buf.numFrames - (88200 * 0.05), 1 );
});


x.do({ |buf, i|
	buf.copyLoopCF( y[i], 0, 0.05 );
});

y[0].plot"/Users/woutersnoei/Copy/Work/godelieve/samples"

y.do({ |item, i|
	item.write( "/Users/woutersnoei/Copy/Work/godelieve/samples/tremolo" ++ (i+1) ++ ".aif" )
});
*/