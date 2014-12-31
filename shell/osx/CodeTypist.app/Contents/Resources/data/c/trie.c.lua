return [=[
static TrieNode *trie_find_end(Trie *trie, char *key)
{
    TrieNode *node;
    char *p;

    node = trie->root_node;

    for (p=key; *p != '\0'; ++p) {
          if (node == NULL) {
                  return NULL;
          }
          node = node->next[(unsigned char) *p];
    }

    return node;
}
]=]
