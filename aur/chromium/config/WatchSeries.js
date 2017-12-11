// ==UserScript==
// @name        WatchSeries
// @namespace   http://localhost
// @version     0.0.1
// @description Exposes direct video links on WatchSeries clones
// @run-at      document-end
// @grant       GM_xmlhttpRequest
// @include     /^https?://(?:www.)?onwatchseries\.to/episode/\.*/
// @include     /^https?://(?:www.)?mywatchseries\.to/episode/\.*/
// ==/UserScript==

console.log("Executing WatchSeries...");

// Automatically expand all links
window.setTimeout(function() {
    console.log("Expanding all links");
    [].slice.call(document.getElementsByClassName('hidden-phone')).forEach(
        function(x) { x.click(); });
}, 1000);

// Modify button links to point to cyberlocker rather than ad page
getlinks().forEach(function(link) {
    var href = gethref(link);
    if (href) {
        link.href = href;
        link.style.backgroundColor = "#39AEF4";
    }
});

// Get button links to modify
function getlinks() {
	return [].slice.call(document.getElementsByClassName('buttonlink'));
}

// Get href from button links
function gethref(link) {
    try {
        return window.atob(link.href.replace(/^.*\?../, ""));
    } catch(e) {
        return null;
    }
}
