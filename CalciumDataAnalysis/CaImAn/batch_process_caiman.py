import sys


sys.path.append(r'/state/partition1/home/pblab/data/MatlabCode/PBLabToolkit/External/CaImAn')
sys.path.append(r'/data/MatlabCode/PBLabToolkit/External/CaImAn')
sys.path.append(r'/export/home/pb/data/MatlabCode/PBLabToolkit/External/CaImAn')

from pathlib2 import Path
from main_pipeline import main

foldername = Path(r'/data/David/THY_1_GCaMP_BEFOREAFTER_TAC_290517')
all_files = foldername.rglob('*DAY*EXP_STIM*FOV*.tif')
# foldername = Path(r'/data/Lior/Multiscaler data/27 September 2017/FOV1_with_go_line')
# all_files = foldername.glob('*.hdf5')
is_multiscaler = False

for file in all_files:
    main(filename=str(file), show_movie=False, h5group='/Full Stack/Channel 1',
         is_multiscaler=is_multiscaler, num_of_channels=2)
