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
	masterarm = getprop("controls/armament/master-arm");

	if ( trigger2 and masterarm) { 
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

set_station_status = func() {

	masterarm = getprop("controls/armament/master-arm");
	jettisonall = getprop("controls/armament/station[0]/jettison-all");
	drop1 = getprop("controls/armament/drop1");
	drop2 = getprop("controls/armament/drop2");
	drop3 = getprop("controls/armament/drop3");
	drop4 = getprop("controls/armament/drop4");
	drop5 = getprop("controls/armament/drop5");
	
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
}

setlistener( release , set_station_status );
setlistener( jettisonall , set_station_status );
