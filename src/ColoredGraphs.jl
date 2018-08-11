"""
Coloured graphs for use with Nauty.jl

This is quite distinct from graph coloring.
"""
module ColoredGraphs
	import MetaGraphs
	const mg = MetaGraphs
	import LightGraphs  
	const lg = LightGraphs
    #= import GraphPlot =#
    #= const gp = GraphPlot =#
    import Nauty
    import Colors
    const cl = Colors

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

    NB: This does nothing to the colours of nodes which are not specified in the coldict.
    """
	function setcolors!(g, dict::Dict{Int,String})
		for (vertex, color) in dict
			mg.set_prop!(g, vertex, :color,color)
		end
	end

    function colors(g)::Array{String,1}
        get.(collect(Set(mg.props.(g,1:lg.nv(g)))), :color,"")
    end

    function nautylabelspartition(g;model_t=false,ego=0)::Tuple{Array{Int32,1},Array{Int32,1}}
        # Get an array of arrays of nodes which are all the same colour
        colorsarray::Array{Array{Int64,1},1} = !model_t? [collect(mg.filter_vertices(g,(graph, vertex) -> begin
                                get(mg.props(graph, vertex), :color, "")::String == c
                                # Perhaps there's a cheaper way of finding vertices that have no property?
                            end
                       )) for c in colors(g)]:
            ego==1 ? [[1],collect(2:lg.nv(g))]:
            ego==0 ? [collect(1:lg.nv(g))]: # Shorthand for "it ain't there"
            ego==lg.nv(g) ? [collect(1:ego-1),[ego]]: # Shorthand for "it ain't there"
            [[ego],[1:ego-1..., ego+1:lg.nv(g)...]]

        # Most time is spent in collect
        # potentially quicker option: make array same size as number of nodes,
        # go through each colour and fill in the numbers on by one.

        # Nauty numbers its nodes from 0
        labels::Array{Cint,1} = vcat(colorsarray.-1...)

        # Give the last node of each colour a "label" of 0, otherwise 1, as Nauty requires
        partition::Array{Cint,1} = vcat([begin z[end]=0; z end for z in ones.(Cint,size.(colorsarray))]...)
        return (labels,partition)
    end

    function nauty(g; egonet=false, ego=0 )
        #= a = Nauty.optionblk_mutable(Nauty.DEFAULTOPTIONS_GRAPH) =#
        #= a.getcanon = 1 =#
        #= a.digraph = 1 =#
        #= a.defaultptn = 0 =#
        labels, partition = nautylabelspartition(g;model_t=egonet,ego=ego)
        nautyrtn = Nauty.baked_canonical_form_color(g,labels,partition)
        #Nauty.densenauty(
        #        Nauty.lg_to_nauty(g.graph),
        #        Nauty.optionblk(a),
        #        labels,
        #        partition
        #)

        return nautyrtn
    end

    function plot(g)
        nodefillc = [get(mg.props(g,v),:color,"black") for v in 1:lg.nv(g)]
        #= gp.gplot(g.graph,nodefillc=nodefillc) =#
    end

    function plotnauty(nautyrtn)
        okcol = cl.distinguishable_colors(length(find(x->x==0,nautyrtn.partition)))

        colind = 1
        colarr = []
        for i in nautyrtn.partition
            push!(colarr,okcol[colind])
            colind = i == 0 ? colind + 1 : colind
        end
        #= gp.gplot(lg.Graph(Nauty.label_to_adj(nautyrtn.canong)),nodefillc=colarr) =#
    end


end
