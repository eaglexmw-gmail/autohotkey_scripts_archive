if (!window.encodeURIComponent)
    encodeURIComponent = escape;
if (!window.decodeURIComponent)
    decodeURIComponent = unescape;

if (!Date.prototype.toUTCString)
    Date.prototype.toUTCString = Date.prototype.toGMTString;

Date.prototype.toExpireString = function(maxAge) {
    this.setTime(this.getTime() + maxAge*1000);
    return this.toUTCString();
};

function getCookie(key) {
    var value = new RegExp("(^|[,;]\\s*)" + key + "=\"?([^\",;\\s]+)").exec(document.cookie);
    return value ? decodeURIComponent(value[2]) : "";
}

function setCookie(key, value, maxAge) {
    document.cookie = key + "=\"" + encodeURIComponent(value)
                      + "\"; version=1; path=/; max-age=" + maxAge
                      + "; expires=\"" + new Date().toExpireString(maxAge) + '"';
}

function set2chCookie(key, value, maxAge) {
    document.cookie = key + "=\"" + encodeURIComponent(value)
                      + "\"; version=1; path=/; domain=.2ch.net; max-age=" + maxAge
                      + "; expires=\"" + new Date().toExpireString(maxAge) + '"';
}

function be(i) {
    var w = window.open("http://be.2ch.net/test/p.php?i=" + i + "&u=d:" + document.URL);
    if (w) w.focus();
}

function switchReadJsMode() {
    var readjs = getCookie("READJS"), ison = readjs == "on";
    if (!readjs)
        alert("Cookie が無効になってるか、あるいはサポート外のブラウザです。");
    else if (confirm("read.cgi は現在 " + (ison ? "JavaScript" : "CGI") + " モードです。" + (ison ? "CGI" : "JavaScript") + " モードに切り替えますか？"))
        set2chCookie("READJS", ison ? "off" : "on", 365*24*60*60);
    var menu = document.anchors.length ? document.anchors[0].nextSibling : document.getElementById("menu");
    (menu || document.body).title = ison ? "" : "JavaScript モード";
}

function changeSubbackStyle() {
    if (!changeSubbackStyle.mode)
        for (var i = 0, n = document.links.length
                 - (document.links.length >= 2
                        && document.links[document.links.length - 2].firstChild.data == "read.cgi モード切替"
                    ? 3 : 2); i < n; ) {
            var div = document.createElement("div"),
                small = document.createElement("small");
            div.className = "block";
            div.appendChild(small);
            document.body.insertBefore(div, document.body.childNodes[i / 20]);
            for (var j = 0; j < 20 && i < n; j++, i++)
                small.appendChild(document.links[i]);
        }
    else if (changeSubbackStyle.mode == 1) {
        for (var i = document.body.firstChild; i; i = i.nextSibling)
            if (i.className == "block")
                i.className = "floated";
    }
    else {
        var trad = document.getElementById("trad");
        for (var i = 0; i < document.body.childNodes.length; )
            if (document.body.childNodes[i].className == "floated") {
                while (document.body.childNodes[i].firstChild.firstChild)
                    trad.appendChild(document.body.childNodes[i].firstChild.firstChild);
                document.body.removeChild(document.body.childNodes[i]);
            }
            else
                i++;
    }
    set2chCookie("SUBBACK_STYLE", changeSubbackStyle.mode = ((changeSubbackStyle.mode || 0) + 1) % 3, 30*24*60*60);
}

onload = function(e) {
    var N = getCookie("NAME"), M = getCookie("MAIL"), i;
    for (i = 0; i < document.forms.length; i++)
        if (document.forms[i].FROM && document.forms[i].mail) {
            document.forms[i].FROM.value = N;
            document.forms[i].mail.value = M;
            if (!document.forms[i].addEventListener)
                document.forms[i].addEventListener = function(t, l, c) { this["on"+t] = l; };
            document.forms[i].addEventListener("submit", function(e) {
                setCookie("NAME", this.FROM.value, 30*24*60*60);
                setCookie("MAIL", this.mail.value, 30*24*60*60);
            }, false);
        }
    try {
        if (/^\/\w+\/(?:|(?:index|subback)\.html)$/.test(location.pathname)) {
            var readjs = getCookie("READJS");
            if (!readjs)
                set2chCookie("READJS", "off", 365*24*60*60);
//              set2chCookie("READJS", /MSIE (?:[7-9]|\d{2,})\D|rv:(?:1\.(?:[89]|\d{2,})|[2-9]|\d{2,})\D.*Gecko\/|Opera\/(?:[89]|\d{2,})\D/.test(navigator.userAgent)
//                                         && !/DoCoMo|KDDI|UP\.Browser|J-PHONE|Vodafone|SoftBank|DDIPOCKET|WILLCOM/.test(navigator.userAgent) ? "on" : "off", 365*24*60*60);
            else if (readjs == "on") {
                var menu = document.anchors.length ? document.anchors[0].nextSibling : document.getElementById("menu");
                (menu || document.body).title = "JavaScript モード";
            }
            if (/\/subback\.html$/.test(location.pathname)) {
                var subbackMode = parseInt(getCookie("SUBBACK_STYLE"));
                if (subbackMode) {
                    changeSubbackStyle();
                    if (subbackMode == 2)
                        changeSubbackStyle();
                }
                if (document.links[document.links.length - 2].firstChild.data == "read.cgi モード切替") {
                    if (!document.links[document.links.length - 2].addEventListener)
                        document.links[document.links.length - 2].addEventListener = function(t, l, c) { this["on"+t] = l; };
                    document.links[document.links.length - 2].addEventListener("click", function(e) {
                        if (!e)
                            e = window.event;
                        if (e.shiftKey) {
                            for (var i = 0; i < document.links.length - 3; i++)
                                document.links[i].href = document.links[i].href.replace(/\/read\.cgi\//, "/read.html#");
                            if (e.preventDefault)
                                e.preventDefault();
                            return false;
                        }
                    }, false);
                }
            }
        }
    } catch(e) {}
};
