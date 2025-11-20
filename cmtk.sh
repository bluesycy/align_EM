#!/bin/bash

IMG_PATH=$1
REF_PATH=$2
RESULT_PATH=$3

echo "make_initial_affine"
cmtk make_initial_affine --centers-of-mass $IMG_PATH $REF_PATH $RESULT_PATH/initial.list

echo "registration"
cmtk registration --initial $RESULT_PATH/initial.list --ncc --threads 64 --dofs 6,12 --exploration 8 --accuracy 0.8 -o $RESULT_PATH/affine.list $IMG_PATH $REF_PATH

echo "warp"
cmtk warp --ncc --threads 64 --jacobian-weight 0 --fast -e 18 --grid-spacing 100 --energy-weight 1e-1 --refine 4 --coarsest 10 --ic-weight 0 --output-intermediate --accuracy 0.5 -o $RESULT_PATH/warp.list $RESULT_PATH/affine.list

echo "reformatx"
cmtk reformatx --pad-out 0 -o $RESULT_PATH/init.nrrd --floating $REF_PATH $IMG_PATH $RESULT_PATH/initial.list
cmtk reformatx --pad-out 0 -o $RESULT_PATH/affine.nrrd --floating $REF_PATH $IMG_PATH $RESULT_PATH/affine.list
cmtk reformatx --pad-out 0 -o $RESULT_PATH/warp.nrrd --floating $REF_PATH $IMG_PATH $RESULT_PATH/warp.list

cmtk reformatx --pad-out 0 -o $RESULT_PATH/init_inv.nrrd --floating $IMG_PATH $REF_PATH --inverse $RESULT_PATH/initial.list
cmtk reformatx --pad-out 0 -o $RESULT_PATH/affine_inv.nrrd --floating $IMG_PATH $REF_PATH --inverse $RESULT_PATH/affine.list
cmtk reformatx --pad-out 0 -o $RESULT_PATH/warp_inv.nrrd --floating $IMG_PATH $REF_PATH --inverse $RESULT_PATH/warp.list


echo "done!"