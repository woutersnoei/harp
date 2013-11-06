
~harp = ~harp ? EM();

~harp.live_holdpeak = ~harp.live_holdpeak ? EM();

~harp.live_holdpeak.parent = ~harp;

~harp.live_holdpeak.specs = OEM();
~harp.live_holdpeak.controlNames = [];

[
	\in, 2, ListSpec([1,2,3,4],1,['small_harp', 'large_harp', 'live_sample', 'aux'] ),
	\amp, 0.1, \amp.asSpec,
	\dev, 1, [0,1].asSpec,
	\down, 0, [ 0, 0.75 ].asSpec,
	\winsize, 0.5, [0.01,0.5,\exp].asSpec,
	\thresh, -35, [-inf, 0, \db].asSpec,
].clump(3).do({ |item|
	var key, default, spec;
	#key, default, spec = item;
	~harp.live_holdpeak[ key ] = default;
	~harp.live_holdpeak[ key.asSetter ] = { |evt, value|
		evt[ key ] = value ? default;
		evt.sn.set( key, evt[ key ] );
	};
	~harp.live_holdpeak.specs[ key ] = spec;
	~harp.live_holdpeak.controlNames = ~harp.live_holdpeak.controlNames.add( key );
});

(
SynthDef( "harp_live_holdpeak", { |in = 0, amp = 0.1, dev = 1, thresh = -10, down = 0, loopbuf = 0, 
	winsize = 0.5, gate = 1|
	var pos, sig, rec;
	var loopsig, sg;
	
	sig = PrivateIn.ar( in );
	
	rec = Amplitude.kr( sig ) > thresh.dbamp;
	rec = rec.max( Trig.kr( rec, 0.5 ) );
	rec = Slew.kr( rec, 50, 50 );
	
	RecordBuf.ar( sig, loopbuf, 0, rec, 1-rec, 1, 1 );
	
	loopsig = ({ PlayBufCF.ar( 1, loopbuf, // DelayN.ar( loopbuf, 0.1, 0.1 ), 
		Drand([1,-1],inf), 
		Dwhite(0.2,0.4,inf),
		Dwhite(0,1,inf) * BufFrames.kr( loopbuf ),
		loop: 1,
		lag: 0.2,
		n: 2 ) }!8);
		
	loopsig = SplayAz.ar( 4, loopsig );
	loopsig = sig + ( (1-rec) * loopsig );

	sg = PitchShift.ar( loopsig * amp, winsize.dup(4), 1-down, (0.01 + down) * dev, 0.5 * dev ) * 2;
	
	Out.ar( 0, sg * Env.cutoff.kr(2,gate));
}).load(s);
);

~harp.live_holdpeak.start = { |evt|
	evt.end;
	evt.sn = Synth( "harp_live_holdpeak", [ \loopbuf, evt.buffers.holdpeak ] ++
		evt.getPairs( evt.controlNames ),
		s, \addToTail 
	);
	evt.active = true;
};

~harp.live_holdpeak.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
	evt.active = false;
};
