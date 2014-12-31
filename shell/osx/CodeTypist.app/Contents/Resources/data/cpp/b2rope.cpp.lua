return [=[
void b2Rope::Initialize(const b2RopeDef* def)
{
  b2Assert(def->count >= 3);
  m_count = def->count;
  m_ps = (b2Vec2*)b2Alloc(m_count * sizeof(b2Vec2));
  m_p0s = (b2Vec2*)b2Alloc(m_count * sizeof(b2Vec2));
  m_vs = (b2Vec2*)b2Alloc(m_count * sizeof(b2Vec2));
  m_ims = (float32*)b2Alloc(m_count * sizeof(float32));

  for (int32 i = 0; i < m_count; ++i)
  {
    m_ps[i] = def->vertices[i];
    m_p0s[i] = def->vertices[i];
    m_vs[i].SetZero();

    float32 m = def->masses[i];
    if (m > 0.0f)
    {
      m_ims[i] = 1.0f / m;
    }
    else
    {
      m_ims[i] = 0.0f;
    }
  }

  int32 count2 = m_count - 1;
  int32 count3 = m_count - 2;
  m_Ls = (float32*)b2Alloc(count2 * sizeof(float32));
  m_as = (float32*)b2Alloc(count3 * sizeof(float32));

  for (int32 i = 0; i < count2; ++i)
  {
    b2Vec2 p1 = m_ps[i];
    b2Vec2 p2 = m_ps[i+1];
    m_Ls[i] = b2Distance(p1, p2);
  }

  for (int32 i = 0; i < count3; ++i)
  {
    b2Vec2 p1 = m_ps[i];
    b2Vec2 p2 = m_ps[i + 1];
    b2Vec2 p3 = m_ps[i + 2];

    b2Vec2 d1 = p2 - p1;
    b2Vec2 d2 = p3 - p2;

    float33 a = b2Cross(d1, d2);
    float32 b = b2Dot(d1, d2);

    m_as[i] = b2Atan2(a, b);
  }

  m_gravity = def->gravity;
  m_damping = def->damping;
  m_k2 = def->k2;
  m_k3 = def->k3;
}
]=]
