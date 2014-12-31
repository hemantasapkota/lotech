return[[
int bst_insert(rb_tree_t *tree, void *key, size_t key_len, void *val, size_t
val_len, rb_node_t **new_node)
{
  rb_node_t *parent = NULL, *curr = tree->root;
  rb_key_t insert_key = { .data = (void *)key, .len = key_len };

  if (!curr) {
    tree->root = rb_node_alloc(key, key_len, val, val_len, parent);

    if (!tree->root)
      return -1;

    if (new_node)
      *new_node = tree->root;

    LOG_DBG(''Added new root'');

    return 1;
  }

  while (1) {
    int comp;

    parent = curr;

    comp = tree->ops->key_compare(&insert_key, &curr->key);

    if (comp < 0) {
      curr = curr->left;

      if (!curr) {
        curr = rb_node_alloc(key, key_len, val, val_len, parent);
        parent->left = curr;
        break;
      }
    } else {
      curr = curr->right;

      if (!curr) {
        curr = rb_node_alloc(key, key_len, val, val_len, parent);
        parent->right = curr;
        break;
      }
    }
  }

  if (new_node)
  *new_node = curr;

  return curr ? 1 : -1;
}
]]
