~harp = ~harp ? EM();

~harp.fast_fx = ~harp.fast_fx ? EM();

~harp.fast_fx.parent = ~harp;

~harp.fast_fx.specs = OEM();
~harp.fast_fx.controlNames = [];

[
	\amp, 0.1, \amp.asSpec,
	\ratio, 1, [0.25,4,\exp,0,1].asSpec,
	\stretch, 1, [0.25,4,\exp,0,1].asSpec,
	\stretchDev, 0, [0,1].asSpec,
	\fullness, 1, [0,1].asSpec,
	\filter, 0.5, [0,1].asSpec,
	\filterWidth, 1, [0,1].asSpec,
	\moddepth, 0, [0,1].asSpec,
	\modspeed, 100, [1,300,2].asSpec,
].clump(3).do({ |item|
	var key, default, spec;
	#key, default, spec = item;
	~harp.fast_fx[ key ] = default;
	~harp.fast_fx[ key.asSetter ] = { |evt, value|
		evt[ key ] = value ? default;
		evt.sn.set( key, evt[ key ] );
	};
	~harp.fast_fx.specs[ key ] = spec;
	~harp.fast_fx.controlNames = ~harp.fast_fx.controlNames.add( key );
});

(
SynthDef( "harp_fast_fx", { |bufnum = 0, amp = 0.1, ratio = 1, fullness = 1, filter = 0.5, filterWidth = 1, moddepth = 0, stretch = 1, stretchDev = 0, modspeed = 100, gate = 1|
	var sig;
	stretch = stretch.ratiomidi.varlag(2).midiratio;
	sig = 2.collect({
		var trig;
		trig = TDuty.ar( Dwhite(2,5) );
		PlayBufCF.ar( 4, bufnum, 
			Demand.ar( trig, 0, Dwhite(-1,1).midiratio * ratio ) * (1/stretch), 
			trig, 
			Demand.ar( trig, 0, Dwhite( 0, BufFrames.kr( bufnum )), 1, 2, 2 ) 
		) * [ 1, fullness ].stutter	
	});
	sig = sig[0] + sig[1].rotate(2);
	sig = sig * (1 - LFDNoise3.kr(modspeed.dup(4), moddepth, moddepth )).max(0);
	sig = PitchShift.ar( sig, 0.2, stretch, 0, stretchDev * 0.2);
	filter = LPFLag.kr(filter,0.25);
	filterWidth = LPFLag.kr(filterWidth,0.25);
	sig = BLowCut.ar( sig, filter.linexp( filterWidth.linlin(0, 1, 0, 0.5 ), 1, 20, 20000 ));
	sig = BHiCut.ar( sig, filter.linexp( 0, filterWidth.linlin(0, 1, 1, 0.5), 20, 20000 ));
	sig = sig * amp.lag(0.1) * Env.cutoff.kr(2,gate);
	PrivateOut.ar(4, sig.sum / 4 );
	Out.ar( 0, sig );
}).load(s);
);


~harp.fast_fx.start = { |evt|
	evt.end;
	evt.sn = Synth( "harp_fast_fx", [ \bufnum, evt.buffers.quad[1] ] ++ 
		evt.getPairs( evt.controlNames ) 
	);
	evt.active = true;
};

~harp.fast_fx.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
	evt.active = false;
};
