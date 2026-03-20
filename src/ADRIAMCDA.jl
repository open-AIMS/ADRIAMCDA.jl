module ADRIAMCDA

using JMcDM

# tmp = Dict(
#     :names => ["heat", "waves", "cover", "in_conn", "out_conn"],
#     :weights => [1.0, 0.5, 0.8, 0.5, 0.5],
#     :directions => [minimum, minimum, minimum, maximum, maximum]
# )

# dummy = [
#     1 1 1 1 1;
#     2 2 2 2 2;
#     2 2 2 2 2;
#     2 2 2 2 2;
#     2 2 2 2 2;
#     2 2 2 2 2;
#     2 2 2 2 2;
#     2 2 2 2 2;
#     2 2 2 2 2;
#     2 2 2 2 2
# ]

# dummy = hcat(
#     collect.([
#         1:10,
#         1:10,
#         [4.0, 500.0, 6.0, 10.0, 50.0, 100.0, 100.0, 100.0, 100.0, 100.0],
#         [1000.0, 0.1, 6.0, 10.0, 50.0, 100.0, 100.0, 100.0, 100.0, 100.0],
#         [1000.0, 0.9, 6.0, 10.0, 50.0, 100.0, 100.0, 100.0, 100.0, 100.0]
#     ])...
# )

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
    return size(current_conditions, 1) .- res.ranking .+ 1
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

end