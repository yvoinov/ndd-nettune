#!/sbin/sh

#
# NDD NetTune SMF remove.
# Yuri Voinov (C) 2009-2021
#
# ident "@(#)nettune_smf_rmv.sh    1.1    10/28/09 YV"
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
CUT=`which cut`
ECHO=`which echo`
GREP=`which grep`
ID=`which id`
RM=`which rm`
SVCCFG=`which svccfg`
SVCS=`which svcs`
UNAME=`which uname`

OS_VER=`$UNAME -r|$CUT -f2 -d"."`
OS_NAME=`$UNAME -s|$CUT -f1 -d" "`
OS_FULL=`$UNAME -sr`

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

# OS version check
os_check

# Superuser check
root_check

$ECHO "------------------------------------------"
$ECHO "- $PROGRAM_NAME SMF service will be remove now -"
$ECHO "-                                        -"
$ECHO "- Press <Enter> to continue, or <Ctrl+C> -"
$ECHO "-               to cancel                -"
$ECHO "------------------------------------------"
read p

# Remove SMF files
$ECHO "Remove $PROGRAM_NAME SMF files..."
if [ -f $SVC_MTD/$SCRIPT_NAME -o -f $SMF_DIR/$SMF_XML -o -f $CONFIG_DIR/$CONFIG_FILE ]; then
 $SVCCFG delete -f svc:/network/"$SCRIPT_NAME":default>/dev/null 2>&1
 $RM -f $SMF_DIR/$SMF_XML
 $RM -f $SVC_MTD/$SCRIPT_NAME
 $RM -f $CONFIG_DIR/$CONFIG_FILE
else
 $ECHO "ERROR: $PROGRAM_NAME SMF service files not found. Exiting..."
 exit 1
fi

$ECHO "Verify $PROGRAM_NAME SMF uninstallation..."

# Check uninstallation
$SVCS $SCRIPT_NAME>/dev/null 2>&1

retcode=`$ECHO $?`
case "$retcode" in
 0) 
  $ECHO "*** $PROGRAM_NAME SMF service uninstallation process has errors"
  exit 1 
 ;;
 *) 
  $ECHO "*** $PROGRAM_NAME SMF service uninstallation successfuly"
 ;;
esac

exit 0