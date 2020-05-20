import pandas as pd
import os
import VDJ
import numpy as np
from multiprocessing import Pool, cpu_count
import time
import sys
start_time = time.time()

receptor = str(sys.argv[1])
path = str(sys.argv[2])
cores = cpu_count()
print "Using %s cores" %cores

dbpath = "/shared/db/"

def clean_df(df):
    clean = False
    count = 0
    while clean == False:
        for i in range(len(df)):
            count +=1
            if i == (len(df) - 2):
                clean = True
                break
            if (df["Position"].iloc[i+2] - df["Position"].iloc[i]) < len(df["Read"].iloc[i]):
                df.drop(df.index[i+1], inplace=True)
                df = df.sort_values("Position")
                df = df.reset_index(drop=True)
                break
            else:
                pass
    return df

def build_df(path,files):
    df = pd.DataFrame(columns = ["Read ID", "Read", "Chromosome", "Position", "VID", "V Match", "V Match Percent", "V Match Length", "JID", "J Match", "J Match Percent", "J Match Length", "JUNCTION", "CDR3", "Reason"])
    for file in files:
        mycols = ["Read ID", "B", "Chromosome", "Position", "E", "F", "G", "H", "I", "Read", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",  "V", "W", "X", "Y"]
        try:
            df2 = pd.read_csv(path+file, sep='\t', names=mycols)
        except:
            print "File read error %s" %file
            pass
        df2 = df2[["Read ID", "Read", "Chromosome", "Position"]]
        df2["Filename"] = file
        #df2 = df2.drop_duplicates(["Position"], keep='first')
        df2 = df2.sort_values("Position")
        #df2 = clean_df(df2)
        df = df.append(df2, ignore_index=True)  
        df = df.reset_index(drop=True) 
    return df

files = [f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f))]
print("Found {0} files in {1}".format(len(files), path))
fulldf = build_df(path,files)
df = fulldf.drop_duplicates(["Read"], keep='first')
df = df.reset_index(drop=True)
print("{0} Starting. Aligning {1} Reads".format(receptor, len(df)))
results = pd.DataFrame()
def f(i):
    read = df["Read"].iloc[i]
    if receptor == "TRA":
        a = VDJ.TRA(read, dbpath)
    elif receptor == "TRB":
        a = VDJ.TRB(read, dbpath)
    elif receptor == "TRD":
        a = VDJ.TRD(read, dbpath)
    elif receptor == "TRG":
        a = VDJ.TRG(read, dbpath)
    elif receptor == "IGH":
        a = VDJ.IGH(read, dbpath)
    elif receptor == "IGK":
        a = VDJ.IGK(read, dbpath)
    elif receptor == "IGL":
        a = VDJ.IGL(read, dbpath)
    result = a.run()
    return result
p = Pool(cpu_count())
source = p.map(f, range(len(df["Read"])))
try:
    results = pd.concat(source, axis=1, ignore_index=True).transpose()
except:
    pass
cols_to_use = df.columns.difference(results.columns)
df2 = pd.concat([df[cols_to_use], results], axis=1)
fulldf = fulldf[["Read ID", "Read"]]
df2 = df2.drop("Read ID", axis = 1)
fulldf = pd.merge(fulldf, df2, how='left', on='Read')
fulldf = fulldf[["Filename", "Read ID", "Read", "Chromosome", "Position", "VID", "V Match", "V Match Percent", "V Match Length", "JID", "J Match", "J Match Percent", "J Match Length", "JUNCTION", "CDR3", "Reason"]]
fulldf.to_hdf(dir+"raw_output.h5", receptor)
del df2
del fulldf
del df
del results
print("{0} Complete. Time since start: --- {1} seconds ---".format(receptor,(time.time() - start_time)))
