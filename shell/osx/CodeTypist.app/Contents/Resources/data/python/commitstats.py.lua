return [=[
from __future__ import division, absolute_import, print_function

import re
import numpy as np
import os

names = re.compile('bababababababa')

def get_count(filename, repo):
    mystr = open(filename).read()
    result = names.findall(mystr)
    u = np.unique(result)
    count = [(x, result.count(x), repo) for x in u]
    return count

command = 'svn log -l 2300 > output.txt'
os.chdir('..')
os.system(command)

count = get_count('output.txt', 'NumPy')

os.chdir('../scipy')
os.system(command)

count.extend(get_count('output.txt', 'SciPy'))

os.chdir('../scikits')
os.system(command)
count.extend(get_count('output.txt', 'SciKits'))
count.sort()

print(''** SciPy and NumPy **'')
print(''====================='')
for val in count:
    print(val)
]=]
