return [[
package io

type multiReader struct {
  readers []Reader
}

func (mr *multiReader) Read(p []byte) (n int, err error) {
  for len(mr.readers) > 0 {
    n, err = mr.readers[0].Read(p)
    if n > 0 || err != EOF {
      if err == EOF {
        err = nil
      }
      return
    }
  mr.readers = mr.readers[1:]
  }
  return 0, EOF
}

func MultiReader(readers ...Reader) Reader {
  r := make([]Reader, len(readers))
  copy(r, readers)
  return &multiReader{r}
}

type multiWriter struct {
  writers []Writer
}

func (t *multiWriter) Write(p []byte) (n int, err error) {
  for _, w := range t.writers {
    n, err = w.Write(p)
    if err != nil {
      return
    }
    if n != len(p) {
      err = ErrShortWrite
      return
    }
  }
  return len(p), nil
}

func MultiWriter(writers ...Writer) Writer {
  w := make([]Writer, len(writers))
  copy(w, writers)
  return &multiWriter{w}
}
]]
