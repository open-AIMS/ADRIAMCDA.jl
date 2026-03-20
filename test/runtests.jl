using ADRIAMCDA

using Test
using DataFrames
using JMcDM


# Shared fixtures

"""
Decision matrix where option 1 is clearly dominant:
- Columns 1–3 are cost criteria (minimum): option 1 has the lowest values.
- Columns 4–5 are benefit criteria (maximum): option 1 has the highest values.
"""
const DOMINANT_MATRIX = Float64.(hcat(
    collect.([
        1:10,
        1:10,
        [1.0, 500.0, 6.0, 10.0, 50.0, 100.0, 100.0, 100.0, 100.0, 100.0],
        [1000.0, 0.1, 6.0, 10.0, 50.0, 100.0, 100.0, 100.0, 100.0, 100.0],
        [1000.0, 0.9, 6.0, 10.0, 50.0, 100.0, 100.0, 100.0, 100.0, 100.0],
    ])...
))

const DOMINANT_PREFS = Dict(
    :names => ["c1", "c2", "c3", "c4", "c5"],
    :weights => [1.0, 0.5, 0.8, 0.5, 0.5],
    :directions => [minimum, minimum, minimum, maximum, maximum],
)

const DOMINANT_DF = DataFrame(DOMINANT_MATRIX, :auto)

# rank_locations (Matrix)

@testset "rank_locations — Matrix input" begin
    ranks = rank_locations(DOMINANT_MATRIX, DOMINANT_PREFS)

    @testset "return type and shape" begin
        @test ranks isa AbstractVector
        @test length(ranks) == size(DOMINANT_MATRIX, 1)
    end

    @testset "competition ordering (rank 1 = best)" begin
        # Option 1 is dominant across all criteria and should be ranked first.
        @test ranks[1] == 1
    end

    @testset "rank values are in valid range" begin
        n = size(DOMINANT_MATRIX, 1)
        @test all(1 .<= ranks .<= n)
    end

    @testset "ranks are unique (no ties expected for this matrix)" begin
        @test length(unique(ranks)) == length(ranks)
    end

    @testset "ranks form a complete permutation" begin
        n = size(DOMINANT_MATRIX, 1)
        @test sort(ranks) == collect(1:n)
    end
end

# rank_locations (DataFrame)

@testset "rank_locations — DataFrame dispatch" begin
    ranks_mat = rank_locations(DOMINANT_MATRIX, DOMINANT_PREFS)
    ranks_df = rank_locations(DOMINANT_DF, DOMINANT_PREFS)

    @testset "DataFrame and Matrix dispatch agree" begin
        @test ranks_df == ranks_mat
    end

    @testset "return type and shape" begin
        @test ranks_df isa AbstractVector
        @test length(ranks_df) == nrow(DOMINANT_DF)
    end
end

# rank_scores (Matrix)

@testset "rank_scores — Matrix input" begin
    scores = rank_scores(DOMINANT_MATRIX, DOMINANT_PREFS)

    @testset "return type and shape" begin
        @test scores isa AbstractVector
        @test length(scores) == size(DOMINANT_MATRIX, 1)
    end

    @testset "scores are finite" begin
        @test all(isfinite, scores)
    end

    @testset "score ordering is consistent with ranking" begin
        ranks = rank_locations(DOMINANT_MATRIX, DOMINANT_PREFS)
        # The option with rank 1 should have the highest score.
        best_idx = findfirst(==(1), ranks)
        @test scores[best_idx] == maximum(scores)
    end
end

# rank_scores (DataFrame)

@testset "rank_scores — DataFrame dispatch" begin
    scores_mat = rank_scores(DOMINANT_MATRIX, DOMINANT_PREFS)
    scores_df = rank_scores(DOMINANT_DF, DOMINANT_PREFS)

    @testset "DataFrame and Matrix dispatch agree" begin
        @test scores_df ≈ scores_mat
    end
end

# Monotonicity

@testset "score–rank monotonicity" begin
    scores = rank_scores(DOMINANT_MATRIX, DOMINANT_PREFS)
    ranks = rank_locations(DOMINANT_MATRIX, DOMINANT_PREFS)

    # A higher score should correspond to a lower (better) rank number.
    rank_from_score = sortperm(sortperm(-scores))   # negate so highest score → rank 1
    @test rank_from_score == ranks
end

# Weight scale invariance

@testset "weight scale invariance" begin
    # Doubling all weights should not change the ranking.
    scaled_prefs = Dict(
        :weights => DOMINANT_PREFS[:weights] .* 2.0,
        :directions => DOMINANT_PREFS[:directions],
    )
    @test rank_locations(DOMINANT_MATRIX, DOMINANT_PREFS) ==
          rank_locations(DOMINANT_MATRIX, scaled_prefs)
end

# Alternative methods

@testset "alternative MCDA methods" begin
    for method in [topsis, waspas, grey]
        @testset "$(method)" begin
            ranks = rank_locations(DOMINANT_MATRIX, DOMINANT_PREFS; method=method)
            @test length(ranks) == size(DOMINANT_MATRIX, 1)
            @test all(1 .<= ranks .<= size(DOMINANT_MATRIX, 1))
            # Option 1 should remain rank 1 regardless of method,
            # given how dominant it is across all criteria.
            @test ranks[1] == 1
        end
    end
end
