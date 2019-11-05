import pandas as pd

clean_a = pd.read_csv('clean_a.csv')
clean_b = pd.read_csv('clean_b.csv')
noise_a = pd.read_csv('noise_a.csv')
noise_b = pd.read_csv('noise_b.csv')

clean_a.to_json(r'clean_a.json', orient='records')
clean_b.to_json(r'clean_b.json', orient='records')
noise_a.to_json(r'noise_a.json', orient='records')
noise_b.to_json(r'noise_b.json', orient='records')
