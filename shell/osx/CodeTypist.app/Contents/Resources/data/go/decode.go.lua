return [=[
func Decode(r io.Reader) ([]byte, MetaData, error) {
  d, err := NewDecoder(r)
  if err != nil {
    return nil, MetaData{}, err
  }

  data := make([]byte, 0,
  d.TotalSamples*int64(d.NChannels)*int64(d.BitsPerSample/8))

  for {
    frame, err := d.Next()
    if err == io.EOF {
            break
    } else if err != nil {
            return nil, MetaData{}, err
    }
    data = append(data, frame...)
  }

  h := md5.New()
  if _, err := h.Write(data); err != nil {
    return nil, MetaData{}, err
  }
  if !bytes.Equal(h.Sum(nil), d.MD5[:]) {
    return nil, MetaData{}, errors.New(''Bad MD5 checksum'')
  }
  return data, d.MetaData, nil
}
]=]
