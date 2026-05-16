module ADRIAMCDA

using DataFrames
using JMcDM

"""
    rank_locations(current_conditions::Matrix, prefs::Dict; method=cocoso)
    rank_locations(current_conditions::DataFrame, prefs::Dict; method=cocoso)

Rank locations by the indicated current state/conditions and preferences.
Rankings are returned in "competition" order: Rank 1 indicates "first place".

# Arguments
- `rank_locations` : Criteria values for each location (locations × criteria)
- `prefs` : Preferences indicating the names of criteria, weights, and directionality.

# Returns
Vector of ranks corresponding to each location in their provided order.
"""
function rank_locations(current_conditions::Matrix, prefs::Dict; method=cocoso)
    res = method(current_conditions, prefs[:weights], prefs[:directions])

    # Some methods do not provide a `rankings` field, so have to derive it from the scores.
    _rankings = try
        res.ranking
    catch err
        if !(err isa FieldError)
            rethrow(err)
        end

        # Best score should be rank N, which gets flipped to rank 1 in the return statement
        _r = sortperm(res.scores; rev=true)
        size(current_conditions, 1) .- _r .+ 1
    end

    return size(current_conditions, 1) .- _rankings .+ 1
end
function rank_locations(current_conditions::DataFrame, prefs::Dict; method=cocoso)
    return rank_locations(Matrix(current_conditions), prefs; method=method)
end

"""
    rank_scores(current_conditions::Matrix, prefs::Dict; method=cocoso)
    rank_scores(current_conditions::DataFrame, prefs::Dict; method=cocoso)

Get ranking scores for the locations.

# Arguments
- `rank_locations` : Criteria values for each location (locations × criteria)
- `prefs` : Preferences indicating the names of criteria, weights, and directionality.

# Returns
Vector of rank scores corresponding to each location in their provided order.
"""
function rank_scores(current_conditions::Matrix, prefs::Dict; method=cocoso)
    res = method(current_conditions, prefs[:weights], prefs[:directions])
    return res.scores
end
function rank_scores(current_conditions::DataFrame, prefs::Dict; method=cocoso)
    return rank_scores(Matrix(current_conditions), prefs; method=method)
end

"""
    top_reef_indices(prefs, n; kwargs...) -> Vector{Int}

Return the indices of the top `n` reefs ranked by MCDA criteria.

# Arguments
- `prefs`: preference dictionary with `:names`, `:weights`, and `:directions` entries
- `n`: number of top-ranked reefs to select
- `kwargs`: one keyword argument per criterion named in `prefs[:names]`, each a `Vector{Float64}`

Criteria are assembled into a matrix in `prefs[:names]` order and passed to
`rank_locations`. Errors if any kwarg name is absent from `prefs[:names]`, or if a
name in `prefs[:names]` has no corresponding kwarg.
"""
function top_reef_indices(prefs::Dict, n::Int; kwargs...)
    names = prefs[:names]

    for key in keys(kwargs)
        String(key) ∈ names || error("Argument ':$key' not found in prefs[:names]: $names")
    end

    columns = map(names) do name
        key = Symbol(name)
        haskey(kwargs, key) || error("No argument provided for criterion '$name' (expected in prefs[:names])")
        kwargs[key]
    end

    criteria = hcat(columns...)
    rankings = rank_locations(criteria, prefs)
    return findall(r -> r <= n, rankings)
end

export rank_locations, rank_scores
export top_reef_indices

end