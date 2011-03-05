# set the paratroopers weight
loaded = props.globals.getNode("controls/paratroopers", 1);

set_paratroopers_weight = func() {
	para = getprop("controls/paratroopers");

	if (para)
	{
		setprop("/consumables/fuel/tank[9]/level-gal_us[0]",200);
	}
	if (!para)
	{
		setprop("/consumables/fuel/tank[9]/level-gal_us[0]",0);
	}	
}

setlistener( loaded , set_paratroopers_weight );

# remove the paratroopers weight after they jump
signal = props.globals.getNode("controls/jump-signal", 1);

rm_paratroopers_weight = func() {
	para = getprop("controls/paratroopers");

	if ( para )
	{
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",14) }, 0);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",13) }, 1);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",12) }, 2);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",11) }, 3);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",10) }, 4);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",9) }, 5);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",8) }, 6);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",7) }, 7);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",6) }, 8);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",5) }, 9);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",4) }, 10);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",3) }, 11);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",2) }, 12);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",1) }, 13);
		settimer(func {setprop("/consumables/fuel/tank[9]/level-gal_us[0]",0) }, 14);
	}
}

setlistener( signal , rm_paratroopers_weight );

#monitor the gross weight
#gw = props.globals.getNode("fdm/jsbsim/inertia/weight-lbs", 1);

monitor_weight = func() {
	gweight = getprop("fdm/jsbsim/inertia/weight-lbs");

	if ((gweight != nil) and (gweight > 14444))
	{
		screen.log.write("Warning: Maximum Take Off Weight Exceeded!");
	}
}

#setlistener( gw , monitor_weight );

#monitor the jump signal
signal = props.globals.getNode("controls/signal", 1);

monitor_jumpsignal = func() {
	para = getprop("controls/paratroopers");

	if (para)
	{
		setprop("controls/jump-signal",1);
	}
}

setlistener( signal , monitor_jumpsignal );

