return [=[
- (BOOL)close {

    [self clearCachedStatements];
    [self closeOpenResultSets];

    if (!_db) {
        return YES;
    }

    int  rc;
    BOOL retry;
    BOOL triedFinalizingOpenStatements = NO;

    do {
        retry   = NO;
        rc      = sqlite3_close(_db);
        if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
            if (!triedFinalizingOpenStatements) {
                triedFinalizingOpenStatements = YES;
                sqlite3_stmt *pStmt;
                while ((pStmt = sqlite3_next_stmt(_db, nil)) !=0) {
                    NSLog(@''Closing leaked statement'');
                    sqlite3_finalize(pStmt);
                    retry = YES;
                }
            }
        }
        else if (SQLITE_OK != rc) {
            NSLog(@''error closing!: %d'', rc);
        }
    }
    while (retry);

    _db = nil;
    return YES;
}
]=]
