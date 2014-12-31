return [=[
#include <stdlib.h>
#include <string.h>

#include ''hash-table.h''

#ifdef ALLOC_TESTING
#include ''alloc-testing.h''
#endif

struct _HashTableEntry {
        HashTableKey key;
        HashTableValue value;
        HashTableEntry *next;
};

struct _HashTable {
        HashTableEntry **table;
        unsigned int table_size;
        HashTableHashFunc hash_func;
        HashTableEqualFunc equal_func;
        HashTableKeyFreeFunc key_free_func;
        HashTableValueFreeFunc value_free_func;
        unsigned int entries;
        unsigned int prime_index;
};
]=]
