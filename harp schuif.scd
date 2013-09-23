~harp = ~harp ? EM();
~harp.schuif = ~harp.schuif ? EM();

~harp.schuif.parent = ~harp;

(
SynthDef( "harp_schuif", { |bufnum = #[0,1], gate = 1,
		amp = 0.1, transpAmt = 12, ratio = 1, pdir = 0.5, modSpeed = 0.25,		time = #[ 3, 15 ],
		lowCut = #[ 200, 5000 ], 
		hiCut = #[ 4000, 20000 ],
		reso = 0|
	var sig, env;
	
	env = Env.asr(0.1,1,0.1).kr(2,gate.max(Impulse.kr(0)));
	
	sig = bufnum.collect({ |bufnum|
		PlayBufCF.ar( 1, bufnum, 
		ratio * (2 ** ((Dwhite(transpAmt.neg,transpAmt).round(1) + 6.55) / 12)),
		Dwhite( *time ),
		startPos: Dwhite(0,1) * BufFrames.kr( bufnum ), 
		loop: 1,
		lag: time[0] ) * 1;
	});
		
	sig = BLowCut.ar( sig, LFDNoise3.kr( modSpeed ).exprange( *lowCut.lag(0.25) )
		.clip(20,20000), 4);
	sig = BHiCut.ar( sig, LFDNoise3.kr( modSpeed ).exprange( *hiCut.lag(0.25) )
		.clip(20,20000), 4);
		
	sig = sig.collect({ |sig|
		(CombN.ar( sig, 0.22, 1/(Rand(30,80).midicps), reso * 5 ) * (reso * 0.5)) + (sig * (1-reso));
	});
		
	PrivateOut.ar(4, (sig.sum / 2) * amp * env );
	
	sig = sig.collect({ |sig|
		PanAz.ar( 4, sig, LFSaw.kr( pdir * LFDNoise3.kr(0.2).linexp(-1,1,0.5,2), Rand(0,2) ) );
	}).sum;
	
	Out.ar(0, sig * amp * env );
}).load(s);
);

~harp.schuif.specs = OEM();
~harp.schuif.controlNames = [];

[ 
	'amp', 0.1, ControlSpec(0, 1, 'amp', 0, 0, ""), 
	'transpAmt', 12, ControlSpec(0, 24, 'linear', 0.0, 0, ""), 
	'ratio', 1, ControlSpec(0, 2, 'linear', 0.0, 0, ""), 
	'pdir', 0.05, ControlSpec(-0.1, 0.1, 'linear', 0.0, 0.0, ""), 
	'modSpeed', 0.25, [0,5].asSpec, 
	'time', [ 3, 15 ], RangeSpec(0.1, 25, 0, inf, 'exp', 0.0, [ 0.1, 0.1 ], ""), 
	'lowCut', [ 200, 5000 ], RangeSpec(20, 20000, 0, inf, 'exp', 0.0, [ 440.0, 440.0 ], " Hz"), 
	'hiCut', [ 800, 8000 ], RangeSpec(20, 20000, 0, inf, 'exp', 0.0, [ 440.0, 440.0 ], " Hz"),
	'reso', 0, [0,1].asSpec,
].clump(3).do({ |item|
	var key, default, spec;
	#key, default, spec = item;
	~harp.schuif[ key ] = default;
	~harp.schuif[ key.asSetter ] = { |evt, value|
		evt[ key ] = value ? default;
		evt.synths.do(_.set( key, evt[ key ] ));
	};
	~harp.schuif.specs[ key ] = spec;
	~harp.schuif.controlNames = ~harp.schuif.controlNames.add( key );
});


~harp.schuif.buf = { |evt| evt.buffers.schuif[[3,3]] }; // may be schuif2 too

~harp.schuif.start = { |evt|
	evt.end;
	evt.synths = 4.collect({ 
		Synth( "harp_schuif", [ \bufnum, evt.buf ] ++ evt.getPairs( evt.controlNames ) ); 
	});
	evt.active = true;
};

~harp.schuif.end = { |evt|
	evt.synths.do(_.release);
	evt.synths = nil;
	evt.active = false;
};

/*
~harp.schuif.start;
~harp.schuif.end;

~harp.schuif.lowCut= [20,50];
~harp.schuif.hiCut= [500,2000];
~harp.schuif.amp = 0.01;
~harp.schuif.pwidth = 1;
~harp.schuif.modSpeed = 0.25;
~harp.schuif.ratio = 0.8;
~harp.schuif.ratio = 0.8;
~harp.schuif.time = [0.25, 1];
~harp.schuif.transpAmt = 12;
*/

/*
~harp.schuif.synthDef.allControlNames
	.select({ |item| [ \bufnum, \gate ].includes( item.name ).not })
	.collect({ |item| 
		var spec;
		spec = ~specs[ item.name.toLower ] ? item.name.asSpec;
		if( item.defaultValue.size == 2 ) {
			spec = spec.asRangeSpec;
		};
		[ item.name, item.defaultValue, spec ] 
	}).flatten(1).cs

.do({ |item|
	var name, value;
	name = item.name;
	value = item.defaultValue;
	if( [ \bufnum, \gate ].includes( name ).not ) {
		~harp.schuif[ name ] = value;
		~harp.schuif[ name.asSetter ] = { |evt, val|
			evt[ name ] = val;
			evt.synths.do( _.set( name, val ) );
		};
		
	};
	
});

~harp.schuif.resetControls = { |evt|
	var synthControls;
	synthControls = evt.synthDef.allControlNames;
	evt.controlNames.do({ |name|
		evt.perform( name.asSetter, synthControls.detect({ |item|
			item.name == name;
		}).defaultValue );
	});
};
*/
