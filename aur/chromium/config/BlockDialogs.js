// ==UserScript==
// @name        Block dialogs
// @namespace   http://localhost
// @description Block native dialog functions
// @version     1.0
// @run-at      document-start
// @include     http*://*
// ==/UserScript==

console.log("Executing Block Dialogs");
injectScript(scriptFunc);

function scriptFunc() {
  window.alert = function alert(message) { };
  window.confirm = function confirm(message) { };
  window.print = function print() { };
  window.prompt = function prompt(message) { };
  window.onbeforeunload = function onbeforeunload(message) { };
}

function injectScript(func) {
  var scriptNode = document.createElement('script');
  scriptNode.type = "text/javascript";
  scriptNode.textContent = '(' + func.toString() + ')()';
  console.log(scriptNode.textContent);

  var targ = document.getElementsByTagName('head')[0] || document.body || document.documentElement;
  targ.appendChild(scriptNode);
}

// vim: ft=javascript:ts=2:sw=2:sts=2
