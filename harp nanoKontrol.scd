~harp = ~harp ? EM();

~harp.nanoKONTROL =  ~harp.nanoKONTROL ? EM();

~harp.nanoKONTROL.parent = ~harp;

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
	(
		name: \tremolo,
		index: 0,
		power: true,
		slider: \amp,
		knob: \filter
	),
	(
		name: \chord,
		index: 1,
		power: true,
		slider: \amp,
		knob: \transp
	),
	]
);

~harp.nanoKONTROL.apply = { |evt, index = 0, type = \upper, value = 0|
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
			if( item[ type ].notNil ) {
				switch( item[ type ].class,
					Function, { item[ type ].value( value ) },
					Symbol, { evt[ item.name ].mapSet( item[ type ], value ); },
				);
			};
		};
	});
};

~harp.nanoKONTROL.activate = { |evt, scene = 0|
	NanoKONTROL();
	9.do({ |i|
		NanoKONTROL.sliders[ scene ][ i ].action = { |sl|
			evt.apply( i, \slider, sl.value );
		};
		NanoKONTROL.knobs[ scene ][ i ].action = { |sl|
			evt.apply( i, \knob, sl.value );
		};
		NanoKONTROL.buttons[ scene ][ i ].action = { |sl|
			evt.apply( i, \upper, sl.value );
		};
		NanoKONTROL.buttons[ scene ][ i+9 ].action = { |sl|
			evt.apply( i, \lower, sl.value );
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
		});
	};
};

~harp.nanoKONTROL.activate;

/*
~harp.makeWindow;
~harp.nanoKONTROL.fillGUI;
*/
