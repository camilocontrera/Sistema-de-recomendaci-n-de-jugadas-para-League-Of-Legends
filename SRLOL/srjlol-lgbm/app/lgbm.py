import pandas as pd 
import numpy as np
class Lgbm:
    
    COLS=np.array(['minute', 'building_mid', 'deaths_MIDDLE', 'deaths_BOTTOM',
       'heralds', 'total_gold_MIDDLE', 'deaths_JUNGLE', 'kills_JUNGLE',
       'deaths_TOP', 'kills_TOP', 'building_top',
       'physicalDamageTaken_MIDDLE', 'kills_BOTTOM', 'kills_MIDDLE',
       'building_bot', 'assists_UTILITY', 'deaths_UTILITY',
       'minionsKilled_MIDDLE', 'magicDamageDoneToChampions_MIDDLE'])
    
    def __init__(self, model):
        self.model = model
    
    def predict( self, json_ ):
        for k in json_.keys():
            json_[k] = [json_[k]]
            
        data = pd.DataFrame(json_)
        data_cols = list(data.columns)
        
        if data_cols.sort() == self.COLS.sort():
            print("good")
            return self.model.predict(data)
        else:
            print("bad")
            return None
        