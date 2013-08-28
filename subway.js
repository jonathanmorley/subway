$(function(){
	drawMap();
});

function drawMap() {
	var paper;
	paper = Raphael("map", 1900, 1300);
	
	for (var x = 50; x < 1900; x += 100) {
		if ((x-50) % 200) {
			paper.rect(x-4, 46,8,8)
				.attr("stroke", "rgba(255, 255, 255, 1)")
				.attr("fill", "rgba(255, 255, 255, 1)");
			paper.text(x, 50, (x-150)/200 + 1).attr("fill","blue");
			paper.rect(x-4, 1246,8,8)
				.attr("stroke", "rgba(255, 255, 255, 1)")
				.attr("fill", "rgba(255, 255, 255, 1)");
			paper.text(x, 1250, (x-150)/200 + 1).attr("fill","blue");
		}
		else
			paper.path(Raphael.format("M{0},50l0,1200", x)).attr("stroke","blue").toBack();
	}
	for (var y = 50; y < 1300; y += 100) {
		if ((y-50) % 200) {
			paper.rect(45, y-5,10,10)
				.attr("stroke", "rgba(255, 255, 255, 1)")
				.attr("fill", "rgba(255, 255, 255, 1)");
			paper.text(50, y, String.fromCharCode((y-150)/200 + 65)).attr("fill","blue");
			paper.rect(1845, y-5,10,10)
				.attr("stroke", "rgba(255, 255, 255, 1)")
				.attr("fill", "rgba(255, 255, 255, 1)");
			paper.text(1850, y, String.fromCharCode((y-150)/200 + 65)).attr("fill","blue");
		}
		else
			paper.path(Raphael.format("M50,{0}l1800,0", y)).attr("stroke","blue").toBack();
	}
}