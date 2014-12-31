return [=[
func NewEmail() *Email {
  return &Email{Headers: textproto.MIMEHeader{}}
}

func (e *Email) Attach(r io.Reader, filename string, c string) (a *Attachment,
err error) {
  var buffer bytes.Buffer
  if _, err = io.Copy(&buffer, r); err != nil {
          return
  }
  at := &Attachment{
          Filename: filename,
          Header:   textproto.MIMEHeader{},
          Content:  buffer.Bytes(),
  }

  if c != '''' {
          at.Header.Set(''Content-Type'', c)
  } else {
          at.Header.Set(''Content-Type'', ''application/octet-stream'')
  }

  at.Header.Set(''Content-Disposition'', fmt.Sprintf(''attachment;
  filename=\''%s\'''', filename))

  at.Header.Set(''Content-ID'', fmt.Sprintf(''<%s>'', filename))
  at.Header.Set(''Content-Transfer-Encoding'', ''base64'')
  e.Attachments = append(e.Attachments, at)

  return at, nil
}
]=]
