map =
	grid:
		rows: 6
		columns: 9
		color: "#00B3EF"
	border: 10

$ ->
	map.height = 100*Math.floor($("#map").height()/100)
	map.width = 100*Math.floor($("#map").width()/100)
	map.multiplier = Math.max(map.height, map.width)/1000
	paper = Raphael("map", map.width+2*map.border, map.height+2*map.border)
	drawGridLines(paper)
	$.getJSON(data, (data) ->
		drawRoute(paper, route) for route in data.routes
		drawStation(paper, station) for station in data.stations
	)

drawGridLines = (paper) ->
	column_width = map.width / map.grid.columns
	row_height = map.height / map.grid.rows
	
	#Vertical Lines
	paper.path(Raphael.format("M{0},{1}l0,{2}", map.border + x*column_width, map.border, map.height)).attr("stroke", map.grid.color) for x in [0..map.grid.columns]
	
	#Horizontal lines
	paper.path(Raphael.format("M{1},{0}l{2},0", map.border + x*row_height, map.border, map.width)).attr("stroke", map.grid.color) for x in [0..map.grid.rows]
	
	clearbox =
		stroke: "white"
		fill: "white"
	
	#Numbers along top and bottom
	paper.setStart()
	paper.rect(map.border+(x-0.5)*column_width-4, map.border-5,8,10).attr(clearbox) for x in [0..map.grid.columns]
	paper.text(map.border+(x-0.5)*column_width, map.border, x).attr("fill",map.grid.color) for x in [1..map.grid.columns]
	paper.setFinish().forEach((elem) -> elem.clone().transform(Raphael.format("t0,{0}", map.height)))
	
	#Letters down left and right side
	paper.setStart()
	paper.rect(map.border-4, map.border+(x-0.5)*row_height-5,8,10).attr(clearbox) for x in [0..map.grid.rows]
	paper.text(map.border, map.border+(x-0.5)*row_height, String.fromCharCode(x+64)).attr("fill",map.grid.color) for x in [1..map.grid.rows]
	paper.setFinish().forEach((elem) -> elem.clone().transform(Raphael.format("t{0},0", map.width)))
	
drawRoute = (paper, route) ->
	console.log(getStartEndPoint(route.edges))
	paper.path(Raphael.fullfill("M{start.x},{start.y}L{end.x},{end.y}", edge)).transform(route.translate) for edge in getStartEndPoint(route.edges)
	
drawStation = (paper, station) ->
	console.log(station)
	
getStartEndPoint = (edges) ->
	current =
		x: 0
		y: 0
		
	(
		start: 
			x: if edge.follow then current.x = _results[edge.follow].end.x else current.x
			y: if edge.follow then current.y = _results[edge.follow].end.y else current.y
			curve: edge in edges[1..]
		end:
			x: current.x += Math.round(edge.length * Math.sin(edge.direction * (Math.PI / 4))),
			y: current.y += Math.round(edge.length * -1 * Math.cos(edge.direction * (Math.PI / 4)))
			curve: edge in edges[0...] or edges[_i + 1].follow) for edge in edges