from collections import Counter, namedtuple, defaultdict
from dataclasses import dataclass
import numpy as np
from datetime import date, time, datetime, timedelta
import dateutil.parser as dp
import re
from itertools import *
import scipy as sp
import pandas as pd

c = get_config()

c.InteractiveShellApp.extensions.append('autoreload')
c.InteractiveShellApp.exec_lines.append('%autoreload 2')
c.InteractiveShellApp.exec_lines.append('print("Autoreload and default imports enabled")')

