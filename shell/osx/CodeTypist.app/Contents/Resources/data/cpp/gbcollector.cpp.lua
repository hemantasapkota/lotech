return [=[
GarbageCollector Heap::SelectGarbageCollector(AllocationSpace space,
                                              const char** reason) {
  if (space != NEW_SPACE) {
    isolate_->counters()->gc_compactor_caused_by_request()->Increment();
    *reason = ''GC in old space requested'';
    return MARK_COMPACTOR;
  }

  if (FLAG_gc_global || (FLAG_stress_compaction && (gc_count_ & 1) != 0)) {
    *reason = ''GC in old space forced by flags'';
    return MARK_COMPACTOR;
  }

  if (OldGenerationAllocationLimitReached()) {
    isolate_->counters()->gc_compactor_caused_by_promoted_data()->Increment();
    *reason = ''promotion limit reached'';
    return MARK_COMPACTOR;
  }

  if (old_gen_exhausted_) {
    isolate_->counters()
        ->gc_compactor_caused_by_oldspace_exhaustion()
        ->Increment();
    *reason = ''old generations exhausted'';
    return MARK_COMPACTOR;
  }

  if (isolate_->memory_allocator()->MaxAvailable() <= new_space_.Size()) {
    isolate_->counters()
        ->gc_compactor_caused_by_oldspace_exhaustion()
        ->Increment();
    *reason = ''scavenge might not succeed'';
    return MARK_COMPACTOR;
  }

  *reason = NULL;
  return SCAVENGER;
}
]=]
