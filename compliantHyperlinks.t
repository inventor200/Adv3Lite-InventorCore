#charset "us-ascii"
#include <tads.h>
#include "advlite.h"
#include "inventorCore.h"

class CompULR: object {
    baseHeader = ''
    baseText = 'Click here'
    baseTail = ''
    altText = (baseText)
    name = 'Link to demo'
    url = './link/here'
    clickURL = (url)

    printBase() {
        if (outputManager.htmlMode) {
            say(baseHeader);
            say('<a href="' + clickURL + '">');
            say(baseText);
            say('</a>');
            say(baseTail);
        }
        else {
            say(altText);
        }
    }

    printFooter() {
        if (outputManager.htmlMode) return;
        say('<.p>\t<b>' + name + ':</b>\n');
        say('<tt>' + url + '</tt><.p>');
    }
}


