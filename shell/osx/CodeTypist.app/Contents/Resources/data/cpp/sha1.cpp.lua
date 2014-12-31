return [=[
inline void calc(void const * src, size_t bytelength, unsigned char * hash) {
  unsigned int result[5] = { 0x67452301, 0xefcdab89, 0x98badcfe,
                             0x10325476, 0xc3d2e1f0 };

  unsigned char const * sarray = (unsigned char const *) src;

  unsigned int w[80];

  size_t endCurrentBlock;
  size_t currentBlock = 0;

  if (bytelength >= 64) {
      size_t const endOfFullBlocks = bytelength - 64;

      while (currentBlock <= endOfFullBlocks) {
          endCurrentBlock = currentBlock + 64;

          for (int roundPos = 0; currentBlock < endCurrentBlock; currentBlock
            += 4)
          {
              w[roundPos++] = (unsigned int) sarray[currentBlock + 3]
                      | (((unsigned int) sarray[currentBlock + 2]) << 8)
                      | (((unsigned int) sarray[currentBlock + 1]) << 16)
                      | (((unsigned int) sarray[currentBlock]) << 24);
          }
          innerHash(result, w);
      }
  }

  endCurrentBlock = bytelength - currentBlock;
  clearWBuffert(w);
  size_t lastBlockBytes = 0;
  for (;lastBlockBytes < endCurrentBlock; ++lastBlockBytes) {
      w[lastBlockBytes >> 2] |= (unsigned int) sarray[lastBlockBytes +
      currentBlock] << ((3 - (lastBlockBytes & 3)) << 3);
  }

  w[lastBlockBytes >> 2] |= 0x80 << ((3 - (lastBlockBytes & 3)) << 3);
  if (endCurrentBlock >= 56) {
      innerHash(result, w);
      clearWBuffert(w);
  }
  w[15] = bytelength << 3;
  innerHash(result, w);

  for (int hashByte = 20; --hashByte >= 0;) {
      hash[hashByte] = (result[hashByte >> 2] >> (((3 - hashByte) & 0x3) << 3))
      & 0xff;
  }
}
]=]
