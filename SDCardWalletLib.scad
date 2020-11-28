////////////////////////////////////////////////////////////////
// SD Card holder
// By Nuno João from https://EmbeddedDreams.com
// Released 2020 under Creative Commons 3.0
//
// This creates a compact SD card wallet, from 2 to many cards
// in several configurations.
//

use <SDCardHolderLib.scad>;

cHoldersCfg = [ [0] ];

cCardsX = len(cHoldersCfg);
cCardsY = len(cHoldersCfg[0]);
cBackHoles = 0;
cFingerOpenWidth = 0.24;    // %/100 of X axis box len

cLockSection = 3.9;
cLockHoleLen = 8;
cLockDistFromSide = 2.5;
cLockDistFromFront = 0.4;
cLockPinLen = 3.7;          // Length, defines "engagement" between top and bottom pins
cLockPinWidth = cLockSection;
cLockLockGap = 0.15;
cLockPinBaseLen = 0.8;
cLockPinThickness = 1;

cHingeGap = 0.44;       // Gap between male and female hinges, affects printability
cHingeOfst = 0.28;      // Extra offset from box to hinge rotation axis
cHingeHoleBodyLen = 4 + (cCardsX - 1) * 1.2 + (cCardsY - 1) * 0.5;
cHingePinBodyLen = cHingeHoleBodyLen * 1.8;

// Reserved params
cBoxBodyChamferDiam = 1.8;
// Design version, to be coded as no-hole/hole between the lock pin's holes.
cStampVersion = "yes";      // if you want to turn it off
cVersionBinaryVector = [0, 0, 0, 0, 0, 0, 0, 0];    // binary 0..255, MSB -> LSB


module RoundTopPrism (len, diam, sphereDiamK)  {
    cube([len, diam+0.4, diam+0.4], center = true);
    translate([len * 0.45, 0, 0])
        sphere(d = diam * sphereDiamK, $fn = 40);
}


module GeneralLockPin (baseWidth = 3.9, springLen = 3.1, tipFlushOfst = 0.25)  {
    thickness = cLockPinThickness;
    tipDiameter = thickness + tipFlushOfst;
    width = 3.3;
    rotate([90, 0, 0])  {
        // Bold base
        translate([0, cLockPinBaseLen/2, 0])
            cube([2, cLockPinBaseLen, baseWidth], center = true);
        // Spring body
        translate([0, springLen/2, 0])
            cube([thickness, springLen, width], center = true);
        // Base chamfers
        translate([thickness/2, 0.6/2 + thickness/2, 0])
            rotate([0, 0, 0])
                RoundChamferMold(radius = thickness, width = width);
        translate([-thickness/2, 0.6/2 + thickness/2, 0])
            rotate([0, 180, 0])
                RoundChamferMold(radius = thickness, width = width);
        // Protruding tip
        translate([0, springLen, -width/2])
            scale([1, 1.5, 1])
                cylinder(h = width, r = tipDiameter/2, $fn=25);
    }
}


module LockHoles (outDx)  {
    // 2 lock holes to keep the half wallet parts closed
    translate([outDx - cLockHoleLen/2 - cLockDistFromSide, 0, 0])
        rotate([0, 0, 180])
            cube([cLockHoleLen, cLockSection, cLockSection], center = true);
    translate([cLockHoleLen/2 + cLockDistFromSide, 0, 0])
        rotate([0, 0, 0])
            cube([cLockHoleLen, cLockSection, cLockSection], center = true);
}


module HalfMaleHinge (len, diameter)  {
    fn = 40;
    chamferDiam = 1.4;
    originalLen = len;
    len = len - (chamferDiam / 2 + diameter / 2);

    //// Body block
    // Cylindrical body
    rotate([0, 90, 0])
        cylinder(h = len, r = diameter, $fn = fn);
    // Round chamfer of the cylinder (body) "front" (a torus)
    translate([len, 0, 0])  {
        rotate([0, 90, 0])
            rotate_extrude($fn = 40, convexity = 2)
                translate([diameter - chamferDiam/2, 0, 0])
                    circle(d = chamferDiam, $fn = fn/2);
    }
    // Cover up the torus hole
    translate([len, 0, 0])
        rotate([0, 90, 0])
            cylinder(h = chamferDiam/2, r = diameter - chamferDiam/2, $fn = fn);
    // Half-sphere cylinder (body) "back"
    translate([0, 0, 0])
        scale([0.5, 1, 1])
            rotate([0, 90, 0])
                sphere(diameter, $fn = fn);
    // Hinge pin
    translate([originalLen - diameter * 0.7 - 0.8, 0, 0])
        scale([1, 0.7, 0.7])
            rotate([0, 90, 0])
                sphere(diameter, $fn = fn);

    //// Connection to box with round chamfer on the hinge pin side
    difference()  {
        translate([0, 0, -diameter])
            cube([len, diameter + 2*cHingeOfst, diameter]);
        translate([len, diameter/2, -diameter])
            rotate([90, -90, 0])
                RoundChamferMold(radius = chamferDiam, width = diameter + 0.6);
    }
}

module MaleHinge (outDx, outDz, thickZ)  {
    gapAdjust = cHingePinBodyLen + cHingeHoleBodyLen + cHingeGap - 1;

    translate([-outDx/2 + gapAdjust, 0, 0])
        scale([-1, 1, 1])
            HalfMaleHinge(cHingePinBodyLen, outDz);
    translate([+outDx/2 - gapAdjust, 0, 0])
            HalfMaleHinge(cHingePinBodyLen, outDz);
}


module HalfFemaleHinge (len, diameter)  {
    fn = 40;
    chamferDiam = 1.4;
    originalLen = len;
    len = len;

    //// Body block
    difference()  {
        union()  {
            // Cylindrical body
            rotate([0, 90, 0])
                cylinder(h = len, r = diameter, $fn = fn);
            // Round chamfer of the cylinder (body) "front" (a torus)
            translate([len, 0, 0])  {
                rotate([0, 90, 0])
                    rotate_extrude($fn = 40, convexity = 2)
                        translate([diameter - chamferDiam/2, 0, 0])
                            circle(d = chamferDiam, $fn = fn/2);
            }
            // Cover up the torus hole
            translate([len, 0, 0])
                rotate([0, 90, 0])
                    cylinder(h = chamferDiam/2, r = diameter - chamferDiam/2, $fn = fn);

            //// Connection to box with round chamfer on the hinge pin side
            difference()  {
                translate([0, 0, -diameter])
                    cube([originalLen + chamferDiam/2, diameter + 2*cHingeOfst, diameter]);
                translate([originalLen + chamferDiam/2, diameter/2, -diameter])
                    rotate([90, -90, 0])
                        RoundChamferMold(chamferDiam, diameter + 0.5);
            }
        }
        translate([0, diameter/2, -diameter])
            rotate([90, 0, 0])
                RoundChamferMold(cBoxBodyChamferDiam, diameter * 2 + 0.6);

        // Hinge pin negative
        translate([originalLen + diameter * 0.7 - 0.2, 0, 0])
            scale([1, 0.71, 0.71])
                rotate([0, 90, 0])
                    sphere(diameter, $fn = fn);
    }
}


module FemaleHinge (outDx, outDz, thickZ)  {
    translate([outDx, 0, 0])
        scale([-1, 1, 1])
            HalfFemaleHinge(cHingeHoleBodyLen, outDz);
    translate([0, 0, 0])
            HalfFemaleHinge(cHingeHoleBodyLen, outDz);
}


module BoxHalfFrame (inDx, inDy, inDz, thickX, thickFront, thickBack, thickZ)  {
    outDx = inDx + thickX * 2;
    outDy = inDy + thickFront + thickBack;
    outDz = inDz + thickZ;
    fingerOpenWidth = inDx * cFingerOpenWidth;
    translate([-outDx/2, -outDy/2 + thickFront/2, 0])  {
        difference()  {
            union()  {
                translate([0, 0, -thickZ])
                    cube([outDx, outDy, outDz]);
                translate([outDx/2, -thickFront/2 + outDz/2 + 0.15, outDz/4 - thickZ + 0.038])
                    scale([1, 0.7, 1])
                        rotate([90, 0, -90])
                           RoundChamferMold(outDz - 0.2, outDx, 0.45);
            }
            union()  {
            translate([thickX, thickBack, thickZ + 0.05])
                cube([inDx, inDy, inDz + 0.1]);
            // Round corners
            translate([0, outDy, outDz * 0.5 - thickZ])
                rotate([0, 0, -90])
                    RoundChamferMold(radius = 4, width = outDz + thickZ*2);
            translate([outDx, outDy, outDz * 0.5 - thickZ])
                rotate([0, 0, 180])
                    RoundChamferMold(radius = 4, width = outDz + thickZ*2);
            // Reentrance to put fingers to open
            translate([(outDx - fingerOpenWidth) / 2, outDy, inDz])
                rotate([0, 90, 0])
                    cylinder(h = fingerOpenWidth, r = outDz * 0.8, $fn = 40);
            a = outDx - fingerOpenWidth;
            translate([a / 2 + 0.1, outDy, inDz])
                rotate([0, 90, 0])
                    semisphere(outDz * 2 * 0.8);
            translate([a / 2 + fingerOpenWidth - 0.1, outDy, inDz])
                rotate([0, -90, 0])
                    semisphere(outDz * 2 * 0.8);
            }
            // Round the main exterior edge that faces the outside (down).
            hingeRadius = outDz;
            curveExtra = 1.5;
            translate([0, outDy/2 - 0.05 - curveExtra/2, -thickZ])
                rotate([90, -90, 180])
                    RoundChamferMold(radius = cBoxBodyChamferDiam, width = outDy + curveExtra);
            translate([outDx, outDy/2 - 0.05 -curveExtra/2, -thickZ])
                rotate([90, 0, 180])
                    RoundChamferMold(radius = cBoxBodyChamferDiam, width = outDy+curveExtra);
        }
    }
}


module BottomWallet (inDx, inDy, inDz, thickX, thickFront, thickBack, thickZ)  {
    outDx = inDx + thickX * 2;
    outDy = inDy + thickFront + thickBack;
    outDz = inDz + thickZ;

    difference()  {
        BoxHalfFrame(inDx, inDy, inDz, thickX, thickFront, thickBack, thickZ);
        // 2 lock holes to keep the half wallet parts closed
        translate([-outDx/2, outDy/2 - cLockDistFromFront,
                   cLockSection/2 + (outDz - thickZ) - cLockSection + 0.35])
            LockHoles(outDx);
        // Design version, in binary, coded as holes.
        if (cStampVersion == "yes")  {
            holeDept = 0.4;
            holeSide = 0.6;
            fingerOpenWidth = inDx * cFingerOpenWidth;
            for (dx = [0:7])  {
                if (cVersionBinaryVector[dx] == 1)
                    translate([dx * holeSide * 2 - fingerOpenWidth/2,
                               outDy/2 - thickFront/2, outDz - holeDept*1.5])
                        cube([holeSide, holeSide, holeDept]);
            }
        }
    }
    // Close lock pins, 2 on the left and 2 on the right.
    translate([0, outDy/2 - cLockDistFromFront - cLockSection/2 + cLockPinWidth/2, -0.15])  {
        innerLeftHoleEdge  = +outDx/2 - cLockDistFromSide - cLockHoleLen;
        innerRightHoleEdge = -outDx/2 + cLockDistFromSide + cLockHoleLen;
        translate([innerRightHoleEdge - 1.6, 0, 0])
            GeneralLockPin(cLockPinWidth, cLockPinLen);
        translate([innerRightHoleEdge - 4.8, 0, 0])
            GeneralLockPin(cLockPinWidth, cLockPinLen);
        translate([innerLeftHoleEdge  + 1.6, 0, 0])
            GeneralLockPin(cLockPinWidth, cLockPinLen);
        translate([innerLeftHoleEdge  + 4.8, 0, 0])
            GeneralLockPin(cLockPinWidth, cLockPinLen);
    }
    // Hinge part
    translate([0, -outDy/2 - outDz/2 + thickZ + 0.4 - cHingeOfst, outDz - thickZ])
        MaleHinge(outDx, outDz, thickZ);
}


module TopWallet (inDx, inDy, inDz, thickX, thickFront, thickBack, thickZ)  {
    outDx = inDx + thickX * 2;
    outDy = inDy + thickFront + thickBack;
    outDz = inDz + thickZ;

    difference()  {
        BoxHalfFrame(inDx, inDy, inDz, thickX, thickFront, thickBack, thickZ);
        // 2 lock holes to keep the half wallet parts closed
        translate([-outDx/2, outDy/2 - cLockDistFromFront,
                   cLockSection/2 + (outDz - thickZ) - cLockSection + 0.35])
            LockHoles(outDx);
    }
    // Close lock pins, 2 on the left and 2 on the right
    translate([0, outDy/2 - cLockDistFromFront + cLockSection/2 - cLockPinWidth/2, -0.15])  {
        innerLeftHoleEdge  = +outDx/2 - cLockDistFromSide - cLockHoleLen;
        innerRightHoleEdge = -outDx/2 + cLockDistFromSide + cLockHoleLen;
        translate([innerRightHoleEdge - cLockPinThickness - cLockLockGap - 1.6, 0, 0])
            GeneralLockPin(cLockPinWidth, cLockPinLen);
        translate([innerRightHoleEdge - cLockPinThickness - cLockLockGap - 4.8, 0, 0])
            GeneralLockPin(cLockPinWidth, cLockPinLen);

        translate([innerLeftHoleEdge + cLockPinThickness + cLockLockGap + 1.6, 0, 0])
            GeneralLockPin(cLockPinWidth, cLockPinLen);
        translate([innerLeftHoleEdge + cLockPinThickness + cLockLockGap + 4.8, 0, 0])
            GeneralLockPin(cLockPinWidth, cLockPinLen);
    }
    // Hinge part
    translate([-outDx/2, -outDy/2 - outDz/2 + thickZ + 0.4 - cHingeOfst, outDz - thickZ])
        FemaleHinge(outDx, outDz, thickZ);
}


module HolderSet (flip = 1.0)  {
    holderSetDx = GetSDCardHolderLength() * (cCardsX - 1);
    holderSetDy = GetSDCardHolderWidth() * (cCardsY - 1);
    for (row = [0 :cCardsX - 1])  {
        cols = cHoldersCfg[row];
        for (col = [0 :cCardsY - 1])  {
            orient = (cols[col] > 0)? 180 : 0;
            mirror = (cols[col] > 0)? -1 : 1;
            translate([-holderSetDx/2 + row * GetSDCardHolderLength(),
                       -holderSetDy/2 + col * GetSDCardHolderWidth() + 0.05, 0])
                scale([flip, mirror, 1])
                    SDCard(zangle = orient, backHole = cBackHoles);
        }
    }
}


module Wallet ()  {
    inDx = GetSDCardHolderLength() * cCardsX;
    inDy = GetSDCardHolderWidth() * cCardsY;
    translate([0, 0, 0])  {
        BottomWallet(inDx, inDy, GetSDCardHolderHeight(),
                     1,
                     5, 0.1,
                     0.28);
        HolderSet();
    }
    // Top part
    rotate([0, 0, 180])
    translate([0, inDy + 7.6 + cHingeOfst*2, 0])  {
        TopWallet(inDx, inDy, GetSDCardHolderHeight(),
                     1,
                     5, 0.1,
                     0.28);
        HolderSet(-1.0);
    }
}


module ClosedWallet ()  {
    inDx = GetSDCardHolderLength() * cCardsX;
    inDy = GetSDCardHolderWidth() * cCardsY;
    translate([0, 0, 0])  {
        BottomWallet(inDx, inDy, GetSDCardHolderHeight(),
                     1,
                     5, 0.1,
                     0.28);
        HolderSet();
    }
    // Top part
    rotate([180, 0, 180])
    translate([0, 0.0, -2*GetSDCardHolderHeight() -.02])  {
        TopWallet(inDx, inDy, GetSDCardHolderHeight(),
                     1,
                     5, 0.1,
                     0.28);
        HolderSet(-1.0);
    }
}

module _SDCardWalletLib_Test ()  {
    rotate([0, 180,0])
    intersection()  {
        translate([0, 25, 0]) Wallet();
        // Leave only the hinge part
        //translate([0, 25/2-4, 0]) cube([45, 22, 15], center = true);
        /*/ Remove front to see the lock pins
        translate([0, 25, 0]) ClosedWallet();
        translate([0, 29, 0]) cube([45, 22, 15], center = true); /**/
    }
}

//GeneralLockPin(cLockPinWidth, cLockPinLen);
//_SDCardWalletLib_Test();
