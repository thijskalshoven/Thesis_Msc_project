####-------------------------------####
source('/Users/thijskalshoven/Documents/UU_data_science/6_THESIS_Streamflow_predictions/Data/GitHub/Magni-PCR-GLOBWB-RF-NEW/source/R/fun_0_loadLibrary.R')
####-------------------------------####

stationInfo <- read.csv('/Users/thijskalshoven/Documents/UU_data_science/6_THESIS_Streamflow_predictions/Data/GitHub/Magni-PCR-GLOBWB-RF-NEW/source/data/stationLatLon.csv')

#- stations to use
use_station <- read.csv('/Users/thijskalshoven/Documents/UU_data_science/6_THESIS_Streamflow_predictions/Data/GitHub/Magni-PCR-GLOBWB-RF-NEW/source/data/grdc_no_list.csv', header = FALSE)
grdc_list <- use_station$V1
stationInfo <- stationInfo[stationInfo$grdc_no %in% grdc_list, ]

subsample <- '5'
outputDir <- paste0('/Users/thijskalshoven/Documents/UU_data_science/6_THESIS_Streamflow_predictions/Data/GitHub/OUTPUT_MAGNI/RF/0_rf_input/subsample_',subsample,'/')
dir.create(outputDir, showWarnings = F, recursive = T)

#~ filePathPreds <- '../../../data/predictors/pcr_allpredictors/'
filePathPreds <- '/Users/thijskalshoven/Documents/UU_data_science/6_THESIS_Streamflow_predictions/Data/GitHub/Magni-PCR-GLOBWB-RF-NEW/source/data/predictors/pcr_allpredictors_ALL_low/'
fileListPreds <- list.files(filePathPreds, pattern='.csv')
filenames <- paste0(filePathPreds, fileListPreds)

#---- subsample such that train_stations has between 2/3 and 70% of available data ----#
source('/Users/thijskalshoven/Documents/UU_data_science/6_THESIS_Streamflow_predictions/Data/GitHub/Magni-PCR-GLOBWB-RF-NEW/source/R/2_randomForest/fun_2_0_subsample_train_test.R')
registerDoParallel(12)
print('sampling...')
repeat{
  
  ## subset train station, select and read file tables, collect, read nrow
  train_stations <- stationInfo[sample(nrow(stationInfo),225),] # number of train stations depends on whole set dimension (~70%)
  train_table <- subsample_table(train_stations) %>%           # 321 * 0.7 = 224.7
					mutate(datetime=as.Date(datetime))
  nrow_train <- nrow(train_table)
  
  print('finished: train dataset')
  
  ## same for test stations
  test_stations <- setdiff(stationInfo, train_stations)
  test_table <- subsample_table(test_stations)
  nrow_test <- nrow(test_table)
  
  print('finished: test dataset')
  
  ratio_subsamples <- nrow_train/(nrow_train+nrow_test)
  
  if(ratio_subsamples > 0.66 & ratio_subsamples < 0.73){
    print('subsample successful! writing...')
    break
        }
  else{
    print('subsample failed :/ train dataset too small/big... resampling...')
  }
}

# write tables: train_stations, test_stations, train_table
write.csv(train_stations, paste0(outputDir,'train_stations.csv'), row.names = F)
write.csv(test_stations, paste0(outputDir,'test_stations.csv'), row.names = F)
write.csv(train_table, paste0(outputDir,'train_table_allpredictors.csv'), row.names = F)