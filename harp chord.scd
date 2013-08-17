~harp = ~harp ? EM();

~harp.chord = ~harp.chord ? EM();

~harp.chord.parent = ~harp;

~harp.chord.specs = OEM();

[
	\amp, 0.1, \amp.asSpec,
	\transp,  0, [-24,24,\lin,1].asSpec,
].clump(3).do({ |item|
	var key, default, spec;
	#key, default, spec = item;
	~harp.chord[ key ] = default;
	~harp.chord[ key.asSetter ] = { |evt, value|
		evt[ key ] = value ? default;
		evt.synths.do( _.set( key, evt[ key ] ) );
	};
	~harp.chord.specs[ key ] = spec;
});

(
SynthDef( "harp_alt", { |bufnum = 0, min = 0.25, max = 0.75, rate = 1, transp = 0, amp = 0.1, gate = 1|
	var sig;
	var trig;
	var change;
	var env;
	
	env = Env.cutoff(0.2).kr(2,gate);
	rate = ((96000 * 2)/44100) * rate * transp.midiratio;
	min = BufDur.kr( bufnum ) * min;
	max = BufDur.kr( bufnum ) * max;
	trig = TDuty.kr( (max - min) / 10 * Dwhite(0.5, 2) / rate );
	sig = LocalIn.kr(1).linlin(min,max,0,1);
	sig = Sweep.kr(1, TWChoose.kr( trig, [1,-1], [ 1-sig, sig ] ) * rate );
	LocalOut.kr(sig);
	
	change = Changed.kr( Slope.kr( sig ) > 0 );
	sig = PlayBufAlt.ar( 2, bufnum, rate, change, lag: 0.3, n: 4 )[1];
	sig = sig * Line.kr(1,2,9);
	sig = RoundPan.ar( 4, sig * amp, LFDNoise3.kr(0.1) * 2 );
	
	Out.ar( 0, sig * env );
}).load(s);
);

~harp.chord.start = { |evt|
	evt.end;
	evt.synths = ((-17..17).scramble[..9]).sort.collect({ |i|
		Synth("harp_alt", [ 
			\bufnum, evt.buffers.note_filt.wrapAt(i), 
			\amp, evt.amp ? 0.1, 
			\transp, evt.transp ? 0,
			\rate, i.midiratio
		] );
	});
	evt.active = true;
};

~harp.chord.end = { |evt|
	evt.synths.do(_.release);
	evt.synths = nil;
	evt.active = false;
};

/*
~harp.chord.start;
~harp.chord.end;

~harp.chord.transp = -6;
~harp.chord.transp = 0;
*/