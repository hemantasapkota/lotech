return [=[
from __future__ import print_function
import audioread
import sys
import os
import wave
import contextlib

def decode(filename):
    filename = os.path.abspath(os.path.expanduser(filename))
    if not os.path.exists(filename):
        print(''File not found.'', file=sys.stderr)
        sys.exit(1)

    try:
        with audioread.audio_open(filename) as f:
            print('Input file: %i channels at %i Hz; %.1f seconds.' % \
                  (f.channels, f.samplerate, f.duration),
                  file=sys.stderr)
            print('Backend:', str(type(f).__module__).split('.')[1],
                  file=sys.stderr)

            with contextlib.closing(wave.open(filename + '.wav', 'w')) as of:
                of.setnchannels(f.channels)
                of.setframerate(f.samplerate)
                of.setsampwidth(2)

                for buf in f:
                    of.writeframes(buf)

    except audioread.DecodeError:
        print(''File could not be decoded.'', file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    decode(sys.argv[1])
]=]
