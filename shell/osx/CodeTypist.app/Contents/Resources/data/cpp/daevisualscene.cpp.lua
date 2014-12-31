return [=[
struct DaeVisualScene
{
  std::string               id;
  std::vector< DaeNode * >  nodes;

  ~DaeVisualScene()
  {
    for( unsigned int i = 0; i < nodes.size(); ++i ) delete nodes[i];
  }


  bool parse( const XMLNode &visSceneNode )
  {
    id = visSceneNode.getAttribute( ''id'', '''' );
    if( id == '''' ) return false;

    XMLNode node1 = visSceneNode.getFirstChild( ''node'' );
    while( !node1.isEmpty() )
    {
      DaeNode *node = new DaeNode();
      if( node->parse( node1 ) ) nodes.push_back( node );
      else delete node;

      node1 = node1.getNextSibling( ''node'' );
    }

    return true;
  }
};
]=]
