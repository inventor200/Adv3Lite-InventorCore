#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "inventorCore.h"

freeAction() {
    if (gFormatForScreenReader) return 'free action';
    return '<b><i>FREE</i> action</b>';
}

freeActions() {
    if (gFormatForScreenReader) return 'free actions';
    return '<b><i>FREE</i> actions</b>';
}

hyperDirCore: object {
    getDefaultTravelAction() {
        return 'go';
    }
}

formatTitle(str) {
    if (gFormatForScreenReader) {
        return
            '<.p>\^' +
            str.toLower() +
            '.<.p>';
    }
    return
        '<.p><center><b><tt>' +
        str.toUpper().findReplace('&NBSP;', '&nbsp;') +
        '</tt></b></center><.p>';
}

formatAlert(str) {
    if (gFormatForScreenReader) {
        return
            '<.p>\^' +
            str.toLower() +
            '<.p>';
    }
    return
        '<.p><b><tt>' +
        str +
        '</tt></b><.p>';
}

commandFormatter: object {
    frontEnd =
        (transScreenReader.encapVec[transScreenReader.encapVecIndexPreference]
        .frontEnd)
    backEnd =
        (transScreenReader.encapVec[transScreenReader.encapVecIndexPreference]
        .backEnd)

    _longFormat(str, tooLong) {
        local comStr = str.toUpper();
        if (!tooLong && !gFormatForScreenReader) {
            comStr = comStr.findReplace('&NBSP;', '&nbsp;').findReplace(' ', '&nbsp;');
        }
        return comStr;
    }

    _encapsulate(str, fr, bk, encapComma) {
        local ecstr = (encapComma ? ', ' : ' ');
        return fr + ecstr + str + ecstr + bk;
    }

    _screenReaderFormat(str, definiteName) {
        if (!gFormatForScreenReader || definiteName) return str;
        return _encapsulate(str, frontEnd, backEnd, transScreenReader.encapPreferCommas);
    }

    _simpleCommand(str, commandEnum, definiteName) {
        local parts = str.split(':', 2);
        str = parts[1].trim();
        local arg = '';
        if (parts.length > 1) {
            arg = '&nbsp;' + formatCommandArg(parts[2].trim());
        }

        local tooLong;
        local isFake;

        switch (commandEnum) {
            default:
            case shortFakeCmd:
                tooLong = nil;
                isFake = true;
                break;
            case shortCmd:
                tooLong = nil;
                isFake = nil;
                break;
            case longFakeCmd:
                tooLong = true;
                isFake = true;
                break;
            case longCmd:
                tooLong = true;
                isFake = nil;
                break;
        }

        local baseRes = _longFormat(str, tooLong);
        local res = baseRes + arg;

        if (gFormatForScreenReader) {
            return _screenReaderFormat(res, definiteName);
        }

        local isClickable = !isFake && !gFormatForScreenReader && outputManager.htmlMode;

        local styledRes = '<b><u>' + baseRes + '</u></b>' + arg;

        if (isClickable) {
            res = aHrefAlt(
                str.toLower(),
                baseRes,
                styledRes
            );

            return res;
        }

        return styledRes;
    }
}

// Default is shortFakeCmd
enum shortCmd, longCmd, shortFakeCmd, longFakeCmd;

formatCommand(str, commandEnum?) {
    return commandFormatter._simpleCommand(str, commandEnum, nil);
}

formatTheCommand(str, commandEnum?) {
    return 'the ' + commandFormatter._simpleCommand(str, commandEnum, true) + ' command';
}

formatCommandArg(str) {
    return '<i>(' + str.toLower().findReplace(' ', '&nbsp;') + ')</i>';
}

titleCommand(str) {
    str = commandFormatter._longFormat(str, nil);
    if (gFormatForScreenReader) {
        return commandFormatter._screenReaderFormat(str, nil);
    }
    return '<u>' + str + '</u>';
}

theTitleCommand(str) {
    str = commandFormatter._longFormat(str, nil);
    if (gFormatForScreenReader) {
        str = commandFormatter._screenReaderFormat(str, true);
    }
    else {
        str = '<u>' + str + '</u>';
    }
    return 'the ' + str + ' command';
}

formatInput(str) {
    if (gFormatForScreenReader) {
        return '<i>' + str.toLower().findReplace(' ', '&nbsp;') + '</i>';
    }
    return '<i>&gt;' + str.toLower().findReplace(' ', '&nbsp;') + '</i>';
}

abbr(str) {
    return '<tt><b><u>' + str.toUpper().findReplace('&NBSP;', '&nbsp;') + '</u></b></tt>';
}

getStandardBulletPoint() {
    if (gFormatForScreenReader) return 'Bullet point. ';
    return '<b><tt>[&gt;&gt;]</tt></b>';
}

createOrderedList(items) {
    local lst = valToList(items);
    local strBfr = new StringBuffer(lst.length * 5);

    for (local i = 1; i <= lst.length; i++) {
        createListItem(strBfr, '<b><tt>' + toString(i) + '.</tt></b>', lst[i]);
    }

    return '<.p>' + toString(strBfr) + '<.p>';
}

createUnorderedList(items) {
    local lst = valToList(items);
    local strBfr = new StringBuffer(lst.length * 5);

    for (local i = 1; i <= lst.length; i++) {
        createListItem(strBfr, getStandardBulletPoint(), lst[i]);
    }

    return '<.p>' + toString(strBfr) + '<.p>';
}

createFlowingList(items, conj?) {
    local lst = valToList(items);
    local strBfr = new StringBuffer(lst.length * 5);

    if (conj == nil) conj = 'or';

    if (gFormatForScreenReader) {
        strBfr.append('\^');
    }

    for (local i = 1; i <= lst.length; i++) {
        if (gFormatForScreenReader) {
            strBfr.append(toString(lst[i]));
            if (lst.length > 2 && i < lst.length) {
                strBfr.append(', ');
            }
            if (i == lst.length - 1) {
                strBfr.append(' ');
                strBfr.append(conj);
                strBfr.append(' ');
            }
        }
        else {
            createBasicListItem(
                strBfr, getStandardBulletPoint(),
                '\^' + toString(lst[i])
            );
        }
    }

    if (gFormatForScreenReader) {
        strBfr.append('.');
    }

    return '<.p>' + toString(strBfr) + '<.p>';
}

createListItem(strBfr, marker, str) {
    local markerStr = toString(marker);
    if (gFormatForScreenReader) {
        strBfr.append(markerStr);
        strBfr.append(' ');
        strBfr.append(toString(str));
        strBfr.append('<.p>');
    }
    else {
        createBasicListItem(strBfr, markerStr, toString(str));
    }
}

createBasicListItem(strBfr, markerStr, str) {
    strBfr.append('\t');
    strBfr.append(markerStr);
    strBfr.append(' ');
    strBfr.append(str);
    strBfr.append('\n');
}

waitForPlayer() {
    "\b";
    if (transScreenReader.includeWaitForPlayerPrompt) {
        if (gFormatForScreenReader) {
            "<.p>Press any key to continue.<.p>";
        }
        else if (outputManager.htmlMode) {
            "<.p><center><<
            aHrefAlt(
                '', 'Press any key to continue...',
                '<b><tt>Press any key to continue...</tt></b>'
            )>></center><.p>";
        }
        else {
            "<.p><center><b><tt>Press any key to continue...</tt></b></center><.p>";
        }
    }
    inputManager.pauseForMore();
    "\b";
}

formatRemember() {
    "<<formatAlert('Remember:')>>"; 
}

formatNote() {
    "<<formatAlert('Note:')>>"; 
}

formatWarning() {
    "<<formatAlert('Warning!')>>"; 
}

class InstructionsChapter: Cutscene {
    name = 'Untitled Chapter'
    indented = nil

    play() {
        say(formatTitle(name));
        local len = script.length;
        for (local i = 1; i <= len; i++) {
            "<.p>";
            if (gFormatForScreenReader) {
                "<b><tt>(page <<i>> of <<len>>)</tt></b><.p>";
            }
            script[i].page();
            if (!gFormatForScreenReader) {
                "<.p><b><tt>(pg <<i>> of <<len>>)</tt></b>\n";
            }
            if (i >= len) {
                gameMenuHandler.findInstructions().offerNavigation(self);
            }
            else {
                waitForPlayer();
            }
        }
    }
}

class InstructionsPage: object {
    page() { }
}

class VerbsPage: InstructionsPage {
    formatVerb(cmd, other, purpose, shortened, abbreviation, arg) {
        local res = formatCommand(cmd);
        if (other != nil) {
            res += ' / ' + formatCommand(other);
        }
        if (arg != nil) {
            res += '&nbsp;' + formatCommandArg(arg);
        }
        if (shortened != nil) {
            res += '\n\tShortened to: ' + formatCommand(shortened);
        }
        if (abbreviation != nil) {
            res += '\n\tAbbreviation: ' + abbr(abbreviation);
        }
        if (purpose != nil) {
            res += '\n\t' + purpose;
        }
        return res + '\b';
    }

    formatPrepVerb(cmd, other, purpose, shortened, abbreviation, arg, prep, arg2) {
        local res = formatCommand(cmd);
        if (other != nil) {
            res += ' / ' + formatCommand(other);
        }
        if (arg != nil) {
            res += '&nbsp;' + formatCommandArg(arg);
        }
        if (prep != nil) {
             res += '&nbsp;' + formatCommand(prep);
        }
        if (arg2 != nil) {
            res += '&nbsp;' + formatCommandArg(arg2);
        }
        if (shortened != nil) {
            res += '\n\tShortened to: ' + formatCommand(shortened);
        }
        if (abbreviation != nil) {
            res += '\n\tAbbreviation: ' + abbr(abbreviation);
        }
        if (purpose != nil) {
            res += '\n\t' + purpose;
        }
        return res + '\b';
    }
}

class InGameBook: object {
    chapters = []
    isOpen = nil
    isDefaultHelp = nil

    offerNavigation(srcChapter) {
        isOpen = true;
        local index = chapters.indexOf(srcChapter);
        local navChoice = new ChoiceGiver(
            'This chapter has concluded.',
            'Where would you like to go next?'
        );
        local choiceMap = [];
        if (index > 1) {
            choiceMap += 1;
            navChoice.add('P', 'Go to previous chapter', chapters[index - 1].name);
        }
        if (index < chapters.length) {
            choiceMap += 2;
            navChoice.add('N', 'Go to next chapter', chapters[index + 1].name);
        }
        choiceMap += 3;
        navChoice.add('T', 'Go to the table of contents');
        choiceMap += 4;
        navChoice.add('Q', 'Return to the game');
        local choice = choiceMap[navChoice.ask()];

        say('\b\b\b');

        if (choice == 1) {
            chapters[index - 1].play();
        }
        else if (choice == 2) {
            chapters[index + 1].play();
        }
        else if (choice == 3) {
            openTableOfContents();
        }
        else {
            returnToGame();
        }
    }

    open() {
        if (!isOpen) say('\b\b\b');
        isOpen = true;
    }

    openTableOfContents() {
        open();
        say(formatTitle('Table of Contents'));
        local chapterChoice = new ChoiceGiver(
            'Please choose a chapter to review.'
        );
        for (local i = 1; i <= chapters.length; i++) {
            local chapter = chapters[i];
            local chapterName = chapter.name;
            if (chapter.indented) chapterChoice.indentNextChoice();
            chapterChoice.add(toString(i), chapterName);
        }
        chapterChoice.add('Q', 'Return to the game');

        local chapterSel = chapterChoice.ask();
        if (chapterSel > chapters.length) {
            returnToGame();
        }
        else {
            chapters[chapterSel].play();
        }
    }

    returnToGame() {
        isOpen = nil;
        //say('\b\b\b');
        gPlayerChar.getOutermostRoom().lookAroundWithin();
    }
    
    verbsChapterObj = nil
    
    showVerbs() {
        open();
        local selectedVerbsChapterObj = verbsChapterObj;
        if (selectedVerbsChapterObj == nil) {
            say(gameMenuHandler.noVerbsMsg);
            "\b";
            selectedVerbsChapterObj = defaultHelpBook.verbsChapterObj;
        }
        selectedVerbsChapterObj.play();
    }
}

inventorCoreInit: InitObject {
    execBeforeMe = [screenReaderInit]
    
    execute() {
        local beforePrinted = nil;
        local duringPrinted = nil;
        local afterPrinted = nil;
        // Do a check every time, in case a skip was requested
        if (gameMenuHandler.showContentWarnings) {
            beforePrinted = gOutStream.watchForOutput({: gameMenuHandler.beforeWarnings() }) != nil;
        }
        if (gameMenuHandler.showContentWarnings) {
            duringPrinted = gOutStream.watchForOutput({: gameMenuHandler._showContentWarnings() }) != nil;
        }
        if (gameMenuHandler.showContentWarnings) {
            afterPrinted = gOutStream.watchForOutput({: gameMenuHandler.showOtherWarnings() }) != nil;
        }
        if (gameMenuHandler.showContentWarnings && (beforePrinted || duringPrinted || afterPrinted)) {
            "<<wait for player>>";
        }
    }
}

transient gameMenuHandler: object {
    quitMsg = 'Are you sure you would like to quit? '
    restartMsg = 'Are you sure you would like to restart? '
    noVerbsMsg = 'This story does not have a defined list of verbs. '
    
    contentWarnings = []
    
    showContentWarnings = true
    
    handleConfirmedRestart() { }
    afterConfirmedRestart() { }
    
    handleConfirmedUndo() { }
    handleConfirmedRestore() { }
    handleConfirmedStateRecovery() { }
    afterConfirmedUndo() { }
    afterConfirmedRestore() { }
    
    showHowToWinAndProgress() { }
    explainHelpIntro(fromHelpCommand) {
        "<<formatCommand('about', shortCmd)>> for a general summary.\n
        <<formatCommand('credits', shortCmd)>> for author and tester credits.";
        if (!fromHelpCommand) {
            "\n<<formatCommand('help', shortCmd)>> for tutorials and assistance.";
        }
    }
    showAdditionalHelp(fromHelpCommand) { }
    explainInstructions() {
        "To read the in-game how-to-play guide, type in
        <<formatTheCommand('guide', shortCmd)>> at the prompt.
        This could be necessary, if you are new to
        interactive fiction (<q><<abbr('IF')>></q>), text games, parser games,
        text adventures, etc.";
    }
    explainVerbs() {
        "For a reference list of verbs and commands, type in
        <<formatTheCommand('verbs', shortCmd)>>.";
    }
    explainExtraHelp() { }
    
    beforeWarnings() { }
    
    _showContentWarnings() {
        if (contentWarnings == nil) return;
        if (contentWarnings.length == 0) return;
        
        "<<formatAlert('Content warning:')>>";
        say(createFlowingList(contentWarnings));
    }
    
    showOtherWarnings() { }
    
    findInstructions() {
        for (local cur = firstObj(InGameBook);
            cur != nil ; cur = nextObj(cur, InGameBook)) {
            if (cur.isDefaultHelp) continue;
            return cur;
        }
        return defaultHelpBook;
    }
}

modify helpMessage {
    showHowToWinAndProgress() {
        gameMenuHandler.showHowToWinAndProgress();
    }

    fromHelpCommand = nil

    showHeader() {
        "<.p>";
        gameMenuHandler.explainHelpIntro(fromHelpCommand);
        gameMenuHandler.showAdditionalHelp(fromHelpCommand);
        
        fromHelpCommand = nil;
    }

    printMsg() {
        showHowToWinAndProgress();

        "\b";
        gameMenuHandler.explainInstructions();
        "\b";
        gameMenuHandler.explainVerbs();
        gameMenuHandler.explainExtraHelp();

        fromHelpCommand = true;
        
        showHeader();
    }

    briefIntro() {
        Instructions.showInstructions();
    }
}

modify VerbRule(instructions) 
    'instructions' |
    ('show'|'read'|'x'|'open'|'review'|'look' 'at'|) ('help'|'instruction'|'instructions'|) 'guide' 
    :
;

modify Instructions {
    showInstructions() {
        gameMenuHandler.findInstructions().openTableOfContents();
    }
}

VerbRule(ShowVerbs)
    ('show'|'list'|'remind' 'me' 'of'|'refresh' ('me'|) ('on'|'about')|'review'|'see') (('all'|) 'verbs' | 'verb' 'list') |
    ('verb'|'verbs') ('all'|'list') |
    ('all'|) 'verbs'
    : VerbProduction
    action = ShowVerbs
    verbPhrase = 'show/showing verbs'        
;

DefineSystemAction(ShowVerbs)
    execAction(cmd) {
        gameMenuHandler.findInstructions().showVerbs();
    }
;

modify Undo {
    execAction(cmd) {
        local undoAllowed = gameUndoBroker.initUndoCheck();
        
        if (!undoAllowed) {
            if (gameUndoBroker.undoBlockedReason != nil && gameUndoBroker.undoBlockedReason.length > 0) {
                say(gameUndoBroker.undoBlockedReason);
            }
            return nil;
        }
        
        local res = inherited(cmd);
        
        if (res) {
            gameMenuHandler.handleConfirmedUndo();
            gameMenuHandler.handleConfirmedStateRecovery();
            gameMenuHandler.afterConfirmedUndo();
            if (gameUndoBroker.undoSuccessMsg != nil && gameUndoBroker.undoSuccessMsg.length > 0) {
                say(gameUndoBroker.undoSuccessMsg);
            }
        }
        
        return res;
    }   
}

modify Restore {
    performRestore(fname, code) {
        local ret = inherited(fname, code);

        if (ret) {
            gameMenuHandler.handleConfirmedRestore();
            gameMenuHandler.handleConfirmedStateRecovery();
            gameMenuHandler.afterConfirmedRestore();
        }

        return ret;
    }
}

modify Restart {
    execAction(cmd) {
        local desireRestart = ChoiceGiver.staticAsk(
            gameMenuHandler.restartMsg
        );

        if (desireRestart) {
            doRestartGame();
        }
    }

    doRestartGame() {
        gameMenuHandler.handleConfirmedRestart();
        gameMenuHandler.afterConfirmedRestart();
        PreRestartObject.classExec();
        throw new RestartSignal();
    }
}

modify Quit {
    execAction(cmd) {      
        local desireQuit = ChoiceGiver.staticAsk(
            gameMenuHandler.quitMsg
        );

        if (desireQuit) {
            "\b";
            throw new QuittingException;
        }       
    }
}
