# ALSR
Recognition of faces and facial attributes using Accumulative Local Sparse Representations (ALSR)

# Abstract
This paper addresses the problem of automated recognition of faces and facial attributes by proposing a new general approach called Accumulative Local Sparse Representation (ALSR). In the learning stage, we build a general dictionary of patches that are extracted from face images in a dense man- ner on a grid. In the testing stage, patches of the query image are sparsely represented using a local dictionary. This dictionary contains similar atoms of the general dictionary that are spatially in the same neighborhood. If the sparsity con- centration index of the query patch is high enough, we build a descriptor by using a sum-pooling operator that evaluates the contribution provided by the atoms of each class. The classification is performed by maximizing the sum of the de- scriptors of all selected patches. ALSR can learn a model for each recognition task dealing with more variability in ambient lighting, pose, expression, occlusion, face size, etc. Experiments on three popular face databases (LFW for faces, AR for gender and Oulu-CASIA for expressions), show that ALSR outperforms representative methods in the literature, when a huge number of training images is not available.

# Requirements
ALSR requires the following toolboxes:
- [Experimental Toolbox](https://github.com/domingomery/experimental)
- [Balu Toolbox](https://github.com/domingomery/Balu)
- [SPAMS Toolbox](http://spams-devel.gforge.inria.fr/)
- [VLFeat Toolbox](http://http://www.vlfeat.org) 
- [INface Toolbox](https://la.mathworks.com/matlabcentral/fileexchange/26523-the-inface-toolbox-v2-0-for-illumination-invariant-face-recognition)

# Reference
Mery, D.; and Banerjee, S. [Recognition of Faces and Facial Attributes using Accumulative Local Sparse Representations](http://dmery.sitios.ing.uc.cl/Prints/Conferences/International/2018-ICASSP.pdf). In International Conference on Acoustics, Speech, and Signal Processing (ICASSP 2018), 2018. Calgary, Canada, 15-20/Apr. 
