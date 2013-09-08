~harp = ~harp ? EM();

~harp.hamel = ~harp.hamel ? EM();

~harp.hamel.parent = ~harp;

~harp.hamel.specs = OEM();

[
	\amp, 0.1, \amp.asSpec,
	\avgTime, 10, [1, 30, \lin, 1 ].asSpec,
	\filter, 0.5, [0,1].asSpec,
	\transp, [0, 0], [-24,24,\lin,1].asSpec.asRangeSpec,
	\shiftAmt, 0, [0,400,\lin].asSpec,
].clump(3).do({ |item|
	var key, default, spec;
	#key, default, spec = item;
	~harp.hamel[ key ] = default;
	~harp.hamel[ key.asSetter ] = { |evt, value|
		evt[ key ] = value ? default;
		evt.sn.set( key, evt[ key ] );
	};
	~harp.hamel.specs[ key ] = spec;
});

(
SynthDef( "harp_crawling_2", { |amp = 0.1, gate = 1, avgTime = 10, filter = 0.5, transp = #[-2,9],
		shiftAmt = 0|
	var trigger;
	var sigs;
	var bufs, n = 2;
	var env;
	bufs = \bufs.kr(0!n);
	env = Env.asr(0.2,1,0.2).kr(2, gate);
	filter = filter.lag(1);
	trigger = TDuty.kr( Dwhite(avgTime/2, avgTime*2) );
	sigs =  PlayBuf.ar( 1, bufs, 
			TIRand.kr( 0.dup( n ), 0, trigger )
			.round.midiratio * (
				TIRand.kr( transp[0].dup( n ), transp[1], trigger ).midiratio *
				TWChoose.kr( trigger, [-1,1],[0.1,0.9] )
			),
		startPos: Rand(0, BufFrames.kr(bufs)), loop: true );
	sigs = FreqShift.ar( sigs, LFDNoise3.kr(0.026.dup( n )) * shiftAmt );
	sigs = BLowCut.ar(sigs, 
		LFDNoise3.kr(0.2.dup(sigs.size)).exprange( 20, filter.linexp(0,1,20,20000) ), 
		3 
	);
	sigs = BHiCut.ar(sigs,
		LFDNoise3.kr(0.2.dup(sigs.size)).exprange( (1-filter).linexp(0,1,20,20000), 20000 ), 
		3 
	 );
	sigs = sigs.collect({ |sig|
		RoundPan.ar( 2, sig, LFDNoise3.kr(0.05) * 2 );
	}).sum;
	Out.ar(0, sigs * amp * env );
}).load(s);
);


~harp.hamel.start = { |evt|
	evt.end;
	evt.sn = Synth( "harp_crawling_2", [ 
		\bufs, (evt.buffers.hamel!2).flatten(1), 
		\amp, evt.amp ? 0.1,
		\filter, evt.filter ? 0.5,
		\avgTine, evt.avgTime ? 10,
		\transp, evt.transp ? [-2, 9],
		\shiftAmt, evt.shiftAmt ? 0,
	] );
	evt.active = true;
};

~harp.hamel.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
	evt.active = false;
};


/*

~harp.hamel.start;

~harp.hamel.end;

~harp.hamel.amp = 0.1;
~harp.hamel.filter = 1;
~harp.hamel.filter = 0.9;
~harp.hamel.filter = 0.7;
~harp.hamel.filter = 0.5;
~harp.hamel.transp = [-12,3];
~harp.hamel.transp = [-24,24];
~harp.hamel.transp = [-12,0];
~harp.hamel.transp = [12,24];
~harp.hamel.transp = [-2,9];
~harp.hamel.avgTime = 5;

~harp.hamel.shiftAmt = 0;
~harp.hamel.shiftAmt = 200;
~harp.hamel.shiftAmt = 400;

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