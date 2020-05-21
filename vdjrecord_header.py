import pandas as pd
import numpy as np
from openpyxl import load_workbook
import os
import sys
from Bio.SeqUtils.ProtParam import ProteinAnalysis
from Bio.SeqUtils import ProtParamData
from Bio import SeqIO
from localcider.sequenceParameters import SequenceParameters
from scipy import stats
from vdjrecord import VDJrecord



results_path = str(sys.argv[1])
try:
	samples_path = str(sys.argv[2])
except:
	samples_path = None

vdjrecord = VDJrecord(samples_path = samples_path)
vdjrecord.load_raw_hdf_path(path = os.path.join(results_path, "raw_output.h5"))
vdjrecord.full_filter()
vdjrecord.analyze_physicochem()
vdjrecord.save_hdf(os.path.join(results_path,'vdj_recoveries.h5'))
vdjrecord.save_excel(os.path.join(results_path,'VDJ_Recoveries.xlsx'))

