function showInfo(info) {
    obj = document.getElementById("popup");
    obj.innerHTML = "<div style='cursor: pointer;position: absolute; right: 5px; color: black;' onclick='javascript: document.getElementById(\"popup\").style.display = \"none\";' title='close'>x</div>" + info;
    obj.style.top = document.body.scrollTop;
    // obj.style.left = document.body.scrollLeft+7;
    obj.style.display = "";
}
