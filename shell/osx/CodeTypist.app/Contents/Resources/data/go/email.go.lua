return [=[
package email

import (
  "bytes"
  "encoding/base64"
  "errors"
  "fmt"
  "io"
  "mime"
  "mime/multipart"
  "net/mail"
  "net/smtp"
  "net/textproto"
  "os"
  "path/filepath"
  "strings"
  "time"
)

const (
  MaxLineLength = 76
)

type Email struct {
  From        string
  To          []string
  Bcc         []string
  Cc          []string
  Subject     string
  Text        []byte
  HTML        []byte
  Headers     textproto.MIMEHeader
  Attachments []*Attachment
  ReadReceipt []string
}
]=]
