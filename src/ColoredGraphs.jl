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

    function colors(g)
        get.(collect(Set(mg.props.(g,1:lg.nv(g)))), :color,"")
    end

    function nautylabelspartition(g)
        # Get an array of arrays of nodes which are all the same colour
        colorsarray = [collect(mg.filter_vertices(g,(graph, vertex) -> begin
                                get(mg.props(graph, vertex), :color, "") == c
                            end
                       )) for c in colors(g)]

        # Nauty numbers its nodes from 0
        labels = Cint.(vcat(colorsarray.-1...))

        # Give the last node of each colour a "label" of 0, otherwise 1, as Nauty requires
        partition = vcat([begin z[end]=0; z end for z in ones.(Cint,size.(colorsarray))]...)
        return (labels,partition)
    end

    function nauty(g)
        a = Nauty.optionblk_mutable(Nauty.DEFAULTOPTIONS_GRAPH)
        a.getcanon = 1
        a.digraph = 1
        a.defaultptn = 0
        labels, partition = nautylabelspartition(g)
        nautyrtn = Nauty.densenauty(
                Nauty.lg_to_nauty(g.graph),
                Nauty.optionblk(a),
                labels,
                partition
        )

        return nautyrtn
    end

    function plot(g)
        nodefillc = [get(mg.props(g,v),:color,"black") for v in 1:lg.nv(g)]
        gp.gplot(g.graph,nodefillc=nodefillc)
    end

    function plotnauty(nautyrtn)
        okcol = cl.distinguishable_colors(length(split(join(string.(nautyrtn.partition)),"1",keep=true)))

        colind = 0
        colarr = []
        for i in nautyrtn.partition
            colind = i == 0 ? colind + 1 : colind
                push!(colarr,okcol[colind])
            end
        colarr
        #colarr2 = [x[2] for x in sort(collect(enumerate(colarr)),by=x->blah.labels[x[1]])]
        gp.gplot(lg.Graph(Nauty.label_to_adj(nautyrtn.canong)),nodefillc=colarr)
    end


end
