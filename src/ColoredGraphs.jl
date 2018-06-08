"""
Coloured graphs for use with Nauty.jl

This is quite distinct from graph coloring.
"""
module ColoredGraphs
	import MetaGraphs
	const mg = MetaGraphs
	import LightGraphs  
	const lg = LightGraphs
    import GraphPlot
    const gp = GraphPlot
    import Nauty

	# colors:
	# give labelling which is node labels .- 1 sorted in terms of color
	# partition which is array of 1s until color changes in label, where it is 0.


    """
    Example colour dict:

        coldict = Dict(
            1 => "green",
            2 => "yellow",
            3 => "orange",
            4 => "pink",
            5 => "green",
            6 => "orange",
        )
    """
	function setcolors!(g, dict::Dict{Int,String})
		for (vertex, color) in dict
			mg.set_prop!(g, vertex, :color,color)
		end
	end

	#= setcolors!(g,coldict) =#
	#= colors = get.(collect(Set(mg.props.(g,1:lg.nv(g)))), :color,"") # get all colors =#


    #= # Get an array of arrays of nodes which are all the same color =#
	#= colorsarray = [collect(mg.filter_vertices(g,(graph, vertex) -> begin =#
	#= 						get(mg.props(graph, vertex), :color, "") == c =#
	#= 					end =#
	#= 				)) for c in colors] =#

    #= # Nauty numbers its nodes from 0 =#
	#= labelling = Cint.(vcat(colorsarray.-1...)) =#

    #= # Give the last node of each color a "label" of 0, otherwise 1, as Nauty requires =#
    #= partition = vcat([begin z[end]=0; z end for z in ones.(Cint,size.(colorsarray))]...) =#

	#= a = Nauty.optionblk_mutable(Nauty.DEFAULTOPTIONS_GRAPH) =#
	#= a.getcanon = 1 =#
	#= a.digraph = 1 =#
	#= a.defaultptn = 0 =#
	#= blah = Nauty.label_to_adj( =#
	#= 	Nauty.densenauty( =#
	#= 		Nauty.lg_to_nauty(g.graph), =#
	#= 		Nauty.optionblk(a), =#
	#= 		labelling, =#
	#= 		partition =#
	#= 	).canong =#
	#= ) =#

    function plot(g)
        nodefillc = [get(mg.props(g,v),:color,"black") for v in 1:lg.nv(g)]
        gp.gplot(g.graph,nodefillc=nodefillc)
    end

end
