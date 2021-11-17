# Standard library
import json
import pickle
import zipfile
import os
import re
import difflib
import shutil

from collections import namedtuple, defaultdict
from dataclasses import dataclass
from datetime import date, time, timedelta
from pathlib import Path
from functools import partial, lru_cache, reduce

# External
import numpy as np
import pandas as pd
import scipy as sp
from dateutil.parser import parse as dateparse

from toolz.functoolz import *
from toolz.itertoolz import *
from toolz.dicttoolz import *

import pyperclip

print(
    "LOADED DEFAULT IMPORTS ~/.ipython/profile_default/startup/00--default-imports.py"
)
