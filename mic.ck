@import "Rave"

// perform timbre transfer on your microphone input,
// voice to house music!
adc => Rave r(Rave.downtempoHouseModel()) => dac;

eon => now;