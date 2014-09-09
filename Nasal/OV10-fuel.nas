init_fuel = func {

	internal = getprop("/consumables/fuel/tank[0]/level-gal_us[0]");
	#internal += getprop("/consumables/fuel/tank[1]/level-gal_us[0]");

	failed = getprop("controls/external-tank/pump-has-failed[0]");
	if (failed)
	{
		external = 0;
	}
	else
	{
		external = getprop("consumables/fuel/tank[1]/level-gal_us[0]");
	}

	print (internal);
	print (external);
	amount = internal+external/2;
	print (amount);
	setprop("controls/initial-fuel-gal_us[0]",amount);
	setprop("/consumables/fuel/tank[0]/level-gal_us[0]",amount);
	#setprop("/consumables/fuel/tank[1]/level-gal_us[0]",(internal+external)/2);
};
#settimer(init_fuel, 0);

update_fuel = func {

	feeding = getprop("controls/external-tank/is-feeding[0]");
	attached = getprop("controls/external-tank/is-attached[0]");
	empty = getprop("controls/external-tank/is-empty[0]");
	failed = getprop("controls/external-tank/pump-has-failed[0]");
	#total = getprop("controls/initial-fuel-gal_us[0]");
	current = getprop("/consumables/fuel/tank[0]/level-gal_us[0]");
	#current += getprop("/consumables/fuel/tank[1]/level-gal_us[0]");
	restart = getprop("controls/external-tank/pump-restart[0]");
	stop = getprop("controls/external-tank/pump-stop[0]");
	failtime = getprop("controls/external-tank/pump-fail-time[0]");
	last_restart = getprop("controls/external-tank/last-level-gal_us[0]");
	ext_tank_level = getprop("/consumables/fuel/tank[1]/level-gal_us[0]");
	current_G = getprop("accelerations/pilot/z-accel-fps_sec[0]");
	negGtimeT = getprop("controls/negGtime[0]");
	speed = getprop("velocities/airspeed-kt[0]");
	fuel_cutoff1 = getprop("controls/fuel-cutoff1");
	fuel_cutoff2 = getprop("controls/fuel-cutoff2");
	
	if (feeding and !empty and !failed and !restart and attached)
	{
		setprop("/consumables/fuel/tank[0]/level-gal_us[0]",last_restart);
		setprop("/consumables/fuel/tank[1]/level-gal_us[0]",ext_tank_level-(last_restart-current));
		ext_level = getprop("/consumables/fuel/tank[1]/level-gal_us[0]");
		if (ext_level <= 0)
		{
			setprop("controls/external-tank/is-empty[0]","true");
			setprop("/consumables/fuel/tank[1]/level-gal_us[0]",0);
		}
	}

	# gravity feed cutoff if negGtime > 15
	if (!feeding and speed>30)
	{
		if (current_G>=0)
		{
			negGtimeT = negGtimeT +1;
			setprop("controls/negGtime[0]",negGtimeT);
			if (negGtimeT >= 15)
			{
				setprop("controls/engines/engine[0]/cutoff[0]","true");
				setprop("controls/engines/engine[1]/cutoff[0]","true");
				negGtimeT = 0;
				setprop("controls/negGtime[0]",negGtimeT);
			}
		}
		else
		{
			negGtimeT = 0;
			setprop("controls/negGtime[0]",negGtimeT);
		}
		
	}

	if (feeding and !empty and !failed and restart and attached )
	{
		setprop("controls/external-tank/last-level-gal_us[0]",current);
		setprop("controls/external-tank/pump-restart[0]","false");
	}

	#if (!feeding and !empty and !failed and stop)
	#{
	#	#setprop("controls/external-tank/is-feeding[0]","false");
	#	setprop("controls/external-tank/pump-stop[0]","false");
	#	external = getprop("controls/external-tank/level-gal_us[0]");
	#	setprop("/consumables/fuel/tank[0]/level-gal_us[0]",(current-external));
	#	#setprop("/consumables/fuel/tank[1]/level-gal_us[0]",(current-external)/2);
	#}

	if (feeding and empty and !failed and attached)
	{
		failtime = failtime +1;
		setprop("controls/external-tank/pump-fail-time[0]",failtime);
		if (failtime >= 900)
		{
			setprop("controls/external-tank/pump-has-failed[0]","true");
		}
	}
	if (feeding and !attached and !failed)
	{
		failtime = failtime +1;
		setprop("controls/external-tank/pump-fail-time[0]",failtime);
		if (failtime >= 900)
		{
			setprop("controls/external-tank/pump-has-failed[0]","true");
		}
	}

	if (fuel_cutoff1)
	{
		setprop("/controls/engines/engine[0]/cutoff",1);
	}
	if (fuel_cutoff2)
	{
		setprop("/controls/engines/engine[1]/cutoff",1);
	}
};
