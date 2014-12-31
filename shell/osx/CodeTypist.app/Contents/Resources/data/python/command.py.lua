return [=[
#!/usr/bin/env python
import os

class MoveFileCommand(object):

    def __init__(self, src, dest):
        self.src = src
        self.dest = dest

    def execute(self):
        print('renaming {} to {}'.format(self.src, self.dest))
        os.rename(self.src, self.dest)

    def undo(self):
        print('renaming {} to {}'.format(self.dest, self.src))
        os.rename(self.dest, self.src)

def main():
    command_stack = []

    command_stack.append(MoveFileCommand('foo.txt', 'bar.txt'))
    command_stack.append(MoveFileCommand('bar.txt', 'baz.txt'))

    for cmd in command_stack:
        cmd.execute()

    for cmd in reversed(command_stack):
        cmd.undo()

if __name__ == ''__main__'':
    main()
]=]
