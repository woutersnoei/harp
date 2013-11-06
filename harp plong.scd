~harp = ~harp ? EM();

~harp.plong = ~harp.plong ? EM();

~harp.plong.parent = ~harp;

~harp.plong.specs = OEM();

[
	\amp, 0.5, \amp.asSpec, true,
	\reverse, true, BoolSpec(false), true,
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
SynthDef( "harp_plong", { |bufnum = 0, amp = 0.1, semitones = 0, ringFreq = 440, pan = 0, moddepth = 0, noise = 0, reverse = 0, gate = 1|
	var sig, env, rev;
	sig = PlayBuf.ar( 1, bufnum, BufRateScale.kr( bufnum ) * semitones.midiratio 
		* (1 - (reverse * 2)), startPos: (BufFrames.kr( bufnum ) - 2) * reverse );
	sig = sig * (1 - Done.kr(sig));
	sig = sig * SinOsc.ar(ringFreq) * 0.5;
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
	if( evt.task.isPlaying.not ) {	
		evt.end;
		evt.task = {
			~harp.drone.stretch = [0.5,1,2].wchoose([0.25,0.5,0.25]);
			~harp.drone.stretchDev = [0,1].choose;
			~harp.drone.ratio = [0.5,1,2].wchoose([0.25,0.5,0.25]);
			~harp.drone.filterWidth = [0.5,1].choose;
			~harp.drone.moddepth = [0,1].choose;
			~harp.fast_fx.stretch = [0.5,1,2].wchoose([0.25,0.5,0.25]);
			~harp.fast_fx.stretchDev = [0,1].choose;
			~harp.fast_fx.ratio = [0.5,1,2].wchoose([0.25,0.5,0.25]);
			~harp.fast_fx.filterWidth = [0.5,1].choose;
			~harp.fast_fx.moddepth = [0,1].choose;
			[0,0.5,1,-0.5].scramble.collect({ |item|
				evt.synths = evt.synths.add(
					Synth( "harp_plong", [ 
						\bufnum, evt.buffers.plong.choose, 
						\semitones, evt.semitones[0] rrand: evt.semitones[1], 
						\ringFreq, evt.ringFreq[0] exprand: evt.ringFreq[1], 
						\noise, evt.noise,
						\pan, item,
						\amp, evt.amp,
						\reverse, evt.reverse,
					]  ).freeAction_({ |sn| 
						evt.synths.remove( sn );
						if( evt.synths.size == 0 ) { evt.active = false };
					})
				);
				evt.active = true;
				evt.waitTime.rand.wait;
			});
		}.fork;
	};
	evt.active = true;
};

~harp.plong.end = { |evt|
	evt.synths.do(_.release);
	evt.active = false;
	evt.task.stop;
	~harp.drone.stretch = 1;
	~harp.drone.stretchDev = 0;
	~harp.drone.ratio = 1;
	~harp.drone.filterWidth = 0.5;
	~harp.drone.moddepth = 0;
	~harp.fast_fx.stretch = 1;
	~harp.fast_fx.stretchDev = 0;
	~harp.fast_fx.ratio = 1;
	~harp.fast_fx.filterWidth = 0.5;
	~harp.fast_fx.moddepth = 0;
	
};

/*
~harp.plong.start;
~harp.plong.end;

~harp.plong.transp = -6;
~harp.plong.transp = 0;
*/