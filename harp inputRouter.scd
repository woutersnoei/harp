~harp = ~harp ? EM();

~harp.inputRouter = InputRouter.unique( s, "harp", [ \silent, \small_harp, \large_harp ] );

~harp.inputRouter.gui;
