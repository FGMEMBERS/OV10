
# B1900d systems

millibars = 0.0;
pph1 = 0.0;
pph2 = 0.0;
power = nil;
eadi = nil;
engines = nil;
instruments = nil;
panel = nil;
volts = nil;
eyepoint = 0.0;
force = 0.0;
fuel_density=0.0;
viewnum = nil;
gpsmode = nil;
gpsnode = nil;
navnode = nil;
apprnode= nil;
LEFTMODES =["TRI ","MOD ","FPL ","NAV ","CAL ","STA ","SET ","OTH "];
RIGHTMODES =["CTR ","REF ","ACT ","D/T ","NAV ","APT ","VOR ","NDB ","INT ","SUP "];
PAGENUM = ["1","2","3","4","5","6","7","8","9","10"];
stall = 0.0;
rhmenu = nil;
lhmenu = nil;
lhsubmenu =[0,0,0,0,0,0,0,0];
rhsubmenu =[0,0,0,0,0,0,0,0,0,0];

dmode = nil;
getpage = nil;
modestring1 = nil;



init_gps = func{
lhmenu = 3;
rhmenu = 5;
lhsubmenu[lhmenu] = 1;
rhsubmenu[rhmenu] = 3;

setprop("/instrumentation/altimeter/millibars",0.0);
fuel_density=getprop("consumables/fuel/tank[0]/density-ppg");
setprop("/instrumentation/gps-annunciator/mode-string[0]","PWR OFF");
setprop("/instrumentation/gps-annunciator/mode-string[1]","PWR OFF");
setprop("/instrumentation/gps/wp/wp/ID",getprop("/sim/tower/airport-id"));
setprop("/instrumentation/gps/wp/wp/waypoint-type","airport");
setprop("/instrumentation/heading-indicator/offset-deg",-1 * getprop("/environment/magnetic-variation-deg"));
print("KLN-90B Initialized ");
}



settimer(init_gps, 1);



gpspower = func {
           gpsnode = props.globals.getNode("/instrumentation/gps/serviceable");
           node = 1 - getprop("/instrumentation/gps/serviceable");
           gpsnode.setBoolValue(node);
           if (node != 0.0){
setprop("/instrumentation/gps-annunciator/mode-string[0]",LEFTMODES[lhmenu] ~ PAGENUM[lhsubmenu[lhmenu]]);
setprop("/instrumentation/gps-annunciator/mode-string[1]",RIGHTMODES[rhmenu] ~ PAGENUM[rhsubmenu[rhmenu]]);
}else{
setprop("/instrumentation/gps-annunciator/mode-string[0]","POWER OFF");
setprop("/instrumentation/gps-annunciator/mode-string[1]","POWER OFF");
}}

GpsAppr = func {
gpsnode = props.globals.getNode("/instrumentation/gps/leg-mode");
      apprnode = props.globals.getNode("/instrumentation/gps/approach-active");
      navnode = props.globals.getNode("/instrumentation/nav/slaved-to-gps");
      if(apprnode.getBoolValue()){
      apprnode.setBoolValue(0);
      navnode.setBoolValue(0);
      } else {
      apprnode.setBoolValue(1);
      navnode.setBoolValue(1);
      gpsnode.setBoolValue(0);
      }
}

GpsCrs = func {gpsnode = props.globals.getNode("/instrumentation/gps/leg-mode");
      apprnode = props.globals.getNode("/instrumentation/gps/approach-active");
      navnode = props.globals.getNode("/instrumentation/nav/slaved-to-gps");
      if(gpsnode.getBoolValue()){
      gpsnode.setBoolValue(0);
      navnode.setBoolValue(0);
      } else {
      gpsnode.setBoolValue(1);
      navnode.setBoolValue(1);
      apprnode.setBoolValue(0);
      }
}



lh_menu_update = func (){
setprop("/instrumentation/gps-annunciator/mode-string[0]","POWER OFF");
if(gpsnode != 0.0){
volts = getprop("/systems/electrical/outputs/gps");
 if(volts > 0.2){
modestring1 = getprop("/instrumentation/gps-annunciator/mode-string[0]");
test = arg[0];
if(test == 1){lh_menu_modify(1);}
if(test == 2){lh_menu_modify(2);}
if(test == 3){lh_submenu_modify(1);}
if(test == 4){lh_submenu_modify(2);}
}}}

lh_menu_modify = func (){
test=arg[0];
if(test == 1){
lhmenu = lhmenu - 1;
if(lhmenu < 0 ){lhmenu =lhmenu + 8;}
}
else{
if(test == 2){
lhmenu = lhmenu + 1;
if(lhmenu > 7 ){lhmenu =lhmenu - 8;}
}}
setprop("/instrumentation/gps-annunciator/mode-string[0]",LEFTMODES[lhmenu] ~ PAGENUM[lhsubmenu[lhmenu]]);
}

lh_submenu_modify = func (){
test=arg[0];
if(test == 1){
lhsubmenu[lhmenu] = lhsubmenu[lhmenu] - 1;
if(lhsubmenu[lhmenu] < 0 ){lhsubmenu[lhmenu] =lhsubmenu[lhmenu] + 5;}
}
else{
if(test == 2){
lhsubmenu[lhmenu] = lhsubmenu[lhmenu] + 1;
if(lhsubmenu[lhmenu] > 4 ){lhsubmenu[lhmenu] =lhsubmenu[lhmenu] - 5;}
}}
setprop("/instrumentation/gps-annunciator/mode-string[0]",LEFTMODES[lhmenu] ~ PAGENUM[lhsubmenu[lhmenu]]);
}


# right hand knob

rh_menu_update = func (){
setprop("/instrumentation/gps-annunciator/mode-string[1]","POWER OFF");
if(gpsnode != 0.0){
volts = getprop("/systems/electrical/outputs/gps");
 if(volts > 0.2){
test = arg[0];
if(test == 1){rh_menu_modify(1);}
if(test == 2){rh_menu_modify(2);}
if(test == 3){rh_submenu_modify(1);}
if(test == 4){rh_submenu_modify(2);}
}}}


rh_menu_modify = func (){
test=arg[0];
if(test == 1){
rhmenu = rhmenu - 1;
if(rhmenu < 0 ){rhmenu =rhmenu + 10;}
}
else{
if(test == 2){
rhmenu = rhmenu + 1;
if(rhmenu > 7 ){rhmenu =rhmenu - 10;}
}}
setprop("/instrumentation/gps-annunciator/mode-string[1]",RIGHTMODES[rhmenu] ~ PAGENUM[rhsubmenu[rhmenu]]);
}

rh_submenu_modify = func (){
test=arg[0];
if(test == 1){
rhsubmenu[rhmenu] = rhsubmenu[rhmenu] - 1;
if(rhsubmenu[rhmenu] < 0 ){rhsubmenu[rhmenu] =rhsubmenu[rhmenu] + 5;}
}
else{
if(test == 2){
rhsubmenu[rhmenu] = rhsubmenu[rhmenu] + 1;
if(rhsubmenu[rhmenu] > 4 ){rhsubmenu[rhmenu] =rhsubmenu[rhmenu] - 5;}
}}
setprop("/instrumentation/gps-annunciator/mode-string[1]",RIGHTMODES[rhmenu] ~ PAGENUM[rhsubmenu[rhmenu]]);
}

direct_to = func {
setprop("/instrumentation/gps/wp/wp/waypoint-type","fix");
setprop("/instrumentation/gps/wp/wp/ID","");
setprop("/instrumentation/gps/wp/wp/name","");
setprop("/instrumentation/gps/wp/wp/latitude-deg",getprop("/position/latitude-deg"));
setprop("/instrumentation/gps/wp/wp/longitude-deg",getprop("/position/longitude-deg"));
}
