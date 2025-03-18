@import "Chumpinate"
@import "Rave_ub/Rave"

Rave.version() => string version;

// instantiate a Chumpinate package
Package pkg("Rave");

// Add our metadata...
"Nick Shaheed" => pkg.authors;

"https://github.com/ccrma/chugin-rave" => pkg.homepage;
"https://github.com/ccrma/chugin-rave" => pkg.repository;

"Creative Commons Attribution-NonCommercial 4.0 International" => pkg.license;
"A UGen to load and synthesize real-time audio from variational autoencoder models. Based on IRCAM's RAVE (Realtime Audio Variational autoEncoder) by Caillon and Esling. (See https://github.com/acids-ircam/RAVE for more info.)" => pkg.description;

["RAVE", "UGen", "machine learning", "AI", "VAE"] => pkg.keywords;

// generate a package-definition.json
// This will be stored in "Chumpinate/package.json"
"./" => pkg.generatePackageDefinition;

<<< "Defining version " + version >>>;;

// Now we need to define a specific PackageVersion for test-pkg
PackageVersion ver("Rave", version);

"10.2" => ver.apiVersion;

"1.5.5.0" => ver.languageVersionMin;

"mac" => ver.os;
"universal" => ver.arch;

// The chugin file
ver.addFile("Rave_ub/Rave.chug");
ver.addFile("models/rave_chafe_data_rt.ts", "models");
ver.addFile("models/downtempo_house.ts", "models");
ver.addFile("Rave_ub/libc10.dylib");
ver.addFile("Rave_ub/libfbjni.dylib");
ver.addFile("Rave_ub/libpytorch_jni.dylib");
ver.addFile("Rave_ub/libshm.dylib");
ver.addFile("Rave_ub/libtorch_cpu.dylib");
ver.addFile("Rave_ub/libtorch_global_deps.dylib");
ver.addFile("Rave_ub/libtorch_python.dylib");
ver.addFile("Rave_ub/libtorch.dylib");
ver.addFile("Rave_ub/libomp.dylib");
ver.addFile("Rave_ub/libbackend_with_compiler.dylib");
ver.addFile("Rave_ub/libiomp5.dylib");
ver.addFile("Rave_ub/libjitbackend_test.dylib");
ver.addFile("Rave_ub/libtorchbind_test.dylib");

ver.addExampleFile("lfo.ck");
ver.addExampleFile("rave_test.ck");
ver.addExampleFile("help.ck");
ver.addExampleFile("mic.ck");
ver.addExampleFile("blit.ck");

// The version path
"chugins/Rave/" + ver.version() + "/" + ver.os() + "/Rave.zip" => string path;

<<< path >>>;

// wrap up all our files into a zip file, and tell Chumpinate what URL
// this zip file will be located at.
ver.generateVersion("./", "Rave_mac", "https://ccrma.stanford.edu/~nshaheed/" + path);

chout <= "Use the following commands to upload the package to CCRMA's servers:" <= IO.newline();
chout <= "ssh nshaheed@ccrma-gate.stanford.edu \"mkdir -p ~/Library/Web/chugins/Rave/"
      <= ver.version() <= "/" <= ver.os() <= "\"" <= IO.newline();
chout <= "scp Rave_mac.zip nshaheed@ccrma-gate.stanford.edu:~/Library/Web/" <= path <= IO.newline();

// Generate a version definition json file, stores this in "chumpinate/<VerNo>/Chumpinate_mac.json"
ver.generateVersionDefinition("Rave_mac", "./" );