map =
	grid:
		rows: 6
		columns: 9
		color: "#00B3EF"
	border: 10

$ ->
	map.height = 100*Math.floor($("#map").height()/100)
	map.width = 100*Math.floor($("#map").width()/100)
	paper = Raphael("map", map.width+2*map.border, map.height+2*map.border)
	drawGridLines(paper)
	$.getJSON(data, (data) ->
		drawRoute(paper, route) for route in data.routes
		drawStation(paper, station) for station in data.stations
	)

drawGridLines = (paper) ->
	column_width = map.width / map.grid.columns
	row_height = map.height / map.grid.rows
	
	paper.path(Raphael.format("M{0},{1}l0,{2}", map.border + x*column_width, map.border, map.height)).attr("stroke", map.grid.color) for x in [0..map.grid.columns]
	paper.path(Raphael.format("M{1},{0}l{2},0", map.border + x*row_height, map.border, map.width)).attr("stroke", map.grid.color) for x in [0..map.grid.rows]
	
	clearbox =
		stroke: "white"
		fill: "white"
	
	paper.setStart()
	paper.rect(map.border+(x-0.5)*column_width-4, map.border-5,8,10).attr(clearbox) for x in [0..map.grid.columns]
	paper.text(map.border+(x-0.5)*column_width, map.border, x).attr("fill",map.grid.color) for x in [1..map.grid.columns]
	paper.setFinish().forEach((elem) -> elem.clone().transform(Raphael.format("t0,{0}", map.height)))
	
	paper.setStart()
	paper.rect(map.border-4, map.border+(x-0.5)*row_height-5,8,10).attr(clearbox) for x in [0..map.grid.rows]
	paper.text(map.border, map.border+(x-0.5)*row_height, String.fromCharCode(x+64)).attr("fill",map.grid.color) for x in [1..map.grid.rows]
	paper.setFinish().forEach((elem) -> elem.clone().transform(Raphael.format("t{0},0", map.width)))
	
drawRoute = (paper, route) ->
	console.log(route.edges)
	
drawStation = (paper, station) ->
	paper.setStart()
	paper.setFinish()