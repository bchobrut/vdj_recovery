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


class VDJrecord(object):
    
    def __init__(self, samples_path=None):
        self.samples_path = samples_path
    
    def load_raw_excel_path(self, path):
        print ("Loading excel files from path: %s" %path)
        self.raw = pd.DataFrame()
        for file in os.listdir(path):
            if file.endswith(".xlsx") and not file.startswith('~') and not file.startswith('V'):
                filepath = os.path.join(path, file)
                print ("Loading: %s"%filepath)
                df = pd.read_excel(filepath, sheetname=0)
                df["Receptor"] = file.replace(".xlsx", "")
                self.raw = pd.concat([self.raw, df])
        self.filtered = self.raw
        print ("Loading excel files from path complete")
        return self.raw
        
    def load_raw_hdf_path(self, path):
        print ("Loading hdf files from path: %s" %path)
        self.raw = pd.DataFrame()
        for receptor in ["TRA", "TRB", "TRG", "TRD", "IGH", "IGK", "IGL", "TRA_UM", "TRB_UM", "TRG_UM", "TRD_UM", "IGH_UM", "IGK_UM", "IGL_UM"]:
            print ("Loading hdf %s" %receptor.replace("_UM", "")
            df = pd.read_hdf(path,receptor.replace("_UM", ""))
            df["Receptor"] = receptor.replace("_UM", "")
            self.raw = pd.concat([self.raw, df])
        self.filtered = self.raw
        print ("Loading hdf files from path complete")
        return self.raw
    
    def save_hdf(self, filepath):
        print ("Saving data to hdf file: %s" %filepath)
        if hasattr(self, 'raw'):
            print( 'Saving raw data to hdf')
            self.raw.to_hdf(filepath, "raw")
        if hasattr(self, 'filtered_productive'):
            print ('Saving filtered productive data to hdf')
            self.filtered_productive.to_hdf(filepath, "filtered_productive")
        if hasattr(self, 'filtered_unproductive'):
            print ('Saving filtered unproductive data to hdf')
            self.filtered_unproductive.to_hdf(filepath, "filtered_unproductive")
        if hasattr(self, 'physicochem'):
            print( 'Saving physicochemical data to hdf')
            self.physicochem.to_hdf(filepath, "physicochem")
            
    def save_excel(self, filepath):
        print ("Saving data to excel file: %s" %filepath)
        writer = pd.ExcelWriter(filepath)
        if hasattr(self, 'filtered_productive'):
            print ('Saving filtered productive data to excel')
            self.filtered_productive.to_excel(writer, "filtered_productive", index=False)
        if hasattr(self, 'filtered_unproductive'):
            print ('Saving filtered unproductive data to excel')
            self.filtered_unproductive.to_excel(writer, "filtered_unproductive", index=False)
        if hasattr(self, 'physicochem'):
            print ('Saving physicochemical data to excel')
            self.physicochem.to_excel(writer, "physicochem", index=False)
        writer.save()

    def load_hdf(self, filepath):
        print ("Loading data from hdf file: %s" %filepath)
        try:
            print ("Loading raw data from hdf file")
            self.raw = pd.read_hdf(filepath, "raw")
            self.filtered = self.raw
        except:
            raise ValueError("Hdf raw file doesn't exist")
        try:
            print( "Loading filtered productive data from hdf file")
            self.filtered_productive = pd.read_hdf(filepath, "filtered_productive")
        except:
            print ("Filtered productive data doesn't exist in file")
        try:
            print ("Loading filtered unproductive data from hdf file")
            self.filtered_unproductive = pd.read_hdf(filepath, "filtered_unproductive")
        except:
            print ("Filtered unproductive data doesn't exist in file")
        try:
            print ("Loading physicochemical data from hdf file")
            self.physicochem = pd.read_hdf(filepath, "physicochem")
        except:
            print( "Physicochemical data doesn't exist in file")


    def nt_match_length_filter(self, V_length = 14, J_length = 14):
        print ("Filtering match lengths: V = {0}, J = {1}".format(V_length, J_length))
        self.filtered = self.filtered.loc[self.filtered["V Match Length"] >= V_length]
        self.filtered = self.filtered.loc[self.filtered["J Match Length"] >= J_length]
        return self.filtered

    def nt_match_percent_filter(self, V_percent = 50, J_percent = 50):
        print ("Filtering match percents: V = {0}%, J = {1}%".format(V_percent, J_percent))
        self.filtered = self.filtered.loc[self.filtered["V Match Percent"] >= V_percent]
        self.filtered = self.filtered.loc[self.filtered["J Match Percent"] >= J_percent]
        return self.filtered
    
    def raw_filename_format(self):
	print ("Loading samples db: %s" %self.samples_path)
        self.samples = pd.read_csv(self.samples_path)
        filenamelist = []
        samplelist = []
        self.raw["Filename"] = self.raw["Filename"].str.replace("sliced_","")
        self.raw["Filename"] = self.raw["Filename"].str.replace(".tsv","")
        self.raw["Filename"] = self.raw["Filename"].str.replace("_unmapped","")
        print ("Matching filenames to samples db")
        for i in self.raw["Filename"]:
            filename = self.samples.loc[self.samples["File Name"] == i, ["Case ID", "Sample"]]
            filenamelist.append(filename["Case ID"].iloc[0])
            samplelist.append(filename["Sample"].iloc[0])
        self.raw["Filename"] = filenamelist
        self.raw.insert(1, 'Sample', samplelist)
        self.filtered = self.raw
        return self.raw
    
    def productive_unproductive_split(self):
        print ("Splitting filtered data into productive and unproductive sets")
        self.filtered_unproductive = self.filtered[self.filtered["CDR3"] == 'Unproductive']
        self.filtered_productive = self.filtered[self.filtered["CDR3"] != 'Unproductive']
	
	if self.samples_path == None:
		self.filtered_productive = self.filtered_productive[['Filename','Read ID','Read','Chromosome','Position','VID','V Match','V Match Percent','V Match Length','JID','J Match','J Match Percent','J Match Length','JUNCTION','CDR3','Receptor']]
		self.filtered_unproductive = self.filtered_unproductive[['Filename','Read ID','Read','Chromosome','Position','VID','V Match','V Match Percent','V Match Length','JID','J Match','J Match Percent','J Match Length','JUNCTION','CDR3','Reason','Receptor']]
	else:
		self.filtered_productive = self.filtered_productive[['Filename','Sample','Read ID','Read','Chromosome','Position','VID','V Match','V Match Percent','V Match Length','JID','J Match','J Match Percent','J Match Length','JUNCTION','CDR3','Receptor']]
		self.filtered_unproductive = self.filtered_unproductive[['Filename','Sample','Read ID','Read','Chromosome','Position','VID','V Match','V Match Percent','V Match Length','JID','J Match','J Match Percent','J Match Length','JUNCTION','CDR3','Reason','Receptor']]

        return self.filtered_productive, self.filtered_unproductive
    
    def full_filter(self):
	if self.samples_path == None:
		self.raw["Filename"] = self.raw["Filename"].str.replace(".tsv","")
		self.filtered = self.raw
	else:
        	self.raw_filename_format()
        self.nt_match_length_filter()
        self.nt_match_percent_filter()
        self.productive_unproductive_split()
        return self.filtered_productive, self.filtered_unproductive

    def analyze_physicochem(self):
        print ("Analyzing CDR3 physicochemical data")
	if self.samples_path == None:
		df = self.filtered_productive[["Filename", "CDR3", "Receptor"]]
	else:
        	df = self.filtered_productive[["Filename", "CDR3", "Sample", "Receptor"]]
        length = []
        fraction_tiny=[]
        fraction_small=[]
        fraction_charged=[]
        fraction_positive=[]
        fraction_negative=[]
        fraction_expanding=[]
        fraction_aromatic=[]
        molecular_weight = []
        isoelectric_point = []
        gravy = []
        aromaticity = []
        instability_index = []
        secondary_structure_helix = []
        secondary_structure_turn = []
        secondary_structure_sheet = []
        mean_hydropathy = []
        uversky_hydropathy = []
        NCPR = []
        kappa = []
        omega = []
        PPII_propensity = []
        delta = []
        fraction_disorder_promoting = []
        
        def count_aa(sequence, aas):
            count = 0
            for aa in aas:
                count += sequence.count(aa)
            return count
            
        def sequence_analysis(sequence):
            try:
                cdr3 = ProteinAnalysis(str(sequence))
                cidercdr3 = SequenceParameters(str(sequence)) 
                molecular_weight = (cdr3.molecular_weight())
                isoelectric_point = (cdr3.isoelectric_point())
                gravy = (cdr3.gravy())
                aromaticity = (cdr3.aromaticity())
                instability_index = (cdr3.instability_index())
                secondary = cdr3.secondary_structure_fraction()
                secondary_structure_helix = (secondary[0])
                secondary_structure_turn = (secondary[1])
                secondary_structure_sheet = (secondary[2])
                length = (len(sequence))
                fraction_tiny = (float(count_aa(sequence,"ABCGST"))/float(len(sequence)))
                fraction_small = (float(count_aa(sequence,"ABCDGNPSTV"))/float(len(sequence)))
                fraction_aromatic = (float(count_aa(sequence,"FHWY"))/float(len(sequence)))
                fraction_charged = (cidercdr3.get_FCR())
                fraction_positive = (cidercdr3.get_fraction_positive())
                fraction_negative = (cidercdr3.get_fraction_negative())
                fraction_expanding = (cidercdr3.get_fraction_expanding())
                mean_hydropathy = (cidercdr3.get_mean_hydropathy())
                NCPR = (cidercdr3.get_NCPR())
                uversky_hydropathy = (cidercdr3.get_uversky_hydropathy())
                kappa = (cidercdr3.get_mean_hydropathy())
                omega = (cidercdr3.get_Omega())
                PPII_propensity = (cidercdr3.get_PPII_propensity())
                delta = (cidercdr3.get_delta())
                fraction_disorder_promoting = (cidercdr3.get_fraction_disorder_promoting())
                return (molecular_weight, isoelectric_point, gravy, aromaticity, instability_index, secondary_structure_helix, secondary_structure_turn, secondary_structure_sheet, length, fraction_tiny, fraction_small, fraction_aromatic, fraction_charged, fraction_positive, fraction_negative, fraction_expanding, mean_hydropathy, NCPR, uversky_hydropathy,  kappa, omega, PPII_propensity, delta, fraction_disorder_promoting)
            except:
                return (np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan,  np.nan, np.nan, np.nan, np.nan, np.nan)

        for sequence in df["CDR3"]:
            a = sequence_analysis(sequence)
            molecular_weight.append(a[0])
            isoelectric_point.append(a[1])
            gravy.append(a[2])
            aromaticity.append(a[3])
            instability_index.append(a[4])
            secondary_structure_helix.append(a[5])
            secondary_structure_turn.append(a[6])
            secondary_structure_sheet.append(a[7])
            length.append(a[8])
            fraction_tiny.append(a[9])
            fraction_small.append(a[10])
            fraction_aromatic.append(a[11])
            fraction_charged.append(a[12])
            fraction_positive.append(a[13])
            fraction_negative.append(a[14])
            fraction_expanding.append(a[15])
            mean_hydropathy.append(a[16])
            NCPR.append(a[17])
            uversky_hydropathy.append(a[18])
            kappa.append(a[19])
            omega.append(a[20])
            PPII_propensity.append(a[21])
            delta.append(a[22])
            fraction_disorder_promoting.append(a[23])
        df["length"] = length
        df["fraction_tiny"] = fraction_tiny
        df["fraction_small"] = fraction_small
        df["fraction_aromatic"] = fraction_aromatic
        df["fraction_charged"] = fraction_charged
        df["fraction_positive"] = fraction_positive
        df["fraction_negative"] = fraction_negative
        df["fraction_expanding"] = fraction_expanding
        df["fraction_disorder_promoting"] = fraction_disorder_promoting
        df["molecular_weight"] = molecular_weight
        df["isoelectric_point"] = isoelectric_point
        df["ncpr"] = NCPR
        df["mean_hydropathy"] = mean_hydropathy
        df["uversky_hydropathy"] = uversky_hydropathy
        df["ppii_propensity"] = PPII_propensity
        df["gravy"] = gravy
        df["aromaticity"] = aromaticity
        df["kappa"] = kappa
        df["omega"] = omega
        df["delta"] = delta
        df["instability_index"] = instability_index
        df["secondary_structure_helix"] = secondary_structure_helix
        df["secondary_structure_turn"] = secondary_structure_turn
        df["secondary_structure_sheet"] = secondary_structure_sheet
        self.physicochem = df
        return self.physicochem
    
