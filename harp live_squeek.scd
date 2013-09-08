~harp = ~harp ? EM();

~harp.live_squeek = ~harp.live_squeek ? EM();

~harp.live_squeek.parent = ~harp;

~harp.live_squeek.specs = OEM();
~harp.live_squeek.controlNames = [];

[
	\in, 2, [0,3,\lin,1].asSpec,
	\amp, 0.1, \amp.asSpec,
	\pwidth, 0.25, [0.25, 1].asSpec, 
	\lag, 0, [0,1].asSpec,
	\speed, 1, [0.1,100,\exp].asSpec,
	\freq, [1000, 5000], [20,20000,\exp].asSpec.asRangeSpec,
	\feedback, 0, [0,1].asSpec,
	\limit, 0.03, \amp.asSpec
].clump(3).do({ |item|
	var key, default, spec;
	#key, default, spec = item;
	~harp.live_squeek[ key ] = default;
	~harp.live_squeek[ key.asSetter ] = { |evt, value|
		evt[ key ] = value ? default;
		evt.sn.set( key, evt[ key ] );
	};
	~harp.live_squeek.specs[ key ] = spec;
	~harp.live_squeek.controlNames = ~harp.live_squeek.controlNames.add( key );
});

(
SynthDef( "harp_live_squeek", { |in = 0, amp = 0.5, pwidth = 0.25, lag = 0, speed = 1,
			freq = #[ 1000, 5000 ], feedback = 0, gate = 1, limit = 0.5, level = 1|
			
		var sig, n = 8;
		var env;
		
		env = Env.asr(0.1,1,0.25).kr(2,gate);
		
		sig = PrivateIn.ar( in ) * level.lag(0.5) * 0.5;
		
		sig = DelayC.ar( sig + (LeakDC.ar( LocalIn.ar(n)  ) * feedback * 0.25),1, 
			LFNoise2.kr(0.2.dup(n)).exprange(0.05,1) );
		
		sig = CombC.ar( BLowCut.ar( sig, freq[0].clip(20,20000), 2 ), 0.01, 
			{ 1/Duty.kr( Dstutter(5,Dwhite(1/(5*speed),1/speed)), 0, 
				Dwhite(*freq.cpsmidi).round(1) ).lag(lag).midicps }!n, 0.25 );
			
		LocalOut.ar( sig.rotate(1) );
		
		sig = sig.collect({ |sig|
			RoundPan.ar( 4, sig, LFNoise2.kr(0.5) * pwidth );
		}).sum;
		
		Out.ar( 0, Limiter.ar( sig * amp.lag(0.5), limit ) * env );
	
	}).load(s)
);

~harp.live_squeek.start = { |evt|
	evt.end;
	evt.sn = Synth( "harp_live_squeek", evt.getPairs( evt.controlNames ), s, \addToTail );
	evt.active = true;
};

~harp.live_squeek.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
	evt.active = false;
};
