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
	curved_edges = getCurvedEdges(route.vectors)
	full_edges = getFullEdges(route.vectors)
	curves = getCurves(curved_edges, full_edges)
	console.log(curves)
	drawSolidEdge(paper, edge)
		.transform(Raphael.fullfill("t{x},{y}", route.translate)) for edge in curved_edges
	drawSolidCurve(paper, curve)
		.transform(Raphael.fullfill("t{x},{y}", route.translate)) for curve in curves
		
drawSolidEdge = (paper, edge) ->
	paper
		.path(Raphael.fullfill("M{start.x},{start.y}L{end.x},{end.y}", edge))
		.attr("stroke-width", map.multiplier*10)
		
drawSolidCurve = (paper, curve) ->
	paper
		.path(Raphael.fullfill("M{start.x},{start.y}S{end.x},{end.y},{control.x},{control.y}", curve))
		.attr("stroke-width", map.multiplier*10)
	
drawStation = (paper, station) ->
	console.log(station)

# Very messy
getFullEdges = (vectors) ->
	current =
		x: 0
		y: 0
	
	(
		start:
			x: (if vector.follow then current.x = _results[vector.follow].end.x else current.x)
			y: (if vector.follow then current.y = _results[vector.follow].end.y else current.y)
		end:
			x: (current.x += Math.round(vector.length * map.multiplier * Math.sin(vector.direction * (Math.PI / 4))))
			y: (current.y += Math.round(vector.length * map.multiplier * -Math.cos(vector.direction * (Math.PI / 4))))) for vector,index in vectors

getCurvedEdges = (vectors) ->
	current =
		x: 0
		y: 0
	
	(
		start:
			x: (if vector.follow then current.x = _results[vector.follow].end.x else current.x) + (if vector in vectors[1..] and vectors[index - 1].direction isnt vector.direction then Math.round(map.base_radius * map.multiplier * Math.sin(vector.direction * (Math.PI / 4))) else 0)
			y: (if vector.follow then current.y = _results[vector.follow].end.y else current.y) + (if vector in vectors[1..] and vectors[index - 1].direction isnt vector.direction then Math.round(map.base_radius * map.multiplier * -Math.cos(vector.direction * (Math.PI / 4))) else 0)
		end:
			x: (current.x += Math.round(vector.length * map.multiplier * Math.sin(vector.direction * (Math.PI / 4)))) - (if vector in vectors[0...-1] and not vectors[index + 1].follow? and vectors[index + 1].direction isnt vector.direction then Math.round(map.base_radius * map.multiplier * Math.sin(vector.direction * (Math.PI / 4))) else 0)
			y: (current.y += Math.round(vector.length * map.multiplier * -Math.cos(vector.direction * (Math.PI / 4)))) - (if vector in vectors[0...-1] and not vectors[index + 1].follow? and vectors[index + 1].direction isnt vector.direction then Math.round(map.base_radius * map.multiplier * -Math.cos(vector.direction * (Math.PI / 4))) else 0)) for vector,index in vectors

getCurves = (curved_edges, full_edges) ->
	curves = (
		start: edge.end
		end: curved_edges[index + 1].start
		control: full_edges[index].end) for edge,index in curved_edges[...-1] when edge.end isnt curved_edges[index + 1].start