return [=[
float64
vector_sum_norm(float32 * vec, int32 len)
{
    float64 sum, f;
    int32 i;

    sum = 0.0;
    for (i = 0; i < len; i++)
        sum += vec[i];

    if (sum != 0.0) {
        f = 1.0 / sum;
        for (i = 0; i < len; i++)
            vec[i] *= f;
    }

    return sum;
}
]=]
