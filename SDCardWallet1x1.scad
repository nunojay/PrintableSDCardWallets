include <SDCardWalletLib.scad>;

//// Overwrite configuration variables from SDCardWalletLib:

cHoldersCfg = [ [0] ];
cFingerOpenWidth = 0.32;    // %/100 of X axis box len
cLockDistFromSide = 1.9;

//// Build it!
Wallet();
