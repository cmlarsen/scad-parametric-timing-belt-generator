/*
Parametric belting generator, including straights, loops, and spirals, by Jeff Hertzberg
Derived from:
http://www.thingiverse.com/thing:19758 by The DoomMeister
http://www.thingiverse.com/thing:16627 by Droftarts
https://www.youmagine.com/designs/parametric-timing-belt-generator

LICENSE: Creative Commoons - Attribution-ShareAlike 3.0 Unported

belting
 Use: Generates belting in several standard tooth profiles.
 Arguements:
    print_layout (required) - how the belt will be arranged on the print surface. 
        Current valid values: 
            straight, (straight belt segment)
            loop, (closed loop with teeth on inner side of loop)
            loop_inner, (same as loop)
            loop_outer, (closed loop with teeth on outer side of loop)
            loop_match, (closed loop with teeth mirrored on both sides of loop)
            loop_offset, (closed loop with teeth on both sides of loop, offset by half a tooth)
            spiral. (belt spiraling inward from maximum_diameter with teeth on the inner side)
            
    tooth_profile (required) - shape of tooth. Only use profiles where the tooth form module is defined.
        Current valid values: 
            MXL, 
            T2.5, 
            T5, 
            T10, 
            GT2_2mm, 
            GT2_3mm, 
            GT2_5mm, 
            AT5, 
            HTD_3mm, 
            HTD_5mm, 
            HTD_8mm, 
            40DP, 
            XL, 
            L
            
    tooth_count (alternate) - total belt length measured in number of teeth. If specified, then belt_length is ignored.
    belt_length (alternate) - total belt length in mm, increased to next multiple of tooth pitch if necessary.
    
    belting_width (optional) - Override default width for the belt in mm.
    
    backing_thickness (optional) - Override default mm of belt backing behind tooth profile.
    
    max_diameter (optional) - Maximum diameter for loops and spirals. Default is 200mm.
*/


$fa = 2; // Try increasing this number if rendering of curves is unusably slow.

// Set maximum_diameter to the shorter of your x or y axis.
// It is used to limit length of straights and diameter of loops and spirals.
maximum_diameter = 200;	

// Tooth profile default values chosen from belts offered in catalog pages at http://sdp-si.com
// Tooth profile defaults are ordered: tooth_profile, tooth_pitch, back_thickness, belt_width
tooth_profile_defaults = [
	[ "belt", 2, 2, 15 ],
	[ "MXL", 2.032, 0.74, 6.35 ],
	[ "T2.5", 2.5, 0.6, 6 ],
	[ "T5", 5, 1, 10 ],
	[ "T10", 10, 2, 16 ],
	[ "GT2_2mm", 2, 0.76, 6 ],
	[ "GT2_3mm", 3, 1.27, 9 ],
	[ "GT2_5mm", 5, 1.88, 15 ],
	[ "AT5", 5, 1, 10 ],
	[ "HTD_3mm", 3, 1.19, 9 ],
	[ "HTD_5mm", 5, 1.73, 9 ],
	[ "HTD_8mm", 8, 2.64, 30 ],
	[ "40DP", 2.073, 0.74, 4.7625 ],
	[ "XL", 5.08, 1.03, 7.94 ],
	[ "L", 9.525, 1.66, 19.05 ]
];

//Examples
// Rendering speeds are a function of the number and complexity of teeth, and the print layout, and they increase exponentially.

// belting("spiral", "GT2_2mm", belt_length = 100);
// belting("loop_match","T5", tooth_count = 40 );
// belting("loop","MXL", tooth_count = 298 );
// belting("straight","T10", belt_length = 150, belting_width = 25 );


// By Default this will Render as a 3d object.  If you'd like export it as a DXF you can uncomment out thef following line
//projection() // UnComment this line to render as 2d for exporting as DXF
belting("loop", "XL", tooth_count = 35, belting_width = 6.35);
// ^---Edit this line to set parameters

module belting(

	print_layout = undef, 
	tooth_profile = undef, 
	tooth_count = undef, 
	belt_length = undef, 
	belting_width = undef, 
	backing_thickness = undef, 
	max_diameter = maximum_diameter,)
{

	// Initalization
	belt_defaults = tooth_profile_defaults[search([tooth_profile], tooth_profile_defaults)[0]];
	tooth_pitch = belt_defaults[1];
	belt_width = belting_width == undef ? belt_defaults[3] : belting_width;
	back_thickness = backing_thickness == undef ? belt_defaults[2] : backing_thickness;
	tooth_cnt = tooth_count == undef ? ceil(belt_length/tooth_pitch) : tooth_count;

	if ( belt_defaults == undef ) {
		echo(str("ERROR: Empty or invalid tooth_profile in belting module: ", tooth_profile));
	}
	else if( tooth_cnt == undef || tooth_cnt <= 0 ) {
		echo(str("ERROR: Invalid belt_length and/or tooth_count in belting module."));
	}
	else if( belt_width == undef || belt_width <= 0 ) {
		echo(str("ERROR: Invalid belt_width in belting module: ", belt_width));
	}
	else if( back_thickness == undef || back_thickness <= 0 ) {
		echo(str("ERROR: Invalid back_thickness in belting module: ", back_thickness));
	}
	else if( max_diameter == undef || max_diameter <= 0 ) {
		echo(str("ERROR: Invalid max_diameter in belting module: ", max_diameter));
	}

	// Inputs validated (except for layout).
	else {

		echo(str("Generating a ", print_layout, " of ", tooth_profile, " belt with ", tooth_cnt, " teeth, ", 
			tooth_cnt*tooth_pitch, "mm long, ", belt_width, "mm wide and ", back_thickness, "mm thick." ));
	
		if( print_layout == "straight") {	// Straight belt
			straight_belt(tooth_cnt, tooth_pitch, back_thickness, belt_width, max_diameter)
				belt_tooth(tooth_profile, belt_width);
            
		} else if( print_layout == "loop" ||
            print_layout == "loop_inner" ||
            print_layout == "loop_outer" ||
            print_layout == "loop_match" ||
            print_layout == "loop_offset" 
        ) {	// Closed loop

			loop_belt(tooth_cnt, tooth_pitch, back_thickness, belt_width, max_diameter-(back_thickness*2), print_layout)
				belt_tooth(tooth_profile, belt_width);
            
		} else if( print_layout == "spiral") {	// Spiral belt (to fit more belt on the bed than with straight)
			spiral_belt(tooth_cnt, tooth_pitch, back_thickness, belt_width, max_diameter-(back_thickness*2))
				belt_tooth(tooth_profile, belt_width);
		} else {
			echo("ERROR: Invalid print_layout in belting module. Valid layouts are <b>straight</b>, <b>loop</b>, <b>loop_inner</b>, <b>loop_outer</b>, or <b>spiral</b>.");
		}
	}
                   
}

module straight_belt(tooth_cnt, tooth_pitch, back_thickness, belt_width, max_diameter)
{
	if( tooth_pitch * tooth_cnt > max_diameter ) {
		echo(str("WARNING: Straight belt is ", tooth_pitch * tooth_cnt, 
			"mm long. If not be printable on your printer, try spiral." ));
	}

	union() {
		translate([-tooth_pitch/2,-back_thickness,0])cube([tooth_pitch*tooth_cnt,back_thickness,belt_width]);
		for( i = [0:tooth_cnt-1]) {
			translate([tooth_pitch*i,0,0]) children(0);
		}
	}
}

module loop_belt(tooth_cnt, tooth_pitch, back_thickness, belt_width, max_diameter, print_layout)
{
	radius = tooth_cnt * tooth_pitch / PI / 2;
	
	if( (radius + back_thickness) * 2 > max_diameter ) {
		echo(str("WARNING: Loop belt diameter is ", (radius + back_thickness) * 2, "mm. May not be printable." ));
	}

    if(print_layout == "loop" || print_layout == "loop_inner") {
        union() {
            render(convexity = 2) difference() {
                cylinder (h = belt_width, r=radius+back_thickness);
                cylinder (h = belt_width, r=radius);
            }
            for( i = [0:tooth_cnt-1]) {
                rotate(i/tooth_cnt*360)translate([0,-radius,0]) children(0);
            }
        }
    }

    if(print_layout == "loop_outer") {
        union() {
            render(convexity = 2) difference() {
                cylinder (h = belt_width, r=radius);
                cylinder (h = belt_width, r=radius-back_thickness);
            }
            for( i = [0:tooth_cnt-1]) {
                rotate(i/tooth_cnt*360)translate([0,-radius,0]) rotate([0,0,180]) children(0);
            }
        }
    }

    if(print_layout == "loop_match") {
        union() {
            render(convexity = 2) difference() {
                cylinder (h = belt_width, r=radius+back_thickness);
                cylinder (h = belt_width, r=radius);
            }
            for( i = [0:tooth_cnt-1]) {
                rotate(i/tooth_cnt*360)translate([0,-radius,0]) children(0);
                rotate(i/tooth_cnt*360)translate([0,-radius-back_thickness,0]) rotate([0,0,180]) children(0);
            }
        }
    }

    if(print_layout == "loop_offset") {
        union() {
            render(convexity = 2) difference() {
                cylinder (h = belt_width, r=radius+back_thickness);
                cylinder (h = belt_width, r=radius);
            }
            for( i = [0:tooth_cnt-1]) {
                rotate(i/tooth_cnt*360) translate([0,-radius,0]) children(0);
                rotate((i+0.5)/tooth_cnt*360) translate([0,-radius-back_thickness,0]) rotate([0,0,180]) children(0);
            }
        }
    }
}

module spiral_belt(tooth_cnt, tooth_pitch, back_thickness, belt_width, max_diameter, rot_angle = 0)
{
	max_radius = max_diameter/2;
	radius = sqrt(pow(max_radius,2) - (tooth_cnt * tooth_pitch * 2)); 
	next_radius = sqrt(pow(max_radius,2)-((tooth_cnt - 1) * tooth_pitch * 2));
	rad_diff = next_radius - radius;
	angle = atan(tooth_pitch/radius);

	if(tooth_cnt > 0)
	{
		union() {
			spiral_belt((tooth_cnt-1), tooth_pitch, back_thickness, belt_width, max_diameter, angle+rot_angle) children(0);
			rotate(rot_angle) translate([0,-radius,0]) {
				translate([0,-rad_diff/2,0]) rotate(-atan(rad_diff/tooth_pitch)) children(0);
				translate([-tooth_pitch/2,0,0]) rotate(-atan(rad_diff/tooth_pitch)) linear_extrude(belt_width)
					polygon([[-rad_diff,0],[-(rad_diff*back_thickness/2),-back_thickness],[tooth_pitch+(rad_diff*back_thickness/2),-back_thickness],[tooth_pitch,0]]);
			}
		}
	}
}

module belt_tooth(tooth_profile = undef, belt_width = undef)
{
	if( tooth_profile == "T2.5" ) {T2_5(width = belt_width);}
	else if( tooth_profile == "T5" ) {T5(width = belt_width);}
	else if( tooth_profile == "T10" ) {T10(width = belt_width);}
	else if( tooth_profile == "MXL" ) {MXL(width = belt_width);}
	else if( tooth_profile == "GT2_2mm" ) {GT2_2mm(width = belt_width);}
	else if( tooth_profile == "GT2_3mm" ) {GT2_3mm(width = belt_width);}
	else if( tooth_profile == "GT2_5mm" ) {GT2_5mm(width = belt_width);}
	else if( tooth_profile == "AT5" ) {AT5(width = belt_width);}
	else if( tooth_profile == "HTD_3mm" ) {HTD_3mm(width = belt_width);}
	else if( tooth_profile == "HTD_5mm" ) {HTD_5mm(width = belt_width);}
	else if( tooth_profile == "HTD_8mm" ) {HTD_8mm(width = belt_width);}
	else if( tooth_profile == "40DP" ) {40DP(width = belt_width);}
	else if( tooth_profile == "XL" ) {XL(width = belt_width);}
	else if( tooth_profile == "L" ) {L(width = belt_width);}
	else if( tooth_profile == "belt" ) {}
	else echo("INTERNAL ERROR: Missing tooth_profile module detected by belt_tooth module.");
}

// Tooth forms taken from http://www.thingiverse.com/thing:16627
// Much credit to Droftarts for deriving the tooth profile polygons.

module T2_5(width = 2)
{
	linear_extrude(height=width) polygon([[-0.839258,-0.5],[-0.839258,0],[-0.770246,0.021652],[-0.726369,0.079022],[-0.529167,0.620889],[-0.485025,0.67826],[-0.416278,0.699911],[0.416278,0.699911],[0.484849,0.67826],[0.528814,0.620889],[0.726369,0.079022],[0.770114,0.021652],[0.839258,0],[0.839258,-0.5]]);
}

module T5(width = 2)
{
	linear_extrude(height=width) polygon([[-1.632126,-0.5],[-1.632126,0],[-1.568549,0.004939],[-1.507539,0.019367],[-1.450023,0.042686],[-1.396912,0.074224],[-1.349125,0.113379],[-1.307581,0.159508],[-1.273186,0.211991],[-1.246868,0.270192],[-1.009802,0.920362],[-0.983414,0.978433],[-0.949018,1.030788],[-0.907524,1.076798],[-0.859829,1.115847],[-0.80682,1.147314],[-0.749402,1.170562],[-0.688471,1.184956],[-0.624921,1.189895],[0.624971,1.189895],[0.688622,1.184956],[0.749607,1.170562],[0.807043,1.147314],[0.860055,1.115847],[0.907754,1.076798],[0.949269,1.030788],[0.9837,0.978433],[1.010193,0.920362],[1.246907,0.270192],[1.273295,0.211991],[1.307726,0.159508],[1.349276,0.113379],[1.397039,0.074224],[1.450111,0.042686],[1.507589,0.019367],[1.568563,0.004939],[1.632126,0],[1.632126,-0.5]]);
}

module T10(width = 2)
{
	linear_extrude(height=width) polygon([[-3.06511,-1],[-3.06511,0],[-2.971998,0.007239],[-2.882718,0.028344],[-2.79859,0.062396],[-2.720931,0.108479],[-2.651061,0.165675],[-2.590298,0.233065],[-2.539962,0.309732],[-2.501371,0.394759],[-1.879071,2.105025],[-1.840363,2.190052],[-1.789939,2.266719],[-1.729114,2.334109],[-1.659202,2.391304],[-1.581518,2.437387],[-1.497376,2.47144],[-1.408092,2.492545],[-1.314979,2.499784],[1.314979,2.499784],[1.408091,2.492545],[1.497371,2.47144],[1.581499,2.437387],[1.659158,2.391304],[1.729028,2.334109],[1.789791,2.266719],[1.840127,2.190052],[1.878718,2.105025],[2.501018,0.394759],[2.539726,0.309732],[2.59015,0.233065],[2.650975,0.165675],[2.720887,0.108479],[2.798571,0.062396],[2.882713,0.028344],[2.971997,0.007239],[3.06511,0],[3.06511,-1]]);
}

module MXL(width = 2)
{
	linear_extrude(height=width) polygon([[-0.660421,-0.5],[-0.660421,0],[-0.621898,0.006033],[-0.587714,0.023037],[-0.560056,0.049424],[-0.541182,0.083609],[-0.417357,0.424392],[-0.398413,0.458752],[-0.370649,0.48514],[-0.336324,0.502074],[-0.297744,0.508035],[0.297744,0.508035],[0.336268,0.502074],[0.370452,0.48514],[0.39811,0.458752],[0.416983,0.424392],[0.540808,0.083609],[0.559752,0.049424],[0.587516,0.023037],[0.621841,0.006033],[0.660421,0],[0.660421,-0.5]]);
}

module GT2_2mm(width = 2)
{
	linear_extrude(height=width) polygon([[0.747183,-0.5],[0.747183,0],[0.647876,0.037218],[0.598311,0.130528],[0.578556,0.238423],[0.547158,0.343077],[0.504649,0.443762],[0.451556,0.53975],[0.358229,0.636924],[0.2484,0.707276],[0.127259,0.750044],[0,0.76447],[-0.127259,0.750044],[-0.2484,0.707276],[-0.358229,0.636924],[-0.451556,0.53975],[-0.504797,0.443762],[-0.547291,0.343077],[-0.578605,0.238423],[-0.598311,0.130528],[-0.648009,0.037218],[-0.747183,0],[-0.747183,-0.5]]);
}

module GT2_3mm(width = 2)
{
	linear_extrude(height=width) polygon([[-1.155171,-0.5],[-1.155171,0],[-1.065317,0.016448],[-0.989057,0.062001],[-0.93297,0.130969],[-0.90364,0.217664],[-0.863705,0.408181],[-0.800056,0.591388],[-0.713587,0.765004],[-0.60519,0.926747],[-0.469751,1.032548],[-0.320719,1.108119],[-0.162625,1.153462],[0,1.168577],[0.162625,1.153462],[0.320719,1.108119],[0.469751,1.032548],[0.60519,0.926747],[0.713587,0.765004],[0.800056,0.591388],[0.863705,0.408181],[0.90364,0.217664],[0.932921,0.130969],[0.988924,0.062001],[1.065168,0.016448],[1.155171,0],[1.155171,-0.5]]);
}

module GT2_5mm(width = 2)
{
	linear_extrude(height=width) polygon([[-1.975908,-0.75],[-1.975908,0],[-1.797959,0.03212],[-1.646634,0.121224],[-1.534534,0.256431],[-1.474258,0.426861],[-1.446911,0.570808],[-1.411774,0.712722],[-1.368964,0.852287],[-1.318597,0.989189],[-1.260788,1.123115],[-1.195654,1.25375],[-1.12331,1.380781],[-1.043869,1.503892],[-0.935264,1.612278],[-0.817959,1.706414],[-0.693181,1.786237],[-0.562151,1.851687],[-0.426095,1.9027],[-0.286235,1.939214],[-0.143795,1.961168],[0,1.9685],[0.143796,1.961168],[0.286235,1.939214],[0.426095,1.9027],[0.562151,1.851687],[0.693181,1.786237],[0.817959,1.706414],[0.935263,1.612278],[1.043869,1.503892],[1.123207,1.380781],[1.195509,1.25375],[1.26065,1.123115],[1.318507,0.989189],[1.368956,0.852287],[1.411872,0.712722],[1.447132,0.570808],[1.474611,0.426861],[1.534583,0.256431],[1.646678,0.121223],[1.798064,0.03212],[1.975908,0],[1.975908,-0.75]]);
}



module AT5(width = 2)
{
	linear_extrude(height=width) polygon([[-2.134129,-0.75],[-2.134129,0],[-2.058023,0.005488],[-1.984595,0.021547],[-1.914806,0.047569],[-1.849614,0.082947],[-1.789978,0.127073],[-1.736857,0.179338],[-1.691211,0.239136],[-1.653999,0.305859],[-1.349199,0.959203],[-1.286933,1.054635],[-1.201914,1.127346],[-1.099961,1.173664],[-0.986896,1.18992],[0.986543,1.18992],[1.099614,1.173664],[1.201605,1.127346],[1.286729,1.054635],[1.349199,0.959203],[1.653646,0.305859],[1.690859,0.239136],[1.73651,0.179338],[1.789644,0.127073],[1.849305,0.082947],[1.914539,0.047569],[1.984392,0.021547],[2.057906,0.005488],[2.134129,0],[2.134129,-0.75]]);
	}

module HTD_3mm(width = 2)
{
	linear_extrude(height=width) polygon([[-1.135062,-0.5],[-1.135062,0],[-1.048323,0.015484],[-0.974284,0.058517],[-0.919162,0.123974],[-0.889176,0.206728],[-0.81721,0.579614],[-0.800806,0.653232],[-0.778384,0.72416],[-0.750244,0.792137],[-0.716685,0.856903],[-0.678005,0.918199],[-0.634505,0.975764],[-0.586483,1.029338],[-0.534238,1.078662],[-0.47807,1.123476],[-0.418278,1.16352],[-0.355162,1.198533],[-0.289019,1.228257],[-0.22015,1.25243],[-0.148854,1.270793],[-0.07543,1.283087],[-0.000176,1.28905],[0.075081,1.283145],[0.148515,1.270895],[0.219827,1.252561],[0.288716,1.228406],[0.354879,1.19869],[0.418018,1.163675],[0.477831,1.123623],[0.534017,1.078795],[0.586276,1.029452],[0.634307,0.975857],[0.677809,0.91827],[0.716481,0.856953],[0.750022,0.792167],[0.778133,0.724174],[0.800511,0.653236],[0.816857,0.579614],[0.888471,0.206728],[0.919014,0.123974],[0.974328,0.058517],[1.048362,0.015484],[1.135062,0],[1.135062,-0.5]]);
}

module HTD_5mm(width = 2)
{
	linear_extrude(height=width) polygon([[-1.89036,-0.75],[-1.89036,0],[-1.741168,0.02669],[-1.61387,0.100806],[-1.518984,0.21342],[-1.467026,0.3556],[-1.427162,0.960967],[-1.398568,1.089602],[-1.359437,1.213531],[-1.310296,1.332296],[-1.251672,1.445441],[-1.184092,1.552509],[-1.108081,1.653042],[-1.024167,1.746585],[-0.932877,1.832681],[-0.834736,1.910872],[-0.730271,1.980701],[-0.62001,2.041713],[-0.504478,2.09345],[-0.384202,2.135455],[-0.259708,2.167271],[-0.131524,2.188443],[-0.000176,2.198511],[0.131296,2.188504],[0.259588,2.167387],[0.384174,2.135616],[0.504527,2.093648],[0.620123,2.04194],[0.730433,1.980949],[0.834934,1.911132],[0.933097,1.832945],[1.024398,1.746846],[1.108311,1.653291],[1.184308,1.552736],[1.251865,1.445639],[1.310455,1.332457],[1.359552,1.213647],[1.39863,1.089664],[1.427162,0.960967],[1.467026,0.3556],[1.518984,0.21342],[1.61387,0.100806],[1.741168,0.02669],[1.89036,0],[1.89036,-0.75]]);
}

module HTD_8mm(width = 2)
{
	linear_extrude(height=width) polygon([[-3.301471,-1],[-3.301471,0],[-3.16611,0.012093],[-3.038062,0.047068],[-2.919646,0.10297],[-2.813182,0.177844],[-2.720989,0.269734],[-2.645387,0.376684],[-2.588694,0.496739],[-2.553229,0.627944],[-2.460801,1.470025],[-2.411413,1.691917],[-2.343887,1.905691],[-2.259126,2.110563],[-2.158035,2.30575],[-2.041518,2.490467],[-1.910478,2.66393],[-1.76582,2.825356],[-1.608446,2.973961],[-1.439261,3.10896],[-1.259169,3.22957],[-1.069074,3.335006],[-0.869878,3.424485],[-0.662487,3.497224],[-0.447804,3.552437],[-0.226732,3.589341],[-0.000176,3.607153],[0.226511,3.589461],[0.447712,3.552654],[0.66252,3.497516],[0.870027,3.424833],[1.069329,3.33539],[1.259517,3.229973],[1.439687,3.109367],[1.608931,2.974358],[1.766344,2.825731],[1.911018,2.664271],[2.042047,2.490765],[2.158526,2.305998],[2.259547,2.110755],[2.344204,1.905821],[2.411591,1.691983],[2.460801,1.470025],[2.553229,0.627944],[2.588592,0.496739],[2.645238,0.376684],[2.720834,0.269734],[2.81305,0.177844],[2.919553,0.10297],[3.038012,0.047068],[3.166095,0.012093],[3.301471,0],[3.301471,-1]]);
}

module 40DP(width = 2)
{
	linear_extrude(height=width) polygon([[-0.612775,-0.5],[-0.612775,0],[-0.574719,0.010187],[-0.546453,0.0381],[-0.355953,0.3683],[-0.327604,0.405408],[-0.291086,0.433388],[-0.248548,0.451049],[-0.202142,0.4572],[0.202494,0.4572],[0.248653,0.451049],[0.291042,0.433388],[0.327609,0.405408],[0.356306,0.3683],[0.546806,0.0381],[0.574499,0.010187],[0.612775,0],[0.612775,-0.5]]);
}

module XL(width = 2)
{
	linear_extrude(height=width) polygon([[-1.525411,-1],[-1.525411,0],[-1.41777,0.015495],[-1.320712,0.059664],[-1.239661,0.129034],[-1.180042,0.220133],[-0.793044,1.050219],[-0.733574,1.141021],[-0.652507,1.210425],[-0.555366,1.254759],[-0.447675,1.270353],[0.447675,1.270353],[0.555366,1.254759],[0.652507,1.210425],[0.733574,1.141021],[0.793044,1.050219],[1.180042,0.220133],[1.239711,0.129034],[1.320844,0.059664],[1.417919,0.015495],[1.525411,0],[1.525411,-1]]);
}

module L(width = 2)
{
	linear_extrude(height=width) polygon([[-2.6797,-1],[-2.6797,0],[-2.600907,0.006138],[-2.525342,0.024024],[-2.45412,0.052881],[-2.388351,0.091909],[-2.329145,0.140328],[-2.277614,0.197358],[-2.234875,0.262205],[-2.202032,0.334091],[-1.75224,1.57093],[-1.719538,1.642815],[-1.676883,1.707663],[-1.62542,1.764693],[-1.566256,1.813112],[-1.500512,1.85214],[-1.4293,1.880997],[-1.353742,1.898883],[-1.274949,1.905021],[1.275281,1.905021],[1.354056,1.898883],[1.429576,1.880997],[1.500731,1.85214],[1.566411,1.813112],[1.625508,1.764693],[1.676919,1.707663],[1.719531,1.642815],[1.752233,1.57093],[2.20273,0.334091],[2.235433,0.262205],[2.278045,0.197358],[2.329455,0.140328],[2.388553,0.091909],[2.454233,0.052881],[2.525384,0.024024],[2.600904,0.006138],[2.6797,0],[2.6797,-1]]);
}
