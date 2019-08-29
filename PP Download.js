javascript:(function(){
	html = document.body.innerHTML;
	url = html.match(/appdownurl=".*?"/);
	url = url.toString().replace(/\"|appdownurl=/g, "");
	window.open(atob(url),'_self');
})()