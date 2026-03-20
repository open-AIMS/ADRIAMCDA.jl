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
"""
function rank_scores(current_conditions::Matrix, prefs::Dict; method=cocoso)
    res = method(current_conditions, prefs[:weights], prefs[:directions])
    return res.scores
end
function rank_scores(current_conditions::DataFrame, prefs::Dict; method=cocoso)
    return rank_scores(Matrix(current_conditions), prefs; method=method)
end

export rank_locations, rank_scores

end