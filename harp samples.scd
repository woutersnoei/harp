~harp = ~harp ? EM();

~harp.samplesPath = thisProcess.nowExecutingPath.dirname.dirname +/+ "samples";

~harp.loadBuffers = { |evt, action|
	var localAction;
	evt.buffers = EM();
	localAction = {
		evt.buffers.holdpeak = Buffer.alloc(s, 0.5 * 44100, 1 );
		action.value;
	};
	Buffer.readMultiple(
		(evt.samplesPath +/+ "*/*").pathMatch.collect({ |path|
			path.dirname.basename +/+ path.basename;
		}),
		evt.samplesPath,
		action: localAction
	).do({ |buf|
		var key;
		key = buf.path.dirname.basename.asSymbol;
		evt.buffers[ key ] = evt.buffers[ key ].add( buf );
	});
};