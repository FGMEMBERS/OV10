# EXPORT : functions ending by export are called from xml
# CRON : functions ending by cron are called from timer
# SCHEDULE : functions ending by schedule are called from cron



# ==============
# DME Selector
# ==============

# DME

dmeschedule = func{
   brgmode=getprop("/instrumentation/navcomputer/brg-switch-position");
   inrange="false";
   distance=999.9;
   bearing=0;
   heading=0;
   if(brgmode == 1){
       inrange=getprop("/instrumentation/dme/in-range");
       if(inrange){distance=getprop("/instrumentation/dme/indicated-distance-nm");};
       bearing=getprop("/instrumentation/nav/radials/reciprocal-radial-deg");
   }
   if(brgmode == 2){
       inrange=getprop("/instrumentation/tacan/in-range");
       if(inrange){distance=getprop("/instrumentation/tacan/indicated-distance-nm");};
       bearing=getprop("/instrumentation/tacan/indicated-bearing-true-deg")-getprop("/environment/magnetic-variation-deg");
   }
   if(brgmode == 3){
       inrange=getprop("/instrumentation/tacan/in-range");
       if(inrange){distance=getprop("/instrumentation/tacan/indicated-distance-nm");};
       bearing=getprop("/instrumentation/adf/indicated-bearing-deg");
       heading=getprop("/orientation/heading-magnetic-deg[0]");
       bearing=bearing+heading;
   }
   if(brgmode == 4){
       inrange=getprop("/instrumentation/tacan/in-range");
       if(inrange){distance=getprop("/instrumentation/tacan/indicated-distance-nm");};
       bearing=getprop("/instrumentation/nav/radials/reciprocal-radial-deg");
   }
   setprop("/instrumentation/navcomputer/in-range", inrange);
   setprop("/instrumentation/navcomputer/indicated-bearing", bearing);
   setprop("/instrumentation/navcomputer/indicated-distance-nm", distance);

}

# Fuel pump warning light
matlist = { # MATERIALS
#       status   diffuse            ambient            emission           specular           shi trans
	"on":    [0.97, 0.368, 0.1,    0.97, 0.368, 0.1,    0.97, 0.368, 0.1,     0.05, 0.05, 0.05,     10, 0],
	"off":   [0.61, 0.39, 0.29,    0.61, 0.39, 0.29,    0.0, 0.0, 0.0,     0.05, 0.05, 0.05,     10, 0],
};

update_fuel_pump_warning = func() {
	i = 0;
	
	feeding = getprop("controls/external-tank/is-feeding[0]");
	empty = getprop("controls/external-tank/is-empty[0]");
	attached = getprop("controls/external-tank/is-attached[0]");
	failed = getprop("controls/external-tank/pump-has-failed[0]");
	if (feeding and empty and !failed)
	{
		mat = matlist ["on"];
	}
	elsif (feeding and !attached and !failed)
	{
		mat = matlist ["on"];
	}
	else
	{
		mat = matlist ["off"];
	}

	base = "sim/model/extfuelwarning/material/light-on/";
	foreach (t; ["diffuse", "ambient", "emission", "specular"]) {
		foreach (c; ["red", "green", "blue"]) {
			setprop(base ~ t ~ "/" ~ c, mat[i]);
			i += 1;
		}
	}
	setprop(base ~ "shininess", mat[i]);
	setprop(base ~ "transparency/alpha", 1.0 - mat[i + 1]);
}

# set gun trigger on only if master-arm is on
trigger = props.globals.getNode("controls/armament/trigger", 1);

set_gun_trigger = func() {
	trigger2 = getprop("controls/armament/trigger");
	gun_charged = getprop("controls/armament/gun-charged");
	g_ready = getprop("controls/armament/g_ready");
	masterarm = getprop("controls/armament/master-arm");
	easy = getprop("controls/level/easy");

	if ( trigger2 and masterarm and !gun_charged and g_ready) { 
		setprop("controls/armament/gun-charged", 1);
		setprop("controls/armament/charging", 1);
	}
	if ( trigger2 and masterarm and gun_charged and g_ready and !easy) { 
		setprop("controls/armament/charging", 0);
		setprop("controls/armament/gun-trigger", 1);
	}
	if ( trigger2 and masterarm and easy) { 
		setprop("controls/armament/charging", 0);
		setprop("controls/armament/gun-trigger", 1);
	}
	if ( !trigger2 and masterarm) { 
		setprop("controls/armament/gun-trigger", 0);
	}
}

setlistener( trigger , set_gun_trigger );

# set weapon station status
release = props.globals.getNode("/controls/armament/release", 1);
jettisonall = props.globals.getNode("controls/armament/station[0]/jettison-all", 1);

nstation1 = props.globals.getNode("/controls/armament/nstation1", 1);
nstation2 = props.globals.getNode("/controls/armament/nstation2", 1);
nstation3 = props.globals.getNode("/controls/armament/nstation3", 1);
nstation4 = props.globals.getNode("/controls/armament/nstation4", 1);
nstation5 = props.globals.getNode("/controls/armament/nstation5", 1);

set_station_status = func() {

	masterarm = getprop("controls/armament/master-arm");
	jettisonall = getprop("controls/armament/station[0]/jettison-all");
	release = getprop("/controls/armament/release");

	drop1 = getprop("controls/armament/drop1");
	drop2 = getprop("controls/armament/drop2");
	drop3 = getprop("controls/armament/drop3");
	drop4 = getprop("controls/armament/drop4");
	drop5 = getprop("controls/armament/drop5");

	fire1 = getprop("controls/armament/fire1");
	fire2 = getprop("controls/armament/fire2");
	fire3 = getprop("controls/armament/fire3");
	fire4 = getprop("controls/armament/fire4");
	fire5 = getprop("controls/armament/fire5");

	station1 = getprop("controls/armament/station1");
	station5 = getprop("controls/armament/station5");
     	count1 = getprop("ai/submodels/submodel[4]/count");
     	count5 = getprop("ai/submodels/submodel[6]/count");
	
	if (masterarm and drop1)
	{
		setprop("controls/armament/station1",1);
		setprop("consumables/fuel/tank[5]/level-gal_us",0);
	}
	if (masterarm and drop2)
	{
		setprop("controls/armament/station2",1);
		setprop("consumables/fuel/tank[3]/level-gal_us",0);
	}
	if (masterarm and drop3)
	{
		setprop("controls/external-tank/is-attached[0]",0);
		setprop("controls/armament/station3",1);
		setprop("consumables/fuel/tank[1]/level-gal_us",0);
	}
	if (masterarm and drop4)
	{
		setprop("controls/armament/station4",1);
		setprop("consumables/fuel/tank[2]/level-gal_us",0);
	}
	if (masterarm and drop5)
	{
		setprop("controls/armament/station5",1);
		setprop("consumables/fuel/tank[4]/level-gal_us",0);
	}
	if (jettisonall)
	{
		setprop("controls/armament/station1",1);
		setprop("consumables/fuel/tank[5]/level-gal_us",0);
		setprop("controls/armament/station2",1);
		setprop("consumables/fuel/tank[3]/level-gal_us",0);
		setprop("controls/external-tank/is-attached[0]",0);
		setprop("controls/armament/station3",1);
		setprop("consumables/fuel/tank[1]/level-gal_us",0);
		setprop("controls/armament/station4",1);
		setprop("consumables/fuel/tank[2]/level-gal_us",0);
		setprop("controls/armament/station5",1);
		setprop("consumables/fuel/tank[4]/level-gal_us",0);
	}
	if (masterarm and fire1 and !station1 and count1>0)
	{
		setprop("controls/armament/trigger1",1);
	}
	if (masterarm and fire5 and !station5 and count5>0)
	{
		setprop("controls/armament/trigger5",1);
	}
	if (masterarm and fire1 and !release)
	{
		setprop("controls/armament/trigger1",0);
	}
	if (masterarm and fire5 and count5<0)
	{
		setprop("controls/armament/trigger5",0);
	}
}

setlistener( release , set_station_status );
setlistener( jettisonall , set_station_status );

set_station1 = func() {
	nstation1 = getprop("/controls/armament/nstation1");

	if ( nstation1 )
	{
		setprop("controls/armament/station1",0);
		setprop("consumables/fuel/tank[5]/level-gal_us",1000);
	}
	if ( !nstation1 )
	{
		setprop("controls/armament/station1",1);
		setprop("consumables/fuel/tank[5]/level-gal_us",0);
	}
}

set_station2 = func() {
	nstation2 = getprop("/controls/armament/nstation2");

	if ( nstation2 )
	{
		setprop("controls/armament/station2",0);
		setprop("consumables/fuel/tank[3]/level-gal_us",1000);
	}
	if ( !nstation2 )
	{
		setprop("controls/armament/station2",1);
		setprop("consumables/fuel/tank[3]/level-gal_us",0);
	}
}

set_station3 = func() {
	nstation3 = getprop("/controls/armament/nstation3");

	if ( nstation3 )
	{
		setprop("controls/armament/station3",0);
		setprop("consumables/fuel/tank[1]/level-gal_us",1000);
		setprop("controls/external-tank/is-attached[0]",1);
	}
	if ( !nstation3 )
	{
		setprop("controls/armament/station3",1);
		setprop("consumables/fuel/tank[1]/level-gal_us",0);
		setprop("controls/external-tank/is-attached[0]",0);
	}
}

set_station4 = func() {
	nstation4 = getprop("/controls/armament/nstation4");

	if ( nstation4 )
	{
		setprop("controls/armament/station4",0);
		setprop("consumables/fuel/tank[2]/level-gal_us",1000);
	}
	if ( !nstation4 )
	{
		setprop("controls/armament/station4",1);
		setprop("consumables/fuel/tank[2]/level-gal_us",0);
	}
}

set_station5 = func() {
	nstation5 = getprop("/controls/armament/nstation5");

	if ( nstation5 )
	{
		setprop("controls/armament/station5",0);
		setprop("consumables/fuel/tank[4]/level-gal_us",1000);
	}
	if ( !nstation5 )
	{
		setprop("controls/armament/station5",1);
		setprop("consumables/fuel/tank[4]/level-gal_us",0);
	}
}

setlistener( nstation1 , set_station1 );
setlistener( nstation2 , set_station2 );
setlistener( nstation3 , set_station3 );
setlistener( nstation4 , set_station4 );
setlistener( nstation5 , set_station5 );

# outer/inner marker

matlist3 = { # MATERIALS
#       status   diffuse            ambient            emission           specular           shi trans
	"on":    [0.97, 0.368, 0.1,    0.97, 0.368, 0.1,    0.97, 0.368, 0.1,     0.05, 0.05, 0.05,     10, 0],
	"off":   [0.61, 0.39, 0.29,    0.61, 0.39, 0.29,    0.0, 0.0, 0.0,     0.05, 0.05, 0.05,     10, 0],
};

set_marker_light = func() {
	i = 0;
	outer = getprop("/instrumentation/marker-beacon/outer");
	inner = getprop("/instrumentation/marker-beacon/inner");	

	if (outer or inner)
	{
		mat = matlist3 ["on"];
	}
	else
	{	
		mat = matlist3 ["off"];
	}

	base = "sim/model/nav/material/light-on/";
	foreach (t; ["diffuse", "ambient", "emission", "specular"]) {
		foreach (c; ["red", "green", "blue"]) {
			setprop(base ~ t ~ "/" ~ c, mat[i]);
			i += 1;
		}
	}
	setprop(base ~ "shininess", mat[i]);
	setprop(base ~ "transparency/alpha", 1.0 - mat[i + 1]);

}

# warning panel
pbrakes = props.globals.getNode("/controls/gear/brake-parking", 1);

matlist2 = { # MATERIALS
#       fuselage   diffuse            ambient            emission           specular           shi trans
	"on":    [1.0, 1.0, 1.0,    1.0, 1.0, 1.0,    1.0, 1.0, 1.0,     0.2, 0.2, 0.2,     0,  0],
	"off":   [0.0, 0.0, 0.0,    0.0, 0.0, 0.0,    0.0, 0.0, 0.0,     0.2, 0.2, 0.2,     10, 0],
};

set_pbrakes_warnings = func() {
	i = 0;
	pbrakes = getprop("/controls/gear/brake-parking");	

	if (pbrakes)
	{
		mat = matlist2 ["on"];
	}
	else
	{	
		mat = matlist2 ["off"];
	}

	base = "sim/model/ov10/material/pbrakes/";
	foreach (t; ["diffuse", "ambient", "emission", "specular"]) {
		foreach (c; ["red", "green", "blue"]) {
			setprop(base ~ t ~ "/" ~ c, mat[i]);
			i += 1;
		}
	}
	setprop(base ~ "shininess", mat[i]);
	setprop(base ~ "transparency/alpha", 1.0 - mat[i + 1]);
}

#setlistener(pbrakes, set_pbrakes_warnings );

set_fuel_warning = func() {
        i = 0;
	current = getprop("/consumables/fuel/tank[0]/level-gal_us[0]");

	if (current < 38.0)
	{
		mat = matlist2 ["on"];
	}
	else
	{	
		mat = matlist2 ["off"];
	}

	base = "sim/model/ov10/material/lowfuel/";
	foreach (t; ["diffuse", "ambient", "emission", "specular"]) {
		foreach (c; ["red", "green", "blue"]) {
			setprop(base ~ t ~ "/" ~ c, mat[i]);
			i += 1;
		}
	}
	setprop(base ~ "shininess", mat[i]);
	setprop(base ~ "transparency/alpha", 1.0 - mat[i + 1]);
}

set_G_warning = func() {
        i = 0;
	current = getprop("/accelerations/pilot/z-accel-fps_sec");
	current = current/(-32);

	if (current > 4.0)
	{
		mat = matlist2 ["on"];
		base = "sim/model/ov10/material/maxG/";
		foreach (t; ["diffuse", "ambient", "emission", "specular"]) {
			foreach (c; ["red", "green", "blue"]) {
				setprop(base ~ t ~ "/" ~ c, mat[i]);
				i += 1;
			}
		}
		setprop(base ~ "shininess", mat[i]);
		setprop(base ~ "transparency/alpha", 1.0 - mat[i + 1]);
	}
	elsif (current < -1.2)
	{
		mat = matlist2 ["on"];
		base = "sim/model/ov10/material/minG/";
		foreach (t; ["diffuse", "ambient", "emission", "specular"]) {
			foreach (c; ["red", "green", "blue"]) {
				setprop(base ~ t ~ "/" ~ c, mat[i]);
				i += 1;
			}
		}
		setprop(base ~ "shininess", mat[i]);
		setprop(base ~ "transparency/alpha", 1.0 - mat[i + 1]);
	}
	else
	{	
		mat = matlist2 ["off"];

		i = 0;
		base = "sim/model/ov10/material/maxG/";
		foreach (t; ["diffuse", "ambient", "emission", "specular"]) {
			foreach (c; ["red", "green", "blue"]) {
				setprop(base ~ t ~ "/" ~ c, mat[i]);
				i += 1;
			}
		}
		setprop(base ~ "shininess", mat[i]);
		setprop(base ~ "transparency/alpha", 1.0 - mat[i + 1]);
		i = 0;
		base = "sim/model/ov10/material/minG/";
		foreach (t; ["diffuse", "ambient", "emission", "specular"]) {
			foreach (c; ["red", "green", "blue"]) {
				setprop(base ~ t ~ "/" ~ c, mat[i]);
				i += 1;
			}
		}
		setprop(base ~ "shininess", mat[i]);
		setprop(base ~ "transparency/alpha", 1.0 - mat[i + 1]);
	}

}

beacon = func() {
	#turn off tail beacon
	base = "sim/model/ov10/material/tailBeacon/";
	setprop(base ~ "diffuse/red", 0.4);
	setprop(base ~ "ambient/red", 0.4);
	setprop(base ~ "emission/red", 0);

	settimer(bellyBeacon,0.5);
	settimer(tailBeacon,1);
}

bellyBeacon = func() {
	base = "sim/model/ov10/material/bellyBeacon/";
	setprop(base ~ "diffuse/red", 1);
	setprop(base ~ "ambient/red", 1);
	setprop(base ~ "emission/red", 1);
}

tailBeacon = func() {
	base = "sim/model/ov10/material/bellyBeacon/";
	setprop(base ~ "diffuse/red", 0.4);
	setprop(base ~ "ambient/red", 0.4);
	setprop(base ~ "emission/red", 0);

	base = "sim/model/ov10/material/tailBeacon/";
	setprop(base ~ "diffuse/red", 1);
	setprop(base ~ "ambient/red", 1);
	setprop(base ~ "emission/red", 1);
}

# TACAN channels
channel = props.globals.getNode("/instrumentation/tacan/frequencies/selected-channel[4]", 1);

update_channel = func() {
	channel = getprop("/instrumentation/tacan/frequencies/selected-channel[4]");
	if  ( channel == "X" )
	{
		#print("X");
		setprop("/instrumentation/tacan/frequencies/valueXY",0.0);
	}
	else
	{
		#print("Y");
		setprop("/instrumentation/tacan/frequencies/valueXY",1.0);
	}
}

update_channel();
#setlistener( channel , update_channel );

increase_first_2 = func() {
	h = getprop("/instrumentation/tacan/frequencies/selected-channel[1]");
	d = getprop("/instrumentation/tacan/frequencies/selected-channel[2]");

	d = d+1;

	if ( d == 10 )
	{	
		d = 0;
		h = h+1;
	}
	if ( h == 10 )
	{
		h = 0;
	}

	setprop("/instrumentation/tacan/frequencies/selected-channel[1]",h);
	setprop("/instrumentation/tacan/frequencies/selected-channel[2]",d);
}

decrease_first_2 = func() {
	h = getprop("/instrumentation/tacan/frequencies/selected-channel[1]");
	d = getprop("/instrumentation/tacan/frequencies/selected-channel[2]");

	d = d-1;

	if ( d == -1 )
	{	
		d = 9;
		h = h-1;
	}
	if ( h == -1 )
	{
		h = 9;
	}

	setprop("/instrumentation/tacan/frequencies/selected-channel[1]",h);
	setprop("/instrumentation/tacan/frequencies/selected-channel[2]",d);
}

increase_last_2 = func() {
	u = getprop("/instrumentation/tacan/frequencies/selected-channel[3]");
	x = getprop("/instrumentation/tacan/frequencies/selected-channel[4]");

	u = u+1;

	if ( u == 10 )
	{	
		u = 0;
		if ( x == "X" )
		{
			x = "Y";
		}
		else
		{
			x = "X";
		}
	}

	setprop("/instrumentation/tacan/frequencies/selected-channel[3]",u);
	setprop("/instrumentation/tacan/frequencies/selected-channel[4]",x);
}

decrease_last_2 = func() {
	u = getprop("/instrumentation/tacan/frequencies/selected-channel[3]");
	x = getprop("/instrumentation/tacan/frequencies/selected-channel[4]");

	u = u-1;

	if ( u == -1 )
	{	
		u = 9;
		if ( x == "X" )
		{
			x = "Y";
		}
		else
		{
			x = "X";
		}
	}

	setprop("/instrumentation/tacan/frequencies/selected-channel[3]",u);
	setprop("/instrumentation/tacan/frequencies/selected-channel[4]",x);
}
