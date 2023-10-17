#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "inventorCore.h"

/* TRINKETS
 * by Joseph Cramsey
 * 
 * A Thing that can be interacted with, but has limited listing
 * behaviors, and is excluded from _ ALL actions.
 */

// Modify Listen to obey restrictions placed on ALL.
modify Listen {
	execAction(cmd) {
        local s_list = gActor.getOutermostRoom.allContents.subset({
            x: Q.canHear(gActor,x) && x.isProminentNoise
        });
        
        s_list = s_list.getUnique();
        
        local r_list = getRemoteSoundList().getUnique() - s_list;
			
        local somethingDisplayed = nil;
			
        foreach (local cur in s_list) {
            if (!cur.forceListenSuccess) {
                if (cur.hideFromAll(self)) continue;
            }
			if (cur.displayAlt(&listenDesc)) {
			    somethingDisplayed = true;
            }
		}

        local validRemoteSounds = [];

        foreach (local cur in r_list) {
            if (!cur.forceListenSuccess) {
                if (cur.hideFromAll(self)) continue;
            }
			validRemoteSounds += cur;
		}
		
		if (listRemoteSounds(validRemoteSounds)) {
			somethingDisplayed = true;
        }
			
        if (!somethingDisplayed) {
            "{I} hear{s/d} nothing out of the ordinary.<.p>";
        }
    }
}

// Modify Smell to obey restrictions placed on ALL.
modify Smell {
    execAction(cmd) {
        local s_list = gActor.getOutermostRoom.allContents.subset({
            x: Q.canSmell(gActor, x)  &&  x.isProminentSmell
        });
        
        local r_list = getRemoteSmellList().getUnique() - s_list;
        
        local somethingDisplayed = nil;
        
        foreach (local cur in s_list) {
            if (!cur.forceSmellSuccess) {
                if (cur.hideFromAll(self)) continue;
            }
            if (cur.displayAlt(&smellDesc)) {
                somethingDisplayed = true;
            }
        }

        local validRemoteSmells = [];

        foreach (local cur in r_list) {
            if (!cur.forceSmellSuccess) {
                if (cur.hideFromAll(self)) continue;
            }
			validRemoteSmells += cur;
		}
        
        if (listRemoteSmells(validRemoteSmells)) {
            somethingDisplayed = true;
        }
             
        if (!somethingDisplayed) {
            "{I} {smell} nothing out of the ordinary.<.p>";
        }
    }
}

modify Thing {
    // Only apply ALL to me if I'm in inventory
    pleaseIgnoreMe = nil
    // Never apply ALL to me
    alwaysHideFromAll = (isDecoration)
    // Only allow EXAMINE ALL for me
    onlyExamineAll = (isDecoration)
    // Always succeed for LISTEN
    forceListenSuccess = nil
    // Always succeed for SMELL
    forceSmellSuccess = nil

    hideFromAll(action) {
        if (action.ofKind(ListenTo) && forceListenSuccess) {
            return nil;
        }

        if (action.ofKind(SmellSomething) && forceSmellSuccess) {
            return nil;
        }

        if (alwaysHideFromAll) {
            return true;
        }

        local isHeld = isHeldBy(gPlayerChar);

        if (onlyExamineAll) {
            if (isOrIsIn(gPlayerChar) && !examined) return nil;
            return !action.ofKind(Examine);
        }

        // If the object is set to be ignored, then ALL only applied for inventory
        if (pleaseIgnoreMe) {
            return !isHeld;
        }

        // Don't bother with anyone's clothing
        if (isWearable && wornBy != nil) {
            return true;
        }

        // Skip SubComponents
        if (self.ofKind(SubComponent)) {
            return true;
        }

        // Actor inventory and parts need special handling
        local containingActor = nil;
        if (!self.ofKind(Actor)) {
            local simpleObj = InventorSpecial.simplifyComplexObject(self);
            if (simpleObj != nil) {
                if (simpleObj.location != nil) {
                    if (simpleObj.location.ofKind(Actor)) {
                        containingActor = simpleObj.location;
                    }
                }
            }
        }

        // Skip potential body parts
        if (containingActor != nil && isFixed) {
            return true;
        }
        // Do not spy into other inventories with ALL
        if (containingActor != gPlayerChar) {
            return true;
        }

        // Ignore yourself
        if (self == gPlayerChar) return true;

        // Simple examination is fine
        if (action.ofKind(Examine)) return nil;

        // For any other senses, we need the player to be more specific.
        if (
            action.ofKind(ListenTo) &&
            action.ofKind(Feel) &&
            action.ofKind(Taste) &&
            action.ofKind(SmellSomething)
        ) {
            return true;
        }

        // Skip obvious problems
        if (action.ofKind(Open) || action.ofKind(Close)) return !isOpenable;
        if (action.ofKind(Take) || action.ofKind(TakeFrom)) return !isTakeable;
        if (action.ofKind(Wear) || action.ofKind(Doff)) return !isWearable;

        // Player has full control over inventory
        return !isHeld;
    }
}

modify Noise {
    forceListenSuccess = true
}

modify Odor {
    forceSmellSuccess = true
}

modify SubComponent {
    alwaysHideFromAll = true
    onlyExamineAll = true
}

modify Platform {
    pleaseIgnoreMe = true
}

modify Booth {
    pleaseIgnoreMe = true
}

class Trinket: Thing {
    // This property works in both Adv3 and Adv3Lite
    isListed = (!canBeIgnored())

    // Adv3Lite properties
    inventoryListed = true
    lookListed = (isListed)
    examineListed = true
    searchListed = true

    // Adv3 properties
    isListedInInventory = true
    isListedInContents = true

    // Stuff for obvious actions
    doNotSuggestTake = true

    // This check works in both Adv3 and Adv3Lite!
    hideFromAll(action) {
        return canBeIgnored() || inherited(action);
    }

    // The bit that handles the actual logic.
    // This ALSO works in both Adv3 and Adv3Lite!
    canBeIgnored() {
        // If we are exposed, in the middle of the room, then
        // we cannot be ignored.
        if (location == getOutermostRoom()) {
            return nil;
        }

        // Allow actions like DROP ALL if we are being carried.
        if (isHeldBy(gPlayerChar)) {
            return nil;
        }

        // Otherwise, pay us no mind in X ALL.
        return true;
    }
}
