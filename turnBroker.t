#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "inventorCore.h"

transient gameUndoBroker: object {
    undoBlockedReason = ''
    undoSuccessMsg = ''
    
    initUndoCheck() {
        undoBlockedReason = '';
        undoSuccessMsg = '';
        return checkUndo();
    }
    
    checkUndo() { return true; }
}

gameTurnBroker: object {
    announceFreeActions = true
    revokedFreeTurn = nil
    hadNegativeOutcome = nil
    freeTurnAlertsRemaining = 2
    freeTurnMsg = 'This was a <<free action>>!'
    freeTurnEndMsg = 'From now-on, you will only be alerted if a <<free action>> was given a cost penalty!'
    freeTurnPenaltyMsg = 'These particular consequences have cost you a turn! Normally, you would have gotten this for FREE!'
    
    hadRevokedFreeAction(action) {
        return action.turnsTaken == 0 && revokedFreeTurn;
    }
    
    actionWasCostly(action) {
        return (action.turnsTaken > 0 || hadRevokedFreeAction(action)) && !action.actionFailed;
    }
    
    actionWasNegative(action) {
        return action.actionFailed || hadNegativeOutcome;
    }
    
    beforeTurnHandling(action) { return true; }
    
    beforeTurnCosts(action) { }
    afterTurnCosts(action) { }
    
    finishActionStatus(action, wasNegative) { }
    
    processTurnCosts(action) {
        beforeTurnCosts(action);
        
        local wasCostly = actionWasCostly(action);
        
        if (wasCostly) {
            if (revokedFreeTurn && announceFreeActions) {
                "<.p><i>(<<freeTurnPenaltyMsg>>)</i>";
            }
            advanceTurns(action);
            handleCostlyTurn(action);
        }
        else {
            handleFreeTurnNotification(action);
            handleFreeTurn(action);
        }
        
        afterTurnCosts(action);
        
        if (wasCostly) {
            local npcTurnCount = action.turnsTaken;
            if (npcTurnCount < 0) npcTurnCount = 1;
            for (local i = 0; i < npcTurnCount; i++) {
                handleNPCTurn(action);
            }
        }
        
        finishActionStatus(action, actionWasNegative(action));
        
        if (hadRevokedFreeAction(action)) libGlobal.totalTurns++;
        
        revokeFreeTurn = nil;
        hadNegativeOutcome = nil;
    }
    
    advanceTurns(action) { }
    handleCostlyTurn(action) { }
    handleFreeTurn(action) { }
    handleNPCTurn(action) { }
    
    handleFreeTurnNotification(action) {
        if (freeTurnAlertsRemaining > 0) {
            if (announceFreeActions) {
                if (freeTurnAlertsRemaining > 1) {
                    "<.p><i>(<<freeTurnMsg>>)</i><.p>";
                }
                else {
                    "<.p><i>(<<freeTurnEndMsg>>)</i><.p>";
                }
            }
            freeTurnAlertsRemaining--;
        }
    }
    
    revokeFreeTurn() {
        revokedFreeTurn = true;
    }
    
    makeNegative() {
        hadNegativeOutcome = true;
    }
}

modify Action {
    turnSequence() {
        if (!gameTurnBroker.beforeTurnHandling(self)) return;
        inherited();
        gameTurnBroker.processTurnCosts(self);
    }
}

modify Inventory {
    turnsTaken = 0
}

modify Examine {
    turnsTaken = 0
}

modify Look {
    turnsTaken = 0
}
