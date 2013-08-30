map =
	grid:
		rows: 6
		columns: 9
		color: "#00B3EF"
	border: 10
	base_radius: 15
	

$ ->
	map.height = 100*Math.floor($("#map").height()/100)
	map.width = 100*Math.floor($("#map").width()/100)
	map.multiplier = Math.min(map.height, map.width)/1000
	map.grid.length = Math.min(map.width / map.grid.columns, map.height / map.grid.rows)
	paper = Raphael("map", map.width+2*map.border, map.height+2*map.border)
	drawGridLines(paper)
	$.getJSON(data, (data) ->
		drawRoute(paper, route) for route in data.routes when route.name is "test"
		drawStation(paper, station) for station in data.stations
	)

drawGridLines = (paper) ->
	drawHorizontalLine(paper, map.border + i*map.grid.length, if i in [1...map.grid.rows] then 0.25 else 1) for i in [0..map.grid.rows]
	drawVerticalLine(paper, map.border + i*map.grid.length, if i in [1...map.grid.columns] then 0.25 else 1) for i in [0..map.grid.columns]
	
	drawHorizontalLabel(paper, i) for i in [1..map.grid.columns]
	drawVerticalLabel(paper, i) for i in [1..map.grid.rows]
	
drawHorizontalLine = (paper, position, width) ->
	paper
		.path(Raphael.format("M{0},{1}l{2},0", map.border, position, map.grid.length*map.grid.columns))
		.attr("stroke", map.grid.color)
		.attr("stroke-width", map.multiplier*width)
		
drawVerticalLine = (paper, position, width) ->
	paper
		.path(Raphael.format("M{0},{1}l0,{2}", position, map.border, map.grid.length*map.grid.rows))
		.attr("stroke", map.grid.color)
		.attr("stroke-width", map.multiplier*width)
		
drawHorizontalLabel = (paper, x) ->
	createLabel(paper, x)
		.forEach((elem) -> elem.transform(Raphael.format("t{0},{1}", map.border + (x-0.5)*map.grid.length, map.border)))
		.forEach((elem) -> elem.clone().transform(Raphael.format("t{0},{1}", map.border + (x-0.5)*map.grid.length, map.border + map.grid.rows*map.grid.length)))
		
drawVerticalLabel = (paper, x) ->
	createLabel(paper, String.fromCharCode(x+64))
		.forEach((elem) -> elem.transform(Raphael.format("t{0},{1}", map.border,map.border + (x-0.5)*map.grid.length)))
		.forEach((elem) -> elem.clone().transform(Raphael.format("t{0},{1}", map.border + map.grid.columns*map.grid.length, map.border + (x-0.5)*map.grid.length)))

createLabel = (paper, label) ->
	clearbox =
		attr:
			stroke: "white"
			fill: "white"
		height: map.multiplier*12
		width: map.multiplier*8

	paper.setStart()
	paper
		.rect(-clearbox.width/2, -clearbox.height/2,clearbox.width,clearbox.height)
		.attr(clearbox.attr)
	paper
		.text(0,0, label)
		.attr("fill",map.grid.color)
		.attr("font-size", map.multiplier*13)
	paper.setFinish()
		
drawRoute = (paper, route) ->
	route.translate[key] = value * map.multiplier for key,value of route.translate
	drawSolidEdge(paper, edge)
		.transform(Raphael.fullfill("t{x},{y}", route.translate)) for edge in getStartEndPoint(route.edges)
		
	console.log(getStartEndPoint(route.edges))

drawSolidEdge = (paper, edge) ->
	paper
		.path(Raphael.fullfill("M{start.x},{start.y}L{end.x},{end.y}", edge))
		.attr("stroke-width", map.multiplier*10)
	
drawStation = (paper, station) ->
	console.log(station)

# Very messy
getStartEndPoint = (edges) ->
	current =
		x: 0
		y: 0
	
	values = (
		start: 
			x: (if edge.follow then current.x = _results[edge.follow].end.x else current.x) + (if edge in edges[1..] and edges[index - 1].direction isnt edge.direction then Math.round(map.base_radius * map.multiplier * Math.sin(edge.direction * (Math.PI / 4))) else 0)
			y: (if edge.follow then current.y = _results[edge.follow].end.y else current.y) + (if edge in edges[1..] and edges[index - 1].direction isnt edge.direction then Math.round(map.base_radius * map.multiplier * -Math.cos(edge.direction * (Math.PI / 4))) else 0)
		end:
			x: (current.x += Math.round(edge.length * map.multiplier * Math.sin(edge.direction * (Math.PI / 4)))) - (if edge in edges[0...-1] and not edges[index + 1].follow? and edges[index + 1].direction isnt edge.direction then Math.round(map.base_radius * map.multiplier * Math.sin(edge.direction * (Math.PI / 4))) else 0)
			y: (current.y += Math.round(edge.length * map.multiplier * -Math.cos(edge.direction * (Math.PI / 4)))) - (if edge in edges[0...-1] and not edges[index + 1].follow? and edges[index + 1].direction isnt edge.direction then Math.round(map.base_radius * map.multiplier * -Math.cos(edge.direction * (Math.PI / 4))) else 0)) for edge,index in edges


	