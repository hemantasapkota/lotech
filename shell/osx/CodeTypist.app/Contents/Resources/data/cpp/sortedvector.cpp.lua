return [=[
template<typename _KeyTp, typename _ValueTp> struct sorted_vector
{
    sorted_vector() {}
    void clear() { vec.clear(); }
    size_t size() const { return vec.size(); }
    _ValueTp& operator [](size_t idx) { return vec[idx]; }
    const _ValueTp& operator [](size_t idx) const { return vec[idx]; }

    void add(const _KeyTp& k, const _ValueTp& val)
    {
        std::pair<_KeyTp, _ValueTp> p(k, val);
        vec.push_back(p);
        size_t i = vec.size()-1;
        for( ; i > 0 && vec[i].first < vec[i-1].first; i-- )
            std::swap(vec[i-1], vec[i]);
        CV_Assert( i == 0 || vec[i].first != vec[i-1].first );
    }

    bool find(const _KeyTp& key, _ValueTp& value) const
    {
        size_t a = 0, b = vec.size();
        while( b > a )
        {
            size_t c = (a + b)/2;
            if( vec[c].first < key )
                a = c+1;
            else
                b = c;
        }

        if( a < vec.size() && vec[a].first == key )
        {
            value = vec[a].second;
            return true;
        }
        return false;
    }

    void get_keys(std::vector<_KeyTp>& keys) const
    {
        size_t i = 0, n = vec.size();
        keys.resize(n);

        for( i = 0; i < n; i++ )
            keys[i] = vec[i].first;
    }

    std::vector<std::pair<_KeyTp, _ValueTp> > vec;
};
]=]
