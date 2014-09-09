# pour envoyer les données des pylones en mp 

var undercarriage = 0;
var pylone1 = 0;
var pylone2 = 0;
var pylone3 = 0;
var pylone4 = 0;
var pylone5 = 0;

var update = func() {
	undercarriage = pylone1 + pylone2 + pylone3 + pylone4 + pylone5;
	setprop("/sim/multiplay/generic/int[1]", undercarriage);
	};

setlistener("/controls/armament/station1", func() {
	pylone1 = (getprop("/controls/armament/station1")) ? 0: 1;
	update();
	},1,0);

setlistener("/controls/armament/station2", func() {
	pylone2 = (getprop("/controls/armament/station2")) ? 0: 2;
	update();
	},1,0);

setlistener("/controls/armament/station3", func() {
	pylone3 = (getprop("/controls/armament/station3")) ? 0: 4;
	update();
	},1,0);

setlistener("/controls/armament/station4", func() {
	pylone4 = (getprop("/controls/armament/station4")) ? 0: 8;
	update();
	},1,0);

setlistener("/controls/armament/station5", func() {
	pylone5 = (getprop("/controls/armament/station5")) ? 0: 16;
	update();
	},1,0);


