/* Extract Pages By # */
var pageString = app.response("What pages would like to extract? (e.g. 2, 4-6, 8)");
if (pageString !== null) {
    var pageArray = pageString.split(",");
    var finalPageArray = [];
    for (var i = 0; i < pageArray.length; i++) {
        var page = String(pageArray[i]).trim();
        if (page.indexOf("-") !== -1) {
            var range = page.split("-");
            var start = parseInt(range[0]);
            var end = parseInt(range[1]);
            for (var j = start; j <= end; j++) {
                finalPageArray.push(j);
            }
        } else {
            finalPageArray.push(parseInt(page));
        }
    }
    if (finalPageArray.length > 0) {
        var d = app.newDoc(); // this will add a temporary page to start the document
        for (var n = 0; n < finalPageArray.length; n++) {
            d.insertPages( {
                nPage: d.numPages-1,
                cPath: this.path,
                nStart: finalPageArray[n]-1,
                nEnd: finalPageArray[n]-1,
            } );
        }
        d.deletePages(0); // remove the temporary page
    }
}
