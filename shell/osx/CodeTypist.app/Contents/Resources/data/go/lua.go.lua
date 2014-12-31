return [=[
import ''C''
import ''unsafe''

import ''fmt''

type LuaStackEntry struct {
  Name string
  Source string
  ShortSource string
  CurrentLine int
}

func newState(L *C.lua_State) *State {
  var newstatei interface{}
  newstate := &State{L, make([]interface{}, 0, 8), make([]uint, 0, 8)}
  newstatei = newstate
  ns1 := unsafe.Pointer(&newstatei)
  ns2 := (*C.GoInterface)(ns1)
  C.clua_setgostate(L, *ns2)
  C.clua_initstate(L)
  return newstate
}

func (L *State) addFreeIndex(i uint) {
  freelen := len(L.freeIndices)
  if freelen+1 > cap(L.freeIndices) {
    newSlice := make([]uint, freelen, cap(L.freeIndices)*2)
    copy(newSlice, L.freeIndices)
    L.freeIndices = newSlice
  }
  L.freeIndices = L.freeIndices[0 : freelen+1]
  L.freeIndices[freelen] = i
}

func (L *State) getFreeIndex() (index uint, ok bool) {
  freelen := len(L.freeIndices)
  if freelen > 0 {
    i := L.freeIndices[freelen-1]
    L.freeIndices = L.freeIndices[0:freelen-1]
    return i, true
  }
  return 0, false
}
]=]
