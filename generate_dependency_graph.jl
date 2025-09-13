using TOML
using Graphs: DiGraph, add_vertex!, add_edge!, edges, src, dst
using GraphViz
using FileIO

"""
Generate dependency graph and save to files

# Arguments
- `toml_path::String`: Path to TOML file (default: "libraries.toml")
- `prefix::String`: Output file prefix (default: "libdeps")
- `width::Real`: Canvas width in inches (default: 6.0)
- `height::Real`: Canvas height in inches (default: 6.0)

# Returns
- Tuple of generated file names (svg_file,)
"""
function generate_dependency_graph(toml_path::String = "libraries.toml", prefix::String = "", width::Real = 6.0, height::Real = 6.0)
    @show width, height
    
    # Auto-generate prefix from TOML filename if not provided
    if isempty(prefix)
        prefix = splitext(basename(toml_path))[1]
    end
    
    # Read TOML file
    spec = TOML.parsefile(toml_path)

    # Get list of libraries
    libs = spec["libraries"]

    # Get dependency information
    deps = spec["library_dependencies"]

    # Create directed graph
    g = DiGraph()
    lib_names = collect(keys(libs))

    # Add each library as a node
    for ln in lib_names
        add_vertex!(g)
    end

    # Create mapping dictionary from library name to index
    name_to_idx = Dict{String, Int}()
    for (i, ln) in enumerate(lib_names)
        name_to_idx[ln] = i
    end

    # Dictionary to store edge attributes: (src_idx, dst_idx) => dependency type
    edge_attrs = Dict{Tuple{Int,Int}, String}()

    # Process strong dependencies (strong_deps)
    for (lib, sub) in deps
        if haskey(sub, "strong_deps")
            for tgt in sub["strong_deps"]
                src_idx = name_to_idx[lib]
                dst_idx = name_to_idx[tgt]
                add_edge!(g, src_idx, dst_idx)
                edge_attrs[(src_idx, dst_idx)] = "strong"
            end
        end
        # Process weak dependencies (weak_deps)
        if haskey(sub, "weak_deps")
            for tgt in sub["weak_deps"]
                src_idx = name_to_idx[lib]
                dst_idx = name_to_idx[tgt]
                add_edge!(g, src_idx, dst_idx)
                edge_attrs[(src_idx, dst_idx)] = "weak"
            end
        end
    end

    # Build DOT format string
    dot_lines = [
        "digraph library_dependencies {",
        "  rankdir=TB;",
        "  size=\"" * string(width) * "," * string(height) * "\";",
        "  ratio=compress;",
        "  overlap=false;",
        "  splines=true;",
        "  nodesep=2.0;",
        "  ranksep=3.0;",
        "  node [shape=box, style=rounded, fontname=\"Arial\", fontsize=12, margin=\"0.2,0.2\"];",
        "  edge [fontname=\"Arial\", fontsize=10];"
    ]

    # Define nodes (using library names as identifiers)
    for ln in lib_names
        desc = libs[ln]["desc"]
        # Use HTML-like labels to control font sizes
        label = "<<b>$ln</b><br/><font point-size=\"10\">$desc</font>>"
        push!(dot_lines, "  \"$ln\" [label=$label];")
    end


    # Define edges (strong dependencies: solid line, weak dependencies: dashed line)
    for e in edges(g)
        src_idx, dst_idx = src(e), dst(e)
        src_name = lib_names[src_idx]
        dst_name = lib_names[dst_idx]
        etype = edge_attrs[(src_idx, dst_idx)]
        
        style, color = if etype == "strong"
            ("solid", "black")  # Strong dependency: solid black line
        else
            ("dashed", "gray")  # Weak dependency: dashed gray line
        end
        push!(dot_lines, "  \"$src_name\" -> \"$dst_name\" [style=$style, color=$color];")
    end

    push!(dot_lines, "}")

    dot_str = join(dot_lines, "\n")

    # Load DOT string with GraphViz and create graph object
    g_dot = GraphViz.Graph(dot_str)

    # Generate output file name
    svg_file = "$prefix.svg"
    @show svg_file
    FileIO.save(svg_file, g_dot)

    return (svg_file,)
end

# Help function
function show_help()
    println("Generate dependency graph from TOML file")
    println()
    println("USAGE:")
    println("  julia generate_dependency_graph.jl [options] [arguments]")
    println()
    println("OPTIONS:")
    println("  -h, --help     Show this help message and exit")
    println()
    println("ARGUMENTS:")
    println("  toml_file      Path to TOML file (default: libraries.toml)")
    println("  prefix         Output file prefix (default: libdeps)")
    println("  width          Canvas width in inches (default: 8.0)")
    println("  height         Canvas height in inches (default: 6.0)")
    println()
    println("EXAMPLES:")
    println("  julia generate_dependency_graph.jl                                    # Use defaults")
    println("  julia generate_dependency_graph.jl my_graph                           # Specify prefix")
    println("  julia generate_dependency_graph.jl my_libs.toml my_graph              # Specify TOML and prefix")
    println("  julia generate_dependency_graph.jl my_graph 12.0 8.0                  # Specify prefix and size")
    println("  julia generate_dependency_graph.jl my_libs.toml my_graph 10.0 6.0     # Specify all parameters")
    println()
    println("OUTPUT:")
    println("  Generates an SVG file showing library dependencies with:")
    println("  - Solid arrows for strong dependencies")
    println("  - Dashed arrows for weak dependencies")
end

# Process command line arguments
if length(ARGS) == 0
    # No arguments: execute with defaults
    svg_file = generate_dependency_graph()[1]
    println("Dependency graph generated: $svg_file")
elseif length(ARGS) == 1
    # Check for help option
    if ARGS[1] in ["-h", "--help"]
        show_help()
    else
        # One argument: TOML file path (prefix auto-generated)
        toml_path = ARGS[1]
        svg_file = generate_dependency_graph(toml_path)[1]
        println("Dependency graph generated: $svg_file")
    end
elseif length(ARGS) == 2
    # Check for help option
    if any(arg in ["-h", "--help"] for arg in ARGS)
        show_help()
    else
        # Two arguments: TOML file path and prefix
        toml_path = ARGS[1]
        prefix = ARGS[2]
        svg_file = generate_dependency_graph(toml_path, prefix)[1]
        println("Dependency graph generated: $svg_file")
    end
elseif length(ARGS) == 3
    # Check for help option
    if any(arg in ["-h", "--help"] for arg in ARGS)
        show_help()
    else
        # Three arguments: TOML file, width, height (prefix auto-generated)
        toml_path = ARGS[1]
        width = parse(Float64, ARGS[2])
        height = parse(Float64, ARGS[3])
        svg_file = generate_dependency_graph(toml_path, "", width, height)[1]
        println("Dependency graph generated: $svg_file")
    end
elseif length(ARGS) == 4
    # Check for help option
    if any(arg in ["-h", "--help"] for arg in ARGS)
        show_help()
    else
        # Four arguments: TOML file, prefix, width, height
        toml_path = ARGS[1]
        prefix = ARGS[2]
        width = parse(Float64, ARGS[3])
        height = parse(Float64, ARGS[4])
        svg_file = generate_dependency_graph(toml_path, prefix, width, height)[1]
        println("Dependency graph generated: $svg_file")
    end
else
    # Invalid number of arguments
    show_help()
end
