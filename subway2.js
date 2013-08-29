$(function(){
	drawMap(6,9);
});

function drawMap(rows, columns) {
	var border = 10;
	var height = $("#map").height();
	var width = $("#map").width();
	
	var paper = Raphael("map", width+2*border, height+2*border);
	drawGridLines(paper, rows, columns, border);
}

function drawGridLines(paper, rows, columns, border) {
	var column_width = $("#map").width() / (columns*2);
	var row_height = $("#map").height() / (rows*2);
	for (var x = 0; x <= 2*columns; x++) {
		if (x % 2) {
			var column_labels = paper.set();
			column_labels.push(
				paper.rect(border+x*column_width-4, border-4,8,8)
					.attr("stroke", "white")
					.attr("fill", "white"),
				paper.text(border+x*column_width, border, (x+1)/2).attr("fill","blue")
			);
			column_labels.forEach(function(obj) {
				obj.clone().transform(Raphael.format("t0,{0}", height));
			});
		}
		else
			paper.path(Raphael.format("M{0},{1}l0,{2}", border + x*column_width, border, height))
				.attr("stroke","blue").toBack();
	}
	for (var y = 0; y <= 2*rows; y++) {
		if (y % 2) {
			var row_labels = paper.set();
			row_labels.push(
				paper.rect(border-5, border+y*row_height-5,10,10)
					.attr("stroke", "white")
					.attr("fill", "white"),
				paper.text(border, border+y*row_height, String.fromCharCode((y+1)/2 + 64)).attr("fill","blue")
			);
			row_labels.forEach(function(obj) {
				obj.clone().transform(Raphael.format("t{0},0", width));
			});
		}
		else
			paper.path(Raphael.format("M{1},{0}l{2},0", border + y*row_height, border, width))
				.attr("stroke","blue").toBack();
	}
}