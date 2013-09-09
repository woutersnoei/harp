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
		name: \hamel,
		index: 0,
		power: true,
		slider: \amp,
		shift_slider: \shiftAmt,
		knob: \filter
	),
	(
		name: \schuif,
		index: 2,
		power: true,
		slider: \amp,
		knob: \ratio
	),
	(
		name: \fast_fx,
		index: 3,
		power: true,
		slider: \amp,
		knob: \filter
	),
	(
		name: \drone,
		index: 4,
		power: true,
		slider: \amp,
		knob: \filter
	),
	(
		name: \clicks,
		index: 5,
		power: true,
		slider: \amp,
		knob: \ratio
	),
	(
		name: \live_squeek,
		index: 6,
		power: true,
		slider: \amp,
		knob: \lag
	),
	(
		name: \live_echos,
		index: 7,
		power: true,
		slider: \amp,
		knob: \maxShift
	),
	(
		name: \live_holdpeak,
		index: 8,
		power: true,
		slider: \amp,
		knob: \dev
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
				}
			);
			if( shift ) { type = ("shift_" ++ type).asSymbol };
			if( item[ type ].notNil ) {
				switch( item[ type ].class,
					Function, { item[ type ].value( value ) },
					Symbol, { evt[ item.name ].mapCatchSet( item[ type ], value ); },
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
