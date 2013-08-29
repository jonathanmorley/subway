map =
	grid:
		rows: 6
		columns: 9
		color: "#00B3EF"
	border: 10

$ ->
	map.height = 100*Math.floor($("#map").height()/100)
	map.width = 100*Math.floor($("#map").width()/100)
	map.multiplier = Math.min(map.height, map.width)/1000
	paper = Raphael("map", map.width+2*map.border, map.height+2*map.border)
	drawGridLines(paper)
	$.getJSON(data, (data) ->
		drawRoute(paper, route) for route in data.routes
		drawStation(paper, station) for station in data.stations
	)

drawGridLines = (paper) ->
	column_width = Math.min(map.width / map.grid.columns, map.height / map.grid.rows)
	row_height = Math.min(map.width / map.grid.columns, map.height / map.grid.rows)
	cell_dimension = Math.min(map.width / map.grid.columns, map.height / map.grid.rows)
	
	#Vertical Lines
	paper.path(Raphael.format("M{0},{1}l0,{2}", map.border + x*column_width, map.border, cell_dimension*map.grid.rows)).attr("stroke", map.grid.color).attr("stroke-width", map.multiplier*0.25) for x in [1...map.grid.columns]
	
	#Horizontal lines
	paper.path(Raphael.format("M{1},{0}l{2},0", map.border + x*row_height, map.border, cell_dimension*map.grid.columns)).attr("stroke", map.grid.color).attr("stroke-width", map.multiplier*0.25) for x in [1...map.grid.rows]
	
	clearbox =
		attr:
			stroke: "white"
			fill: "white"
		height: map.multiplier*12
		width: map.multiplier*8
	
	#Numbers along top and bottom
	paper.setStart()
	paper.path(Raphael.format("M{0},{0}l{1},0", map.border, cell_dimension*map.grid.columns)).attr("stroke", map.grid.color).attr("stroke-width", map.multiplier*1)
	paper.rect(map.border+((x-0.5)*column_width)-(clearbox.width/2), map.border-clearbox.height/2,clearbox.width,clearbox.height).attr(clearbox.attr) for x in [0..map.grid.columns]
	paper.text(map.border+(x-0.5)*column_width, map.border, x).attr("fill",map.grid.color).attr("font-size", map.multiplier*13) for x in [1..map.grid.columns]
	paper.setFinish().forEach((elem) -> elem.clone().transform(Raphael.format("t0,{0}", cell_dimension*map.grid.rows)))
	
	#Letters down left and right side
	paper.setStart()
	paper.path(Raphael.format("M{0},{0}l0,{1}", map.border, cell_dimension*map.grid.rows)).attr("stroke", map.grid.color).attr("stroke-width", map.multiplier*1)
	paper.rect(map.border-clearbox.width/2, map.border+(x-0.5)*row_height-clearbox.height/2,clearbox.width,clearbox.height).attr(clearbox.attr) for x in [0..map.grid.rows]
	paper.text(map.border, map.border+(x-0.5)*row_height, String.fromCharCode(x+64)).attr("fill",map.grid.color).attr("font-size", map.multiplier*13) for x in [1..map.grid.rows]
	paper.setFinish().forEach((elem) -> elem.clone().transform(Raphael.format("t{0},0", cell_dimension*map.grid.columns)))
	
drawRoute = (paper, route) ->
	console.log(getStartEndPoint(route.edges))
	paper.path(Raphael.fullfill("M{start.x},{start.y}L{end.x},{end.y}", edge)).transform(Raphael.format("t{0},{1}", route.translate.x * map.multiplier, route.translate.y * map.multiplier)).attr("stroke-width", map.multiplier*5) for edge in getStartEndPoint(route.edges)
	
drawStation = (paper, station) ->
	console.log(station)
	
getStartEndPoint = (edges) ->
	current =
		x: 0
		y: 0
		
	(
		start: 
			x: Math.round if edge.follow then current.x = _results[edge.follow].end.x else current.x
			y: Math.round if edge.follow then current.y = _results[edge.follow].end.y else current.y
			curve: edge in edges[1..] and not (edges[_i - 1].direction is edge.direction)
		end:
			x: current.x += Math.round(edge.length * map.multiplier * Math.sin(edge.direction * (Math.PI / 4))),
			y: current.y += Math.round(edge.length * map.multiplier * -1 * Math.cos(edge.direction * (Math.PI / 4)))) for edge in edges