cmake_minimum_required(VERSION 2.8)
CMAKE_POLICY(VERSION 2.8)

set(INSTALL_RUNTIME_DESTINATION dtiplayground-tools)
set(INSTALL_LIBRARY_DESTINATION dtiplayground-tools)
set(INSTALL_ARCHIVE_DESTINATION lib/static)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

set(DTI-RegPath     DTI-Reg)
set(dtiaveragePath  dtiaverage)
set(dtiprocessPath  dtiprocess)
set(GreedyAtlasPath GreedyAtlas)
set(GreedyWarp      GreedyWarp)
set(unuPath         unu)
set(CropDTIPath     CropDTI)
set(ImageMathPath   ImageMath)
set(BRAINSFitPath   BRAINSFit)
set(ResampleDTIlogEuclideanPath  ResampleDTIlogEuclidean)
set(ITKTransformToolsPath        ITKTransformTools)

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/DTIPlaygroundToolPaths.yml.in ${CMAKE_INSTALL_PREFIX}/${INSTALL_RUNTIME_DESTINATION}/software_paths.yml)

install(PROGRAMS ${AtlasWerks_BINARY_DIR}/GreedyAtlas 
                 ${AtlasWerks_BINARY_DIR}/GreedyWarp 
                 ${DTI-Reg_BINARY_DIR}/DTI-Reg 
                 ${DTIProcess_BINARY_DIR}/dtiaverage 
                 ${DTIProcess_BINARY_DIR}/dtiestim
                 ${DTIProcess_BINARY_DIR}/dtiprocess
                 ${teem_BINARY_DIR}/unu
                 ${niral_utilities_BINARY_DIR}/CropDTI
                 ${niral_utilities_BINARY_DIR}/ImageMath
                 ${BRAINSTools_BINARY_DIR}/BRAINSFit
                 ${ResampleDTIlogEuclidean_BINARY_DIR}/ResampleDTIlogEuclidean
                 ${ITKTransformTools_BINARY_DIR}/ITKTransformTools
DESTINATION ${INSTALL_RUNTIME_DESTINATION}
COMPONENT RUNTIME)

