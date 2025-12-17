
#!/bin/bash

energy_weight=0.1
../cmtk_no_init_no_centroids.sh /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/em_fixed.nrrd /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/pica_moving.nrrd /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/energy_weight_$energy_weight $energy_weight


energy_weight=0.2
../cmtk_no_init_no_centroids.sh /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/em_fixed.nrrd /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/pica_moving.nrrd /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/energy_weight_$energy_weight $energy_weight


energy_weight=0.5
../cmtk_no_init_no_centroids.sh /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/em_fixed.nrrd /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/pica_moving.nrrd /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/energy_weight_$energy_weight $energy_weight


energy_weight=1
../cmtk_no_init_no_centroids.sh /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/em_fixed.nrrd /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/pica_moving.nrrd /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/energy_weight_$energy_weight $energy_weight


energy_weight=10
../cmtk_no_init_no_centroids.sh /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/em_fixed.nrrd /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/pica_moving.nrrd /nfs/data8/chuyu/data/20230422_160839/connectome/aligned_stacks_20251215/energy_weight_$energy_weight $energy_weight