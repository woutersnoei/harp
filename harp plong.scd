~harp = ~harp ? EM();

~harp.plong = ~harp.plong ? EM();

~harp.plong.parent = ~harp;

~harp.plong.specs = OEM();

[
	\amp, 0.1, \amp.asSpec, true,
	\semitones,  [-24,0], [-24,24,\lin,1].asSpec.asRangeSpec, false,
	\ringFreq,  [100,1000], [20,20000,\exp].asSpec.asRangeSpec, false,
	\noise, 0, \amp.asSpec, true,
	\waitTime, 0.125, [0,1,4].asSpec, false
].clump(4).do({ |item|
	var key, default, spec, setSynth;
	#key, default, spec, setSynth = item;
	~harp.plong[ key ] = default;
	if( setSynth ) {
			~harp.plong[ key.asSetter ] = { |evt, value|
				evt[ key ] = value ? default;
				evt.synths.do(_.set( key, evt[ key ] ));
			};
	};
	~harp.plong.specs[ key ] = spec;
});

(
SynthDef( "harp_plong", { |bufnum = 0, amp = 0.1, semitones = 0, ringFreq = 440, pan = 0, moddepth = 0, noise = 0, gate = 1|
	var sig, env, rev;
	sig = PlayBuf.ar( 1, bufnum, BufRateScale.kr( bufnum ) * semitones.midiratio ) * 
		SinOsc.ar(ringFreq) * 0.5;
	sig = sig ring1: LPF.ar( BrownNoise.ar(noise), 500 );
	rev = GVerb.ar( sig, Rand( 20, 100), 12, drylevel: 0, maxroomsize: 100 ) * 0.125;
	rev = rev * LFDNoise3.kr(100.dup).linlin(-1,1,Line.kr(1,-1,6),1).max(0);
	env = Env([1,0],[12]).kr(2);
	sig = (sig + rev) * amp;
	sig = sig.collect({ |sig,i|
		RoundPan.ar(4, sig, pan + [ -0.25, 0.25 ][i] );
	}).sum;
	Out.ar(0, sig * env * Env.cutoff(0.5).kr(2,gate) );
}).load(s);
);

~harp.plong.start = { |evt|
	evt.end;
	{
		evt.synths = [0,0.5,1,-0.5].scramble.collect({ |item|
			var synth;
			synth = Synth( "harp_plong", [ 
				\bufnum, evt.buffers.plong.choose, 
				\semitones, evt.semitones[0] rrand: evt.semitones[1], 
				\ringFreq, evt.ringFreq[0] exprand: evt.ringFreq[1], 
				\noise, evt.noise,
				\pan, item,
				\amp, evt.amp
			]  );
			evt.waitTime.rand.wait;
			synth
		});
	}.fork;
	evt.active = true;
};

~harp.plong.end = { |evt|
	evt.synths.do(_.release);
	evt.synths = nil;
	evt.active = false;
};

/*
~harp.plong.start;
~harp.plong.end;

~harp.plong.transp = -6;
~harp.plong.transp = 0;
*/