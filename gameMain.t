#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "inventorCore.h"

// This file mostly exists so the editor knows how to handle editing the library.
// This file (and Makefile.t3m) are not actually used during compilation,
// because this is a library, and not a game.

gameMain: GameMainDef {
    initialPlayerChar = me
}

versionInfo: GameID {
    name = 'Inventor Core'
    byline = 'by Joey Cramsey'
    htmlByline = 'by <a href="mailto:josephcsoftware@gmail.com">Joey Cramsey</a>'
    version = __GAME_VERSION
    authorEmail = ' josephcsoftware@gmail.com'
    desc = 'A standard layer on top of Adv3Lite.'
    htmlDesc = 'A standard layer on top of Adv3Lite.'
    licenseType = 'freeware'
    copyingRules = '<a href="https://www.gnu.org/licenses/gpl-3.0.en.html"
        >GPLv3.0</a>'
    presentationProfile = 'Plain Text'
}

startRoom: Room { 'Start Room'
    "Just a simple room."
}

+me: Actor { 'you;;me yourself myself'
    "Looking great...!"
    person = 2
}
