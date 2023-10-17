#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "inventorCore.h"

// Adv3Lite has many useful tricks for helping new or confused players.
// However, my own testing data reveals that they are becoming a hinderance
// for the kinds of games that I want to create, so I need to universally
// expand, rework, or remove a lot of these systems.

// If a player is experimenting and gets hit with any kind of
// "Are you sure you don't need help?" message at any point, it
// is going to come of as incredibly insulting or demoralizing.
// For this reason, we are simply gutting this.
modify playerHelper {
    execute() { }
}

// The body part list was not exhaustive enough, but also the response
// message was way too long and condescending, and became problematic
// when some body parts were used in the game, while others were not.
modify bodyParts {
    vocab = 'body; (my) (your) (his) (her) (their) (its) (this) (left)
    (right); head hand hands ear ears fist fists finger fingers
    thumb thumbs arm arms leg legs foot feet eye eyes face nose mouth
    tooth teeth tongue lip lips knee knees elbow elbows toe toes neck
    chest torso belly butt eyebrow eyebrows cheek cheeks'

    notHereMsg = 'That part of the body is not important for this game. '
}

// Do not alienate players for typing "look here"
modify LookHere {
    execAction(cmd) {
        gActor.getOutermostRoom.lookAroundWithin();
    }
}

// The command "say something" gets annoying when the following handler
// gets activated, because this is a valid attempt, and should be handled
// as something other than a newbie mistake.
modify somethingPreParser {
    safePat = static new RexPattern('<NoCase>^(say)')
    pat = static new RexPattern('<NoCase>(someone|something|somewhere|anyone|anything|anywhere)')

    doParsing(str, which) {
        local ret = rexSearch(safePat, str);
        if (ret != nil) {
            // Player used the SAY command; false alarm.
            return str;
        }

        ret = rexSearch(pat, str);
        if (ret != nil) {
            // These checks are from the original Adv3Lite
            local lst = cmdDict.findWord(ret[3]);
            lst = lst.intersect(Q.scopeList(gPlayerChar));

            // Hit the error message, but reworded.
            if (lst.length == 0) {
                """
                This game struggles to understand commands which
                have unknown or non-specific words (such as <q><<ret[3]>></q>).
                To increase understanding, please refer to specific
                objects, and remember that this game also
                has a very limited vocabulary.
                """;
                return nil;
            }
        }
        return str;
    }
}

// Redirect "say something" to "hello"
modify SayAction {
    exec(cmd) {
        local message = cmd.dobj.name.trim().toLower();
        if (message.startsWith('something') || message.startsWith('anything')) {
            "Saying <q>hello</q> counts as saying something, so {i} tr{ies/ied} that.<.p>";
            Parser.parse('hello');
        }
        else {
            inherited(cmd);
        }
    }
}

// Redirect "say something to person" to "person, hello"
modify SayTo {
    exec(cmd) {
        local message = cmd.iobj.name.trim().toLower();
        if (message.startsWith('something') || message.startsWith('anything')) {
            "Saying <q>hello</q> counts as saying something, so {i} tr{ies/ied} that.<.p>";
            Parser.parse(cmd.dobj.name + ', hello');
        }
        else {
            inherited(cmd);
        }
    }
}

// Expand greetings
modify VerbRule(TalkTo)
    ('greet' | 'say' ('hello'|'hi'|'hallo') 'to' | 'talk' 'to' | 'wave' ('to'|'at')) singleDobj :
;

modify VerbRule(Hello)
    (('say'|'wave'|) ('hello'|'hallo'|'hi')) | 'wave' | 'greetings' :
;

// Expand goodbyes
modify VerbRule(Goodbye)
    ('say'|'wave'|) ('goodbye'|'good-bye'|'good' 'bye'|'bye'|
    'farewell'|'see' ('you'|'ya') ('later'|)|'cya') :
;

// We have defined a USE action,
// which will handle ambiguities with suggestions.
modify usePreParser {
    // Cancel this pre-parser
    doParsing (str, which) {
        return str;
    }
}

VerbRule(Use)
    ('use' | 'utilize') singleDobj
    : VerbProduction
    action = Use
    verbPhrase = 'use/using (what)'
    missingQ = 'what do you want to use'
;

DefineTAction(Use)
    turnsTaken = 0
;

VerbRule(UseOn)
    ('use' | 'utilize') singleDobj ('on' | 'for' | 'with' | 'against') singleIobj
    : VerbProduction
    action = UseOn
    verbPhrase = 'use/using (what) (for what)'
    missingQ = 'what do you want to use; what do you want to use it on'
;

DefineTIAction(UseOn)
    turnsTaken = 0
    resolveIobjFirst = nil
;

modify Thing {
    handleVagueUse() {
        if (inventorExamineController.showObviousActions) {
            """
            <i>(You will need to be a bit more specific with your intent.
            Now examining obvious actions instead...)</i>
            <.p>
            """;
            inventorExamineController.lastExaminedObject = self;
            inventorExamineController.clkObject(self);
            printObviousActionHandler(nil, true, true);
        }
        else {
            """
            You will need to be a bit more specific with your intent.
            This game expects experimentation with verbs as part of the puzzle.
            Use <<formatTheCommand('VERBS', shortCmd)>> to review a list of
            likely verbs that are known by this game.
            """;
        }
    }

    dobjFor(Use) {
        preCond = [touchObj, objVisible]
        action() {
            handleVagueUse();
        }
    }

    dobjFor(UseOn) {
        preCond = [touchObj, objVisible]
        action() {
            inventorExamineController.usingIobj = gIobj;
            handleVagueUse();
            inventorExamineController.usingIobj = nil;
        }
    }

    iobjFor(UseOn) {
        preCond = [touchObj, objVisible]
    }
}

// Make the verbose command redirect a bit more direct,
// and avoid calling the player "chatty".
modify pronounUsePreParser {
    doParsing(str, which) {
        if (rexMatch(pat3, str) || gPlayerChar.currentInterlocutor != nil) {
            return str;
        }
        
        if(rexMatch(pat, str) || rexMatch(pat2, str)) {
            """
            Were you trying to record a comment...?\b
            If so, make sure you have a running transcript with
            <<formatTheCommand('script on')>>, and start your comments with
            an asterisk (*).\n
            If you get a response of <q>Comment NOT recorded</q>, then you
            have not set a valid transcript file.
            <<formatRemember()>>
            This game has a limited vocabulary, and understands most commands
            when they follow a simple, verb-first, imperative pattern, such as
            <<formatCommand('take cup')>> or
            <<formatCommand('put cup on shelf')>>.\b
            You can always review the game's list of verbs with
            <<formatTheCommand('verbs', shortCmd)>>. Further assistance is also
            available with <<formatTheCommand('help', shortCmd)>>.
            """;
            return nil;
        }
        return str;
    }
}

// The "where can I get help" response could be a bit more direct.
modify WhereHelp {
    turnsTaken = (Help.turnsTaken)
    execAction(cmd) {
        helpMessage.printMsg();
    }
}

// Unify some styles
modify Inventory {
    // We gotta copy-paste the entire original definition here,
    // because we need to undo the modifications from newbie.t
    execAction(cmd) {
        if (splitListing) {
            local wornList = gActor.contents.subset({
                o: o.wornBy == gActor
            });
            local carriedList = gActor.contents.subset({
                o: o.wornBy == nil && o.isFixed == nil
            });
            
            local wornListShown = 0;
            
            if (wornList.length > 0) {
                gActor.myWornLister.show(wornList, 0, nil);
                
                if (carriedList.length == 0) {
                    ".<.p>";
                }
                
                wornListShown = 1;
            }
            
            if (carriedList.length > 0 || wornList.length == 0) {
                gActor.myInventoryLister.show(carriedList, wornListShown);
            }
        }
        else {
            gActor.myInventoryLister.show(gActor.contents, 0);
        }
        
        gActor.contents.forEach({x: x.noteSeen()});

        // Okay, we actually modify THIS PART...
        if (cmd.verbProd.grammarTag == 'WhatAmICarrying') {
            """
            <<formatRemember()>>
            You can also enter the abbreviation <<abbr('I')>>, which is short
            for <<formatTheCommand('check inventory')>>.
            """;
        }            
    } 
}

modify WhereAmI {
    turnsTaken = (Look.turnsTaken)
    execAction(cmd) {
        gActor.getOutermostRoom.lookAroundWithin();
        """
        <<formatRemember()>>
        You can also enter the abbreviation <<abbr('L')>>, which is short
        for <<formatTheCommand('look around')>>.
        """;
    }
}

modify Examine {
    execAction(cmd) {
        // Again, we gotta copy-paste from Adv3Lite to overwrite
        // what newbie.t had here.     
        curDobj = cmd.dobj;
        notePronounAntecedent(curDobj);
        execResolvedAction();
        
        // And this bit gets re-written:
        if(cmd.verbProd.grammarTag == 'WhatIsNoun') {
            local objName = cmd.dobj.name.toUpper();
            """
            <<formatRemember()>>
            You can also enter
            <<formatCommand('X ' + objName)>>, which is shorthand
            for <<formatCommand('Examine ' + objName)>>.
            """;
        }            
    }   
}

// I feel like "WHO AM I" is a perfectly valid thing for the player
// to enter, so the help text should be a lot more direct.
modify WhoAmI {
    turnsTaken = 0
    execAction(cmd) {
        nestedAction(Examine, gPlayerChar);
        """
        <<formatRemember()>>
        You can also enter
        <<formatCommand('X ME')>>, which is shorthand
        for <<formatCommand('Examine me')>>.
        """;
    }
}

// Unify style
modify WhereGo {
    turnsTaken = 0
    execAction(cmd) {
        nestedAction(Exits);
        """
        <<formatRemember()>>
        You can also enter <<formatTheCommand('EXITS')>>,
        which might be easier...!
        """;
    }
}

// The SEEK action has a very clumsy fallback response, especially when
// the player knows it works in other contexts.
modify Seek {
    turnsTaken = 0
    execAction(cmd) {
        local obj = getBestMatch(cmd);
        gMessageParams(obj);
        if (obj && obj.ofKind(Unthing)) {
            say(obj.notImportantMsg);
            return;
        }

        // This response is adorable, and I am absolutely
        // leaving it as-is from Adv3Lite.
        if (obj == gPlayerChar) {
            "If you've managed to lose your player character, things must be
            desperate! But don't worry, {I}{\'m} right {here}. ";
            return;
        }
        
        if (obj && obj.ofKind(Thing) && gActor.hasSeen(obj)) {
            local loc = obj.location;
            if (loc == nil) {
                if (obj.isIn(gActor.getOutermostRoom)) {
                    loc = gActor.getOutermostRoom;
                }
                else if (obj.ofKind(MultiLoc) && obj.locationList.length > 0) {
                    loc = obj.locationList[1];
                }
            }
            
            if (obj.isIn(gActor)) {
                "{I} {am} carrying {him obj}. ";
            }
            else if (gActor.canSee(obj) && loc != nil) {
                "{The subj obj} {is} ";
                if (loc == gActor.getOutermostRoom) {
                    "right {here}. ";
                }
                else {
                    "<<obj.isIn(gActor.getOutermostRoom) ? '' : 'nearby, '>>
                    <<locDesc(obj, loc)>>. ";
                }
            }
            else {
                "{I} {|had} last <<senseDesc(obj)>> {the obj}
                <<locDesc(obj, obj.lastSeenAt)>>. ";
            }
        }
        else {
            """
            You must locate something on your own before you
            can use that command to recall its location.
            """;
        }
    }
}

// Autocorrect is often a bit too aggressive, and has given TADS a bit
// of a reputation, so we can disable it for now.
// We can restore the default functionality if the player wants it.
modify Parser {
    isAutocorrectActive = nil
    autoSpell = (isAutocorrectActive ? (gPlayerChar.currentInterlocutor == nil) : nil)
}

//TODO: TYPO command