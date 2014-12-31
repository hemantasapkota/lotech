return [=[
package leveldb

import (
  ''container/list''
  ''fmt''
  ''io''
  ''os''
  ''runtime''
  ''strings''
  ''sync''
  ''sync/atomic''
  ''time''

  ''github.com/syndtr/goleveldb/leveldb/errors''
  ''github.com/syndtr/goleveldb/leveldb/iterator''
  ''github.com/syndtr/goleveldb/leveldb/journal''
  ''github.com/syndtr/goleveldb/leveldb/memdb''
  ''github.com/syndtr/goleveldb/leveldb/opt''
  ''github.com/syndtr/goleveldb/leveldb/storage''
  ''github.com/syndtr/goleveldb/leveldb/table''
  ''github.com/syndtr/goleveldb/leveldb/util''
)

type DB struct {
  seq uint64

  s *session

  memMu             sync.RWMutex
  memPool           chan *memdb.DB
  mem, frozenMem    *memDB
  journal           *journal.Writer
  journalWriter     storage.Writer
  journalFile       storage.File
  frozenJournalFile storage.File
  frozenSeq         uint64

  snapsMu   sync.Mutex
  snapsList *list.List

  aliveSnaps, aliveIters int32

  writeC       chan *Batch
  writeMergedC chan bool
  writeLockC   chan struct{}
  writeAckC    chan error
  writeDelay   time.Duration
  writeDelayN  int
  journalC     chan *Batch
  journalAckC  chan error

  tcompCmdC   chan cCmd
  tcompPauseC chan chan<- struct{}
  mcompCmdC   chan cCmd
  compErrC    chan error
  compPerErrC chan error
  compErrSetC chan error
  compStats   []cStats

  closeW sync.WaitGroup
  closeC chan struct{}
  closed uint32
  closer io.Closer
}
]=]
