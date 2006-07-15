print("Digitrak Loading");

#
# Digitrak Autopilot System
#
#

Locks        = "/autopilot/digitrak/locks";
Settings     = "/autopilot/digitrak/settings";
Annunciators = "/autopilot/digitrak/annunciators";
Internal     = "/autopilot/digitrak/internal";
#Systems      = "/systems/";
#maybe electrical?
#Electrical = "/systems/electrical/";

annunciator = "";
annunciator_state = "";
flash_interval = 0.0;
flash_count = 0.0;
flash_timer = -1.0;

# Flasher function from digitrak autopilot distributed with FlightGear
# goes here

flasher = func {
  flash_timer = -1.0;
  annunciator = arg[0];
  flash_interval = arg[1];
  flash_count = arg[2] + 1;
  annunciator_state = arg[3];

  flash_timer = 0.0;

  flash_annunciator();
}

flash_annunciator = func {
  ##print(annunciator);
  ##print(flash_interval);
  ##print(flash_count);

  ##
  # If flash_timer is set to -1 then flashing is aborted
  if (flash_timer < -0.5)
  {
    ##print ("flash abort ", annunciator);
    setprop(Annunciators, annunciator, "off");
    return;
  }

  if (flash_timer < flash_count)
  {
    #flash_timer = flash_timer + 1.0;
    if (getprop(Annunciators, annunciator) == "on")
    {
      setprop(Annunciators, annunciator, "off");
      settimer(flash_annunciator, flash_interval / 2.0);
    }
    else
    #elsif (getprop(Annunciators, annunciator) == "off")
    {
      flash_timer = flash_timer + 1.0;
      setprop(Annunciators, annunciator, "on");
      settimer(flash_annunciator, flash_interval);
    }
  }
  else
  {
    flash_timer = -1.0;
    setprop(Annunciators, annunciator, annunciator_state);
  }
}


  #
  # Initialize the autopilot.
  #
  #
  
ap_init = func {
  print("Digitrak Initializing");
  
  elec = getprop("/systems/electrical/outputs/autopilot");
  print("Autopilot Power: " ~ elec);

# Relevant nasal electrical system props
#/controls/switches/master-avionics
#/systems/electrical/outputs/autopilot
 
  # Caution: For the electrical system outputs to be avialable
  # on initialization, the aircraft configuration file must
  # load the electrical system configuration file before
  # the autopilot configuration file (this file) is loaded.
  # Otherwise, the electrical system will not exist and
  # the electrical values will be nil and this will fail. Also,
  # this script must delay initialization briefly to allow time
  # for the electrical system to be established.

  # test for electrical system presence
  # is this necessary anymore now that we have the power good function?
  if( ! getprop("/systems/electrical/outputs/autopilot") ) {
    print("Digitrak (Warning): No power to autopilot.");
  }

  #
  # Ensure properties are properly initialized
  #

  # The following properties are used by this module:
  #
  # /autopilot/digitrak/internal/power-good (on|off)
  # /autopilot/digitrak/locks/gps-track (on|off)
  # /autopilot/digitrak/locks/gps-flight (on|off)	
  # /autopilot/digitrak/internal/status
  # /autopilot/digitrak/annunciators/hdg

# Properties:
# power-good
# The Digitrak has determined there is sufficient power available for a
# sufficiently long period to assume power is good.
#
# gps-valid
# Recieving a valid gps connection; The digitrak is is connected and talking to a gps,
# not that there is a gps flight plan. If GPS is valid, the digitrak will maintain a
# heading based on the GPS signal and the selected heading when ON.
#
# gps-valid-plan
# Recieveing a valid gps flight plan (i.e. the GPS unit has a waypoint zero and
# waypoint one (next destination) defined and is communicating it to the digitrak.
# If a valid GPS flight plan is communicated, the digitrak will maintain its
# course line. (This is not implemented yet, you must call the intercept_course function
# using the dialog).


	setprop(Internal, "power-good", "off");	
	setprop(Locks, "gps-track", "off");
	setprop(Locks, "gps-flight", "off");
	setprop(Locks, "hdg-hold", "off");
	setprop(Internal, "status", "disengaged");
	setprop(Annunciators, "hdg", "off");
	# assume gps
	setprop(Internal, "gps-valid", "on");

	# future use
	setprop(Settings, "activity-adj", 0);	

	setprop(Settings, 'intercept-angle', 45);
	
	setprop(Internal, 'xtk-turn-to', 'none');
	
	setprop(Internal, "gps-valid-plan", "off");
	
	# props to monitor stages of gps flight
	# used for modes of the aunnciator
	# when capturing and intercepting a course
	setprop(Internal, "course-captured", "off"); # captured
	setprop(Internal, "course-intercept", "off"); # intercepting
	setprop(Internal, "course-intercepted", "off"); # intercepted
	
 
  #
  # The autopilot (not the servos) unit requires:
  # +12v - +14v DC
  # 0.3 Amp
  # 180mA if buttons illuminated
  
  # Maybe this conditional should set a "power-good" internal value?
  # Yes, I think this is necessary, given the buttons should not be
  # active if there is no power.
  
  #
  # Power Good Signal
  #
  
check_power_good();
 
 
  if( getprop(Internal, "power-good") == "on" ) {
	print("has power");
	
  	# set init status
  	setprop(Internal, "status", "init");
  
  	#
  	# Initialization delay
  	#

  	# flash heading indicator for ten seconds
  	flasher("hdg", 1.0, 10, "on");
 
 # The problem is that flasher immediately returns, I need
 # --- to flash and then at the end, set status. This runs
 # a slightly longer than ten second delay to ensure
 # maintains init status until done flashing. Then
 # disengaged status is set.
 # or possibly before returning, the flasher could call
 # the engaged function, same as pressing the button.
 
 	
    settimer(delay, 15);
	 
  	# Initialization complete
 	
  } else {
  	print("Digitrak: No power.");
  	# and do what ... ?
  }
}


delay = func { setprop(Internal, "status", "disengaged"); }


#
# Buttons
#
#

# left button std turn

std_trn_lt = func {
 print("Standard Turn Left");

  # temporary
  setprop("/instrumentation/gps/tracking-bug", getprop("/instrumentation/gps/indicated-track-magnetic-deg") - 90 );
}

# left button std turn

std_trn_rt = func {
 print("Standard Turn Right");
  # temporary
  setprop("/instrumentation/gps/tracking-bug", getprop("/instrumentation/gps/indicated-track-magnetic-deg") + 90 );
}

# on/engage button
 
on_button = func {
  print("on_button");
 	
  if( getprop(Internal, "power-good") == "on" ) {

   	#
 	# Engage Autopilot
 	#
	 
	if( getprop(Internal, "gps-valid") == "on" ) {
	 print("gps valid");
	
	
	if( getprop(Internal, "gps-valid-plan", "on") ) {
	  setprop(Locks, "gps-flight", "on");
	  setprop(Locks, "gps-track", "off");
	  #intercept_course();
	} else {
	
	#
 	   # Capture and hold GPS track
 	   #
  
 	   # The Digitrak, when engaged, if a valid GPS signal is present, captures and holds the current heading track automatically. 

 	   # This is modeled by setting the gps tracking bug
 	   # to the current ground track heading
 	   setprop("/instrumentation/gps/tracking-bug", getprop("/instrumentation/gps/indicated-track-magnetic-deg"));

      setprop(Locks, "gps-flight", "off");
	  setprop(Locks, "gps-track", "on");
	} 
	   

	  } else {
	    print("gps invalid");
	
	    #
	    # Heading Hold Mode
	    #
	    #
	
	    # The digitrak contains its own DG slaved
	    # to the compass. When there is no gps signal, the
	    # digitrak tries to maintain the original track
	    # using the DG. The track becomes a heading to
	    # hold.

	    # I do _not_ want to use the DG instrument. That would
	    # mean the heading bug could move the heading around
	    # on the digitrak. There is _no_ connection to any
	    # other instrument than the GPS.
	
	    compass_hdg = getprop("/instrumentation/magnetic-compass/indicated-heading-deg");

	    setprop("/instrumentation/gps/tracking-bug", compass_hdg);
	
	    # probably need a function to set all locks off then set the desired lock
	    setprop(Locks, "gps-flight", "off");
	    setprop(Locks, "gps-track", "off");
	    setprop(Locks, "hdg-hold", "on");
	
	  }
		
 	 #
 	 # Change status to engaged
 	 #
 	 setprop(Internal, "status", "engaged");
   
  
 	 # ensure display is on
 	 setprop(Annunciators, "hdg", "on");
	 
	 print("Digitrak: Autopilot Engaged.");
		
	 } else {
	 }
	
 }

# off/disengage button

of_button = func {
  #print("off_button");
  
  if( getprop(Internal, "power-good") == "on" ) {
    # disengage/turn off ap
  
    setprop(Internal, "status", "disengaged");
    # ensure display is on
    setprop(Annunciators, "hdg", "on");
    # ensure locks are off
	
    setprop(Locks, "gps-track", "off");
    setprop(Locks, "gps-flight", "off");
	setprop(Locks, "hdg-hold", "off");
	
	print("Digitrak: Autopilot Disengaged.");
  }
 }
 

  # Simulate invalid gps signal or gps turned off/disconnected
  # Unused

no_gps = func {
	  setprop(Locks, "gps-track", "off");
  setprop(Locks, "gps-flight", "off");
  setprop(Locks, "gps-valid", "off");
  setprop(Locks, "hdg-hold", "on");	

}
 

#
# Intercept Course
# (Polling code after Andy Ross)
#

# Note: I may have got the wrong properties for course.
# There are course figures under wp/wp1 the active waypoint
# which is where I need to take my values. But I'm not sure
# because the desired course is there but the figures do
# not match the leg course. I'm not sure what these
# figures represent. I would think the leg course figures
# are the figures for the course line from wp0 to wp1, but
# perhaps they are figures for the "infinite" line as if
# there were no origin to the active waypoint.


intercept_course = func {
print("intercept course");

  # want to create a left/right flag in internals
  # /autopilot/digitrak/internal/xtk-turn-to (right|left)

  #
  # Set XTK turn flag.
  #
  # Note: This could use deviation.
  # I do not have to set a prop, but it might come in handy.
  if(
    getprop('/instrumentation/gps/wp/leg-course-error-nm') > 0 ) {
      setprop(Internal, 'xtk-turn-to', 'left')
    } elsif(
    getprop('/instrumentation/gps/wp/leg-course-error-nm') < 0 ) {
    setprop(Internal, 'xtk-turn-to', 'right')
  }

  #
  # Calculate intercept
  #
  #

  # actually a heading, sort of
  intercept_angle = getprop(Settings, 'intercept-angle');
  print("intercept angle: " ~ intercept_angle);
  
  # long way around, but want to use the props for this
  # so values can be watched or used at will
  # XTK determins subtract or add, could use course deviation

  # Note: if the gps has not been setup, this gives an
  # error because nil is used in a numeric expression
  # needs checking
  if( getprop(Internal, 'xtk-turn-to') == "left" ) {
	intercept_heading = getprop("/instrumentation/gps/wp/leg-mag-course-deg[0]") + intercept_angle;
  } else {
    intercept_heading = getprop("/instrumentation/gps/wp/leg-mag-course-deg[0]") - intercept_angle;
  }
  
  print("Digitrak: Intercept heading: " ~ intercept_heading);

  #
  # Turn onto intercept track.
  # Notice how this is all automaticaly wind compensated
  # becuase GPS can follow a _track_.

  print("GPS Bug: " ~ intercept_heading);
  setprop("/instrumentation/gps/tracking-bug", intercept_heading );

  # flash DG heading while intercepting
  # hack, this really needs to flash indefinitely, until course captured
  flasher("hdg", 1.0, 100, "on");
  setprop(Internal, "course-intercept", "on" );
  
  # start capture
  capture_course();

}

capture_course = func {
print("capturing course");

  # could use either or both ?
  # /instrumentation/gps/wp/leg-course-error-nm
  # /instrumentation/gps/wp/leg-course-deviation-deg

  # start monitoring course deviation
  # as we fly the intercept
  
  check_course();
  
}

# want to write
# maybe lowercase 'and' works in nasal?
#if( ($crsdev < 2) AND ($crsdev > -2) ) {
#	print "in deadband";
#}



check_course = func {
print("Digitrak: Monitoring course.");

if( getprop(Internal, "power-good") == "on" and
getprop(Internal, "status") == "engaged"
 ) {
  
  # IMPORTANT, a deadband of 2nm is too wide, narrow to .5nm
      course_dev = getprop("/instrumentation/gps/wp/leg-course-deviation-deg");
	# two degree deadband
	# if very close to on course, set course as track on bug
      if( course_dev < 0.5 and course_dev > -0.5 ) {
        setprop("/instrumentation/gps/tracking-bug", getprop("/instrumentation/gps/wp/leg-mag-course-deg"));

        # signal course-intercept off
		# signal course-captured on
        setprop(Internal, "course-intercept", "off" );
        setprop(Internal, "course-captured", "on");
        print("Digitrak: Course Captured");
        return;
      }
	  
	# Note:
	# settimer() specifies how many iterations should be run during one second. The code
	# continues to execute over FlightGear screen redraws, but the iterations are split
	# into numerous "bursts" depending on your framerate (fps).
	# settimer(check_course, 0.2) produces a 100 iterations per second, but the 100
	# iterations are split into burts dependent on the framerate.
	# Moreover, the FlightGear properties database does not get updated in between
	# redraws. Propeties do not change until the next redraw at the current FPS. So it
	# is useless to monitor with any greater frequency than the redraw.
	# It doesn't matter if you do settimer(check_course, 0.2) or settimer(check_course, 0).  The latter run once per redraw. settimer tells how many iterations should be run in one second.

	#settimer(func,0) means run when the next main loop comes around, any other time means run on the next occasion aftet hat time has passed, as I understand it. 

	# previous 0.2, does not update more frequently than frame rate, why bother?
      settimer(check_course, 0);
} 

}

# Power Good Function
# This would imitate the probable power up sequence
# for the digitrak, wait for power to stabilize before
# setting power good and initializing. If say, five
# seconds go by and power has not stabilized, then
# abort init and print to console.
check_power_good = func {
   
  #
  # Check and Set Power Good Signal
  #
  
  # I suppose for this to be realistic, I need to test the
  # mains voltage to see if it is sufficent and
  # test the current of a/p output to see if that is enough
  # before saying power is good.

    # output is in volts
    volts = getprop("/systems/electrical/outputs/autopilot");
    
    print("Digitrak Power: " ~ volts);

    if ((volts != nil) and (volts >= 0.3)) {
        print("Digitrak: Power Good");
        setprop(Internal, "power-good", "on");
    } else {
        print("Digitrak: Insufficient power.");
        setprop(Internal, "power-good", "off");
    }
}
 

 # check_gps_plan
 # Determine if valid GPS flight plan is avaialble.
 #
 #

check_gps_plan = func {
  print("Digitrak: Checking for GPS flight plan:");

# FIXME: may want to integrate gps-valid internal flag with
# in_service = getprop("/instrumentation/gps/servicable");
# property

# To make some things clear, gps-valid means that
# the ap is recieving a valid gps connection, that 
# it is connected and talking to a gps, not that
# there is a gps flight plan.

    if( getprop(Internal, "gps-valid") == "on" ) {
      print("...GPS Valid");


# FIXME: Given it may be possible to enter id's without any
# sensible data, it may be a good idea to find some other
# or additional way to confirm the GPS is supplying a
# valid flight plan (or course between two waypoints...
# as most GPS units only work with two waypoints at a
# time, the zero waypoint and the destination waypoint)
# Maybe this property would help?
# getprop("/instrumentation/gps/wp/leg-course-deviation-deg");

  # GPS serviceable...this is a kind of sim cheat
  # but we don't have an RS232 or other data interface to the GPS...
  in_service = getprop("/instrumentation/gps/serviceable");
  # Waypoint Zero
  wp0id = getprop("/instrumentation/gps/wp/wp[0]/ID");
  # Waypoint One (Immediate Destination)
  wp1id = getprop("/instrumentation/gps/wp/wp[1]/ID");

  if( (wp0id and wp1id) and in_service ) {
    print("...Found flight plan");
    setprop(Internal, "gps-valid-plan", "on");
  } else {
    setprop(Internal, "gps-valid-plan", "off");
  }
}

}


#
# Digitrak Configuration
# Enables the user to configure digitrak.
#


# dialogues =======================================================
# Courtesy A. J. MacLeod

dialog = nil;

showDialog = func {
	name = "digitrak-config";
	if (dialog != nil) {
		fgcommand("dialog-close", props.Node.new({ "dialog-name" : name }));
		dialog = nil;
		return;
	}
	dialog = gui.Widget.new();
	dialog.set("layout", "vbox");
	dialog.set("name", name);
	dialog.set("x", -40);
	dialog.set("y", -40);

	# "window" titlebar
	titlebar = dialog.addChild("group");
	titlebar.set("layout", "hbox");
	titlebar.addChild("empty").set("stretch", 1);
	titlebar.addChild("text").set("label", "Digitrak configuration");
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
	w.prop().getNode("binding[0]/script", 1).setValue("digitrak.dialog = nil");
	w.prop().getNode("binding[1]/command", 1).setValue("dialog-close");

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

	# GPS Valid
	# must set to 'on' when checked How?
	#w = checkbox("GPS Valid");
	#w.set("property", "/autopilot/digitrak/internals/gps-valid");
	#w.prop().getNode("binding[0]/command", 1).setValue("dialog-apply");

	# Intercept Course
	group = dialog.addChild("group");
	group.set("layout", "hbox");
	group.addChild("empty").set("pref-width", 4);

	w = group.addChild("button");
	w.set("halign", "center");
	w.set("legend", "Intercept Course");
	w.set("pref-width", 140);
	w.set("pref-height", 24);
	w.prop().getNode("binding[0]/command", 1).setValue("nasal");
	w.prop().getNode("binding[0]/script", 1).setValue("digitrak.intercept_course()");

#	#w = group.addChild("text");
#	#w.set("halign", "left");
#	#w.set("label", "X");
#	#w.set("pref-width", 200);
#	#w.set("property", "sim/model/bo105/weapons/ammunition");
#	#w.set("live", 1);
#
	group.addChild("empty").set("stretch", 1);

	# finale
	dialog.addChild("empty").set("pref-height", "3");
	fgcommand("dialog-new", dialog.prop());
	gui.showDialog(name);
}

 #
 # Execute
 #
 #
 
 #ap_init();
 
 # Note: Delay initialization long enough for FlightGear to load and establish
 # electrical system.
print("Setting ap_init timer.");
 settimer(ap_init, 1);
 
