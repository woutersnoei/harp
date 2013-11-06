~harp = ~harp ? EM();

~harp.scenes = ~harp.scenes ? EM();

~harp.scenes.scorePath = thisProcess.nowExecutingPath.dirname.dirname +/+ "harp_uscores/_all.uscore";

~harp.scenes.parent = ~harp;

~harp.scenes.specs = OEM();

[
	\scene, 0, [0,6,\lin,1,0].asSpec,
].clump(3).do({ |item|
	var key, default, spec;
	#key, default, spec = item;
	~harp.scenes[ key ] = default;
	~harp.scenes.specs[ key ] = spec;
});


~harp.scenes.goToScore = { |evt, i|
	var editor;
	editor = UScoreEditorGUI.all.detect({ |item| item.score.name == "_all"; });
	if( editor.isNil ) {
		editor = ~harp.scenes.scorePath.load.gui;	
	};
	{	
		editor.scoreView.goToHigherScore( 0 );
		if( i.notNil && { UScore.current[i].notNil } ) {
			editor.scoreView.addtoScoreList( UScore.current[i] );
			UScore.current.events.do(_.stop);
			UScore.current.events.do(_.pos_(0));
			editor.window.front;
			{ editor.scoreView.scoreView.view.focus; }.defer(0.1);
		};
	}.defer(0.2);
};

/*
~harp.scenes.goToScore
*/

(
~harp.scenes.scenes = [
	{ // 0 // nothing
		~harp.scenes.goToScore(); // main
	},
	{ // 1
		~harp.scenes.goToScore(6); // flagio
		~harp.live_squeek.in = 3;
		~harp.live_echos.in = 3;
		~harp.live_holdpeak.in = 3;
		~harp.live_sample.in = 2;
	},
	{ // 2
		~harp.scenes.goToScore(2); // slauerhoff
		~harp.live_squeek.in = 3;
		~harp.live_echos.in = 3;
		~harp.live_holdpeak.in = 3;
		~harp.live_sample.in = 2;
	},
	{ // 3
		~harp.scenes.goToScore(5); // koolmees minispeaker
	},
	{ // 4
		~harp.scenes.goToScore(3); // hamel minispeaker
		~harp.hamel.transp = [0,0];
		~harp.hamel.shiftAmt = 0;
		~harp.live_sample.in = 4;
	},
	{ // 5
		~harp.scenes.goToScore(); // main
		~harp.live_echos.in = 2;
		~harp.schuif.reso = 0;
	},
	{ // 6
		{
			var startAmp, spec, time = 2, res = 10;
			spec = \amp.asSpec;
			startAmp = spec.unmap( ~harp.schuif.amp );
			(time * res).do({ |i|
				 ~harp.schuif.amp = spec.map( i.linlin(-1,(time * res)-1,startAmp,0) );
				(1/res).wait;
			});
		}.fork;
		~harp.live_echos.in = 3;
		~harp.live_sample.in = 1;
		~harp.scenes.goToScore(0); // astrid
	},
];
);

~harp.scenes.scene = 0;

~harp.scenes.scene_ = { |evt, i = 0|
	evt[ \scene ] = i;
	{ evt.scenes[ i ].value; }.defer;
};

/*
~harp.scenes.goToScore(6);
~harp.scenes.goToScore; // to main
*/

// [47, 45, 48, 49, 46, 44 ] << > > O [] *

//UScore.current.events.collect(_.pos)