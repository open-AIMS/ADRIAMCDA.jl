# ADRIAMCDA

Light-weight and cut-down MCDA component wrapping the [JMcDM package](https://github.com/jbytecode/JMcDM)
for the ADRIA decision support framework.

## Installation

From the Pkg REPL (press `]` to enter):

```
pkg> add https://github.com/open-AIMS/ADRIAMCDA.jl
```

## Usage

The default MCDA method adopted (for now) is CoCoSo.

Yazdani, M., Zarate, P., Kazimieras Zavadskas, E. and Turskis, Z. (2019), "A combined compromise solution (CoCoSo) method for multi-criteria decision-making problems", Management Decision, Vol. 57 No. 9, pp. 2501-2519. https://doi.org/10.1108/MD-05-2017-0458

## Worked example

First, define the preferences for each criteria:

```julia
using ADRIAMCDA

# This should be adjusted to reflect the system being assessed
prefs = Dict(
    # Name of each criteria
    :names => ["heat", "waves", "cover", "in_conn", "out_conn"],

    # The desired relative weight to place (0 - 1, higher means more important)
    # Gets normalized so their sum is 0 - 1
    :weights => [1.0, 0.5, 0.8, 0.5, 0.5],

    # Desired directionality - to prefer lower or higher criteria values
    :directions => [minimum, minimum, minimum, maximum, maximum]
)
```

Then define the criteria matrix. Each column represents a criteria, and the values are
normalized on a per-column basis with max-min range normalization.

An example matrix is created below. In practice, the values would represent the "state"
of a system for each criteria.

```julia
dummy_criteria = hcat(
    collect.([
        1:10,  # heat
        1:10,  # waves
        [4.0, 500.0, 6.0, 10.0, 50.0, 100.0, 100.0, 100.0, 100.0, 100.0],  # cover
        [1000.0, 0.1, 6.0, 10.0, 50.0, 100.0, 100.0, 100.0, 100.0, 100.0],  # incoming conn
        [1000.0, 0.9, 6.0, 10.0, 50.0, 100.0, 100.0, 100.0, 100.0, 100.0]  # outgoing conn
    ])...
)
# 10×5 Matrix{Float64}:
#   1.0   1.0    4.0  1000.0  1000.0
#   2.0   2.0  500.0     0.1     0.9
#   3.0   3.0    6.0     6.0     6.0
#   4.0   4.0   10.0    10.0    10.0
#   5.0   5.0   50.0    50.0    50.0
#   6.0   6.0  100.0   100.0   100.0
#   7.0   7.0  100.0   100.0   100.0
#   8.0   8.0  100.0   100.0   100.0
#   9.0   9.0  100.0   100.0   100.0
#  10.0  10.0  100.0   100.0   100.0
```

Based on the criteria and the defined preferences, the locations can then be ranked.
Rankings are returned in "competition" order: a value of 1 indicates "first place" or
"most desirable".

```julia
rankings = rank_locations(dummy_criteria, prefs)
# 10-element Vector{Int64}:
#   1
#   9
#   2
#   3
#   4
#   5
#   6
#   7
#   8
#  10
```

If scores are desired instead:

```julia
rank_scores(dummy_criteria, prefs)
# 10-element Vector{Float64}:
#  3.7240178190888944
#  1.4775280469799914
#  2.523534137686779
#  2.431686854852975
#  2.3913406512090942
#  2.2886988326788242
#  2.1549365172359267
#  2.0098602461381363
#  1.840379445892517
#  1.2937847886739582
```
