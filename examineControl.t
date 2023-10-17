#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "inventorCore.h"

#define getActionTarget(actionName) filterRemapActionTarget(remapDobj##actionName)

inventorExamineController: object {
    showObviousActions = true
    lastExaminedObject = nil
    showActionsOnly = nil
    hasShownObviousActions = nil
    usingIobj = nil

    clkObject(obj) {
        gameTurnBroker.wasExamineAction = true;
        if (lastExaminedObject == obj) {
            showActionsOnly = !showActionsOnly;
        }
        else {
            lastExaminedObject = obj;
            showActionsOnly = nil;
        }
        return showActionsOnly;
    }

    handleObviousActionsTutorial() {
        if (!showObviousActions) return;
        if (hasShownObviousActions) return;
        hasShownObviousActions = true;

        """
        <<formatNote()>>
        The author has marked this game as <q>not a puzzler</q>,
        which means that guessing verbs is unnecessary
        for intended play. For this reason, examining something for the
        first time will also list some possible <q>obvious actions</q>.
        \b
        The listed actions are not exhaustive, and simply outline a few general
        expectations for whatever you might find. There might
        still be secret actions, which require traditional experimentation,
        but these are unlikely for game completion.
        Some listed actions might also not be possible, viable, or
        even necessary, depending on the situation.
        \b
        To refresh yourself on the obvious actions for something,
        simply examine it twice in a row.
        You can do this quickly by examining something, and then entering only the
        letter <<abbr('G')>> as your command for the following turn,
        as this is an abbreviation for repeating your last action.
        Alternatively, some interpreters might allow you to
        press the up arrow on your keyboard to copy your previous action.
        <<formatRemember()>>
        This information is intended to
        be known, so obvious actions are not hints.
        <.p>
        """;
    }
}

// We need to grievously modify Examine to inject obvious actions
modify Thing {
    listObviousActions = (!isDecoration)

    // nil will make the object use procedural obvious actions
    obviousActions = nil
    // More actions to add to the procedural/defined list
    // Usually, this is what will be added to, as it's additive-only
    extraObviousActions = nil
    // Something there will be a tool which can be used on other stuff,
    // so we should be able to suggest these actions as well.
    // IMPORTANT: This is a list of strings! Examples:
    // - 'cut (something) with (me)'
    // - 'unlock (something) with (me)'
    // The token "(me)" will be replaced with the name of the object, and
    // the token "(something)" will simply be removed.
    indirectObviousActionStrings = nil
    // Do not list take. This applies to stuff that is not meant for
    // the player to carry, even if it's technically possible.
    doNotSuggestTake = nil
    // For some reason, you can look through stuff by default in Adv3Lite,
    // so we are disabling this here.
    canLookThroughMe = nil

    // We don't want to spam obvious actions, so just show them once,
    // unless we examine it twice in a row.
    listedObviousActions = nil

    noObviousActionsMsg = '{I} {do} not notice any obvious actions for {that dobj}.'

    filterRemapActionTarget(remapResult) {
        if (remapResult == nil) return self;
        return remapResult;
    }

    dobjFor(LookThrough) {
        verify() {
            if (contType == In) {
                logical;
            }
            else if (!canLookThroughMe) {
                illogical(cannotLookThroughMsg);
            }
        }
        action() {
            if (contType == In) {
                nestedAction(LookIn, self);
            }
            else if (!gOutStream.watchForOutput({:handleLookingThrough()})) {
                say(lookThroughMsg);
            }
        }
    }

    // The stuff seen on the other side
    handleLookingThrough() {
        // Override this as needed
    }

    dobjFor(LookIn) {
        preCond = (isTransparent ? [objVisible] : [objVisible, containerOpen])
    }

    dobjFor(Examine) {
        action() {
            local descDisplayed = nil;
            local canPrintActions = printingOfActionsAllowed();
            local examinedTwice = nil;

            if (gPlayerChar == self) {
                // Listing obvious actions for the player seems weird.
                canPrintActions = nil;
            }

            if (canPrintActions) {
                examinedTwice = inventorExamineController.clkObject(self);
            }

            // If we examined twice in a row, then we are likely
            // trying to find the list of obvious actions.
            if (!examinedTwice) {
                if (propType(&inDarkDesc) != TypeNil && !getOutermostRoom.isIlluminated()) {
                    display(&inDarkDesc);
                    return;
                }

                if (gOutStream.watchForOutput({:display(&desc)})) {
                    descDisplayed = true;
                }

                if (gOutStream.watchForOutput({:examineStatus()})) {
                    descDisplayed = true;
                }

                if (!descDisplayed) {
                    "{I} {see} nothing special about {the dobj}. ";
                    descDisplayed = true;
                }
            }

            printObviousActionHandler(descDisplayed, canPrintActions, examinedTwice);

            examined = true;

            if (gActor == gPlayerChar) {
                noteSeen();
            }

            "\n";
        }
    }

    printObviousActionHandler(descDisplayed, canPrintActions, examinedTwice) {
        local printedActions = nil;

        if (canPrintActions) {
            printedActions = gOutStream.watchForOutput({:
                printObviousActions(examinedTwice)
            });
            if (!printedActions && !inventorExamineController.hasShownObviousActions) {
                say('<.p><i>(' + noObviousActionsMsg + ')</i>');
                inventorExamineController.handleObviousActionsTutorial();
                printedActions = true;
            }
        }

        if (!descDisplayed && !printedActions) {
            say(noObviousActionsMsg);
        }
    }

    // This can be overridden for procedural lists
    getObviousActions() {
        local ret = [];

        if (isReadable) {
            ret += Read;
        }

        if (isTakeable && !isFixed) {
            if (isHeldBy(gActor)) {
                ret += Drop;
            }
            else if (!doNotSuggestTake) {
                ret += Take;
            }
        }

        if (isWearable) {
            if (isWornBy(gActor)) {
                ret += Doff;
            }
            else {
                ret += Wear;
            }
        }

        if (isEdible) {
            ret += Eat;
        }
        else if (isDrinkable) {
            ret += Drink;
        }

        local openTarg = getActionTarget(Open);

        if (openTarg.isLocked) {
            if (openTarg.isOpenable) {
                if (!openTarg.isOpen) {
                    ret += Unlock;
                }
            }
            else {
                ret += Unlock;
            }
        }
        else if (openTarg.isOpenable) {
            if (openTarg.isOpen) {
                ret += Close;
            }
            else {
                ret += Open;
                if (openTarg.lockability != notLockable) {
                    ret += Lock;
                }
            }
        }

        local lookInTarg = getActionTarget(PutIn);

        if (lookInTarg.contType == In) {
            if (lookInTarg.isOpenable || !lookInTarg.isOpen || lookInTarg.enclosing) {
                ret += LookIn;
            }
        }

        local getOnTarg = getActionTarget(Board);

        if (getOnTarg.isBoardable) {
            if (getOnTarg.canLieOnMe) {
                ret += LieOn;
            }
            else if (getOnTarg.canSitOnMe) {
                ret += SitOn;
            }
            else {
                ret += Board;
            }
        }

        local getInTarg = getActionTarget(Enter);
        local goThroughTarg = getActionTarget(GoThrough);

        if (getInTarg.isEnterable || goThroughTarg.canGoThroughMe) {
            if (goThroughTarg.canGoThroughMe) {
                ret += GoThrough;
            }
            else {
                ret += Enter;
            }
        }

        local lookThroughTarg = getActionTarget(LookThrough);

        if (lookThroughTarg.canLookThroughMe) {
            if (lookThroughTarg.isOpenable) {
                if (lookThroughTarg.isOpen) {
                    ret += LookThrough;
                }
            }
            else {
                ret += LookThrough;
            }
        }

        return ret;
    }

    getOpenDoorObviousActions() {
        return [GoThrough, Close];
    }

    getClosedDoorObviousActions() {
        if (isLocked) {
            return [Unlock];
        }

        if (lockability != notLockable) {
            return [Open, Lock];
        }

        return [Open];
    }

    getDoorObviousActions() {
        if (isOpen) {
            return getOpenDoorObviousActions();
        }

        return getClosedDoorObviousActions();
    }

    printingOfActionsAllowed() {
        // Make sure we should show obvious actions
        // with the current context, which must only concern
        // a single, specific object. Do not show obvious actions
        // if multiple objects are being targeted in any way at all.
        if (!inventorExamineController.showObviousActions) {
            return nil;
        }

        if (!listObviousActions) {
            return nil;
        }

        if (gCommand == nil) {
            return nil;
        }

        if (gCommand.matchedAll || gCommand.matchedMulti) {
            return nil;
        }

        if (gAction == nil) {
            return nil;
        }

        local grammarTag = 'normal';
        local gobj = gCommand.verbProd;
        if (gobj != nil) {
            gobj = gobj.dobjMatch;
            if (gobj != nil) {
                gobj = gobj.grammarTag;
                if (gobj != nil) {
                    grammarTag = gobj;
                }
            }
        }
        if (grammarTag != 'normal' && grammarTag != 'nonTerminal') {
            return nil;
        }

        return true;
    }

    printObviousActions(examinedTwice) {
        if (listedObviousActions && !examinedTwice) {
            return;
        }

        listedObviousActions = true;

        // Get the list of obvious actions.
        // A value of nil specifically means "default list",
        // while an empty list means none.
        local processedList = [];
        if (obviousActions == nil) {
            processedList = processedList.appendUnique(valToList(getObviousActions()));
        }
        else {
            processedList = processedList.appendUnique(valToList(obviousActions));
        }

        processedList = processedList.appendUnique(valToList(extraObviousActions));
        local indirectList = valToList(indirectObviousActionStrings);

        if (processedList.length + indirectList.length == 0) {
            return;
        }

        local stringList = [];

        for (local i = 1; i <= processedList.length; i++) {
            local vp = processedList[i].getVerbPhrase1(
                true, processedList[i].verbRule.verbPhrase, theName, nil
            ).trim().toLower();
            stringList += formatCommand(vp, longCmd);
        }

        // Don't offer to entertain the player as an indirect object
        if (inventorExamineController.usingIobj != gPlayerChar) {
            local somethingReplaced = '';
            if (inventorExamineController.usingIobj != nil) {
                somethingReplaced = inventorExamineController.usingIobj.theName + ' ';
            }

            for (local i = 1; i <= indirectList.length; i++) {
                local item = indirectList[i].trim().toLower();
                // Replace/Wipe (something) from the string
                item = item.findReplace('(something) ', somethingReplaced);
                // Use the object's name
                item = item.findReplace('(me)', theName);
                stringList += formatCommand(item, longCmd);
            }
        }

        """
        <<formatAlert('Obvious Actions:')>>
        <<createUnorderedList(stringList)>>
        """;

        inventorExamineController.handleObviousActionsTutorial();
    }
}

modify Surface {
    // It's very unlikely the player is meant to take a Surface
    doNotSuggestTake = true
}

modify TravelConnector {
    // Do not make any assumptions for what needs to be done
    obviousActions = []
}

modify Door {
    obviousActions = nil

    getObviousActions() {
        return getDoorObviousActions();
    }
}