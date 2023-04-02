#!/sbin/sh

#
# NDD NetTune SMF installation.
# Yuri Voinov (C) 2009-2021
#
# ident "@(#)nettune_smf_inst.sh    1.1    10/28/09 YV"
#

#############
# Variables #
#############

PROGRAM_NAME="NetTune"
SCRIPT_NAME="ndd-nettune"
CONFIG_FILE="ndd.conf"
CONFIG_DIR="/etc"
SMF_XML="$SCRIPT_NAME"".xml"
SMF_DIR="/var/svc/manifest/network"
SVC_MTD="/lib/svc/method"

# OS utilities  
CHOWN=`which chown`
CHMOD=`which chmod`
COPY=`which cp`
CUT=`which cut`
ECHO=`which echo`
GETENT=`which getent`
GROUPADD=`which groupadd`
ID=`which id`
SVCCFG=`which svccfg`
SVCS=`which svcs`
UNAME=`which uname`

OS_VER=`$UNAME -r|$CUT -f2 -d"."`
OS_NAME=`$UNAME -s|$CUT -f1 -d" "`
OS_FULL=`$UNAME -sr`
ZONE=`$ZONENAME`

###############
# Subroutines #
###############

os_check ()
{
 if [ "$OS_NAME" != "SunOS" ]; then
  $ECHO "ERROR: Unsupported OS $OS_NAME. Exiting..."
  exit 1
 elif [ "$OS_VER" -lt "10" ]; then
  $ECHO "ERROR: Unsupported $OS_NAME version $OS_VER. Exiting..."
  exit 1
 fi
}

root_check ()
{
 if [ ! `$ID | $CUT -f1 -d" "` = "uid=0(root)" ]; then
  $ECHO "ERROR: You must be super-user to run this script."
  exit 1
 fi
}

##############
# Main block #
##############

# Pre-inst checks
# OS version check
os_check

# Superuser check
root_check

$ECHO "-----------------------------------------------"
$ECHO "- NDD $PROGRAM_NAME SMF service will be install now -"
$ECHO "-                                             -"
$ECHO "- Press <Enter> to continue, or <Ctrl+C> to   -"
$ECHO "-                   cancel                    -"
$ECHO "-----------------------------------------------"
read p

# Copy SMF files and install service
$ECHO "Copying $PROGRAM_NAME SMF files..."
if [ -f "$SCRIPT_NAME" -a -f "$SMF_XML" -a -f "$CONFIG_FILE" ]; then

 # Copy SMF method
 $COPY $SCRIPT_NAME $SVC_MTD
 $CHMOD 555 $SVC_MTD/$SCRIPT_NAME

 # Copy service manifest
 $COPY $SMF_XML $SMF_DIR

 # Copy config file
 $COPY $CONFIG_FILE $CONFIG_DIR

 # Make needful permissions fo files
 $CHOWN root:sys $SVC_MTD/$SCRIPT_NAME
 $CHOWN root:sys $SMF_DIR/$SMF_XML
 $CHOWN root:sys $CONFIG_DIR/$CONFIG_FILE

 # Validate and import service manifest
 $SVCCFG validate $SMF_DIR/$SMF_XML>/dev/null 2>&1
 retcode=`$ECHO $?`
 case "$retcode" in
  0) $ECHO "*** XML service descriptor validation successful";;
  *) $ECHO "*** XML service descriptor validation has errors";;
 esac
 $SVCCFG import ./$SMF_XML>/dev/null 2>&1
 retcode=`$ECHO $?`
 case "$retcode" in
  0) $ECHO "*** XML service descriptor import successful";;
  *) $ECHO "*** XML service descriptor import has errors";;
 esac
else
 $ECHO "ERROR: $PROGRAM_NAME SMF service files not found. Exiting..."
 exit 1
fi

$ECHO "Verify $PROGRAM_NAME SMF installation..."

# View installed service
$SVCS $SCRIPT_NAME

$ECHO "If $PROGRAM_NAME service installed correctly, enable and start it now"

exit 0
##