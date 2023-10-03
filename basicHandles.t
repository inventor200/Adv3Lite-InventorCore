#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "inventorCore.h"

handleAccessRestrictions: object {
    lickedHandle = nil

    handleAccessibilityFor(actor) {
        //
    }
}

DefineDistComponent(TinyDoorHandle)
    tinyDoorHandleProperties
    getLikelyHatch(obj) {
        if (obj.remapIn != nil) {
            if (obj.remapIn.contType == In && obj.remapIn.isOpenable) {
                return obj.remapIn;
            }
        }
        if (obj.remapOn != nil) {
            if (obj.remapOn.contType == In && obj.remapOn.isOpenable) {
                return obj.remapOn;
            }
        }
        return nil;
    }
;
