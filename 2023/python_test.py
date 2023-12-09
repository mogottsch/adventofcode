# The user has requested a code solution that works for both series.
# The first series had a complex pattern that required multiple derivations to find a constant difference.
# The second series is a simple arithmetic progression.

# Here's a revised approach that should work for both:


def extrapolate_next(series):
    differences = [series[i] - series[i - 1] for i in range(1, len(series))]
    derived_series = [differences]

    # Loop to derive differences until a pattern emerges or we reach a constant set
    while len(set(derived_series[-1])) > 1:  # Continue until all elements are the same
        current_differences = [
            derived_series[-1][i] - derived_series[-1][i - 1]
            for i in range(1, len(derived_series[-1]))
        ]
        derived_series.append(current_differences)

    # If the first set of differences is constant, we can return the next number in an arithmetic series.
    # Otherwise, we use the last derived constant difference to extrapolate.
    print(f"Derived series: {derived_series}")
    print(f"Length of set: {len(set(derived_series[0]))}")
    if len(set(derived_series[0])) == 1:
        return series[-1] + derived_series[0][0]
    else:
        next_value = series[-1]
        for diff in reversed(derived_series[:-1]):
            next_value += diff[-1]
        return next_value


# Testing the function with both series
series1 = [
    3,
    -3,
    -6,
    11,
    81,
    262,
    654,
    1429,
    2882,
    5527,
    10296,
    18955,
    34930,
    64825,
    120957,
    225074,
    412708,
    735639,
    1255391,
    2011191,
    2927270,
]
series2 = [0, 3, 6, 9, 12, 15]
series3 = [
    10,
    13,
    16,
    21,
    30,
    45,
]

next_series1 = extrapolate_next(series1)
next_series2 = extrapolate_next(series2)
next_series3 = extrapolate_next(series3)

print(next_series1)
print(next_series2)
print(next_series3)
