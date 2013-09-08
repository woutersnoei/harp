~harp = ~harp ? EM();

~harp.live_sample = ~harp.live_sample ? EM();

~harp.live_sample.parent = ~harp;

~harp.live_sample.specs = OEM();
~harp.live_sample.controlNames = [];

~harp.live_sample.makeBuffer = { |evt|
	evt.recBuf = Buffer.alloc(s, 5 * 44100, 1 );
};

~harp.live_sample.makeBuffer;

[
	\in, 2, [0,2,\lin,1].asSpec,
	\catch, false, BoolSpec(false), 
	\duration, 2, [0.5,4,\lin].asSpec,
	\amp, 0.0, \amp.asSpec,
	\pwidth, 0.25, [0.25, 1].asSpec,
].clump(3).do({ |item|
	var key, default, spec;
	#key, default, spec = item;
	~harp.live_sample[ key ] = default;
	~harp.live_sample[ key.asSetter ] = { |evt, value|
		evt[ key ] = value ? default;
		evt.sn.set( key, evt[ key ] );
	};
	~harp.live_sample.specs[ key ] = spec;
	~harp.live_sample.controlNames = ~harp.live_sample.controlNames.add( key );
});

~harp.live_sample[ \catch_ ] = { |evt, value|
	evt[ \catch ] = value ? false;
	if( evt[ \catch ].booleanValue == true ) { evt.sendTrig; };
	evt.sn.set( \catch, evt[ \catch ] );
};

~harp.live_sample.sendTrig = { |evt|
	evt.sn.set( \t_getPos, 1 );
};

~harp.live_sample.copyLoop = { |evt, value = 0|
	evt.loopBuf.free;
	evt.loopBuf = Buffer.alloc( s, evt.duration * 44100, 1, {|buf|["/b_query",buf.bufnum]} );
	evt.sn.set( \loopBuf, evt.loopBuf );
	evt.loopBuf.doOnInfo_({
		evt.recBuf.copyLoopCF( evt.loopBuf, value - ((evt.duration + 0.125) * 44100), 0.125, 
		-1, { "copied loop".postln });
	});
};

(
SynthDef( "harp_live_sample", { |in = 0, amp = 0.0, pwidth = 0.25, catch = 0, gate = 1,
		recBuf = 0, loopBuf = 0, t_getPos = 0, level = 1|
		var sig, playLoop;
		var env;
		
		env = Env.asr(0.1,1,0.25).kr(2,gate);
		
		sig = PrivateIn.ar( in ) * level.lag(0.5);
		
		RecordBuf.ar( sig, recBuf );
		
		SendTrig.kr( t_getPos, 0, Phasor.ar( 0, 1, 0, BufFrames.kr(recBuf) ) );
		
		playLoop = PlayBufCF.ar( 1, loopBuf, 1, 
			Dwhite(0.5,2), Dwhite(0,BufFrames.kr( loopBuf )), 1, 0.25 
		);
		
		catch = Slew.kr( Slew.kr( catch, 1/0.25, inf ) > 0.9999, 1/0.25, 1/0.25 ).linlin(0,1,-1,1);
		sig = XFade2.ar( sig, playLoop, catch );
		
		PrivateOut.ar( 3, sig );
		
		sig = RoundPan.ar( 4, sig, LFNoise2.kr(0.2) * pwidth );
		
		Out.ar( 0,  sig * amp.lag(0.5) * env );
	
	}).load(s)
);

~harp.live_sample.start = { |evt|
	evt.end;
	evt.sn = Synth( "harp_live_sample", 
		evt.getPairs( evt.controlNames ++ [ \recBuf, \catchBuf ]), 
		s, \addToHead 
	).register;
	ReceiveTrig( evt.sn, { |value|
		value.postln;
		evt.copyLoop( value );
	});
	evt.active = true;
};

~harp.live_sample.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
	evt.active = false;
};
