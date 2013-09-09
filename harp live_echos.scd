~harp = ~harp ? EM();

~harp.live_echos = ~harp.live_echos ? EM();

~harp.live_echos.parent = ~harp;

~harp.live_echos.specs = OEM();
~harp.live_echos.controlNames = [];

[
	\in, 2, [0,3,\lin,1].asSpec,
	\amp, 0.1, \amp.asSpec,
	\pwidth, 0.25, [0.25, 1].asSpec, 
	\maxShift, 10, [1,1000,\exp].asSpec,
	\speed, 1, [0.1,10,\exp].asSpec,
	// \fb, 0, [0,0.99,\lin].asSpec,
	\limit, 0.5, \amp.asSpec
].clump(3).do({ |item|
	var key, default, spec;
	#key, default, spec = item;
	~harp.live_echos[ key ] = default;
	~harp.live_echos[ key.asSetter ] = { |evt, value|
		evt[ key ] = value ? default;
		evt.sn.set( key, evt[ key ] );
	};
	~harp.live_echos.specs[ key ] = spec;
	~harp.live_echos.controlNames = ~harp.live_echos.controlNames.add( key );
});

(
SynthDef( "harp_live_echos", { |in = 0, amp = 0.5, pwidth = 0.25, maxShift = 10, gate = 1, 
			limit = 0.5, speed = 1, level = 1|
		var sig, n = 4;
		var env;
		
		env = Env.asr(0.1,1,0.25).kr(2,gate);
		
		sig = PrivateIn.ar( in ) * level.lag(0.5) * 2;
		
		//sig = sig + (LeakDC.ar( LocalIn.ar( 4 ) ) * fb);
		
		sig = DelayC.ar( sig, 1, LFDNoise3.kr(0.1.dup(n) * speed).range(0.125,1) ) ++
			DelayC.ar( sig, 2, LFDNoise3.kr(0.01.dup(n) * speed).range(0.5,2) );
		
		sig = FreqShift.ar( sig, Rand(0.dup(n*2),1) * maxShift);
		
		// LocalOut.ar( sig );
		
		sig = sig.collect({ |sig|
			RoundPan.ar( 4, sig, LFNoise2.kr(0.5) * pwidth );
		}).sum;
		
		Out.ar( 0,  Limiter.ar( sig * amp.lag(0.5), limit ) *  env );
	
	}).load(s)
);

~harp.live_echos.start = { |evt|
	evt.end;
	evt.sn = Synth( "harp_live_echos", evt.getPairs( evt.controlNames ), s, \addToTail  );
	evt.active = true;
};

~harp.live_echos.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
	evt.active = false;
};
