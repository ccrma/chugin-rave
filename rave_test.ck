@import "Rave"

<<< "rave test (poop)" >>>;

TriOsc s => Rave r => dac;
r.model(me.dir() + "rave_chafe_data_rt.ts");

// while (100::ms => now) <<< r.last() >>>;
1::eon => now;
