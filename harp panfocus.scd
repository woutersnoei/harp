~harp = ~harp ? EM();

~harp.panfocus = ~harp.panfocus ? EM();

~harp.panfocus.parent = ~harp;

~harp.panfocus.specs = OEM();
~harp.panfocus.controlNames = [];

[
	\pan, 0, [-1,1,\lin,0.25].asSpec,
	\amount, 0, [0,1].asSpec
].clump(3).do({ |item|
	var key, default, spec;
	#key, default, spec = item;
	~harp.panfocus[ key ] = default;
	~harp.panfocus[ key.asSetter ] = { |evt, value|
		evt[ key ] = value ? default;
		evt.sn.set( key, evt[ key ] );
	};
	~harp.panfocus.specs[ key ] = spec;
	~harp.panfocus.controlNames = ~harp.panfocus.controlNames.add( key );
});

(
SynthDef( "harp_panfocus_4", { |pan = 0, amount = 0, gate = 1|
	var sig, pansig, n = 4;
	sig = In.ar(0, n);
	pansig = PanAz.kr(n, 1, pan, 1, amount.linlin(0.5,1,4,2,\minmax) );
	pansig = LinXFade2.kr( 1.dup(n), pansig, amount.linlin(0,0.5,-1,1,\minmax) ); 
	ReplaceOut.ar(0, sig * pansig * Env.cutoff(0).kr(2,gate) );
}).load(s);
);


~harp.panfocus.start = { |evt|
	evt.end;
	evt.sn = Synth.after( s, "harp_panfocus_4", evt.getPairs( evt.controlNames ) );
	evt.active = true;
};

~harp.panfocus.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
	evt.active = false;
};
