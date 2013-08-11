~harp = ~harp ? EM();

~harp.samplesPath = thisProcess.nowExecutingPath.dirname.dirname +/+ "samples";

~harp.loadBuffers = { |evt, action|
	evt.buffers = EM();
	Buffer.readMultiple(
		(evt.samplesPath +/+ "*/*").pathMatch.collect({ |path|
			path.dirname.basename +/+ path.basename;
		}),
		evt.samplesPath,
		action: action
	).do({ |buf|
		var key;
		key = buf.path.dirname.basename.asSymbol;
		evt.buffers[ key ] = evt.buffers[ key ].add( buf );
	});
};