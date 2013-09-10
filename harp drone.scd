~harp = ~harp ? EM();

~harp.drone = ~harp.drone ? EM();

~harp.drone.parent = ~harp;

~harp.drone.specs = OEM();
~harp.drone.controlNames = [];

[
	\amp, 0.1, \amp.asSpec,
	\ratio, 1, [0.25,4,\exp,0,1].asSpec,
	\fullness, 1, [0,1].asSpec,
	\filter, 0.5, [0,1].asSpec,
	\filterWidth, 1, [0,1].asSpec,
	\moddepth, 0, [0,1].asSpec,
	\modspeed, 100, [1,300,2].asSpec,
].clump(3).do({ |item|
	var key, default, spec;
	#key, default, spec = item;
	~harp.drone[ key ] = default;
	~harp.drone[ key.asSetter ] = { |evt, value|
		evt[ key ] = value ? default;
		evt.sn.set( key, evt[ key ] );
	};
	~harp.drone.specs[ key ] = spec;
	~harp.drone.controlNames = ~harp.drone.controlNames.add( key );
});

(
SynthDef( "harp_drone", { |bufnum = 0, amp = 0.1, ratio = 1, fullness = 1, filter = 0.5, filterWidth = 1, moddepth = 0, modspeed = 100, gate = 1|
	var sig;
	sig = 2.collect({
		PlayBufCF.ar( 4, bufnum, Dwhite(-0.1,0.1).midiratio * ratio, Dwhite(4,7), Dwhite( 0, BufFrames.kr( bufnum )), 1, 4, 2 ) * 
		[ 1, fullness ].stutter
	});
	sig = sig[0] + sig[1].rotate(2);
	filter = LPFLag.kr(filter,0.25);
	filterWidth = LPFLag.kr(filterWidth,0.25);
	sig = BLowCut.ar( sig, filter.linexp( filterWidth.linlin(0, 1, 0, 0.5 ), 1, 20, 20000 ));
	sig = BHiCut.ar( sig, filter.linexp( 0, filterWidth.linlin(0, 1, 1, 0.5), 20, 20000 ));
	sig = sig * (1 - LFDNoise3.kr(modspeed.dup(4), moddepth, moddepth )).max(0);
	sig = sig * amp.lag(0.5) * Env.cutoff.kr(2,gate);
	PrivateOut.ar(4, sig.sum / 4 );
	Out.ar( 0, sig );
}).load(s);
);


~harp.drone.start = { |evt|
	evt.end;
	evt.sn = Synth( "harp_drone", [ \bufnum, evt.buffers.quad[0] ] ++ 
		evt.getPairs( evt.controlNames ) 
	);
	evt.active = true;
};

~harp.drone.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
	evt.active = false;
};
