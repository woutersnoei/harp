~harp = ~harp ? EM();

~harp.nanoKONTROL =  ~harp.nanoKONTROL ? EM();

~harp.nanoKONTROL.parent = ~harp;

~harp.lastValueDict = EM();

~harp.mapCatchSet = { |evt, key = \amp, value = 0|
	var current, last;
	current = evt.mapGet( key );
	last = evt.lastValueDict[ evt.getParentKey ] !? _[ key ];
	if( last.notNil ) {
		evt.mapSet( key, value );
	} {
		if( value.equalWithPrecision( current, 0.1 ) ) {
			evt.mapSet( key, value );
			evt.lastValueDict[ evt.getParentKey ] = (evt.lastValueDict[ evt.getParentKey ] ? EM())
				.put( key, value )
		};
	};
};

~harp.getParentKey = { |evt|
	evt.parent !? { |parent|
		parent.findKeyForValue( evt );
	};
};

(
~harp.midiOut = MIDIOut(0, 
	MIDIClient.destinations.detect({ |item| 
		item.device.find( "face" ).notNil 
	}) !? _.uid ? 0
).latency_(0.1);
);

/*
~harp.midiOut.noteOn( 0, 65, 64 ); 
*/

/*
format:

(
	name: <name of item>,
	index: <index of slider/knob/buttons (0-8)>,
	power: <true/false> // use upper/lower button for on/off
	slider: <key / func>
	knob: <key / func >,
	upper: <key / func>,
	lower: <key / func>,
)
*/

(
~harp.nanoKONTROL.routing = [ 
	/*
	(
		name: \tremolo,
		index: 0,
		power: true,
		slider: \amp,
		shift_slider: \shiftAmt,
		knob: \filter
	),
	(
		name: \chord,
		index: 1,
		power: true,
		slider: \amp,
		knob: \transp
	),
	*/
	(
		name: \plong,
		index: 0,
		power: true,
		slider: { |value|
			var lastVal;
			lastVal = ~harp.plong.lastVal ? 0;
			~harp.plong.lastVal = value;
			~harp.plong.semitones = 
				~harp.plong.semitones.put(1, value.linlin(0,1,-12,24).round(1) );
			if( value >= (lastVal + 0.025) ) {
				~harp.plong.reverse = false;
			};
			if( value <= (lastVal - 0.025) ) {
				~harp.plong.reverse = true;
			};
			if( (value >= (lastVal + 0.1))  or: (value <= (lastVal - 0.1)) ) {
				~harp.plong.start;
			};
			
		}
	),
	(
		name: \hamel,
		index: 1,
		autopower: true,
		slider: \amp,
		shift_slider: \shiftAmt,
		knob: \filter,
		upper: { |value|
			// inc. transp
			var transp;
			transp = ~harp.hamel.transp.abs.sum;
			if( value == 1 ) {	
				case { transp < 24 } {
					~harp.hamel.transp = [-12,12];
				} { transp < 48 } {
					~harp.hamel.transp = [-24,24];
				} {
					~harp.hamel.transp = [0,0];
				};
			};
		},
		lower: { |value|
			// dec. reso
			if( value == 1 ) {	
				~harp.hamel.shiftAmt = (~harp.hamel.shiftAmt + 400).fold(0,400);
			};
		}
	),
	(
		name: \schuif,
		index: 2,
		autopower: true,
		slider: \amp,
		knob: \ratio,
		upper: { |value|
			// inc. reso
			if( value == 1 ) {	
				~harp.schuif.reso = (~harp.schuif.reso + 0.1).min(1);
			};
		},
		lower: { |value|
			// dec. reso
			if( value == 1 ) {	
				~harp.schuif.reso = (~harp.schuif.reso - 0.1).max(0);
			};
		}
	),
	(
		name: \fast_fx,
		index: 3,
		autopower: true,
		slider: \amp,
		knob: \filter,
		upper: { |value|
			// toggle filterWidth
			if( value == 1 ) {
				if( ~harp.fast_fx.filterWidth < 1 ) { 
					~harp.fast_fx.filterWidth = 1 
				} {
					~harp.fast_fx.filterWidth = 0.5
				};
			};
		},
		lower: { |value|
			// toggle moddepth
			if( value == 1 ) {
				if( ~harp.fast_fx.moddepth < 1 ) { 
					~harp.fast_fx.moddepth = 1;
				} {
					~harp.fast_fx.moddepth = 0;
				};
			};
		}
	),
	(
		name: \drone,
		index: 4,
		autopower: true,
		slider: \amp,
		knob: \filter,
		upper: { |value|
			if( value == 1 ) {
				 // toggle filterWidth
				if( ~harp.drone.filterWidth < 1 ) { 
					~harp.drone.filterWidth = 1 
				} {
					~harp.drone.filterWidth = 0.5
				};
			};
		},
		lower: { |value|
			// toggle moddepth
			if( value == 1 ) {	
				if( ~harp.drone.moddepth < 1 ) { 
					~harp.drone.moddepth = 1;
				} {
					~harp.drone.moddepth = 0;
				};
			};
		}
	),
	(
		name: \clicks,
		index: 5,
		autopower: true,
		slider: \amp,
		knob: \ratio
	),
	(
		name: \live_squeek,
		index: 6,
		autopower: true,
		slider: \amp,
		knob: \lag
	),
	(
		name: \live_echos,
		index: 7,
		autopower: true,
		slider: \amp,
		knob: \maxShift
	),
	(
		name: \live_holdpeak,
		index: 8,
		autopower: true,
		slider: \amp,
		knob: \dev,
		upper: { |value|
			if( value == 1 ) {
				 // catch on
				 if( ~harp.live_sample.catch == true	) {
					~harp.live_sample.catch2 = true;	
				 } {
					 ~harp.live_sample.catch = true;	
				 };
			};
		},
		lower: { |value|
			if( value == 1 ) {
				 // catch off
				 if( ~harp.live_sample.catch2 == true	) {
					~harp.live_sample.catch2 = false;	
				 } {
					 ~harp.live_sample.catch = false;
				 };	
			};
		},
	),
	(
		name: \panfocus,
		index: 0,
		knob: \amount
	),

	]
);

~harp.nanoKONTROL.apply = { |evt, index = 0, type = \upper, value = 0, shift = false|
	evt.routing.do({ |item|
		if( item.index == index ) {
			switch( type, 
				\upper, {
					if( item.power.notNil ) {
						if( value.asInt == 1 ) {
							evt[ item.name ].start;
						};
					};
				}, 
				\lower, {
					if( item.power.notNil ) {
						if( value.asInt == 1 ) {
							evt[ item.name ].end;
						};
					};			
				},
				\slider, {
					if( item.autopower.notNil ) {
						if( value > 0 ) {
							if( evt[ item.name ].active != true ) {
								evt[ item.name ].start;
							};
						} {
							evt[ item.name ].end;
						};
					};	
				}
			);
			if( shift ) { type = ("shift_" ++ type).asSymbol };
			if( item[ type ].notNil ) {
				switch( item[ type ].class,
					Function, { item[ type ].value( value ) },
					Symbol, { 
						if( item[ type ] === \amp ) {
							evt[ item.name ].mapSet( item[ type ], 
								value.lincurve(0,1,0,1,2) 
							); 
						} {
							evt[ item.name ].mapSet( item[ type ], value ); 
						};
					},
				);
			};
		};
	});
};

~harp.nanoKONTROL.activate = { |evt, scene = 0|
	NanoKONTROL();
	NanoKONTROL.buttons[scene][23].action = { 
		~harp.lastValueDict = EM();
	};
	9.do({ |i|
		NanoKONTROL.sliders[ scene ][ i ].action = { |sl|
			evt.apply( i, \slider, sl.value, NanoKONTROL.buttons[0][23].value == 1 );
		};
		NanoKONTROL.knobs[ scene ][ i ].action = { |sl|
			evt.apply( i, \knob, sl.value, NanoKONTROL.buttons[0][23].value == 1 );
		};
		NanoKONTROL.buttons[ scene ][ i ].action = { |sl|
			evt.apply( i, \upper, sl.value, NanoKONTROL.buttons[0][23].value == 1 );
		};
		NanoKONTROL.buttons[ scene ][ i+9 ].action = { |sl|
			evt.apply( i, \lower, sl.value, NanoKONTROL.buttons[0][23].value == 1 );
		};
	});
	NanoKONTROL.buttons[scene][18].action = { |bt| // bwd
		if( bt.value == 1 ) {
			~harp.scenes.scene = (~harp.scenes.scene - 1).max(0);
		};
	};
	NanoKONTROL.buttons[scene][20].action = { |bt| // fwd
		if( bt.value == 1 ) {
			~harp.scenes.scene = (~harp.scenes.scene + 1).min(6);
		};
	};
	NanoKONTROL.buttons[scene][23].action = { |bt| // next light cue
		if( bt.value == 1 ) {
			~harp.midiOut.noteOn( 0, 65, 64 ); 
		};
	};
	NanoKONTROL.buttons[scene][21].action = { |bt| // prev light cue
		if( bt.value == 1 ) {
			~harp.midiOut.noteOn( 0, 67, 64 ); 
		};
	};
};

~harp.nanoKONTROL.fillGUI = { |evt|
	if( evt.window.notNil && { evt.window.isClosed.not } ) {
		evt.routing.do({ |item|
			[ \slider, \knob, \upper, \lower ].do({ |type|
				if( item[ type ].class == Symbol ) {
					if( evt[ item.name ].views[ item[ type ] ].isKindOf( Dictionary ) && {
							evt[ item.name ].views[ item[ type ] ].sliderView.notNil
						}
					) {
						evt[ item.name ].views[ item[ type ] ].sliderView.stringColor = Color.gray(0.1).alpha_(0.5);
						evt[ item.name ].views[ item[ type ] ].sliderView.background = Color.yellow.blend( Color.gray, 0.75 ).alpha_(0.5);
						evt[ item.name ].views[ item[ type ] ].sliderView.string = "% %".format( type.asString.firstToUpper, item.index + 1 );
						
					};
				};
			});
			if( item.power == true ) {
				evt[ item.name ].views.label.string = "% (%)".format( item.name, item.index+1 );
			};
		});
	};
};

~harp.nanoKONTROL.activate;

/*
~harp.makeWindow;
~harp.nanoKONTROL.fillGUI;
*/
