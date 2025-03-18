@import "Rave"

// Blit will be timbre transferred into a cello
Blit s => ADSR e => Rave rave(Rave.celloModel()) => dac;

.8 => s.gain;

// set adsr
e.set( 5::ms, 3::ms, .5, 5::ms );

// an array
[ 0, 2, 4, 7, 9, 11 ] @=> int hi[];

// infinite time loop
while( true )
{
    // frequency
    Std.mtof( 36 + Math.random2(0,2) * 12 +
        hi[Math.random2(0,hi.size()-1)] ) => s.freq;

    // harmonics
    Math.random2( 2, 5 ) => s.harmonics;

    // key on
    e.keyOn();
    // advance time
    160::ms => now;
    // key off
    e.keyOff();
    // advance time
    5::ms => now;
}
