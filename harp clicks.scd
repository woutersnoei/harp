~harp = ~harp ? EM();

~harp.clicks = ~harp.clicks ? EM();

~harp.clicks.parent = ~harp;

~harp.clicks.specs = OEM();

[
	\amp, 0.1, \amp.asSpec,
	\speed, 1, [0.25,4,\exp,0,1].asSpec,
	\ratio, 1, [0.25,4,\exp,0,1].asSpec,
	\pan, 1, [0.25,1].asSpec,
	\res, [0.01,0.1], [0.01,1,\exp].asSpec.asRangeSpec,
	\durscale, 0.25, [0.25,1].asSpec,
	\range, [40,80], [40,100,\lin,1].asSpec.asRangeSpec
].clump(3).do({ |item|
	var key, default, spec;
	#key, default, spec = item;
	~harp.clicks[ key ] = default;
	~harp.clicks.specs[ key ] = spec;
});

(
SynthDef( "harp_buf_fade", { |bufnum = 0, freq = 440, amp = 0.1, durscale = 1, rate = 1, pan = 0, res = 0.1|
	var sig, dur, env, actualRate;
	var amps;
	dur = BufDur.kr(bufnum);
	env = Env([1,0],[durscale * dur / rate]).ar;
	actualRate = rate;
	rate = BufRateScale.kr( bufnum ) * rate;
	sig = PlayBuf.ar( 1, bufnum, rate, doneAction: 2 );
	sig = BPeakEQ.ar( sig, 2500 * actualRate, 0.25, -16 ); 
	sig = BLowCut.ar( sig, 200 * actualRate, 2 );
	amps = (1/(1..8)) * ExpRand(0.05.dup(8),1);
	amps = amps / amps.sum;
	sig = (Klank.ar( `[ 
		((freq * (1..8)) + Rand(-2.dup(8),2)).clip(20,20000), amps, res
	], sig ) + (sig * -1)) * 0.2;
	sig = sig * env * amp * 2;
	sig = RoundPan.ar(4, sig, pan );
	Out.ar( 0, sig );
}).load(s);
);

(
~harp.clicks.startPattern = { |evt|
	evt.endPattern;
	evt.pattern = [1,2].collect { |rt|
		{
			var stream, pan, cps;
			stream = Pwrand( [ 
				Pseq([1],4), Pseq([0.5],4), Pseq([2/3],3), Pseq([0.25],4), Pseq([2],1), Pseq([3],1)
			] * 0.2, [0.35,0.1,0.1,0.05,0.1,0.1], inf ).asStream;
			pan = PintL( Pwhite( -1.0 ,1.0,inf), 0.1).asStream;
			cps = PintC( Pwhite( Pfunc({ evt.range[0] }), Pfunc({ evt.range[1] }),inf), 0.1).asStream;
			loop {
				~harp.buffers.cut_clicks.do { |buf, i|
					Synth( "harp_buf_fade", [ 
						\bufnum, ~harp.buffers.cut_clicks[..80].choose, 
						\amp, evt.amp,
						\durscale, evt.durscale, 
						\rate, rt * evt.ratio,
						\pan,  pan.next * evt.pan,
						\res, evt.res[0] exprand: evt.res[1],
						\freq, cps.next.round(1).midicps
					] );
					(stream.next * (1/evt.speed)).wait;
				};
			};
		}.fork;
	};
};

~harp.clicks.endPattern = { |evt|
	evt.pattern.do(_.stop);
	evt.pattern = nil;
};
);

~harp.clicks.start = { |evt|
	evt.startPattern;
	evt.active = true;
};

~harp.clicks.end = { |evt|
	evt.endPattern;
	evt.active = false;
};