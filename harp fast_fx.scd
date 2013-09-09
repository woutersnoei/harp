~harp = ~harp ? EM();

~harp.fast_fx = ~harp.fast_fx ? EM();

~harp.fast_fx.parent = ~harp;

~harp.fast_fx.specs = OEM();
~harp.fast_fx.controlNames = [];

[
	\amp, 0.1, \amp.asSpec,
	\ratio, 1, [0.25,4,\exp,0,1].asSpec,
	\fullness, 1, [0,1].asSpec,
	\filter, 0.5, [0,1].asSpec,
	\filterWidth, 1, [0,1].asSpec
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
SynthDef( "harp_fast_fx", { |bufnum = 0, amp = 0.1, ratio = 1, fullness = 1, filter = 0.5, filterWidth = 1,
		gate = 1|
	var sig;
	sig = 2.collect({
		PlayBufCF.ar( 4, bufnum, Dwhite(-1,1).midiratio * ratio, Dwhite(2,5), Dwhite( 0, BufFrames.kr( bufnum )), 1, 2, 2 ) * 
		[ 1, fullness ].stutter
		
	});
	sig = sig[0] + sig[1].rotate(2);
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
