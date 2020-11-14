include <SDCardWalletLib.scad>;

//// Overwrite configuration variables from SDCardWalletLib:

cHoldersCfg = [ [0, 0],
                [0, 0],
              ];
cFingerOpenWidth = 0.5;    // %/100 of X axis box len
cLockDistFromSide = 6;

//// Build it!
Wallet();
