include <SDCardWalletLib.scad>;

//// Overwrite configuration variables from SDCardWalletLib:

cHoldersCfg = [ [0], [0] ];
cFingerOpenWidth = 0.40;    // %/100 of X axis box len
cLockDistFromSide = 8;

//// Build it!
Wallet();
