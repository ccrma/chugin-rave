#--------------------------------------------------------------
# notarize.sh
# pre-condition: codesigned, packaged, also developer
#     credentials are loaded into the environment
# post-condition: notarizes an installer file, staples the
# notarization, and notarizes the stapled installer
#--------------------------------------------------------------

# where the Rave build can be found
RAVE_DIR=${1}

echo "notarizing Rave.chug installer..."
./notarize.sh Rave.chug.pkg

echo "stapling Rave.chug installer..."
./staple.sh Rave.chug.pkg

echo "notarizing Rave.chug installer..."
./notarize.sh Rave.chug.pkg
