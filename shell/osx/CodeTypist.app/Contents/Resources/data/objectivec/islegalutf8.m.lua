return [=[
static int isLegalUTF8(const UTF8 *source, size_t length) {
  const UTF8 *srcptr = source + length;
  UTF8 a;

  switch(length) {
    default: return(0);
    case 4:
      if(JK_EXPECT_F(((a = (*--srcptr)) < 0x80) || (a > 0xBF))) { return(0); }
    case 3:
      if(JK_EXPECT_F(((a = (*--srcptr)) < 0x80) || (a > 0xBF))) { return(0); }
    case 2:
      if(JK_EXPECT_F( (a = (*--srcptr)) > 0xBF               )) { return(0); }

      switch(*source) {
        case 0xE0: if(JK_EXPECT_F(a < 0xA0)) { return(0); } break;
        case 0xED: if(JK_EXPECT_F(a > 0x9F)) { return(0); } break;
        case 0xF0: if(JK_EXPECT_F(a < 0x90)) { return(0); } break;
        case 0xF4: if(JK_EXPECT_F(a > 0x8F)) { return(0); } break;
        default:   if(JK_EXPECT_F(a < 0x80)) { return(0); }
      }

    case 1:
      if(JK_EXPECT_F((JK_EXPECT_T(*source < 0xC2)) && JK_EXPECT_F(*source >=
        0x80))) { return(0); }
  }

  if(JK_EXPECT_F(*source > 0xF4)) { return(0); }

  return(1);
}
]=]
