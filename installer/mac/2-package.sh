#--------------------------------------------------------------
# package.sh
# lipo into universal binary; create PKG installer file
#--------------------------------------------------------------

RAVE_x86_64=Rave-x86_64
RAVE_arm64=Rave-arm64
# don't change this
RAVE_ub=Rave

# dir location of this bash script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "removing and recreating '${RAVE_ub}' directory..."
rm -rf ${RAVE_ub}
mkdir ${RAVE_ub}

echo "create temp directory mirror install path..."
mkdir -p Rave.tmp/usr/local/lib/chuck

echo "lipo'ing universal binaries..."
# lipo -create -output -$outfile $x86_version $arm_version
lipo -create -output ${RAVE_ub}/Rave.chug ${RAVE_x86_64}/Rave.chug ${RAVE_arm64}/Rave.chug
lipo -create -output ${RAVE_ub}/libc10.dylib ${RAVE_x86_64}/libc10.dylib ${RAVE_arm64}/libc10.dylib
lipo -create -output ${RAVE_ub}/libfbjni.dylib ${RAVE_x86_64}/libfbjni.dylib ${RAVE_arm64}/libfbjni.dylib
lipo -create -output ${RAVE_ub}/libpytorch_jni.dylib ${RAVE_x86_64}/libpytorch_jni.dylib ${RAVE_arm64}/libpytorch_jni.dylib
lipo -create -output ${RAVE_ub}/libshm.dylib ${RAVE_x86_64}/libshm.dylib ${RAVE_arm64}/libshm.dylib
lipo -create -output ${RAVE_ub}/libtorch_cpu.dylib ${RAVE_x86_64}/libtorch_cpu.dylib ${RAVE_arm64}/libtorch_cpu.dylib
lipo -create -output ${RAVE_ub}/libtorch_global_deps.dylib ${RAVE_x86_64}/libtorch_global_deps.dylib ${RAVE_arm64}/libtorch_global_deps.dylib
lipo -create -output ${RAVE_ub}/libtorch_python.dylib ${RAVE_x86_64}/libtorch_python.dylib ${RAVE_arm64}/libtorch_python.dylib
lipo -create -output ${RAVE_ub}/libtorch.dylib ${RAVE_x86_64}/libtorch.dylib ${RAVE_arm64}/libtorch.dylib

echo "copying architecture-specific dependencies"
cp -v ${RAVE_arm64}/libomp.dylib ${RAVE_ub}
cp -v ${RAVE_x86_64}/libbackend_with_compiler.dylib ${RAVE_ub}
cp -v ${RAVE_x86_64}/libiomp5.dylib ${RAVE_ub}
cp -v ${RAVE_x86_64}/libjitbackend_test.dylib ${RAVE_ub}
cp -v ${RAVE_x86_64}/libtorchbind_test.dylib ${RAVE_ub}/

# copy Rave folder into mirrored installed path
# cp -af ${RAVE_ub} Rave.tmp/usr/local/lib/chuck/

# create installer PKG file
# pkgbuild --root Rave.tmp --identifier edu.stanford.chugin.Rave Rave-unsigned.pkg

# run chumpinate here

# codesign the chump file
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements "${SCRIPT_DIR}/Chugin.entitlements" --sign "Developer ID Application" Rave_mac.zip

echo "notarizing PlinkyRev.chug..."
${SCRIPT_DIR}/notarize.sh Rave_mac.zip

# productsign the installer
# productsign --sign "Developer ID Installer" ./Rave-unsigned.pkg ./Rave.chug.pkg

# check signature
# pkgutil --check-signature ./Rave.chug.pkg
