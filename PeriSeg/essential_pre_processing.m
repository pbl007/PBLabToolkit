function [cleaned_seeds_mat,filtered_ch1,vasc_enh_mat]=essential_pre_processing(vascEnhancedMask,mergedcclist,raw_ch1)
centroids_mat = zeros(vascEnhancedMask.maskSize);
vasc_enh_mat = centroids_mat;
vasc_enh_mat(vascEnhancedMask.pixelList) = 1;
c=sub2ind(vascEnhancedMask.maskSize,mergedcclist(:,1),mergedcclist(:,2),mergedcclist(:,3));
centroids_mat(c)=1;
cleaned_seeds_mat = centroids_mat.*vasc_enh_mat;

filtered_ch1=bsxfun(@times, raw_ch1, cast(vasc_enh_mat, 'uint16'));

end