#!/bin/bash

# SAXON should point to Saxon HE jar on your system
SAXON=$SAXON_HOME/Saxon-HE-9.9.1-3.jar

CL="java -jar $SAXON -s:$1 -xsl:$2"
# [debug Saxon config] CL="java -jar $SAXON  net.sf.saxon.Transform -versionmsg"

# [debug CL] echo $CL
$CL
