/* 
Spherical Involute Bevel Gears

   translated into english by @JediJeremy
   modified to build single polyhedron
   fixed geometry errors
   added option to center gears at cone tip (for pairs)
   added options (foot, hub) to improve printability on 3D printers
   added options to subdivide surface into 'segments' along radius

Based on Library for involute gears by Dr Joerg Janssen
   https://www.thingiverse.com/thing:1588110

Author:		Dr Joerg Janssen
Stand:		15. Juni 2016
Version:	1.3
License:	GNU non-commercial license


Permitted modules according to DIN 780:
0.05 0.06 0.08 0.10 0.12 0.16
0.20 0.25 0.3  0.4  0.5  0.6
0.7  0.8  0.9  1    1.25 1.5
2    2.5  3    4    5    6
8    10   12   16   20   25
32   40   50   60

*/


/* [Bevel Gear] */
// display mode
gear_display = "pair"; // ["single", "pair", "pair_interference"]
// Number of gear teeth (1)
gear1_teeth = 30; // [4:120]
// Number of gear teeth (2)
gear2_teeth = 10; // [4:120]
// angle between bevel gears (degrees)
bevel_angle = 90; // [10:120]
/* [Bore Hole Parameters] */
gear1_bore = 5; // [0:0.1:20]
gear1_detent = 0.4; // [0:0.05:5]
gear2_bore = 5; // [0:0.1:20]
gear2_detent = 0.4; // [0:0.05:5]

/* [Gear Parameters] */
// Size of gear teeth at the crown
gear_module = 3; // [0:0.1:20]
// Width of (straight) teeth from the outside towards the tip of the cone (mm)
tooth_width = 15; // [1:100]
// Pressure angle, standard value = 20 degrees according to DIN 867 (degrees)
pressure_angle = 20; // [10:40]
// Helix angle (degrees)
helix_angle = 30; // [-60:60]
// height of 'foot' to improve printability (mm)
gear_foot = 1; // [0:0.1:20]
// inset to 'hub' to improve printability (mm)
gear_hub = 2; // [0:0.1:20]
// radial divisions of gear polygon
gear_segments = 5; // [1:30]

// Play between tooth flanks (in module units)
gear_backlash = 0.00; // [-0.1:0.01:0.4]

/* [Hidden] */

display_bevel_gear();

module display_bevel_gear() {
	if(gear_display=="single") {
		// use customizer properties
		cone_angle = bevel_cone_angle(gear1_teeth, gear2_teeth, bevel_angle);
		bevel_gear(
			gear_module = gear_module, 
			gear_teeth = gear1_teeth, 
			cone_angle = cone_angle, 
			tooth_width = tooth_width, 
			pressure_angle = pressure_angle, 
			helix_angle = helix_angle,
			backlash = gear_backlash,
			segments = gear_segments, 
			foot = gear_foot,
			hub = gear_hub,
			bore_hole = gear1_bore, bore_detent = gear1_detent,
			center=false
		); 
	} else if(gear_display=="pair") {
		// test a pair of gears
		bevel_gear_pair(interference=false);
	} else if(gear_display=="pair_interference") {
		// interference fit test a pair of gears
		bevel_gear_pair(interference=true);
	} else {
	}
}


module bevel_gear_pair(
	gear1_teeth = gear1_teeth, // Number of gear teeth (2)
	gear2_teeth = gear2_teeth, // Number of gear teeth (2)
	bevel_angle = bevel_angle, // angle between bevel gears (degrees)
	gear1_rotate = 360/gear1_teeth * $t,
	gear2_rotate = -0.2,
	interference = true,
	debug = false
) {
	// compute angles for each gear against the other
	cone_angle_1 = bevel_cone_angle(gear1_teeth, gear2_teeth, bevel_angle);
	cone_angle_2 = bevel_cone_angle(gear2_teeth, gear1_teeth, bevel_angle);
	// engaged gear rotations
	grz_1 = gear1_rotate;
	grz_2 = 180/gear2_teeth - gear1_rotate*gear1_teeth/gear2_teeth + gear2_rotate;
	
	// increase convexity if we're going to do intersections
	convexity = interference ? 6 : 4;
	
	// draw the gears
	debug_bevel_gear_pair(interference=interference) {
		// gear 1
		rotate([0,0,grz_1]) bevel_gear(
			gear_module = gear_module, 
			gear_teeth = gear1_teeth, 
			cone_angle = cone_angle_1, 
			tooth_width = tooth_width, 
			pressure_angle = pressure_angle, 
			helix_angle = helix_angle, 
			bore_hole = gear1_bore, bore_detent = gear1_detent,
			center=true,
			debug=debug, gear_color = debug ? [0.3,0.3,0.3] : "orange",
			convexity=convexity
		);
		// gear 2
		rotate([0,bevel_angle,0]) rotate([0,0,grz_2]) bevel_gear(
			gear_module = gear_module, 
			gear_teeth = gear2_teeth, 
			cone_angle = cone_angle_2, 
			tooth_width = tooth_width, 
			pressure_angle = pressure_angle, 
			helix_angle = -helix_angle, 
			bore_hole = gear2_bore, bore_detent = gear2_detent,
			center=true, 
			debug=debug, gear_color = debug ? [0.3,0.3,0.3] : "orange",
			convexity=convexity
		);
	}
}

module debug_bevel_gear_pair(interference=false) {
	if(interference) {
		// gear pair interference check
		color("red") intersection() {
			children(0);
			children(1);
		}
		// gear pair
		color("white" ,0.1) {
			children(0);
			children(1);
		}
	} else {
		// solid gear pair
		children(0);
		children(1);
	}
}


module bevel_gear_test(debug=false,printable=true) {
	bevel_gear(
		gear_module = 4, 
		gear_teeth = 12, 
		cone_angle = 60, 
		tooth_width = 10, 
		pressure_angle = 20, 
		helix_angle = -10, 
		segments = 4,
		foot = printable ? 1 : 0,
		hub = printable ? 2 : 0,
		center = false, 
		debug = debug, 
		opacity = debug ? 0.7 : 1,
		gear_color = debug ? [0.3,0.3,0.3] : "orange"
	);
}

function bevel_cone_tip(gear1_teeth, gear2_teeth, pair_angle=90, gear_module=1) = 
	let( 
		c = gear1_teeth*[1,0]/2 + gear2_teeth*[cos(pair_angle), sin(pair_angle)]/2, // center of gear2 if gear1 is at origin
		v = [-sin(pair_angle), cos(pair_angle)], // direction vector from c2 towards tip
		iy = c[1] - v[1]*c[0]/v[0] // intersection of vector from center with y axis
	)
	gear_module * iy;

function bevel_cone_angle(gear1_teeth, gear2_teeth, pair_angle=90) = 
	let(
		ty = bevel_cone_tip(gear1_teeth, gear2_teeth, pair_angle) // y position of cone tip
	)
	atan2(gear1_teeth/2,ty);

/*  Spherical involute function
     Returns the polar coordinates of a spherical involute
     theta0 = angle of the cone, at the cutting edge of which the involute rolls off to the large sphere
     theta = angle to the cone axis for which the azimuth angle of the involute is to be calculated */
function sphere_involute(theta0,theta) = 1/sin(theta0)*acos(cos(theta)/cos(theta0))-acos(tan(theta0)/tan(theta));

/*  Converts spherical coordinates to Cartesian
     Format: radius, theta, phi; theta = angle to the z-axis, phi = angle to the x-axis on the xy-plane */
function sphere_point(vect) = [
	vect[0]*sin(vect[1])*cos(vect[2]),  
	vect[0]*sin(vect[1])*sin(vect[2]),
	vect[0]*cos(vect[1])
];

module bevel_debug_pointlist(list) {
	// list lines
	color("yellow") for(i=[0:len(list)-2]) bevel_debug_line(list[i],list[i+1]);
	// last to first
	color("white") 	bevel_debug_line(list[len(list)-1],list[0]);
	// start marker
	color("white") translate(list[0]) sphere(d=0.5, $fn=3);
}

module bevel_debug_line(p1,p2,width=0.1,fast=true) {
	if(fast) {
		v = p2-p1;
		v1 = v/norm(v) * width;
		v2 = [v1[1],v1[2],v1[0]];
		v3 = [v1[2],v1[0],v1[1]];
		polyhedron(
			points = [
				p1+v2, p1-v3, p1-v2, p1+v3,
				p2+v2, p2-v3, p2-v2, p2+v3
			],
			faces = [
				[0,1,2,3], [4,5,1,0], [7,6,5,4], [5,6,2,1], [6,7,3,2], [7,4,0,3] // cube faces
			],
			convexity =1
		);
	} else {
		hull() {
			translate(p1) sphere(d=width, $fn=3);
			translate(p2) sphere(d=width, $fn=3);
		}
	}
}

/*  Bevel gear
     gear_module = size of gear teeth at the crown
     gear_teeth = number of gear teeth 
     cone_angle = (half) angle of the cone on which the other ring gear rolls
     tooth_width = length of a straight tooth from the outside towards the tip of the cone
     pressure_angle = pressure angle, standard value = 20 degrees according to DIN 867
	 helix_angle = helix angle, standard value = 0 degrees 
*/
module bevel_gear(
	gear_module = 2, 
	gear_teeth = 10, 
	cone_angle = undef, 
	bevel_angle = 90,
	other_teeth = undef, 
	tooth_width = tooth_width, 
	pressure_angle = pressure_angle, 
	helix_angle = helix_angle,
	backlash = gear_backlash,
	segments = gear_segments, 
	foot = undef,
	hub = undef,
	center = true,
	bore_hole = 0, bore_detent = 0, bore_fn=32,
	gear_color = "orange",
	opacity = 1,
	convexity = 4,
	debug = false
) {
	// default values
	foot = (foot==undef) ? ( cone_angle>60 ? 0 : gear_foot ) : foot;
	hub = (hub==undef) ? ( cone_angle>30 ? gear_hub : 0 ) : hub;
	cone_angle = (cone_angle==undef) ? bevel_cone_angle(gear_teeth, other_teeth, bevel_angle) : cone_angle;
	// Dimension calculations
	d_outer = gear_module * gear_teeth;							// Pitch cone diameter on the cone base surface,
																// corresponds to the chord in the spherical section
	r_outer = d_outer / 2;										// Partial cone radius on the cone base
	rg_outer = r_outer/sin(cone_angle);							// Large cone radius for the outside of the tooth, corresponds to the length of the conical flank;
	rg_inner = rg_outer - tooth_width;							// Large cone radius for tooth inside	
	r_inner = r_outer*rg_inner/rg_outer;
	alpha_front = atan(tan(pressure_angle)/cos(helix_angle));	// Helix angle in the frontal section
	delta_b = asin(cos(alpha_front)*sin(cone_angle));			// Basic taper angle		
	da_outer = (gear_module <1)? d_outer + (gear_module * 2.2) * cos(cone_angle): d_outer + gear_module * 2 * cos(cone_angle);
	ra_outer = da_outer / 2;
	delta_a = asin(ra_outer/rg_outer);
	c = gear_module / 6;										// Head game
	df_outer = d_outer - (gear_module +c) * 2 * cos(cone_angle);
	rf_outer = df_outer / 2;
	delta_f = asin(rf_outer/rg_outer);
	rkf = rg_outer*sin(delta_f);								// Radius of the cone base
	height_f = rg_outer*cos(delta_f);							// Height of the cone from the foot cone
	
	// echo("Partial cone diameter on the cone base = ", d_outer);
	
	// Sizes for complementary truncated cones
	height_k = (rg_outer-tooth_width)/cos(cone_angle);			// Height of the complementary cone for correct tooth length
	rk = (rg_outer-tooth_width)/sin(cone_angle);				// Root radius of the complementary cone
	rfk = rk*height_k*tan(delta_f)/(rk+height_k*tan(delta_f));	// Head radius of the cylinder for
																// Complementary truncated cone
	height_fk = rk*height_k/(height_k*tan(delta_f)+rk);			// Height of the complementary truncated cone

	// echo("Height bevel gear = ", height_f-height_fk);
	
	phi_r = sphere_involute(delta_b, cone_angle);				// Angle to the point of involute on partial cone
		
	// Torsion angle gamma from helix angle
	gamma_g = 2*atan(tooth_width*tan(helix_angle)/(2*rg_outer-tooth_width));
	gamma = 2*asin(rg_outer/r_outer*sin(gamma_g/2));
	
	step = (delta_a - delta_b)/16;
	tau = 360/gear_teeth;										// Pitch angle
	start = (delta_b > delta_f) ? delta_b : delta_f;
	mirror_phi = (180*(1-backlash))/gear_teeth+2*phi_r;
	// align the first tooth with the x-axis; makes alignment with other gears easier
	rotate([0,0,phi_r+90*(1-backlash)/gear_teeth]){				
		// position gear with cone tip at origin, or with base at origin
		translate([0,0,center ? 0 : height_f + foot]) rotate([0,180,0]) {
			// do we need a tooth root
			tooth_root = (delta_b > delta_f);
			// precompute delta lists for tooth profile (up and down the sides of the tooth)
			tooth_step_count = floor( (delta_a-start)/step );
			tooth_delta_a = [for(i=[0:tooth_step_count-1]) start + step*i ];
			tooth_delta_b = [for(i=[tooth_step_count-1:-1:0]) start + step*i ];
			// ring set [radius, angle] one per fragment plus one
			ring_set = [for(i=[0:segments])
				[ rg_outer - (rg_outer-rg_inner)/segments*i, gamma/segments*i ]
			];
			// how many points per tooth profile
			tooth_point_count = ( tooth_step_count + (tooth_root?1:0) )*2;
			// how many points per crown ring
			ring_point_count = tooth_point_count*gear_teeth;
			// precompute the generic set of tooth rotations
			tooth_r = [for(i=[1:gear_teeth]) i*tau ];
			// create a ring for each radius
			bevel_rings = [for(sr = ring_set)
				[for(r=tooth_r) each concat(
					tooth_root ? [sphere_point([sr[0], delta_f, r+sr[1]])] : [],
					[for(delta=tooth_delta_a) sphere_point([sr[0], delta, r+sr[1]+sphere_involute(delta_b, delta)]) ],
					[for(delta=tooth_delta_b) sphere_point([sr[0], delta, r+sr[1]+mirror_phi-sphere_involute(delta_b, delta)]) ],
					tooth_root ? [sphere_point([sr[0], delta_f, r+sr[1]+mirror_phi])] : []
				)]
			];
			// what's the radius of the innermost crown root
			small_p = bevel_rings[segments][0];
			small_r = norm( [small_p[0], small_p[1]] );
			hub_r = small_r - hub;
			// add the optional foot and hub rings
			rings = concat(
				foot ? [[for(i=[0:ring_point_count-1]) [bevel_rings[0][i][0], bevel_rings[0][i][1], height_f+foot] ]] : [],
				bevel_rings,
				hub ? [[for(i=[0:ring_point_count-1]) bevel_hub_projection(bevel_rings[segments][i], hub_r) ]] : []
			);
			// debug the rings
			if(debug) for(ring=rings) bevel_debug_pointlist(ring);
			// collapse all the ring points into a single list
			poly_points = [for(r=rings) each r];
			ring_count = len(rings);
			// generate faces
			poly_faces = concat(
				bevel_crown_cap(0, tooth_point_count, gear_teeth, flip=true), // floor cap
				[for(i=[0:ring_count-2]) each bevel_crown_faces(ring_point_count*i,ring_point_count) ],
				hub ? bevel_crown_hub(ring_point_count*(ring_count-1), tooth_point_count, gear_teeth) // top hub
					: bevel_crown_cap(ring_point_count*(ring_count-1), tooth_point_count, gear_teeth, flip=false) // top cap
			);
			color(gear_color,opacity) difference() {
				// gear poly
				polyhedron(
					points = poly_points,
					faces = poly_faces,
					convexity = convexity
				);
				// bore hole
				if(bore_hole) {
					linear_extrude(
						height = height_f+foot+1,
						convexity = convexity
					) difference() {
						circle(d=bore_hole, $fn=bore_fn);
						translate([bore_hole/2 - bore_detent, -bore_hole/2]) square(bore_hole*[1,1]);
					}
				}
			}
		}
	}
}

function bevel_hub_projection(p, r) = let(n=norm([p[0],p[1]])) [p[0]/n*r, p[1]/n*r, p[2]];

function bevel_crown_faces(index, cpoints) = [for(i=[0:cpoints-1])
	((i==0) ? [cpoints-1,0,cpoints,cpoints+cpoints-1] : [i-1,i,i+cpoints,i+cpoints-1])
	+ index*[1,1,1,1]
];

function bevel_crown_cap(index, tpoints, teeth, flip=false) = concat(
	// tooth faces
	[for(j=[0:teeth-1]) each
		[for(i=[0:tpoints/2-1]) 
			(flip ? [ i+1, i, tpoints-i-1, tpoints-i-2 ] : [ i, i+1, tpoints-i-2, tpoints-i-1 ]) 
			+ (index + j*tpoints)*[1,1,1,1] 
		]
	],
	// base face
	[bevel_reverse_list_if(flip, [for(t=[0:teeth-1]) each [ index+(t*tpoints), index+((t+1)*tpoints)-1 ] ] )]
);

function bevel_crown_hub(index, tpoints, teeth, flip=false) = concat(
	// inter-tooth faces
	[for(j=[0:teeth-1]) each
		let( 
			ti = (index)*[1,1,1,1] + ((j==0)?(teeth-1):(j-1))*tpoints*[1,1,0,0] + j*tpoints*[0,0,1,1]
		) [for(i=[0:tpoints/2-2]) 
			[ tpoints-i-2, tpoints-i-1, i, i+1 ] + ti
		]
	],
	// hub face
	[[for(t=[0:teeth-1]) each [ index+((t+0.5)*tpoints)-1, index+((t+0.5)*tpoints) ] ]]
);
	
function bevel_reverse_list_if(test, list) = test ? [for(i=[len(list)-1:-1:0]) list[i] ] : list;

