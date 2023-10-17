#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "inventorCore.h"

defaultDisclaimerChapter: InstructionsChapter {
    name = 'A Quick Guide Disclaimer'

    script = [
        defaultDisclaimerPage
    ]
}

defaultDisclaimerPage: InstructionsPage {
    page() {
        """
        If you are reading this, then the game you are playing
        does not have a specialized help guide of its own.\b
        
        However, this game was made with the help of a special tool set (called
        the <i><q>Inventor Core</q></i>), which comes with this general-purpose
        help guide, which will briefly explain how text-based games are played.
        """;
    }
}

defaultNewPlayerChapter: InstructionsChapter {
    name = 'New to Parser Games? Read This!'

    script = [
        defaultNewPlayerPage1,
        defaultNewPlayerPage2,
        defaultNewPlayerPage3
    ]
}

defaultNewPlayerPage1: InstructionsPage {
    page() {
        """
        A <q>parser game</q> is a kind of turn-based text game where you
        (the player) interact with a game world by typing in commands.\b

        Now, it is <b>crucial</b> to understand that parsers are generally not
        complex enough to fluently understand English. <b>However</b>, most
        authors still try to foster a comfortable amount of flexibility.\b

        Commands are usually notated in <<formatCommand('ALL-CAPS')>>,
        but you are not expected
        to use upper-case letters <i>at all</i>, even when typing in a proper noun!
        """;
    }
}

defaultNewPlayerPage2: InstructionsPage {
    page() {
        """
        <<formatTitle('Commands, as Notated in Text')>>

        Note how these examples hints are each written in <<formatCommand('all-caps')>>:
        <<createUnorderedList([
            'Try to <<formatCommand('open the door')>>!',
            'Try to <<formatCommand('climb up the ladder')>>!',
            'Try to <<formatCommand('put the cup on the table')>>!'
        ])>>

        <<formatTitle('Commands, as Entered by the Player')>>

        Note how these examples hints are each written in <b>lowercase</b>:
        <<createUnorderedList([
            '<<formatInput('open door')>>',
            '<<formatInput('climb up ladder')>>',
            '<<formatInput('put cup on table')>>'
        ])>>
        """;
    }
}

defaultNewPlayerPage3: InstructionsPage {
    page() {
        """
        <<formatTitle('Familiarity With the Parser')>>

        While there <i>is</i> flexibility, there is <i>also</i>
        a sort of expectation that
        the game will reuse specific verbs, or otherwise hint at what words
        can be used. That way, the player will not be stuck typing in
        unrecognized words and commands all day. Ideally, the parser should
        build a sense of familiarity, expectation, and ease with the player,
        over time.\b

        Of course, the game might not be able to handle your desired action,
        but games tend to be played within a set of rules and constraints,
        anyway. When playing a racing game, you would not attempt to play it
        like a city-building simulator. In a first-person shooter, you would
        not be able to walk <i>everywhere</i>; you would eventually fall off of the
        game's map, or otherwise reach some impassible obstacle at the
        boundaries.\b

        However, you <i>can</i> quickly attain familiarity with parsers, and find a
        comfortable, immersive groove within the game's world.
        """;
    }
}

defaultShorthandChapter: InstructionsChapter {
    name = 'Common Shorthand Examples'
    indented = true

    script = [
        defaultShorthandPage
    ]
}

defaultShorthandPage: InstructionsPage {
    page() {
        """
        There are a few shorthand abbreviations for you to use,
        instead of typing in the whole command: 

        <<createUnorderedList([
            '<<shm('L', 'look around')>>',
            '<<shm('I', 'inventory')>>',
            '<<shm('N', 'go north')>>',
            'Similarly, <<abbr('E')>>, <<abbr('S')>>, and <<abbr('W')>> are
            each shorthand for <<formatCommand('go east')>>,
            <<formatCommand('go south')>>, and <<formatCommand('go west')>>,
            respectively.',
            '<<abbr('X')>> is shorthand for <<formatCommand('examine')>> /
            <<formatCommand('look at')>>.',
            '<<shm('Z', 'wait')>>',
            '<<shm('G', 'again')>>'
        ])>>
        """;
    }

    shm(abbreviation, cmdStr) {
        return
            abbr(abbreviation) +
            ' is shorthand for ' +
            formatCommand(cmdStr) + '.';
    }
}

defaultTravelChapter: InstructionsChapter {
    name = 'Travel'
    indented = true

    script = [
        defaultTravelChapter
    ]
}

defaultTravelPage: InstructionsPage {
    page() {
        """
        This game understands directions according to a standard compass.\b

        Valid directions for travel are <<pdir('north')>>, <<pdir('east')>>,
        <<pdir('south')>>, <<pdir('west')>>,
        <<pdir('northeast', 'ne')>>, <<pdir('northwest', 'nw')>>,
        <<pdir('southeast', 'se')>>, <<pdir('southwest', 'sw')>>,
        <<pdir('up')>>, <<pdir('down')>>, <b>in</b>, and <b>out</b>.\b

        Additionally, there are sometimes features of a room can be traveled through:

        <<createUnorderedList([
            '<<formatCommand('go through window')>>',
            '<<formatCommand('go through door')>>',
            '<<formatCommand('go thru passage')>>',
            '<<formatCommand('go thru vent grate')>>'
        ])>>
        """;
    }

    pdir(dirStr, abbreviation?) {
        if (abbreviation == nil) {
            abbreviation = dirStr.substr(1, 1);
        }
        return '<b>' + dirStr + '</b>&nbsp;(<<abbr(abbreviation)>>)';
    }
}

defaultInventoryChapter: InstructionsChapter {
    name = 'Item Interaction and Inventory'
    indented = true

    script = [
        defaultInventoryPage1,
        defaultInventoryPage2,
        defaultInventoryPage3
    ]
}

defaultInventoryPage1: InstructionsPage {
    page() {
        """
        Given a <b>cup</b>, <b>table</b>, <b>note</b>, and <b>cabinet</b>
        in a room, you can study the following example commands to learn
        how to interact with your environment:

        <<createUnorderedList([
            '<<formatCommand('take cup')>>',
            '<<formatCommand('drop cup')>>',
            '<<formatCommand('put cup on table')>>',
            '<<formatCommand('look at table')>>',
            '<<formatCommand('read note')>>',
            '<<formatCommand('open cabinet')>>',
            '<<formatCommand('look in cabinet')>>',
            '<<formatCommand('put note in cabinet')>>',
            '<<formatCommand('close cabinet')>>'
        ])>>
        """;
    }
}

defaultInventoryPage2: InstructionsPage {
    page() {
        """
        Additionally, you only need to be as specific as the situation requires.
        If there is only one box in the room, then
        <<formatCommand('TAKE BOX')>> would suffice.
        If there is a red and blue box in the room, then you would need to
        specify <<formatCommand('TAKE RED BOX')>>.
        Otherwise, the parser will ask you which of
        the two boxes you meant to take. This also means that if you have
        a door called <q>the south-end garage door</q>, and it's the only
        door in the room, then you can simply refer to it with
        <<formatCommand('DOOR')>>.
        """;
    }
}

defaultInventoryPage3: InstructionsPage {
    page() {
        """
        You can also use pronouns&mdash;like
        <b>it</b> and <b>them</b>&mdash;to refer to items
        from a previous command. This makes the following sequence possible: 

        <<createUnorderedList([
            '<<formatCommand('open cabinet')>>',
            '<<formatCommand('put cup and note in it')>>',
            '<<formatCommand('look at them')>>',
            '<<formatCommand('close cabinet')>>'
        ])>>
        """;
    }
}

defaultTurnsAndUndoChapter: InstructionsChapter {
    name = 'Taking Turns and <<titleCommand('UNDO')>>'
    indented = true

    script = [
        defaultTurnsAndUndoPage1,
        defaultTurnsAndUndoPage2,
        defaultTurnsAndUndoPage3
    ]
}

defaultTurnsAndUndoPage1: InstructionsPage {
    page() {
        """
        Some actions cost turns, while others are <<free actions>>.
        Sometimes, however, the results or consequences of a
        <<free action>> will make it cost a turn instead.\b

        <<free actions>> usually include simple information-checking commands,
        such as <<formatCommand('INVENTORY')>>, as well as all out-of-world utility
        commands, such as <<formatCommand('SAVE')>>,
        <<formatCommand('UNDO')>>, <<formatCommand('RESTART')>>.\b

        Different games will have varying selections and conditions for <<free actions>>,
        but this help guide is written for parser games as a genre, because
        <i>this</i> game seems to be missing a specialized help guide.
        """;
    }
}

defaultTurnsAndUndoPage2: InstructionsPage {
    page() {
        """
        \^<<formatTheCommand('UNDO')>>&mdash;which
        is found in most parser games&mdash;may be used
        <b>at the player's discretion</b>.
        With <<formatTheCommand('undo')>>,
        you are able to reverse your last command.
        """;
    }
}

defaultTurnsAndUndoPage3: InstructionsPage {
    page() {
        """
        Also note that while parser games often allow the use of the
        <<formatCommand('UNDO')>> command, it is neither
        <b>required nor recommended for intended gameplay</b>,
        generally-speaking.\b

        At the same time, however, <<formatCommand('undo')>>
        is also a <b>valuable accessibility feature</b>
        for some parser players, who prefer it to remain available
        <b>for completely valid reasons</b>.
        With the intent to welcome and support these players,
        many titles have not locked out <<formatTheCommand('undo')>>,
        <b>unless certain, rare, game-specific circumstances are in play</b>.
        """;
    }
}

defaultUtilityCommandsChapter: InstructionsChapter {
    name = 'Other Utility Commands'
    indented = true

    script = [
        defaultUtilityCommandsPage
    ]
}

defaultUtilityCommandsPage: InstructionsPage {
    page() {
        """
        There are a few other <q>out-of-world</q>
        utility commands that are available to you:

        <<createUnorderedList([
            '<<formatCommand('again')>> repeats the previous command.',
            '<<formatCommand('exits')>> shows a list of obvious exits from the room.',
            '<<formatCommand('oops')>> allows you to correct a misspelling in
            the previous command, such as <<formatCommand('oops&nbsp;door')>>
            if the previous command was something like <<formatInput(misspell)>>.',
            '<<formatCommand('save')>> saves your game to a file',
            '<<formatCommand('restore')>> loads a saved game.',
            '<<formatCommand('restart')>> restarts the game from the beginning.',
            '<<formatCommand('extras on')>> / <<formatCommand('extras off')>>
            enables or disables tutorial hints during gameplay.\n
            <b>(At this time, tutorial hints have yet to be added to the game.)</b>',
            '<<formatCommand('verbose')>> shows the room description every time you
            enter the the room.',
            '<<formatCommand('brief')>> shows the room description only when
            entering entering the room for the first time.',
            '<<formatCommand('save defaults')>> saves your preferences
            (after things like <<formatInput('brief')>> or <<formatInput('verbose')>>).',
            '<<formatCommand('script')>> starts recording gameplay to a
            transcript text file.',
            '<<formatCommand('script off')>> stops the transcript recording.',
            '<<formatCommand('quit')>> ends the game.'
        ])>>
        """;
    }

    misspell() {
        if (gFormatForScreenReader) {
            return 'open&nbsp;d&nbsp;o&nbsp;p&nbsp;r';
        }
        return 'open&nbsp;dopr';
    }
}
