#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "inventorCore.h"

transient defaultHelpBook: InGameBook {
    chapters = [
        defaultDisclaimerChapter,
        defaultNewPlayerChapter,
        defaultShorthandChapter,
        defaultTravelChapter,
        defaultInventoryChapter,
        defaultTurnsAndUndoChapter,
        defaultUtilityCommandsChapter,
        defaultVerbsChapter
    ]

    isDefaultHelp = true
    
    verbsChapterObj = defaultVerbsChapter
}

modify GameID {
    showCredit() {
        showModules();
    }
    showModules() {
        local modList = ModuleID.getModuleList();
        if (modList.length == 0) return;

        """
        <<formatAlert('Module Credits')>>
        The following modules were used\nin the creation of this game...
        """;

        for (local i = 1; i <= modList.length; i++) {
            local mod = modList[i];
            """
            <<if gFormatForScreenReader>><.p><<else>><.p><b><tt><<end>><<
            mod.showVersion()
            >><<if !gFormatForScreenReader>></b></tt><<end>>\n
            <<if outputManager.htmlMode>><<mod.htmlByline>><<else>><<mod.byline>><<end>>
            """;
        }
    }
}

inventorCoreID: ModuleID {
    name = 'The Inventor Core'
    byline = 'A standard addon layer for adv3Lite.\nby Joey Cramsey '
    htmlByline = 'A standard addon layer for adv3Lite.\nby <a href="mailto:josephcsoftware@gmail.com">Joey Cramsey</a> '
    version = '1.0'
}

forEveryoneID: ModuleID {
    name = 'For Everyone'
    byline = 'A screen reader module.\nby BlindHunter95\n(expanded for the Inventor Core by Joey Cramsey) '
    htmlByline = 'A screen reader <a href="https://intfiction.org/t/new-topic-up-at-tads-3-cookbook/54255/5">module</a>.\n
        by BlindHunter95\n
        (expanded for the Inventor Core by <a href="mailto:josephcsoftware@gmail.com">Joey Cramsey</a>) '
    version = '1.0'
    listingOrder = (inventorCoreID.listingOrder + 1)
}
