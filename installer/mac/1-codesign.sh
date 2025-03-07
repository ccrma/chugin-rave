#--------------------------------------------------------------
# codesign.sh
# lipo into universal binary; codesign result
#--------------------------------------------------------------

RAVE_x86_64=build-x86_64
RAVE_arm64=build-arm64
# DEPS=_deps/pytorch-src/lib
DEPS=Release
# don't change this
RAVE_ub=Rave_ub

echo "removing and recreating '${RAVE_ub}' directory..."
rm -rf ${RAVE_ub}
mkdir ${RAVE_ub}

echo "lipo'ing universal binaries..."
lipo -create -output ${RAVE_ub}/Rave.chug ${RAVE_x86_64}/Rave.chug ${RAVE_arm64}/Rave.chug
lipo -create -output ${RAVE_ub}/libc10.dylib ${RAVE_x86_64}/${DEPS}/libc10.dylib ${RAVE_arm64}/${DEPS}/libc10.dylib
lipo -create -output ${RAVE_ub}/libfbjni.dylib ${RAVE_x86_64}/${DEPS}/libfbjni.dylib ${RAVE_arm64}/${DEPS}/libfbjni.dylib
lipo -create -output ${RAVE_ub}/libpytorch_jni.dylib ${RAVE_x86_64}/${DEPS}/libpytorch_jni.dylib ${RAVE_arm64}/${DEPS}/libpytorch_jni.dylib
lipo -create -output ${RAVE_ub}/libshm.dylib ${RAVE_x86_64}/${DEPS}/libshm.dylib ${RAVE_arm64}/${DEPS}/libshm.dylib
lipo -create -output ${RAVE_ub}/libtorch_cpu.dylib ${RAVE_x86_64}/${DEPS}/libtorch_cpu.dylib ${RAVE_arm64}/${DEPS}/libtorch_cpu.dylib
lipo -create -output ${RAVE_ub}/libtorch_global_deps.dylib ${RAVE_x86_64}/${DEPS}/libtorch_global_deps.dylib ${RAVE_arm64}/${DEPS}/libtorch_global_deps.dylib
lipo -create -output ${RAVE_ub}/libtorch_python.dylib ${RAVE_x86_64}/${DEPS}/libtorch_python.dylib ${RAVE_arm64}/${DEPS}/libtorch_python.dylib
lipo -create -output ${RAVE_ub}/libtorch.dylib ${RAVE_x86_64}/${DEPS}/libtorch.dylib ${RAVE_arm64}/${DEPS}/libtorch.dylib

echo "copying architecture-specific dependencies"
echo cp -v ${RAVE_arm64}/${DEPS}/libomp.dylib ${RAVE_ub}
cp -v ${RAVE_arm64}/${DEPS}/libomp.dylib ${RAVE_ub}
cp -v ${RAVE_x86_64}/${DEPS}/libbackend_with_compiler.dylib ${RAVE_ub}
cp -v ${RAVE_x86_64}/${DEPS}/libiomp5.dylib ${RAVE_ub}
cp -v ${RAVE_x86_64}/${DEPS}/libjitbackend_test.dylib ${RAVE_ub}
cp -v ${RAVE_x86_64}/${DEPS}/libtorchbind_test.dylib ${RAVE_ub}/


# dir location of this bash script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# codesign EVERYTHING
# codesign Rave.chug
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/Rave.chug

codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/libbackend_with_compiler.dylib

codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/libjitbackend_test.dylib
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/libtorch_global_deps.dylib
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/libomp.dylib
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/libtorch_python.dylib
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/libpytorch_jni.dylib
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/libtorchbind_test.dylib
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/libc10.dylib
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/libshm.dylib
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/libfbjni.dylib
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/libtorch.dylib
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/libiomp5.dylib
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements ${SCRIPT_DIR}/rave.entitlements --sign "Developer ID Application" ${RAVE_ub}/libtorch_cpu.dylib

# run chumpinate here
chuck -s build-pkg-mac

# codesign the chump file


# # where the Rave build can be found
# RAVE_DIR=${1}

# # remove code signature from chugin and dylibs
# codesign --remove-signature ${RAVE_DIR}/*



echo "Notarizing..."
${SCRIPT_DIR}/notarize.sh Rave_mac.zip
