
d=0.5;

prop();

module prop(	blades=3,
				hubRadius=10,
				height=10,
				stork=3){
	color("DarkSlateGray")blades(	h=height+d,
											or=height+1,
											ir=height-1,
											blades=blades, 
											stork=stork);
	mountBearing(blades=blades);

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
				rootAOA=30,
				tipAOA=3,
				rootChord=0.6,
				tipChord=0.2,
				rootThickness=1,
				tipThickness=0.2,
				or=11,
				ir=10,
				stork=2.5,
				flushangle=55,
				blade="true"){
	if (blade=="true"){
		difference(){
			translate(v=[0,0,depth/2])
			blade(length=length,
					sections=sections,
					rootAOA=rootAOA,
					tipAOA=tipAOA,
					rootChord=rootChord,
					tipChord=tipChord,
					rootThickness=rootThickness,
					tipThickness=tipThickness);
			
			translate(v=[0,0,-depth])
				cylinder(h=2*depth,r=or);
		
		}
	}
	translate(v=[0,0,0]){
		mount(width=4,
				depth=depth,
				teirs=2,
				ir=ir,
				or=or,
				stork=stork,
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
					stork=2,
					or=11,
					ir=10){
	mountFlush(depth=depth,or=or, ir=ir, a=a);

	translate(v=[0,-ir+ir/6,0])
		treefixture(width=width, 
						storkDepth=ir/5*2,
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

module treefixture(	width=4,
							storkDepth=5,
							depth=10,
							teirs=4,
							core=2,
							stork=3){
	td=storkDepth/teirs;
	color("DarkSeaGreen")
	linear_extrude(height =depth){
		for (i = [0 : teirs-1]){
			translate(v=[0,td*i,0])
			color("green")
			lockingTeir(width=width*(1-(i/(teirs+1))),
							core=core*(1-(i/teirs)),
							storkDepth=td);
			if (i!=teirs-1)
				translate(v=[-core/2*(1-(i/teirs)),td*(i+1)-td/5,0])
					color("darkgreen")square ([core*(1-(i/teirs)),td/5]);
			
		}
		translate(v=[-core/2,-stork,0]){
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

