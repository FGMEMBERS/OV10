# EXPORT : functions ending by export are called from xml
# CRON : functions ending by cron are called from timer
# SCHEDULE : functions ending by schedule are called from cron

# current nasal version doesn't accept :
# - more than multiplication on 1 line.
# - variable with hyphen or underscore.
# - boolean (can only test IF TRUE); replaced by strings.
# - object oriented classes.


# ==============
# INITIALIZATION
# ==============


# 1 seconds cron
sec1cron = func {
#   transferfuelschedule();
   dmeschedule();
   update_fuel_pump_warning();
   update_fuel();
   set_fuel_warning();
   set_marker_light();
   #set_G_warning();

#   feedengineschedule();
#   hydraulicschedule();

   # schedule the next call
   settimer(sec1cron,1);
}

sec15cron = func {
   beacon();
   update_channel();
   settimer(sec15cron,1.5);
}

# 3 seconds cron
#sec3cron = func {
#   tasschedule();
#   autopilotschedule();
#   tcasschedule();

   # schedule the next call
#   settimer(sec3cron,3);
#}

# 5 seconds cron
#sec5cron = func {
#   vmoktschedule();
#   inslightschedule();
#   airbleedschedule();

   # schedule the next call
#   settimer(sec5cron,PRESSURIZESEC);
#}

# 15 seconds cron
#sec15cron = func {
#   tmodegcschedule();
#   insfuelschedule();
#
   # schedule the next call
#   settimer(sec15cron,15);
#}

# 30 seconds cron
#sec30cron = func {
#   bucketdegschedule();
#   tankpressureschedule();

   # schedule the next call
#   settimer(sec30cron,30);
#}

# 60 seconds cron
#sec60cron = func {
   # delay to call ground power
#   groundserviceschedule();

   # schedule the next call
#   settimer(sec60cron,60);
#}

init_startup_status = func() {
	easy = getprop("/controls/level/easy");

	if (!easy)
	{
		print("level: real");
		setprop("/controls/engines/engine[0]/cutoff", 1);
		setprop("/controls/engines/engine[1]/cutoff", 1);
	}
}

# general initialization
init = func {
#   initfuel();
#   presetfuel();
#   initautopilot();

	settimer(init_startup_status,10);

   # schedule the 1st call
#   settimer(flashinglightcron,0);
   settimer(sec1cron,1);
   settimer(sec15cron,1.5);
#   settimer(sec3cron,0);
#   settimer(sec5cron,0);
#   settimer(sec15cron,0);
#   settimer(sec30cron,0);
#   settimer(sec60cron,0);
}

init();

# DIALOG box
dialog = nil;

showDialog = func {
	name = "OV10-settings";
	if (dialog != nil) {
		fgcommand("dialog-close", props.Node.new({ "dialog-name" : name }));
		dialog = nil;
		return;
	}

	dialog = gui.Widget.new();
	dialog.set("layout", "vbox");
	dialog.set("name", name);
	dialog.set("x", 40);
	dialog.set("y", 40);
	dialog.set("width", 550);
	dialog.set("height", 300);

	# "window" titlebar
	titlebar = dialog.addChild("group");
	titlebar.set("layout", "hbox");
	titlebar.addChild("empty").set("stretch", 1);
	titlebar.addChild("text").set("label", "OV10 Settings");
	titlebar.addChild("empty").set("stretch", 1);
	dialog.addChild("hrule").addChild("dummy");

	w = titlebar.addChild("button");
	w.set("pref-width", 16);
	w.set("pref-height", 16);
	w.set("legend", "");
	w.set("default", 1);
	w.set("keynum", 27);
	w.set("border", 1);
	w.prop().getNode("binding[0]/command", 1).setValue("nasal");
	w.prop().getNode("binding[0]/script", 1).setValue("equipment.dialog = nil");
	w.prop().getNode("binding[1]/command", 1).setValue("dialog-close");

	combo = func {
		group = dialog.addChild("group");
		group.set("layout", "hbox");

		label = group.addChild("text");
		label.set("label",arg[0]);
		label.set("halign","left");

		box = group.addChild("combo");
		box.set("pref-width",300);
		box.set("halign","right");

		i=0;
		foreach(choice;arg[1]) {
			box.set("value["~i~"]",choice);
			i+=1;
		}
		label;
		box;
	}

	checkbox = func {
		group = dialog.addChild("group");
		group.set("layout", "hbox");
		group.addChild("empty").set("pref-width", 4);
		box = group.addChild("checkbox");
		group.addChild("empty").set("stretch", 1);

		box.set("halign", "left");
		box.set("label", arg[0]);
		box;
	}

	slider = func {
		path = arg[3];
		group = dialog.addChild("group");
		group.set("layout", "hbox");
		#group.addChild("empty").set("stretch", 1);
		group.addChild("text").set("label", arg[0]);

		slide = group.addChild("slider");
		slide.set("halign", "left");
		slide.set("property", path);
		slide.set("live", 1);
		#if (size(arg) == 3) {
			slide.set("min", arg[1]);
			slide.set("max", arg[2]);
		#}
		slide.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

		number = group.addChild("text");
		number.set("halign", "left");
		number.set("label", "-0.123");
		number.set("format", "%.1f lbs");
		number.set("property", "consumables/fuel/tank[0]/level-lb");
		number.set("live", 1);
		number.setColor(0, 1, 0);	
		
		number;
		slide;
	}

	# Internal Fuel
	w = slider("Internal Fuel: ", 0.0, 230.0,"consumables/fuel/tank[0]/level-gal_us");

	dialog.addChild("hrule").addChild("dummy");

	# Paratroopers
	w = checkbox("5 Paratroopers (1100 lbs)");
	w.set("property", "controls/paratroopers");
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

	# Stations
	w = checkbox("Station 1: LAU-68 rockets (190 lbs)");
	w.set("property", "/controls/armament/nstation1");
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

	w = checkbox("Station 2: Mk82 bomb (500 lbs)");
	w.set("property", "/controls/armament/nstation2");
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

	w = checkbox("Station 3: External Fuel Tank (1500 lbs)");
	w.set("property", "/controls/armament/nstation3");
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

	w = checkbox("Station 4: Mk82 bomb (500 lbs)");
	w.set("property", "/controls/armament/nstation4");
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

	w = checkbox("Station 5: LAU-68 rockets (190 lbs)");
	w.set("property", "/controls/armament/nstation5");
	w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");	

	dialog.addChild("hrule").addChild("dummy");

	w = dialog.addChild("group");
	w.set("layout", "vbox");
	txt = w.addChild("text");
	txt.set("halign","left");
        txt.set("label", "0123456789");
        txt.set("format", "Gross Aircraft Weight: %.0f lbs");
        txt.set("property", "fdm/jsbsim/inertia/weight-lbs");
        txt.set("live", 1);
	
	txt=w.addChild("text");
	txt.set("halign","left");
	txt.set("label","Maximum Takeoff Weight: 14,444 lbs");

	# finale
	dialog.addChild("empty").set("pref-width", 4);
	fgcommand("dialog-new", dialog.prop());
	gui.showDialog(name);
}
