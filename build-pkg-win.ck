@import "Chumpinate"
@import "build/Release/Rave.chug"

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

"windows" => ver.os;
"x86_64" => ver.arch;

// The chugin file
ver.addFile("build/Release/Rave.chug");
ver.addFile("models/rave_chafe_data_rt.ts", "models");
ver.addFile("models/downtempo_house.ts", "models");
ver.addFile("build/Release/asmjit.dll");
ver.addFile("build/Release/c10.dll");
ver.addFile("build/Release/fbgemm.dll");
ver.addFile("build/Release/fbjni.dll");
ver.addFile("build/Release/libiomp5md.dll");
ver.addFile("build/Release/libiompstubs5md.dll");
ver.addFile("build/Release/pytorch_jni.dll");
ver.addFile("build/Release/torch.dll");
ver.addFile("build/Release/torch_cpu.dll");
ver.addFile("build/Release/torch_global_deps.dll");
ver.addFile("build/Release/uv.dll");

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
ver.generateVersion("./", "Rave_win", "https://ccrma.stanford.edu/~nshaheed/" + path);

chout <= "Use the following commands to upload the package to CCRMA's servers:" <= IO.newline();
chout <= "ssh nshaheed@ccrma-gate.stanford.edu \"mkdir -p ~/Library/Web/chugins/Rave/"
      <= ver.version() <= "/" <= ver.os() <= "\"" <= IO.newline();
chout <= "scp Rave_win.zip nshaheed@ccrma-gate.stanford.edu:~/Library/Web/" <= path <= IO.newline();

// Generate a version definition json file, stores this in "chumpinate/<VerNo>/Chumpinate_mac.json"
ver.generateVersionDefinition("Rave_win", "./" );