
d=0.5;
mountBearing();

module mountBearing(number=3,
						r=10,
						height=10){
	difference(){
		cylinder(h=height, r= r);

		translate(v=[0,0,-d])
			mounts(h=height+2*d,number=number,or=r+1, ir=r-1);
	}


	blades(h=height,or=r+1,ir=r-1,number=number);
	
}


module blades(	h=10,
				or=10,
				ir=9,
				number=2){
	for ( i = [0 : number] ){
		rotate([0,0,360/number*i]){
			translate(v=[0,-ir,h/10*6])
				blade(sections=10,startwidth=0.4,startheight=0.6,endwidth=0.1);
		}	
	}	
	color("red")mounts(h=h,number=number,or=or, ir=ir);
}

module mounts(	number=3,
					h=10,
					or=10,
					ir=9){
	union(){
		for ( i = [0 : number] ){
			rotate([0,0,360/number*i])			
				color("blue")
					union()
						mount(width=4, depth=5,teirs=2,height=h,ir=ir,or=or,a=180/number-5);
		}	
	}
}


module mount(	width=4,
				depth=5,
				height=10,
				teirs=4,
				core=2,
				a=30,
				storkLength=3,
				or=11,
				ir=10){

	mountFlush(height=height,a=a, or=or, ir=ir);
	translate(v=[0,-ir+ir/6,0])
		treefixture(width=4, depth=ir/2,teirs=teirs,height=height, storkLength=2);
}



module mountFlush(height=10, or=10, ir=9, a=45){
	difference(){

		color("green")cylinder(h=height, r=or, $fn=32);

		translate(v=[0,0,-d]){

			cylinder(h=height+2*d, r=ir,$fn=32);

			translate(v=[-(or+d),0,0]){
				cube([2*(or+d),2*(or+d),height+2*d]);
			}
		
			rotate(v=[0,0,1],a=180-a){
				cube([2*or+d,2*or+d,height+2*d]);
			}

			mirror([1,0,0]){
				rotate(v=[0,0,1],a=180-a){
					cube([2*or+d,2*or+d,height+2*d]);
				}
			}
		}
	}
}

module treefixture(	width=4,
							depth=5,
							height=10,
							teirs=4,
							core=2,
							storkLength=3){
	td=depth/teirs;
	color("DarkSeaGreen")linear_extrude(height =height){
		for (i = [0 : teirs-1]){
			translate(v=[0,td*i,0])
			color("green")lockingTeir(width=width*(1-(i/(teirs+1))),
							core=core*(1-(i/teirs)),
							depth=td);
			if (i!=teirs-1)
				translate(v=[-core/2*(1-(i/teirs)),td*(i+1)-td/5,0])
					color("darkgreen")square ([core*(1-(i/teirs)),td/5]);
			
		}
		translate(v=[-core/2,-storkLength,0]){
			color("red")square([core,storkLength]);
		}
	}
}

module lockingTeir(	width=10,
							core=5,
							depth=5){
polygon(
	points=[
		[-core/2,depth/5*4],
		[core/2,depth/5*4],
		[width/2,depth/5],
		[width/2,0],
		[-width/2,0],
		[-width/2,depth/5]], 
	paths=[
		[0,1,2,3,4,5]]);
}





module blade(	height=50, 
					sections=20, 
					rotation=45,
					startwidth=0.7,
					startheight=2,
					endwidth=0.2,
					endhight=0.2){

	layerHeight=height/sections;
	lr=rotation/sections;
	layerPercent=100/(sections-1);
	rotate([90,0,0])
	rotate([0,0,-rotation])
	for ( i = [0 : sections-1] ){
		translate(v=[0,0,i*layerHeight])
			rotate([0,0,lr*i])
				bladeLayer(	h=layerHeight,
								r=lr,
								i=i,
								s=sections,
								ew=endwidth,
								eh=endhight,
								sw=startwidth,
								sh=startheight);
	}
}

module bladeLayer(h=10,
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

	layer(
			h=h,
			r=r,
			we=sw*cip + ew*cop,
			ws=sw*oip + ew*oop,
			he=sh*cip + eh*cop,
			hs=sh*oip + eh*oop);

}


module layer(	h = 10, 
					r = 10,
					ws=1,
					we=1,
					hs=1,
					he=1){
	sh=0.1;
hull(){
	color("red") slice(w=ws,h=hs,t=sh);
	rotate([0,0,r])
		translate(v=[0,0,h-sh])
			color("blue") slice(w=we,h=he,t=sh);
}	
}

module slice(	w=1,
					h=1,
					t=1) {
	scale([w,h,1])
		translate(v=[-3,-17,0]){
			linear_extrude(height =t)
				import("ms313-il.dxf",h=60);
		}
}



