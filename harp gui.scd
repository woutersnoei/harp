~harp = ~harp ? EM();

~harp.mapSet = { |evt, what, value| 
	evt.perform( what.asSymbol.asSetter, evt.specs[ what.asSymbol.asGetter ].asSpec.map(value) );
};

~harp.mapGet = { |evt, what, value| 
	evt.specs[ what.asSymbol.asGetter ].asSpec.unmap( evt.perform( what.asSymbol.asGetter ) );
};

~harp.getWindowHeightFor = { |ev, which = 'tttt'|
	(((ev[ which ] !? _.specs).size + 1)* 18)
};

~harp.makeWindowFor = { |ev, which = 'tttt', parent, width = 250|
	var specs, evt, ctrl;
	var path;
	evt = ev[ which ];
	specs = evt !? _.specs;
	evt.composite = EZCompositeView( parent, (width+8)@( ev.getWindowHeightFor( which ) ) );
	if( which.asString[..4] == "live_" ) {
		evt.composite.view.background = Gradient( 
			Color.blue(0.7).blend( Color.gray(0.8), 0.8 ), 
			Color.gray(0.9), \v 
		);
	} {
		evt.composite.view.background = Gradient( Color.gray(0.8), Color.gray(0.9), \v );
	};
	ctrl = SimpleController( evt );
	evt.composite.onClose = { ctrl.remove };
	evt.views = ();
	evt.views[ \power ] = SmoothButton( evt.composite, 14 @ 14 )
			.border_(1)
			.radius_(2)
			.background_( Gradient( Color.gray(1), Color.gray(0.8), \v ) )
			.label_(['power','power'])
			.hiliteColor_( Color.green )
			.action_({ |bt|
				switch( bt.value.asInt,
					1, { evt.start },
					0, { evt.end }
				);
			})
			.resize_(2);
	evt.views[ \label ] = StaticText( evt.composite, (width - 140) @ 14 )
		.string_( which.asString )
		.font_( Font( "Helvetica-Bold", 10 ) );
	if( evt.keys.asArray.includes( \getPreset ) ) {
		evt.views[ \fillPresets ] = {
			evt.views[ \presets ].items = [ "presets", "" ] ++ evt.presetNames ++ 
				[ "", "save", "revert", "add..", "remove.." ];
		};
		evt.views[ \presets ] = PopUpMenu( evt.composite, 108 @ 14 )
			.action_({ |pu|
				case { pu.item.isKindOf( Symbol ) } {
					evt.applyPreset( pu.item );
				} { pu.item == "save" } {
					~harp.presetSystem.save;
				} { pu.item == "revert" } {
					~harp.presetSystem.read;
					~harp.names.do({ |key|
						key = ~harp[ key ];
						if( key.views !? { |x| x.keys.includes( \fillPresets ) } ? false) {
							key.views.fillPresets;
						};
					});
				} { pu.item == "add.." } {
					SCRequestString( "default", "Please enter preset name:", { |string|
						evt.getPreset( string.asSymbol );
						evt.views.fillPresets;	
					});
				} { pu.item == "remove.." } {
					SCRequestString( evt.presetNames.cs, "Please edit preset names:", { 
						|string|
						evt.presetNames_( string.interpret );
						evt.views.fillPresets;
					});
				};
				pu.value = 0;
			}).font_( Font( "Helvetica", 10 ) );
		evt.views.fillPresets;
	} {
		evt.composite.decorator.shift(112,0);
	};
	evt.views[ \file ] = SmoothButton( evt.composite, 14 @ 14 )
		.border_(1)
		.background_( Gradient( Color.gray(1), Color.gray(0.8), \v ) )
		.radius_(2)
		.label_( 'document' )
		.action_({ ( ev.path +/+ "harp" + which ++ ".scd" ).openDocument })
		.resize_(2);
	ctrl.put( \active, {
		evt.views[ \power ].value = (evt.active == true).binaryValue;
	});
	evt.changed( \active );
	if( specs.notNil ) {
		RoundView.pushSkin( ( 
			labelWidth: 50, 
			font:  Font( "Arial", 9 ),  
			baseWidth: 0.9, 
			hiliteColor: Color.gray(0.2).alpha_(0.25),
			knobSize: 0.5,
			knobColor: Color.black.alpha_(0.25)
		) );
		evt.specs.keysValuesDo({ |key, spec|
			var view;
			view = spec.makeView(  evt.composite, width @ 14, key.asString, { |sl, val|
				evt.perform( key.asSetter, val );
			});
			ctrl.put( key, { spec.setView( view, evt.perform( key.asGetter ) ) });
			evt.changed( key );
			evt.views[ key ] = view;
		});
		RoundView.popSkin;
	};
	evt.composite;
};

~harp.makeWindow = { |evt, which, width = 230, columns = 3|
	which = which ? evt.names;
	evt.window = Window( "harp controls", Rect(440, 250,(width+14) * columns, 720) ).front;
	evt.window.addFlowLayout;
	evt.composite = EZCompositeView( evt.window, (width+8) @ evt.window.bounds.height );
	evt.composite.addFlowLayout;
	which.do({ |item|
		var comp;
		if(  evt.composite.decorator.top >= ((evt.composite.bounds.height - 5) - 
				evt.getWindowHeightFor( item ) ) ) {
			evt.composite = EZCompositeView( evt.window, width+8 @ evt.window.bounds.height );
			evt.composite.addFlowLayout;
		};
		comp = evt.makeWindowFor( item, evt.composite, width );
		evt.composite.decorator.nextLine;
	});
};

/*
~harp.makeWindow( );
*/