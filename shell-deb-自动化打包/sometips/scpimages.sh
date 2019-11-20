#!/bin/bash
SCRIPT=$(readlink -f $0)
CWD=$(dirname $SCRIPT)
seeds=$(cat $CWD/seed)
img_dir=$CWD/images

for seed in $seeds;do
    for image in $(ls -1 $img_dir);do
        image_seed_dir=${image:4:2}
        echo "scp [$image] to [$seed]:[$image_seed_dir].."
        scp $img_dir/$image $seed:/pitrix/images-repo/$image_seed_dir/
    done
done
echo Done
