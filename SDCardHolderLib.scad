////////////////////////////////////////////////////////////////
// SD Card holder
// By Nuno João from https://EmbeddedDreams.com
// Released 2020 under Creative Commons 3.0
//
// This creates a compact SD card holder "box" with spring
// that can secure an SD card. Care was taken in order to
// make it work even when printing with low tolerances.
// See the end of the file for usage.
//

// Parameters. These defaults should cover all normal
// cases and there should be no need to change them
// unless you want to adapt for another card format
// or want ticher walls.

cSDCardDx = 32;
cSDCardDy = 24;
cSDCardDz = 2.1;
cSDCardGap = 0.2;           // Gap between card and holder
cSDCardPlanePad = 0.8;      // Exterior holder wall thickness
cZDetachGap = 0.40;         // Gap from spring to "ground"
cSDCardBackthickness = 0.28;
cSDCardSpringLen = 2.3;     // Distance between card top and holder wall, on spring side
cSpringLen = (cSDCardDy + cSDCardGap) * 0.56;
cSpringThickness = 1.0;
cSpringAngle = 19;

// Precalcs

cSDCardPocketDx = cSDCardDx + cSDCardSpringLen + cSDCardGap;
cSDCardPocketDy = cSDCardDy + cSDCardGap;
cSDCardPocketDz = cSDCardDz * 1.5;
cBlockDx = cSDCardPocketDx + 2 * cSDCardPlanePad;
cBlockDy = cSDCardPocketDy + 2 * cSDCardPlanePad;
cBlockDz = cSDCardPocketDz + cSDCardBackthickness;


function GetSDCardHolderWidth() = cBlockDy;

function GetSDCardHolderLength() = cBlockDx;

function GetSDCardHolderHeight() = cBlockDz;



module semisphere (diameter, fn = 40)  {
    difference()  {
        sphere(d = diameter, $fn = fn);
        d = diameter + 0.0;
        translate([0, 0, diameter/2])
            cube([d, d, d], true);
    }
}


module triprism (leng)  {
    linear_extrude(height = leng)
        polygon(points = [[0,0], [0.5,0], [0,-0.8]],
                paths = [[0,1,2,0]], convexity = 10);
}


// Centered where the 90º corner would be placed.
module RoundChamferMold (radius = 1, width = 1, nonRoundLen = 0)  {
    scale([radius, radius, width])
        difference()  {
            cube([1 - nonRoundLen, 1 - nonRoundLen, 1], center = true);
            translate([(1 - nonRoundLen) / 2, (1 - nonRoundLen) / 2, 0])
                cylinder(h = 1.1, d = 1, center = true, $fn = 40);
        }
}


module Spring (leng, rot, thickness, dz)  {
    ofstZ = 0.1;
    ballPointDiam = thickness * 1.8;
    t2 = thickness / 2;
    rotate([0, 0, 90 - rot])  {
        translate([leng/2 + thickness/2, 0, 0])  {
            // Spring body
            translate([-leng/2, -thickness/2, cZDetachGap*2])
                cube([leng, thickness, dz - cZDetachGap*2]);
            // Top, SDCard holder w/ round chamfer and tip round end 
            difference()  {
                translate([leng/2 - leng/3/2, -ballPointDiam/2, dz - ballPointDiam/2/2-0.09])
                    rotate([90, 90, -90])
                        RoundChamferMold(thickness*2, leng/3, 0.46);
                translate([2, -ballPointDiam/2 - thickness/2 - 0.06, dz*3/4 - 0.2])
                    cylinder(h = dz/4 + 0.4, d = thickness*2, $fn = 25);
            }
            translate([leng/2 + 0.08, -0.35, dz - cZDetachGap*3])
                cylinder(h = cZDetachGap*3, r1 = 0.1, r2 = ballPointDiam/2 + 0.2, $fn = 20);
            translate([leng/2, 0, cZDetachGap*2 - ofstZ])
                cylinder(h = dz - cZDetachGap*2 + ofstZ, d = ballPointDiam, $fn = 20);
            // Conical bottom
            translate([leng/2, 0, ofstZ])
                cylinder(h = cZDetachGap*2 - ofstZ*2, r1 = ofstZ*2, r2 = ballPointDiam/2, $fn = 20);
        }
        // Bottom double side chamfer on the spring body
        translate([0.4, 0, cZDetachGap - 0.1])
            rotate([90, 0, 90])
                linear_extrude(leng)
                    polygon(points = [ [-t2,t2], [t2,t2], [0,-t2*0.5] ]);

        translate([cSDCardPlanePad + 0.3, 0, cZDetachGap*2 - thickness/4])
            rotate([180, 90, 90])
                scale([1.2, 1, 1])
                    RoundChamferMold(thickness*2, thickness, 0.2);
    }
}


module MainBlock (backHole = 1)  {
    difference()  {
        cube([cBlockDx, cBlockDy, cBlockDz]);
        translate([cSDCardPlanePad, cSDCardPlanePad, cSDCardBackthickness + 0.05])
            cube([cSDCardPocketDx, cSDCardPocketDy, cSDCardPocketDz]);

        // Remove a little more material from the base plane
        if (backHole == 1)  {
            cHoleDy = cSDCardPocketDy * 0.8;
            cHoleDx = cSDCardPocketDx * 0.6;
            translate([(cBlockDx - cHoleDx) / 2 * 1.55,
                       (cBlockDy - cHoleDy+1) / 2, -0.1])  {
                // Corner rounded square
                linear_extrude(height = cSDCardBackthickness * 2)
                    offset(r = 1, $fn = 20)
                        square([cHoleDx - 1, cHoleDy - 1]);
            }
        }
    }
}


module SDCard (ofstX = 0, ofstY = 0, zangle = 0, fingerGap = 12, backHole = 1)  {
    translate([ofstX, ofstY, 0])
    rotate([0, 0, zangle])
    translate([-GetSDCardHolderLength()/2, -GetSDCardHolderWidth()/2, 0])  {
        // Spring
        translate([cSDCardPlanePad / 2, 0.1, cSDCardBackthickness + cZDetachGap])
            Spring(cSpringLen, rot = cSpringAngle, thickness = cSpringThickness,
                    dz = cSDCardPocketDz - cZDetachGap);
        difference()  {
            union()  {
                // Holder main block
                MainBlock(backHole);
                // Triangular edge to lock the card in place
                translate([cBlockDx - cSDCardPlanePad, 0, cBlockDz])
                    rotate([90, 0, 180])
                        triprism(cBlockDy);
            }
            // Open a gap for a finger to pull the SD card out
            wallLenMinusFGap = cBlockDy - fingerGap;
            if (fingerGap != 0)  {
                cOffset = 2;
                cOffset2 = cOffset / 2;
                gapCenter = cBlockDy / 2;
                translate([cBlockDx - 1.5, gapCenter,
                            cBlockDz/2 + cSDCardBackthickness + cOffset])
                    rotate([0, 90, 0])
                    linear_extrude(height = 4)
                        offset(r = cOffset, $fn = 40)
                            square([cBlockDz, fingerGap - cOffset*2], center = true);
            }
            endWallCenterDx = cBlockDx - cSDCardPlanePad;
            nonGapLen = wallLenMinusFGap/2 + cSDCardPlanePad;
            chamferRadius = 3.2;
            translate([endWallCenterDx, cBlockDy - wallLenMinusFGap/2, cBlockDz])
                rotate([0,90,0]) RoundChamferMold(chamferRadius, cSDCardPlanePad*2.5);
            translate([endWallCenterDx, wallLenMinusFGap/2, cBlockDz])
                rotate([0,90,180]) RoundChamferMold(chamferRadius, cSDCardPlanePad*2.5);
            // Open a small space on the wall for the spring tip to have a
            // little more travel range.
            cSpringTipPocketDiam = 3.5;
            translate([cSpringTipPocketDiam/2 + cSDCardPlanePad - 0.5,
                       cSpringLen * cos(cSpringAngle) + 0.8,
                       cSDCardPocketDz/2 + cSDCardBackthickness + 0.1])
                cylinder(h = cSDCardPocketDz + 0.1, d = cSpringTipPocketDiam, center = true, $fn = 30);
        }
    }
}


// Draw 2 micro SD cards occupying the area of a single SDCard
// @@TODO
module MicroSDCard ()  {
    cube([cSDCardDx, cSDCardDy, cSDCardDz], true);
}


/// Test stuff

//RoundChamferMold(10);
//rotate([0, 90, 0]) RoundChamferMold(2, 3);

//Spring (cSpringLen, rot = 0, thickness = cSpringThickness, dz = cSDCardPocketDz - cZDetachGap);
SDCard(0, 0, 0);
//SDCard(0, GetSDCardHolderWidth(), 0);
//SDCard(15 + GetSDCardHolderWidth(), 0, 90);
//SDCard(15 + GetSDCardHolderWidth() * 2, 0, 90);

for (col = [-1:1])  {
//    SDCard(0, col * GetSDCardHolderDy(), 0);
}
