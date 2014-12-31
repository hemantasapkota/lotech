return [=[
func openDB(s *session) (*DB, error) {
  start := time.Now()
  db := &DB{
          s: s,
          seq: s.stSeqNum,
          memPool: make(chan *memdb.DB, 1),
          snapsList: list.New(),
          writeC:       make(chan *Batch),
          writeMergedC: make(chan bool),
          writeLockC:   make(chan struct{}, 1),
          writeAckC:    make(chan error),
          journalC:     make(chan *Batch),
          journalAckC:  make(chan error),
          tcompCmdC:   make(chan cCmd),
          tcompPauseC: make(chan chan<- struct{}),
          mcompCmdC:   make(chan cCmd),
          compErrC:    make(chan error),
          compPerErrC: make(chan error),
          compErrSetC: make(chan error),
          compStats:   make([]cStats, s.o.GetNumLevel()),
          closeC: make(chan struct{}),
  }

  if err := db.recoverJournal(); err != nil {
    return nil, err
  }

  if err := db.checkAndCleanFiles(); err != nil {
    if db.journal != nil {
            db.journal.Close()
            db.journalWriter.Close()
    }
    return nil, err
  }

  go db.compactionError()
  go db.mpoolDrain()

  db.closeW.Add(3)
  go db.tCompaction()
  go db.mCompaction()
  go db.jWriter()

  s.logf(''db@open done T·%v'', time.Since(start))

  runtime.SetFinalizer(db, (*DB).Close)
  return db, nil
}
]=]
