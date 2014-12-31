return [=[
package ui

type windowDialog interface {
  openFile(f func(filename string))
}

func OpenFile(win Window, f func(filename string)) {
  if win == nil {
    panic(''Window passed to OpenFile() cannot be nil'')
  }
  win.openFile(f)
}
]=]
