document.addEventListener("DOMContentLoaded", function () {
    var results = document.evaluate("//*[@localize]", document, null, XPathResult.ANY_TYPE, null);
    var result, nodes = [];
    while (result = results.iterateNext())
        nodes.push(result);
    for (var index in nodes) {
        var node = nodes[index];
        var key = node.getAttribute('localize');
        var value = cydia.localize(key, node.innerHTML);
        if (node.nodeName == 'TITLE')
            document.title = value;
        else
            node.innerHTML = value;
    }
});
