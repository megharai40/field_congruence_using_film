//Defining global variables
var x,y;
var leftindex_x;
var rightindex_x;
var leftindex_y;
var rightindex_y;
var conv_factor;
var L1,L2,L3,L4,L5,L6,L7,L8;
var cross_plane_x1,cross_plane_x2;
var in_plane_y1, in_plane_y2;
var h = getHeight();
var w = getWidth();

var sCmds = newMenu("Field Congruence Menu Tool",
newArray("Enter Scale Measurement","-","X Profile", "Y Profile","-","Select Optical Field Points","-","Calculate Field Congruence"));

 macro "Field Congruence Menu Tool - C037T1d16F" {
 	cmd = getArgument();
	if(cmd == "Enter Scale Measurement"){
		scale = getString("Enter pixels per cm value","58.9014");
		conv_factor = parseFloat(scale);
	}
	if(cmd == "Select Optical Field Points"){
		setTool("multipoint");
		waitForUser("Select X1, Y2, X2,Y2 points (in that order) and click OK to continue");
		getSelectionCoordinates(x,y);
		
		//Draw Crosshair
		setColor(255,255,255);
		drawLine(0,y[0],w,y[2]);
		drawLine(x[1],0,x[3],h);

		//Getting equations of lines through selected points
		L1 =line(x[0],0,x[0],h);
		L2 = line(0,y[1],w,y[1]);
		L3 = line(x[2],0,x[2],h);
		L4 = line(0,y[3],w,y[3]);
		
		//Finding intersection points
		int1 = intersection(L1,L2);
		int2 = intersection(L2,L3);
		int3 = intersection(L3,L4);
		int4 = intersection(L4,L1);
		
		//Draw lines through the intersection points
		setColor(255,255,255);
		drawLine(int1[0],int1[1],int2[0],int2[1]);
		drawLine(int2[0],int2[1],int3[0],int3[1]);
		drawLine(int3[0],int3[1],int4[0],int4[1]);
		drawLine(int4[0],int4[1],int1[0],int1[1]);

		
		
		

		
		
	}
 	if (cmd=="X profile") {
		setTool("line");
 		waitForUser("Draw  a line and click OK to continue");
		getLine(x1,y1,x2,y2,linewidth);

		//Store coordinates of line in global variables
		cross_plane_x1 = x1;
		cross_plane_x2 = x2;

		cross_plane_y1 = y1;
		cross_plane_y2 = y2;

		profile_x = getProfile();
		Array.getStatistics(profile_x, min, max, mean, std);
		cross_min = min;
		cross_max = max;
		profile_x_len = profile_x.length;
		
		//Calculate FWHM coordinates
		leftindex_x = -1;
		rightindex_x = -1;
		
		x_fwhm = (cross_max-cross_min)/2 + cross_min;

		for (i = 1; i < profile_x_len; i++) {
            			if (floor(abs(profile_x[i] - x_fwhm)) == 0) {
                				rightindex_x= i + cross_plane_x1;
            			}
		}
		for (i = 1 ; i < profile_x_len; i++){
           			 if (floor(abs(profile_x[i] - x_fwhm)) == 0) {
               				leftindex_x= i + cross_plane_x1;
               				 break;
           		 	}
        		}
		//print(leftindex_x);
		//print(rightindex_x);
		Plot.create("Beam Profile (Cross Plane)","Distance","Intensity", profile_x);
		Plot.show()
 	}
	if (cmd=="Y profile") {
		setTool("line");
 		waitForUser("Draw  a line and click OK to continue");
		getLine(x1,y1,x2,y2,linewidth);

		//Store coordinates of line in global variables
		in_plane_x1 = x1;
		in_plane_x2 = x2;

		in_plane_y1 = y1;
		in_plane_y2 = y2;

		profile_y = getProfile();
		Array.getStatistics(profile_y, min, max, mean, std);
		in_min = min;
		in_max = max;
		profile_y_len = profile_y.length;
		
		//Calculate Coordinates for FWHM 
		leftindex_y = -1;
		rightindex_y = -1;

		y_fwhm = round((in_max - in_min)/2 + in_min);

		
		for (i = 1; i < profile_y_len; i++) {
            			if (floor(abs(profile_y[i] - y_fwhm)) ==0) {
                				rightindex_y = i + in_plane_y1;
            			}
		}
		for (i = 1 ; i < profile_y_len; i++){
           			 if (floor(abs(profile_y[i] - y_fwhm)) ==0) {
               				leftindex_y = i + in_plane_y1;
               				 break;
           		 	}
        		}
		//print(leftindex_y);
		//print(rightindex_y);
		Plot.create("Beam Profile (In Plane)","Distance","Intensity", profile_y);
		Plot.show()
	
	 
 	}

	if(cmd == "Calculate Field Congruence"){
	
		//print(leftindex_x);
		//print(rightindex_x);
		//print(leftindex_y);
		//print(rightindex_y);
		

		L5 = line(leftindex_x,0,leftindex_x, h);
		L6 = line(0,leftindex_y, w, leftindex_y);
		L7 = line(rightindex_x, 0, rightindex_x , h);
		L8 = line(0, rightindex_y, w, rightindex_y);

		int5 = intersection(L5,L6);
		int6 = intersection(L6,L7);
		int7 = intersection(L7,L8);
		int8 = intersection(L8,L5);
		
		mid1= midpoint(int5, int6);
		mid2 = midpoint(int6,int7);
		mid3 = midpoint(int8,int7);
		mid4 = midpoint(int5,int8);
		
		//Draw crosshair
		setColor(255,0,0);
		drawLine(mid1[0],0,mid3[0],h);
		drawLine(0,mid4[1],w,mid2[1]);

		//Draw lines through the intersection points
		setColor(255,0,0);
		drawLine(int5[0],int5[1],int6[0],int6[1]);
		drawLine(int6[0],int6[1],int7[0],int7[1]);
		drawLine(int7[0],int7[1],int8[0],int8[1]);
		drawLine(int8[0],int8[1],int5[0],int5[1]);

		
		//Calculating the shifts along 
		s1 = ((L1[2]-L1[1]*h)/L1[0] - leftindex_x)/conv_factor;
		s2 = ((L2[2]-L2[0]*w)/L2[1] - leftindex_y)/conv_factor;
		s3 = -((L3[2]-L3[1]*h)/L3[0] - rightindex_x)/conv_factor;
		s4 = -((L4[2]-L4[0]*w)/L4[1] - rightindex_y)/conv_factor;

		print("Shift along X1: "+s1+"cm");
		print("Shift along X2: "+s3+"cm");
		print("Shift along Y1: "+s4+"cm");
		print("Shift along Y2: "+s2+"cm");
	
		
		
	}
	
	 
 }

//Function for lines

function line(x1,y1,x2,y2){
//Calculate the coefficients for equation of a line
    A = y1-y2;
    B = x2 - x1;
    C = x1*y2 - x2*y1;
     L = newArray(A,B,-C);
    return L;
}


function intersection(L1,L2){
//Cramer's rule to find intersection between lines

    D = L1[0]*L2[1] - L1[1]*L2[0] ; //main determinant
    Dx = L1[2]*L2[1] - L1[1]*L2[2];
    Dy = L1[0]*L2[2] - L1[2]*L2[0];
    
    if (D == 0){
        print("No intersection points found");
    }else{
        x = Dx/D;
        y = Dy/D;
    }
    P = newArray(x,y);
    return P;
}

function midpoint(p1,p2){
    mid_y = abs(p2[1] - p1[1])/2 + p1[1];
    mid_x = abs(p2[0] - p1[0])/2 + p1[0];
    p = newArray(mid_x,mid_y);
    return p;
}

[Macro interactive mode. Type "help" for info.]
