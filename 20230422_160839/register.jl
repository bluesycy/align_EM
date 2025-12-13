using DelimitedFiles,HDF5, PyCall, PyPlot, NRRD,FileIO, TiffImages,Images, ProgressMeter, NaNStatistics, Statistics
using _Data, _CairoUtils
using NRRD, FileIO, ImageCore, AxisArrays, Unitful
using ImageFiltering


@pyimport numpy as np
@pyimport scipy.io as io

experimenter = "chuyu"
server = 8

experiment_filename = "20230422_160839"
ds_save = Dataset(experiment_filename, experimenter, gethostname() == "roli-$(server)" ? "/data" : "/nfs/data$(server)")
result_path = joinpath(data_path(ds_save), "connectome")



# create a function that takes in the EM centroids and output the smoothed EM centroid stack
function create_smoothed_EM_centroid_stack(EM_centroids::Array{Float32,2}, stack_size::Tuple{Int,Int,Int}, sigma::Tuple{Float64,Float64,Float64})
    EM_centroid_volume = zeros(Float32, stack_size);
    for i in 1:size(EM_centroids,1)
        # round the coordinates first
        x = Int(round(EM_centroids[i,1]))
        y = Int(round(EM_centroids[i,2]))
        z = Int(round(EM_centroids[i,3]))
        if x>=1 && x<=stack_size[1] && y>=1 && y<=stack_size[2] && z>=1 && z<=stack_size[3]
            EM_centroid_volume[x,y,z] = 1.0;
        end
    end
    smoothed_EM_centroid_volume = imfilter(EM_centroid_volume, Kernel.gaussian(sigma));
    smoothed_EM_centroid_volume = smoothed_EM_centroid_volume ./ maximum(smoothed_EM_centroid_volume);
    return Float32.(smoothed_EM_centroid_volume)
end


x_min, x_max = 630, 890
y_min, y_max = 190, 430
z_min, z_max = 5, 80


# load EM centroids
# Reslice_downsampled_fine_aligned_volume_32x_alldims_masks_diameter1220231221_EM_model_tps_affine_affine_centroids.csv
# skip first row
EM_centroids = readdlm(joinpath("Reslice_downsampled_fine_aligned_volume_32x_alldims_masks_diameter1220231221_EM_model_tps_affine_affine_centroids.csv"), ',', skipstart=1);
EM_centroids = EM_centroids[:, 2:4]; # first column is index


EM_centroids[:,1] = EM_centroids[:,1] .- x_min .+ 1
EM_centroids[:,2] = EM_centroids[:,2] .- y_min .+ 1
EM_centroids[:,3] = EM_centroids[:,3] .- z_min .+ 1;

EM_centroids = Float32.(EM_centroids);



filename = joinpath(result_path, "$(experiment_filename)_PICAstack.tif")
PICA_stack = Float32.(load(filename));
PICA_stack = np.swapaxes(PICA_stack, 0, 1);


LM_PICA_stack = PICA_stack[x_min:x_max, y_min:y_max, z_min:z_max];
LM_PICA_stack = LM_PICA_stack./np.nanmax(LM_PICA_stack);


# put together a function that takes the floating centroids, reference volume as input, output the transformed centroids (ones that succeeded in registration)
function register_EM_to_LM(EM_centroids::Array{Float32,2}, EM_stack::Array{Float32,3}, LM_stack::Array{Float32,3}, result_path::String, energy_weight::Float64=1e-1)
    # if result_path does not exist, create it
    if !isdir(result_path)
        mkpath(result_path)
    end
    # save EM centroids to a temporary file
    temp_xyz_path = joinpath(result_path, "temp_cell_coordinates.txt")
    writedlm(temp_xyz_path, Float32.(EM_centroids))
    # save EM stack to a temporary file
    temp_EM_stack_path = joinpath(result_path, "temp_EM_stack.nrrd")
    save(temp_EM_stack_path, Float32.(EM_stack))
    # save LM stack to a temporary file
    temp_LM_stack_path = joinpath(result_path, "temp_LM_stack.nrrd")
    save(temp_LM_stack_path, Float32.(LM_stack))
    # run cmtk_no_init.sh, with an option whether to suppress the output
    run(`../cmtk_no_init.sh $temp_EM_stack_path $temp_LM_stack_path $result_path $result_path $energy_weight`)
    # load transformed cell coordinates
    transformed_coordinates = readdlm(joinpath(result_path, "cell_coordinates_registered.txt"));
    # clean up temporary files
    # rm(temp_xyz_path)
    # rm(temp_EM_stack_path)
    # rm(temp_LM_stack_path)
    if size(transformed_coordinates,2) == 3
        transformed_coordinates = hcat(transformed_coordinates, fill("Succeeded", size(transformed_coordinates,1)))
    end

    return transformed_coordinates[:,1:3], transformed_coordinates[:,4]
end



EM_centroids = EM_centroids
EM_stack = create_smoothed_EM_centroid_stack(EM_centroids, size(LM_PICA_stack), (1.5, 1.5, 1.5))
LM_stack = Float32.(LM_PICA_stack)
for energy_weight = [0.1, 0.2, 0.5, 1, 10]
    println("Registering with energy weight: $energy_weight")
    transformed_coordinates, transform_info = register_EM_to_LM(EM_centroids, EM_stack, LM_stack, joinpath(result_path, "LMEM_registration_energyweight$energy_weight"), energy_weight)


    # save transformed coordinates in the original PICA stack coordinate system, as well as the registration info in the same csv
    transformed_coordinates[:,1] = transformed_coordinates[:,1] .+ x_min .- 1
    transformed_coordinates[:,2] = transformed_coordinates[:,2] .+ y_min .- 1
    transformed_coordinates[:,3] = transformed_coordinates[:,3] .+ z_min .- 1;
    writedlm(joinpath(result_path,"LMEM_registration_energyweight$energy_weight","$(experiment_filename)_EM_centroids_registered_to_LM_PICA_energyweight$energy_weight.csv"), hcat(transformed_coordinates, transform_info), ',')
    println("Registration completed and saved.")
end