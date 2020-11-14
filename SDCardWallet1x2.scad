include <SDCardWalletLib.scad>;

//// Overwrite configuration variables from SDCardWalletLib:

cHoldersCfg = [ [0, 0] ];
cFingerOpenWidth = 0.24;    // %/100 of X axis box len
cLockDistFromSide = 2.5;

//// Build it!
Wallet();
