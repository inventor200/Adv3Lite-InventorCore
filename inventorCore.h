#define __GEN_GAME_VERSION(num, stage, name, patch) toString(num) + '.' + toString(stage) + '.' + toString(patch) + ' ' + name + ' (Patch ' + toString(patch) + ')'
#define __GAME_VERSION __GEN_GAME_VERSION(__GAME_VERSION_RELEASE_NUMBER, __GAME_VERSION_STAGE_NUMBER, __GAME_VERSION_STAGE_NAME, __GAME_VERSION_PATCH_NUMBER)

#define gFormatForScreenReader transScreenReader.formatForScreenReader
#define gActorIsPlayer (gActor == gPlayerChar)

string template <<wait for player>> waitForPlayer;
string template <<remember>> formatRemember;
string template <<note>> formatNote;
string template <<warning>> formatWarning;

string template <<free action>> freeAction;
string template <<free actions>> freeActions;

// Macro keyword "cached" acts like "new" for preinit cache data.
// If this is a debug build, then the data is not transient, to
// allow the use of save files.
// In release versions, it WILL be transient, slimming down saves
// quite a bit.
#ifdef __DEBUG
#define cached new
#define __ALLOW_DEBUG_ACTIONS true
#else
#define cached new transient
#define __ALLOW_DEBUG_ACTIONS nil
#endif

#ifdef __DEBUG
#define __DEBUG_PREFS nil
#else
#define __DEBUG_PREFS nil
#endif

#define hyperDir(dirName) \
    (exitLister.enableHyperlinks ? \
        aHrefAlt( \
            hyperDirCore.getDefaultTravelAction() + \
            ' ' + dirName, \
            dirName, \
            dirName \
        ) : dirName)

#define gMoverFrom(actor) (gMoverCore.cacheMover(actor))
#define gMover (gMoverCore.cachedMover)
#define gMoverLocation (gMoverCore.getMoverLocation())
#define gMoverLocationFor(actor) (gMoverCore.getMoverLocation(actor))

#ifdef __DEBUG
#define __SIMPLIFICATION_DEBUG nil
#define __INVENTOR_REACH_DEBUG nil
#else
#define __SIMPLIFICATION_DEBUG nil
#define __INVENTOR_REACH_DEBUG nil
#endif

#define __USE_INVENTOR_REACH_MOD true

#define DefineDistComponent(ComponentClassName) \
    modify Thing { \
        includeDistComp##ComponentClassName = nil \
        hasDistComp##ComponentClassName = nil \
    } \
    prototype##ComponentClassName: DistributedComponent \
        includeMeProp = &includeDistComp##ComponentClassName \
        hasMeProp = &hasDistComp##ComponentClassName \
        originalPrototype = prototype##ComponentClassName

#define DefineDistComponentFor(ComponentClassName, TargetClassName) \
    modify TargetClassName { \
        includeDistComp##ComponentClassName = true \
        hasDistComp##ComponentClassName = nil \
    } \
    prototype##ComponentClassName: DistributedComponent \
        includeMeProp = &includeDistComp##ComponentClassName \
        hasMeProp = &hasDistComp##ComponentClassName \
        targetParentClass = TargetClassName \
        originalPrototype = prototype##ComponentClassName

#define DefineDistSubComponent(ComponentClassName, mySubReferenceProp) \
    modify Thing { \
        includeDistComp##ComponentClassName = nil \
        hasDistComp##ComponentClassName = nil \
        mySubReferenceProp = nil \
    } \
    prototype##ComponentClassName: DistributedSubComponent \
        includeMeProp = &includeDistComp##ComponentClassName \
        hasMeProp = &hasDistComp##ComponentClassName \
        subReferenceProp = &mySubReferenceProp \
        originalPrototype = prototype##ComponentClassName

#define DefineDistSubComponentFor(ComponentClassName, TargetClassName, mySubReferenceProp) \
    modify TargetClassName { \
        includeDistComp##ComponentClassName = true \
        hasDistComp##ComponentClassName = nil \
        mySubReferenceProp = nil \
    } \
    prototype##ComponentClassName: DistributedSubComponent \
        includeMeProp = &includeDistComp##ComponentClassName \
        hasMeProp = &hasDistComp##ComponentClassName \
        targetParentClass = TargetClassName \
        subReferenceProp = &mySubReferenceProp \
        originalPrototype = prototype##ComponentClassName

#define IncludeDistComponent(ComponentClassName) \
    includeDistComp##ComponentClassName = true

#define basicHandleTabProperties \
    distOrder = 2 \
    isDecoration = true \
    addParentVocab(_lexParent) { \
        if (_lexParent != nil) { \
            local lexParentWords = _lexParent.name.split(' '); \
            local startIndex = 1; \
            if (lexParentWords[1] == 'the' || lexParentWords[1] == 'a') { \
                startIndex = 2; \
            } \
            local weakLexParentWords = lexParentWords[startIndex] + '[weak]'; \
            for (local i = startIndex + 1; i <= lexParentWords.length; i++) { \
                weakLexParentWords += ' ' + lexParentWords[i] + '[weak]'; \
            } \
            addVocab(';' + weakLexParentWords + ';'); \
        } \
    }

#define basicHandleProperties \
    basicHandleTabProperties \
    decorationActions = [Examine, Push, Pull, Taste, Lick] \
    matchPhrases = ['handle', 'bar', 'latch'] \
    dobjFor(Taste) { \
        verify() { } \
        check() { } \
        action() { } \
        report() { \
            if (handleAccessRestrictions.lickedHandle) { \
                "Tastes like it's been well-used. "; \
            } \
            else { \
                handleAccessRestrictions.lickedHandle = true; \
                "As {my} tongue leaves its surface, subtle flashbacks of someone \
                else's memories pass through {my} mind, like muffled echoes.\b \
                {I} think {i} remember a name, reaching out from the whispers:\b \
                <center><i><q>Rovarsson...</q></i></center>\b \
                {I}{'m} not really sure what to make of that. Probably should not \
                lick random handles anymore, though. "; \
            } \
        } \
    }

#define hatchHandlerProperties \
    hatch = nil \
    preCreate(_lexParent) { \
        hatch = getLikelyHatch(_lexParent); \
        if (hatch != nil) { \
            owner = hatch; \
            ownerNamed = true; \
        } \
    } \
    postCreate(_lexParent) { \
        addParentVocab(hatch); \
    } \
    remapReach(action) { \
        return hatch; \
    }

#define handleActions(targetAction, actionTarget) \
    dobjFor(Push) { \
        verify() { \
            if (!isPushable) illogical(cannotPushMsg); \
        } \
        check() { } \
        action() { \
            doInstead(targetAction, actionTarget); \
        } \
        report() { } \
    } \
    dobjFor(Pull) { \
        verify() { \
            if (!isPullable) illogical(cannotPullMsg); \
            handleAccessRestrictions.handleAccessibilityFor(gActor); \
        } \
        check() { } \
        action() { \
            doInstead(targetAction, actionTarget); \
        } \
        report() { } \
    }

#define tinyDoorHandleProperties \
    vocab = 'handle;metal[weak] pull[weak];latch' \
    desc = "A tiny pull latch, which can open \
        <<hatch == nil ? 'containers' : hatch.theName>>. " \
    basicHandleProperties \
    cannotPushMsg = '{That dobj} {is} not a push latch. ' \
    cannotPullMsg = '{That dobj} {is} not a pull latch. ' \
    isPullable = true \
    getMiscInclusionCheck(obj, normalInclusionCheck) { \
        return normalInclusionCheck && !obj.ofKind(Door) && (getLikelyHatch(obj) != nil); \
    } \
    hatchHandlerProperties \
    handleActions(Open, hatch)

HomeHaver template 'vocab' @location? "basicDesc"?;

// Define other decorative walls to complement a specific wall
#define otherWallVocabFor(directionList) \
    vocab = perInstance( \
        self.getOtherWallsVocab(directionList) \
    ) \
    matchPhrases = perInstance( \
        self.getWallMatchPhrases(directionList, true) \
    )

// Use this if you want to include a special term for the adjectives list
#define otherWallPartVocabFor(directionList, specificPartAdj) \
    vocab = perInstance( \
        self.getOtherWallsVocab(directionList, specificPartAdj) \
    ) \
    matchPhrases = perInstance( \
        self.getWallMatchPhrases(directionList, true) \
    )
