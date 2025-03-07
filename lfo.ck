@import "Rave"

// Use an lfo to modulate the first dimension of the latent space
SndBuf s("special:dope") => Rave encode(Rave.celloModel(), "encode")
                        => Rave decode(Rave.celloModel(), "decode")
			=> dac;

// define our lfo, it modules the first dimension
// (i.e. the first channel of the Rave object) of the
// latent space over time
SinOsc lfo(0.1) => decode.chan(0);

// make homer loop
true => s.loop;

// doh forever...
eon => now;

