#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "inventorCore.h"

defaultVerbsChapter: InstructionsChapter {
    name = 'Index of Common Parser Verbs'
    indented = true

    script = [
        defaultVerbsPage1,
        defaultVerbsPage2,
        defaultVerbsPage3,
        defaultVerbsPage4,
        defaultVerbsPage5,
        defaultVerbsPage6,
        defaultVerbsPage7,
        defaultVerbsPage8,
        defaultVerbsPage9
    ]
}

defaultVerbsPage1: InstructionsPage {
    page() {
        """
        This is a general-purpose verb list, because this game does not
        provide a specific list of its own.\b

        These are listed with
        <<formatCommand('VERB : object')>> notation.\b

        <<formatCommand('go')>>&nbsp;<<formatCommandArg('compass direction name')>>\n
        Direction names include
        <i>(north)</i>,
        <i>(south)</i>,
        <i>(east)</i>,
        <i>(west)</i>,
        <i>(up)</i>,
        <i>(down)</i>,
        <i>(in)</i>,
        <i>(out)</i>, etc.\n
        Travel can be abbreviated with:\n
        <<abbr('N')>> <<abbr('S')>> <<abbr('E')>> <<abbr('W')>>
        <<abbr('NE')>> <<abbr('SE')>> <<abbr('NW')>> <<abbr('SW')>>
        <<abbr('U')>> <<abbr('D')>>
        """;
    }
}

defaultVerbsPage2: VerbsPage {
    page() {
        """
        <<formatVerb('climb', nil, nil, nil, nil, 'object')>>
        <<formatVerb('climb up', nil, nil, nil, nil, 'object')>>
        <<formatVerb('climb down', nil, nil, nil, nil, 'object')>>
        <<formatVerb('get down', 'get off', nil, nil, nil, nil)>>
        <<formatVerb('get out', 'go out', nil, nil, nil, nil)>>
        <<formatVerb('go in', 'enter', nil, nil, nil, 'container')>>
        """;
    }
}

defaultVerbsPage3: VerbsPage {
    page() {
        """
        <<formatVerb('open', nil, nil, nil, nil, 'door or container')>>
        <<formatVerb('close', nil, nil, nil, nil, 'door or container')>>
        <<formatVerb('unlock', nil, nil, nil, nil, 'door or container')>>
        <<formatVerb('lock', nil, nil, nil, nil, 'door or container')>>
        <<formatVerb('examine', nil, nil, nil, 'x', 'object')>>
        <<formatVerb('read', nil, nil, nil, nil, 'item')>>
        <<formatVerb('look in', nil, nil, nil, nil, 'container')>>
        <<formatVerb('look under', nil, nil, nil, nil, 'object')>>
        <<formatVerb('look behind', nil, nil, nil, nil, 'object')>>
        """;
    }
}

defaultVerbsPage4: VerbsPage {
    page() {
        """
        <<formatVerb('take', nil, nil, nil, nil, 'item')>>
        <<formatVerb('drop', nil, nil, nil, nil, 'item')>>
        <<formatVerb('wear', nil, nil, nil, nil, 'item')>>
        <<formatVerb('take off', nil, nil, nil, nil, 'item')>>
        <<formatPrepVerb('put', nil, nil, nil, nil, 'item', 'on', 'platform name')>>
        <<formatPrepVerb('put', nil, nil, nil, nil, 'item', 'in', 'container')>>
        """;
    }
}

defaultVerbsPage5: VerbsPage {
    page() {
        """
        <<formatVerb('look around', nil, 'Gives a description of surroundings.', nil, 'l', nil)>>
        <<formatVerb('look through', nil, nil, 'look thru', nil, 'aperture name')>>
        <<formatVerb('listen', nil, 'Listens for environmental sounds.', nil, nil, nil)>>
        <<formatVerb('listen to', nil, nil, nil, nil, 'item')>>
        <<formatVerb('smell', nil, 'Smells the environment.', nil, nil, nil)>>
        <<formatVerb('smell', nil, nil, nil, nil, 'item')>>
        <<formatVerb('taste', nil, nil, nil, nil, 'item')>>
        <<formatVerb('feel', nil, nil, nil, nil, 'item')>>
        """;
    }
}

defaultVerbsPage6: VerbsPage {
    page() {
        """
        <<formatVerb('wait', nil, 'Passes a turn.', nil, 'z', nil)>>
        <<formatVerb('undo', nil, nil, nil, nil, nil)>>
        <<formatVerb('save', nil, 'For player convenience.', nil, nil, nil)>>
        <<formatVerb('restore', nil, 'Loads a save file, for player convenience.', nil, nil, nil)>>
        <<formatVerb('restart', nil, 'Starts a new game.', nil, nil, nil)>>
        """;
    }
}

defaultVerbsPage7: VerbsPage {
    page() {
        """
        Not all games support <<formatCommand('go to')>> and <<formatCommand('continue')>>,
        but these two commands are still worth mentioning:\b
        <<formatVerb('go to', nil, nil, nil, nil, 'location')>>
        <<formatVerb('continue', nil, 'Takes the next step toward the go-to goal.', nil, 'c', nil)>>\b
        Additionally, some games include a list of hints, but this is not a guarantee:\b
        <<formatVerb('hint', nil, 'Offers a hint.', nil, nil, nil)>>
        """;
    }
}

defaultVerbsPage8: VerbsPage {
    page() {
        """
        Some games offer a way to examine the thoughts and knowledge of your character:\b
        <<formatVerb('think', nil, 'Examines the thoughts of your character.', nil, nil, nil)>>
        <<formatVerb('think about', nil, nil, nil, nil, 'topic')>>\b
        Sometimes you might find a person or document which has information on a topic:\b
        <<formatPrepVerb('consult', nil, nil, nil, nil, 'document', 'about', 'topic')>>
        <<formatPrepVerb('ask', nil, nil, nil, nil, 'someone', 'about', 'topic')>>
        <<formatPrepVerb('tell', nil, nil, nil, nil, 'someone', 'about', 'topic')>>
        """;
    }
}

defaultVerbsPage9: VerbsPage {
    page() {
        """
        There are many other verbs which the game might know how to handle:\b
        <<formatVerb('push', nil, nil, nil, nil, 'object')>>
        <<formatPrepVerb('cut', nil, nil, nil, nil, 'object', 'with', 'item')>>
        <<formatVerb('yell', nil, nil, nil, nil, nil)>>
        <<formatVerb('sleep', nil, nil, nil, nil, nil)>>
        <<formatVerb('pour', nil, nil, nil, nil, 'item')>>
        <<formatVerb('clean', nil, nil, nil, nil, 'item')>>
        <<formatVerb('eat', nil, nil, nil, nil, 'item')>>\b
        This is not an exhaustive list; sometimes you just need to experiment a bit!
        """;
    }
}
