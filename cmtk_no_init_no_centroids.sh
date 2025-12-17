#!/bin/bash

IMG_PATH=$1
REF_PATH=$2
RESULT_PATH=$3
ENERGY_WEIGHT=$4

echo "registration"
cmtk registration --nmi --verbose-level 6 --dofs 6,9,12 --exploration 8 --accuracy 0.5 -o $RESULT_PATH/affine.list $REF_PATH $IMG_PATH 

echo "warp"
cmtk warp --nmi --verbose-level 6 --energy-weight $ENERGY_WEIGHT --exploration 4 --fast --accuracy 0.5 --grid-spacing 32 --refine 3 --output-intermediate -o $RESULT_PATH/warp.list $REF_PATH $IMG_PATH $RESULT_PATH/affine.list

echo "reformatx"
cmtk reformatx --pad-out 0 -o $RESULT_PATH/affine.nrrd --floating $IMG_PATH $REF_PATH $RESULT_PATH/affine.list
cmtk reformatx --pad-out 0 -o $RESULT_PATH/warp.nrrd --floating $IMG_PATH $REF_PATH  $RESULT_PATH/warp.list

echo "done!"