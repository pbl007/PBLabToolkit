#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Complete pipeline for online processing using OnACID. 

@author: Andrea Giovannucci @agiovann and Eftychios Pnevmatikakis @epnev
Special thanks to Andreas Tolias and his lab at Baylor College of Medicine 
for sharing their data used in this demo.
"""
import sys
# if not any('External/CaImAn' in s for s in sys.path):
sys.path.append(r'/state/partition1/home/pblab/data/MatlabCode/PBLabToolkit/External/CaImAn')

import matplotlib
matplotlib.use('TkAgg')
from time import time
import caiman as cm
from caiman.utils.visualization import view_patches_bar
import pylab as pl
from pathlib2 import Path
from caiman.motion_correction import motion_correct_iteration_fast
import cv2
from caiman.utils.visualization import plot_contours
from caiman.source_extraction.cnmf.online_cnmf import bare_initialization
from copy import deepcopy
from helper_funcs import load_object, save_object
from find_files_to_parse import FileFinder
from os import sep
import numpy as np


def main(filename=None, show_movie=True, h5group='mov', is_multiscaler=False, save_results=True,
         num_of_channels=2, channel_of_neurons=1, epochs=2):
    try:
        if __IPYTHON__:
            print('Debugging!')
            # this is used for debugging purposes only. allows to reload classes when changed
            get_ipython().magic('load_ext autoreload')
            get_ipython().magic('autoreload 2')
    except NameError:
        print('Not IPYTHON')
        pass

    if not filename:
        finder = FileFinder()
        fls = finder.find_files()
        folder_name = finder.parent_folder
    else:
        fls = [filename]
        folder_name = str(Path(filename).parent)
    print("Files to be parsed:")
    print(fls)  # your list of files should look something like this

    # %%   Set up some parameters
    ds_factor = 1  # spatial downsampling factor (increases speed but may lose some fine structure)
    init_files = 1  # number of files used for initialization
    online_files = len(fls) - 1  # number of files used for online
    initbatch = 200 # number of frames for initialization (presumably from the first file)
    expected_comps = 200  # maximum number of expected components used for memory pre-allocation (exaggerate here)
    K = 5  # initial number of components
    gSig = tuple(np.ceil(np.array([6, 6]) / ds_factor))  # expected half size of neurons
    p = 1  # order of AR indicator dynamics
    rval_thr = 0.85  # correlation threshold for new component inclusion
    thresh_fitness_delta = -30  # event exceptionality thresholds
    thresh_fitness_raw = -40  #
    mot_corr = True  # flag for online motion correction
    max_shift = np.ceil(10. / ds_factor).astype('int')  # maximum allowed shift during motion correction
    gnb = 1  # number of background components
    len_file = 16000  # upper bound for number of frames in each file (used right below)
    T1 = len(
        fls) * len_file * epochs  # total length of all files (if not known use a large number, then truncate at the end)
    gSig = tuple(np.ceil(np.array(gSig) / ds_factor).astype('int'))
    channel_of_neurons -= 1  # 0-based indexing
    # %%    Initialize movie

    if ds_factor > 1:  # load only the first initbatch frames and possibly downsample them
        Y = cm.load(fls[0], subindices=slice(channel_of_neurons, initbatch, num_of_channels),
                    var_name_hdf5=h5group, is_multiscaler=is_multiscaler).astype(np.float32).resize(1. / ds_factor, 1. / ds_factor)
    else:
        Y = cm.load(fls[0], subindices=slice(channel_of_neurons, initbatch, num_of_channels),
                    var_name_hdf5=h5group, is_multiscaler=is_multiscaler).astype(np.float32)

    metadata = Y.meta_data

    if mot_corr:  # perform motion correction on the first initbatch frames
        mc = Y.motion_correct(max_shift, max_shift)
        Y = mc[0].astype(np.float32)
        borders = np.max(mc[1])
    else:
        Y = Y.astype(np.float32)

    img_min = Y.min()  # minimum value of movie. Subtract it to make the data non-negative
    Y -= img_min
    img_norm = np.std(Y, axis=0)
    img_norm += np.median(img_norm)  # normalizing factor to equalize the FOV
    Y = Y / img_norm[None, :, :]  # normalize data

    _, d1, d2 = Y.shape
    dims = (d1, d2)  # dimensions of FOV
    Yr = Y.to_2D().T  # convert data into 2D array
    merge_thresh = 0.8  # merging threshold, max correlation allowed
    p = 1  # order of the autoregressive system

    Cn_init = Y.local_correlations(swap_dim=False)  # compute correlation image
    # pl.imshow(Cn_init)
    # pl.title('Correlation Image on initial batch')
    # pl.colorbar()

    # %% initialize OnACID with bare initialization

    cnm_init = bare_initialization(Y[:initbatch].transpose(1, 2, 0), init_batch=initbatch/num_of_channels, k=K, gnb=gnb,
                                   gSig=gSig, p=p, minibatch_shape=100, minibatch_suff_stat=5,
                                   update_num_comps=True, rval_thr=rval_thr,
                                   thresh_fitness_delta=thresh_fitness_delta,
                                   thresh_fitness_raw=thresh_fitness_raw,
                                   batch_update_suff_stat=True, max_comp_update_shape=5,
                                   deconv_flag=False,
                                   simultaneously=False, n_refit=0)

    crd = plot_contours(cnm_init.A.tocsc(), Cn_init, thr=0.9)

    # %% Plot initialization results

    A, C, b, f, YrA, sn = cnm_init.A, cnm_init.C, cnm_init.b, cnm_init.f, cnm_init.YrA, cnm_init.sn
    # view_patches_bar(Yr, scipy.sparse.coo_matrix(A.tocsc()[:, :]), C[:, :], b, f, dims[0], dims[1], YrA=YrA[:, :],
    #                  img=Cn_init)

    # %% Prepare object for OnACID

    save_init = False  # flag for saving initialization object. Useful if you want to check OnACID with different parameters but same initialization
    if save_init:
        cnm_init.dview = None
        save_object(cnm_init, fls[0][:-4] + '_DS_' + str(ds_factor) + '.pkl')
        cnm_init = load_object(fls[0][:-4] + '_DS_' + str(ds_factor) + '.pkl')

    cnm_init._prepare_object(np.asarray(Yr), T1, expected_comps, idx_components=None)

    # %% Run OnACID and optionally plot results in real time

    cnm2 = deepcopy(cnm_init)
    cnm2.max_comp_update_shape = np.inf
    cnm2.update_num_comps = True
    t = cnm2.initbatch
    tottime = []
    Cn = Cn_init.copy()

    plot_contours_flag = False  # flag for plotting contours of detected components at the end of each file
    play_reconstr = show_movie  # flag for showing video with results online (turn off flags for improving speed)
    save_movie = False  # flag for saving movie (file could be quite large..)
    movie_name = str(folder_name) + sep + 'output.avi'  # name of movie to be saved
    resize_fact = 1  # image resizing factor

    if online_files == 0:  # check whether there are any additional files
        process_files = fls[init_files-1]  # end processing at this file
        init_batch_iter = [initbatch + channel_of_neurons]  # place where to start
        end_batch = T1 * num_of_channels
    else:
        process_files = fls[:init_files + online_files]  # additional files
        init_batch_iter = [initbatch * num_of_channels] + [channel_of_neurons] * online_files  # where to start reading at each file

    shifts = []
    if save_movie and play_reconstr:
        fourcc = cv2.VideoWriter_fourcc('8', 'B', 'P', 'S')
        out = cv2.VideoWriter(movie_name, fourcc, 30.0, tuple([int(2 * x * resize_fact) for x in cnm2.dims]))

    for iter in range(epochs):
        if iter > 0:
            process_files = fls[:init_files + online_files]  # if not on first epoch process all files from scratch
            init_batch_iter = [channel_of_neurons] * (online_files + init_files)  #

        if type(process_files) is str:
            process_files = [process_files]

        for file_count, ffll in enumerate(process_files):  # np.array(fls)[np.array([1,2,3,4,5,-5,-4,-3,-2,-1])]:
            print('Now processing file ' + ffll)
            Y_ = cm.load(ffll, subindices=slice(init_batch_iter[file_count], T1, num_of_channels),
                         var_name_hdf5=h5group, is_multiscaler=is_multiscaler)

            if plot_contours_flag:  # update max-correlation (and perform offline motion correction) just for illustration purposes
                if ds_factor > 1:
                    Y_1 = Y_.resize(1. / ds_factor, 1. / ds_factor, 1)
                else:
                    Y_1 = Y_.copy()
                    if mot_corr:
                        templ = (cnm2.Ab.data[:cnm2.Ab.indptr[1]] * cnm2.C_on[0, t - 1]).reshape(cnm2.dims,
                                                                                                 order='F') * img_norm
                        newcn = (Y_1 - img_min).motion_correct(max_shift, max_shift, template=templ)[0].local_correlations(
                            swap_dim=False)
                        Cn = np.maximum(Cn, newcn)
                    else:
                        Cn = np.maximum(Cn, Y_1.local_correlations(swap_dim=False))

            old_comps = cnm2.N  # number of existing components
            for frame_count, frame in enumerate(Y_):  # now process each file
                if np.isnan(np.sum(frame)):
                    raise Exception('Frame ' + str(frame_count) + ' contains nan')
                if t % 100 == 0:
                    print('Epoch: ' + str(iter + 1) + '. ' + str(t) + ' frames have been processed in total. ' + str(
                        cnm2.N - old_comps) + ' new components were added. Total number of components is ' + str(
                        cnm2.Ab.shape[-1] - gnb))
                    old_comps = cnm2.N

                t1 = time()  # count time only for the processing part
                frame_ = frame.copy().astype(np.float32)  #
                if ds_factor > 1:
                    frame_ = cv2.resize(frame_, img_norm.shape[::-1])  # downsample if necessary

                frame_ -= img_min  # make data non-negative

                if mot_corr:  # motion correct
                    templ = cnm2.Ab.dot(cnm2.C_on[:cnm2.M, t - 1]).reshape(cnm2.dims, order='F') * img_norm
                    frame_cor, shift = motion_correct_iteration_fast(frame_, templ, max_shift, max_shift)
                    shifts.append(shift)
                else:
                    templ = None
                    frame_cor = frame_

                frame_cor = frame_cor / img_norm  # normalize data-frame
                cnm2.fit_next(t, frame_cor.reshape(-1, order='F'))  # run OnACID on this frame
                tottime.append(time() - t1)  # store time

                t += 1

                if t % 1000 == 0 and plot_contours_flag:
                    pl.cla()
                    A = cnm2.Ab[:, cnm2.gnb:]
                    crd = cm.utils.visualization.plot_contours(A, Cn, thr=0.9)  # update the contour plot every 1000 frames
                    pl.pause(1)

                if play_reconstr:  # generate movie with the results
                    A, b = cnm2.Ab[:, cnm2.gnb:], cnm2.Ab[:, :cnm2.gnb].toarray()
                    C, f = cnm2.C_on[cnm2.gnb:cnm2.M, :], cnm2.C_on[:cnm2.gnb, :]
                    comps_frame = A.dot(C[:, t - 1]).reshape(cnm2.dims, order='F') * img_norm / np.max(
                        img_norm)  # inferred activity due to components (no background)
                    bgkrnd_frame = b.dot(f[:, t - 1]).reshape(cnm2.dims, order='F') * img_norm / np.max(
                        img_norm)  # denoised frame (components + background)
                    all_comps = (np.array(A.sum(-1)).reshape(cnm2.dims, order='F'))  # spatial shapes
                    frame_comp_1 = cv2.resize(np.concatenate([frame_ / np.max(img_norm), all_comps * 3.], axis=-1),
                                              (2 * np.int(cnm2.dims[1] * resize_fact), np.int(cnm2.dims[0] * resize_fact)))
                    frame_comp_2 = cv2.resize(np.concatenate([comps_frame * 10., comps_frame + bgkrnd_frame], axis=-1),
                                              (2 * np.int(cnm2.dims[1] * resize_fact), np.int(cnm2.dims[0] * resize_fact)))
                    frame_pn = np.concatenate([frame_comp_1, frame_comp_2], axis=0).T
                    vid_frame = np.repeat(frame_pn[:, :, None], 3, axis=-1)
                    vid_frame = np.minimum((vid_frame * 255.), 255).astype('u1')
                    cv2.putText(vid_frame, 'Raw Data', (5, 20), fontFace=5, fontScale=1.2, color=(0, 255, 0), thickness=1)
                    cv2.putText(vid_frame, 'Inferred Activity', (np.int(cnm2.dims[0] * resize_fact) + 5, 20), fontFace=5,
                                fontScale=1.2, color=(0, 255, 0), thickness=1)
                    cv2.putText(vid_frame, 'Identified Components', (5, np.int(cnm2.dims[1] * resize_fact) + 20),
                                fontFace=5, fontScale=1.2, color=(0, 255, 0), thickness=1)
                    cv2.putText(vid_frame, 'Denoised Data',
                                (np.int(cnm2.dims[0] * resize_fact) + 5, np.int(cnm2.dims[1] * resize_fact) + 20),
                                fontFace=5, fontScale=1.2, color=(0, 255, 0), thickness=1)
                    cv2.putText(vid_frame, 'Frame = ' + str(t),
                                (vid_frame.shape[1] // 2 - vid_frame.shape[1] // 10, vid_frame.shape[0] - 20), fontFace=5,
                                fontScale=1.2, color=(0, 255, 255), thickness=1)
                    if save_movie:
                        out.write(vid_frame)
                    cv2.imshow('frame', vid_frame)
                    if cv2.waitKey(1) & 0xFF == ord('q'):
                        break

            print('Cumulative processing speed is ' + str((t - initbatch) / np.sum(tottime))[:5] + ' frames per second.')

    if save_movie:
        out.release()
    cv2.destroyAllWindows()

    # %% extract results from the objects and do some plotting
    A, b = cnm2.Ab[:, cnm2.gnb:], cnm2.Ab[:, :cnm2.gnb].toarray()
    C, f = cnm2.C_on[cnm2.gnb:cnm2.M, t - t // epochs:t], cnm2.C_on[:cnm2.gnb, t - t // epochs:t]
    noisyC = cnm2.noisyC[:, t - t // epochs:t]
    b_trace = [osi.b for osi in cnm2.OASISinstances]

    pl.figure()
    crd = cm.utils.visualization.plot_contours(A, Cn, thr=0.9)

    # %%  save results (optional)
    if save_results:
        np.savez(str(folder_name) + sep + 'results_onACID_' + fls[0].split(sep)[-1][:-4] + '.npz',
                 Cn=Cn, Ab=A, Cf=C, b=b, f=f, metadata=metadata, crd=crd,
                 dims=cnm2.dims, tottime=tottime, noisyC=noisyC, shifts=shifts)

    # view_patches_bar(Yr, scipy.sparse.coo_matrix(A.tocsc()[:, :]), C[:, :], b, f,
    #                  dims[0], dims[1], YrA=noisyC[cnm2.gnb:cnm2.M] - C, img=Cn)


if __name__ == '__main__':
    main(show_movie=True, h5group='/Full Stack/Channel 1', is_multiscaler=True,
         save_results=True, num_of_channels=2, epochs=2)