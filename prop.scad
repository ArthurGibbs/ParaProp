
d=0.5;

//prop();
module prop(	blades=5,
				hubRadius=10,
				height=10,
				stork=2,
				or=10,
				ir=9){
	color("DarkSlateGray")blades(	h=height+d,
									or=or,
									ir=ir,
									blades=blades, 
									stork=stork);
	mountBearing(blades=blades,or=or,ir=ir);

}

//mountBearing();
module mountBearing(	blades=2,
							r=10,
							height=10,
							stork=3,
							ir=10,
							or=11){
	difference(){
		color("LightGrey")
cylinder(h=height, r= or);
		translate(v=[0,0,-d])
			blades(blade="false",h=height+(2*d),or=or+d,ir=ir,blades=blades);
	}
}

//blades();
module blades(	h=12,
					or=10,
					ir=9, 
					blades=3,
					stork=2.5,
					rootAOA=30,
					tipAOA=20,
					blade="true"){
	for ( i = [0 : blades] ){
		rotate([0,0,360/blades*i]){
				//color([1/blades*i,0,1-(1/blades*i)])
					bladeassembley(length=70,
										sections=10,
										rootChord=0.4,
										tipChord=0.1, 
										rootThickness=0.6,
										tipThickness=0.1,
										stork=stork, 
										flushangle=(180/blades)-5,
										blade=blade,
										depth=h,
										rootAOA=rootAOA,
										tipAOA=tipAOA,
										or=or,
										ir=ir);
		}	
	}	
}

//bladeassembley();
module bladeassembley(length=50, 
				depth=10,
				sections=20, 
				rootAOA=60,
				tipAOA=3,
				rootChord=0.6,
				tipChord=0.2,
				rootThickness=1,
				tipThickness=0.2,
				or=11,
				ir=10,
				flushangle=35,
				blade="true"){
	if (blade=="true"){
		intersection(){
			difference(){
				translate(v=[0,0,depth/10*6])
					blade(length=length,
							sections=sections,
							rootAOA=rootAOA,
							tipAOA=tipAOA,
							rootChord=rootChord,
							tipChord=tipChord,
							rootThickness=rootThickness,
							tipThickness=tipThickness);
				translate(v=[0,0,-depth/2])
					cylinder(h=2*depth,r=(or+ir)/2);
			}
		mountFlush(depth=depth,or=or+length, ir=or, a=flushangle);
		}
	}
	translate(v=[0,0,0]){
		mount(width=4,
				depth=depth,
				teirs=4,
				ir=ir,
				or=or,
				a=flushangle);
		
	}
}

//blade();
module blade(	length=50, 
					sections=100, 
					rootAOA=45,
					tipAOA=10,
					rootChord=0.7,
					rootThickness=2,
					tipChord=0.2,
					tipThickness=0.2){

	layerHeight=length/sections;
	layerAOA=(rootAOA-tipAOA)/sections;
	layerPercent=100/(sections-1);
	rotate([90,0,0])
	rotate([0,0,-rootAOA])
	for ( i = [0 : sections-1] ){
		translate(v=[0,0,i*layerHeight])
			rotate([0,0,layerAOA*i])
				bladeLayer(	length=layerHeight,
								r=layerAOA,
								i=i,
								s=sections,
								sw=rootChord,	
								ew=tipChord,
								sh=rootThickness,
								eh=tipThickness);
	}
}

module bladeLayer(length=10,
						r=10,
						i=1,
						s=2,
						ew=0.5,
						eh=0.5,
						sw=1,
						sh=1){
	cop=i/s;
	cip=1-cop;
	oop=(i-1)/s;
	oip=1-oop;
	layer(	length=length,
			 r=r,
			 we=sw*cip + ew*cop, 
			ws=sw*oip + ew*oop, 
			he=sh*cip + eh*cop, 
			hs=sh*oip + eh*oop);
}

module layer(	length = 10, 
				r = 10,
				ws=1,
				we=1,
				hs=1,
				he=1){
	sh=0.1;
	hull(){
		color("red") aerofoil(w=ws,h=hs,t=sh);
		rotate([0,0,r])
			translate(v=[0,0,length-sh])
				color("blue")
					aerofoil(w=we,h=he,t=sh);
	}	
}

module aerofoil(	w=1,
						h=1,
						t=1) {
	scale([w,h,1])
		translate(v=[-3,-17,0]){
			linear_extrude(height =t)
				import("ms313-il.dxf",h=60);
		}
}

//mount();
module mount(	width=4,
					depth=5,
					teirs=4,
					core=2,
					a=20,
					or=11,
					ir=10,
					stork=1.5){
	mountFlush(depth=depth,or=or, ir=ir, a=a);

	translate(v=[0,-ir,0])
		treefixture(teirWidth=width, 
						length=ir/5*2,
						teirs=teirs,
						depth=depth, 
						stork=stork);
}

//mountFlush();
module mountFlush(depth=10, or=10, ir=9, a=45){
	difference(){

		//color("green")
		cylinder(h=depth, r=or, $fn=32);

		translate(v=[0,0,-d]){

			cylinder(h=depth+2*d, r=ir,$fn=32);

			translate(v=[-(or+d),0,0]){
				cube([2*(or+d),2*(or+d),depth+2*d]);
			}
		
			rotate(v=[0,0,1],a=180-a){
				cube([2*or+d,2*or+d,depth+2*d]);
			}

			mirror([1,0,0]){
				rotate(v=[0,0,1],a=180-a){
					cube([2*or+d,2*or+d,depth+2*d]);
				}
			}
		}
	}
}

//treefixture();
module treefixture(	teirWidth=5,
							length=5,
							depth=1,
							teirs=4,
							core=2,
							stork=3){
	td=length/teirs;
	linear_extrude(height =depth){
		translate(v=[0,stork,0])
		for (i = [0 : teirs-1]){
			translate(v=[0,td*i,0])
			color("green")
			lockingTeir(width=teirWidth*(1-(i/(teirs+1))),
							core=core*(1-(i/teirs)),
							storkDepth=td);
			if (i!=teirs-1)
				translate(v=[-core/2*(1-(i/teirs)),td*(i+1)-td/5,0])
					color("darkgreen")square ([core*(1-(i/teirs)),td/5]);
			
		}
		translate(v=[-core/2,0,0]){
			color("red")square([core,stork]);
		}
	}
}

module lockingTeir(width=10,core=5,storkDepth=5){
	polygon(
		points=[
			[-core/2,storkDepth/5*4],
			[core/2,storkDepth/5*4],
			[width/2,storkDepth/5],
			[width/2,0],
			[-width/2,0],
			[-width/2,storkDepth/5]], 
		paths=[
			[0,1,2,3,4,5]]);
}



scale([10,10,10])
airfoil();

module airfoil(root_camber_max = 22,
                         root_camber_position = 4, 
                         root_thickness = 20,
                         tip_camber_max = 10,
                         tip_camber_position = 4, 
                         tip_thickness = 20,
                         length=0.2) {

        //http://www.ppart.de/aerodynamics/profiles/NACA4.html
        
        root_m =  root_camber_max/100;
        tip_m =  tip_camber_max/100;

        root_p =  root_camber_position/10;
        tip_p =  tip_camber_position/10;

        root_t =  root_thickness/100;   
        tip_t  =  tip_thickness/100;
        
        pts = 25; // datapoints on each of upper and lower surfaces
        
        function xx(i) = 1 - cos((i-1)*90/(pts-1));
        function yt(i,t) = t/0.2*(0.2969*pow(xx(i),0.5) - 0.126*xx(i)-0.3516*pow(xx(i),2) + 0.2843*pow(xx(i),3) - 0.1015*pow(xx(i),4));
        function yc(i,p,m)    = xx(i)<p ? m/pow(p,2)*(2*p*xx(i) - pow(xx(i),2)) : m/pow(1-p,2)*(1 - 2*p + 2*p*xx(i) - pow(xx(i),2));

        function xu(j,p,m,t) = xx(j) - yt(j,t)*(sin(atan((yc(j,p,m)-yc(j-1,p,m))/(xx(j)-xx(j-1)))))-0.25;
        function yu(j,p,m,t) = yc(j,p,m) + yt(j,t)*(cos(atan(( yc(j,p,m)-yc(j-1,p,m))/(xx(j)-xx(j-1)))))-0.1;
        function xl(j,p,m,t)  = xx(j) + yt(j,t)*(sin(atan((yc(j,p,m)-yc(j-1,p,m))/(xx(j)-xx(j-1)))))-0.25;
        function yl(j,p,m,t)  = yc(j,p,m) - yt(j,t)*(cos(atan((yc(j,p,m)-yc(j-1,p,m))/(xx(j)-xx(j-1)))))-0.1;

        function root_yt(i) = yt(i,root_t);
        function root_yc(i) = yc(i,root_p,root_m);

        function root_xu(j) =xu(j,root_p,root_m,root_t);
        function root_yu(j) = yu(j,root_p,root_m,root_t);
        function root_xl(j) =xl(j,root_p,root_m,root_t);
        function root_yl(j) = yl(j,root_p,root_m,root_t);

        function tip_yt(i) = yt(i,tip_t);
        function tip_yc(i) = yc(i,tip_p,tip_m);

        function tip_xu(j) =xu(j,tip_p,tip_m,tip_t);
        function tip_yu(j) = yu(j,tip_p,tip_m,tip_t);
        function tip_xl(j) =xl(j,tip_p,tip_m,tip_t);
        function tip_yl(j) = yl(j,tip_p,tip_m,tip_t);


        polyhedron( points=[ 
             // upper side front-to-back
            [tip_xu(01),tip_yu(01),length/2],
            [tip_xu(02),tip_yu(02),length/2],
            [tip_xu(03),tip_yu(03),length/2],
            [tip_xu(04),tip_yu(04),length/2],
            [tip_xu(05),tip_yu(05),length/2],
            [tip_xu(06),tip_yu(06),length/2],
            [tip_xu(07),tip_yu(07),length/2],
            [tip_xu(08),tip_yu(08),length/2],
            [tip_xu(09),tip_yu(09),length/2],
            [tip_xu(10),tip_yu(10),length/2],
            [tip_xu(11),tip_yu(11),length/2],
            [tip_xu(12),tip_yu(12),length/2],
            [tip_xu(13),tip_yu(13),length/2],
            [tip_xu(14),tip_yu(14),length/2],
            [tip_xu(15),tip_yu(15),length/2],
            [tip_xu(16),tip_yu(16),length/2],
            [tip_xu(17),tip_yu(17),length/2],
            [tip_xu(18),tip_yu(18),length/2],
            [tip_xu(19),tip_yu(19),length/2],
            [tip_xu(20),tip_yu(20),length/2],
            [tip_xu(21),tip_yu(21),length/2],
            [tip_xu(22),tip_yu(22),length/2],
            [tip_xu(23),tip_yu(23),length/2],
            [tip_xu(24),tip_yu(24),length/2],
            [tip_xu(25),tip_yu(25),length/2],

            // lower side back to front
            [tip_xl(25),tip_yl(25),length/2],
            [tip_xl(24),tip_yl(24),length/2],
            [tip_xl(23),tip_yl(23),length/2],
            [tip_xl(22),tip_yl(22),length/2],
            [tip_xl(21),tip_yl(21),length/2],
            [tip_xl(20),tip_yl(20),length/2],
            [tip_xl(19),tip_yl(19),length/2],
            [tip_xl(18),tip_yl(18),length/2],
            [tip_xl(17),tip_yl(17),length/2],
            [tip_xl(16),tip_yl(16),length/2],
            [tip_xl(15),tip_yl(15),length/2],
            [tip_xl(14),tip_yl(14),length/2],
            [tip_xl(13),tip_yl(13),length/2],
            [tip_xl(12),tip_yl(12),length/2],
            [tip_xl(11),tip_yl(11),length/2],
            [tip_xl(10),tip_yl(10),length/2],
            [tip_xl(09),tip_yl(09),length/2],
            [tip_xl(08),tip_yl(08),length/2],
            [tip_xl(07),tip_yl(07),length/2],
            [tip_xl(06),tip_yl(06),length/2],
            [tip_xl(05),tip_yl(05),length/2],
            [tip_xl(04),tip_yl(04),length/2],
            [tip_xl(03),tip_yl(03),length/2],
            [tip_xl(02),tip_yl(02),length/2],




               //root
            [root_xu(01),root_yu(01),-length/2],
            [root_xu(02),root_yu(02),-length/2],
            [root_xu(03),root_yu(03),-length/2],
            [root_xu(04),root_yu(04),-length/2],
            [root_xu(05),root_yu(05),-length/2],
            [root_xu(06),root_yu(06),-length/2],
            [root_xu(07),root_yu(07),-length/2],
            [root_xu(08),root_yu(08),-length/2],
            [root_xu(09),root_yu(09),-length/2],
            [root_xu(10),root_yu(10),-length/2],
            [root_xu(11),root_yu(11),-length/2],
            [root_xu(12),root_yu(12),-length/2],
            [root_xu(13),root_yu(13),-length/2],
            [root_xu(14),root_yu(14),-length/2],
            [root_xu(15),root_yu(15),-length/2],
            [root_xu(16),root_yu(16),-length/2],
            [root_xu(17),root_yu(17),-length/2],
            [root_xu(18),root_yu(18),-length/2],
            [root_xu(19),root_yu(19),-length/2],
            [root_xu(20),root_yu(20),-length/2],
            [root_xu(21),root_yu(21),-length/2],
            [root_xu(22),root_yu(22),-length/2],
            [root_xu(23),root_yu(23),-length/2],
            [root_xu(24),root_yu(24),-length/2],
            [root_xu(25),root_yu(25),-length/2],

            // lower side back to front
            [root_xl(25),root_yl(25),-length/2],
            [root_xl(24),root_yl(24),-length/2],
            [root_xl(23),root_yl(23),-length/2],
            [root_xl(22),root_yl(22),-length/2],
            [root_xl(21),root_yl(21),-length/2],
            [root_xl(20),root_yl(20),-length/2],
            [root_xl(19),root_yl(19),-length/2],
            [root_xl(18),root_yl(18),-length/2],
            [root_xl(17),root_yl(17),-length/2],
            [root_xl(16),root_yl(16),-length/2],
            [root_xl(15),root_yl(15),-length/2],
            [root_xl(14),root_yl(14),-length/2],
            [root_xl(13),root_yl(13),-length/2],
            [root_xl(12),root_yl(12),-length/2],
            [root_xl(11),root_yl(11),-length/2],
            [root_xl(10),root_yl(10),-length/2],
            [root_xl(09),root_yl(09),-length/2],
            [root_xl(08),root_yl(08),-length/2],
            [root_xl(07),root_yl(07),-length/2],
            [root_xl(06),root_yl(06),-length/2],
            [root_xl(05),root_yl(05),-length/2],
            [root_xl(04),root_yl(04),-length/2],
            [root_xl(03),root_yl(03),-length/2],
            [root_xl(02),root_yl(02),-length/2]    

          
        ],
        triangles=[
            //top triangles
            [00,01,48],
            [01,02,47],
            [02,03,46],
            [03,04,45],
            [04,05,44],
            [05,06,43],
            [06,07,42],
            [07,08,41],
            [08,09,40],
            [09,10,39],
            [10,11,38],
            [11,12,37],
            [12,13,36],
            [13,14,35],
            [14,15,34],
            [15,16,33],
            [16,17,32],
            [17,18,31],
            [18,19,30],
            [19,20,29],
            [20,21,28],
            [21,22,27],
            [22,23,26],  
            [23,24,25],    

            //lowertriangles    
            [25,26,23],
            [26,27,22],
            [27,28,21],
            [28,29,20],
            [29,30,19],
            [30,31,18],
            [31,32,17],
            [32,33,16],
            [33,34,15],
            [34,35,14],
            [35,36,13],
            [36,37,12],
            [37,38,11],
            [38,39,10],
            [39,40,09],
            [40,41,08],
            [41,42,07],
            [42,43,06],
            [43,44,05],
            [44,45,04],
            [45,46,03],
            [46,47,02],
            [47,48,01],


       [50,49,97],
	[51,50,96],
	[52,51,95],
	[53,52,94],
	[54,53,93],
	[55,54,92],
	[56,55,91],
	[57,56,90],
	[58,57,89],
	[59,58,88],
	[60,59,87],
	[61,60,86],
	[62,61,85],
	[63,62,84],
	[64,63,83],
	[65,64,82],
	[66,65,81],
	[67,66,80],
	[68,67,79],
	[69,68,78],
	[70,69,77],
	[71,70,76],
	[72,71,75],
	[73,72,74],

   
[75,74,72],
[76,75,71],
[77,76,70],
[78,77,69],
[79,78,68],
[80,79,67],
[81,80,66],
[82,81,65],
[83,82,64],
[84,83,63],
[85,84,62],
[86,85,61],
[87,86,60],
[88,87,59],
[89,88,58],
[90,89,57],
[91,90,56],
[92,91,55],
[93,92,54],
[94,93,53],
[95,94,52],
[96,95,51],
[97,96,50],
[98,97,49],


[01,00,49],
[02,01,50],
[03,02,51],
[04,03,52],
[05,04,53],
[06,05,54],
[07,06,55],
[08,07,56],
[09,08,57],
[10,09,58],
[11,10,59],
[12,11,60],
[13,12,61],
[14,13,62],
[15,14,63],
[16,15,64],
[17,16,65],
[18,17,66],
[19,18,67],
[20,19,68],
[21,20,69],
[22,21,70],
[23,22,71],
[24,23,72],
[25,24,73],
[26,25,74],
[27,26,75],
[28,27,76],
[29,28,77],
[30,29,78],
[31,30,79],
[32,31,80],
[33,32,81],
[34,33,82],
[35,34,83],
[36,35,84],
[37,36,85],
[38,37,86],
[39,38,87],
[40,39,88],
[41,40,89],
[42,41,90],
[43,42,91],
[44,43,92],
[45,44,93],
[46,45,94],
[47,46,95],
[48,47,96],
[00,48,97],


[01,49,50],
[02,50,51],
[03,51,52],
[04,52,53],
[05,53,54],
[06,54,55],
[07,55,56],
[08,56,57],
[09,57,58],
[10,58,59],
[11,59,60],
[12,60,61],
[13,61,62],
[14,62,63],
[15,63,64],
[16,64,65],
[17,65,66],
[18,66,67],
[19,67,68],
[20,68,69],
[21,69,70],
[22,70,71],
[23,71,72],
[24,72,73],
[25,73,74],
[26,74,75],
[27,75,76],
[28,76,77],
[29,77,78],
[30,78,79],
[31,79,80],
[32,80,81],
[33,81,82],
[34,82,83],
[35,83,84],
[36,84,85],
[37,85,86],
[38,86,87],
[39,87,88],
[40,88,89],
[41,89,90],
[42,90,91],
[43,91,92],
[44,92,93],
[45,93,94],
[46,94,95],
[47,95,96],
[48,96,97],
[00,97,49]
    ] ); 
}
