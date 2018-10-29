/*
SktScanAPI.h
Main header file for Socket ScanAPI
(c) Socket Mobile, Inc.
*/

#include "SktScanErrors.h"
#include "SktScanPropIds.h"
#include "SktScanTypes.h"
#include "SktScanDeviceType.h"
#include "SktScanCore.h"

// if there is any modification in the include
// files above then this version needs to be updated
// to reflect a change in ScanAPI Interface.
// version 1.0.0 original release
// version 1.0.1 data editing properties
// version 1.0.2 Stand Config property
// NOTE THE NEW VERSION SCHEME REMOVE ONE DIGIT FROM THE PREVIOUS VERSION FORMAT
// DEFINITION.
// OLD FORMAT: Major.Middle.Minor.Revision
// NEW FORMAT: Major.Minor.Revision.Build  (The Revision and Build are automatically 
//  updated during the build)
// version 1.3.0 Version structure new format (dwMajor,dwMiddle,dwMinor,dwBuild: 4 DWORD)
// version 1.4.0 adding the 8Qi device type
// version 1.5.0 adding the kSktScanTriggerContinuousScan (for iOS SoftScan only) 
#define SKTSCANAPIINTERFACE_VERSION "1.5.0"

