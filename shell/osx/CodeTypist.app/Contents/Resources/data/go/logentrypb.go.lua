return [=[
package protobuf

import proto ''code.google.com/p/goprotobuf/proto''
import math ''math''

var _ = proto.Marshal
var _ = math.Inf

type LogEntry struct {
  Index            *uint64 `protobuf:''varint,1,req'' json:''Index,omitempty''`
  Term             *uint64 `protobuf:''varint,2,req'' json:''Term,omitempty''`
  CommandName      *string `protobuf:''bytes,3,req'' json:''CommandName,omitempty''`
  Command          []byte  `protobuf:''bytes,4,opt'' json:''Command,omitempty''`
  XXX_unrecognized []byte  `json:''-''`
}

func (m *LogEntry) Reset()         { *m = LogEntry{} }
func (m *LogEntry) String() string { return proto.CompactTextString(m) }
func (*LogEntry) ProtoMessage()    {}

func (m *LogEntry) GetIndex() uint64 {
  if m != nil && m.Index != nil {
          return *m.Index
  }
  return 0
}

func (m *LogEntry) GetTerm() uint64 {
  if m != nil && m.Term != nil {
          return *m.Term
  }
  return 0
}

func (m *LogEntry) GetCommandName() string {
  if m != nil && m.CommandName != nil {
          return *m.CommandName
  }
  return ''''
}

func (m *LogEntry) GetCommand() []byte {
  if m != nil {
          return m.Command
  }
  return nil
}

func init() {
}
]=]
