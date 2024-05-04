#--------------------------------------------------------------
# codesign.sh
#--------------------------------------------------------------

# where the Rave build can be found
RAVE_DIR=${1}

# remove code signature from chugin and dylibs
codesign --remove-signature ${RAVE_DIR}/*

# codesign Rave.chug
codesign --deep --force --verify --verbose --timestamp --options runtime --entitlements rave.entitlements --sign "Developer ID Application" ${RAVE_DIR}/*
