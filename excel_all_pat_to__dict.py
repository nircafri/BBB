import pandas as pd

excel_file = r'D:\Dropbox (BGU DAL BBB Group)\Nir_Epilepsy_Controls\Epilepsy\Analyse\Excel_results\merged.xlsx'
controls_file = r'D:\Dropbox (BGU DAL BBB Group)\Nir_Epilepsy_Controls\Epilepsy\Analyse\Excel_results\Controls.xlsx'
clinical_data = r'D:\Dropbox (BGU DAL BBB Group)\Nir_Epilepsy_Controls\Epilepsy\Analyse\Epilepsy_clinical_data.xlsx'
clinical_data_df = pd.read_excel(clinical_data, sheet_name='All');
mat = {}
# read sheet 128_Reagions_Linear
result_mat_lin_age = pd.read_excel(excel_file, sheet_name='126_Regions_Linear')
mat['result_mat_lin_age_control'] = pd.read_excel(controls_file, sheet_name='126_Regions_Linear')
codes = clinical_data_df['code']
# remove nan from codes
codes = codes.dropna()
# run over result_mat_lin_age
for index, row in result_mat_lin_age.iterrows():
    # get ID
    Id = row["'ID'"].strip("'")
    # find index in codes that id is contained in
    index_in_codes = codes[[i for i, x in enumerate(codes) if x in Id][0]]
    # change result_mat_lin_age row["'ID'"] to index_in_codes
    result_mat_lin_age.loc[index, "'ID'"] = index_in_codes

# remove rows from clinical_data_df where code is not in result_mat_lin_age
clinical_data_df = clinical_data_df[clinical_data_df['code'].isin(result_mat_lin_age["'ID'"])].reset_index(drop=True)
mat['result_mat_lin_age'] = result_mat_lin_age
# mat['focal_pat_mat_lin'] = result_mat_lin_age where clinical_data_df['Focal/General'] == 'F'
mat['focal_pat_mat_lin'] = result_mat_lin_age[clinical_data_df['Focal/General'] == 'F']
mat['general_pat_mat_lin'] = result_mat_lin_age[clinical_data_df['Focal/General'] == 'G']
# result_mat_lin_age read sheet 
# mat_lin_control = mat['result_mat_lin_age_control']
# mat_tofts_control = mat['result_mat_tofts_age_control']
# mat_lin = mat['result_mat_lin_age']
# mat_tofts = mat['result_mat_tofts_age']
# focal_pat_mat_lin = mat['focal_pat_mat_lin']
# focal_pat_mat_tofts = mat['focal_pat_mat_tofts']
# general_pat_mat_lin = mat['general_pat_mat_lin']
# general_pat_mat_tofts = mat['general_pat_mat_tofts']

# Now you can work with the dataframe 'df'
