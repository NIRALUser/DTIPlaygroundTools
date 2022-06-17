cmake_minimum_required(VERSION 2.8)
CMAKE_POLICY(VERSION 2.8)

set(INSTALL_RUNTIME_DESTINATION dtiplayground-tools)
set(INSTALL_LIBRARY_DESTINATION dtiplayground-tools)
set(INSTALL_ARCHIVE_DESTINATION lib/static)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

set(DTI-RegPath     DTI-Reg/bin/DTI-Reg)
set(dtiaveragePath  DTIProcess/bin/dtiaverage)
set(dtiprocessPath  DTIProcess/bin/dtiprocess)
set(GreedyAtlasPath AtlasWerks/GreedyAtlas)
set(GreedyWarp      AtlasWerks/GreedyWarp)
set(unuPath         teem/bin/unu)
set(CropDTIPath     niral_utilities/bin/CropDTI)
set(ImageMathPath   niral_utilities/bin/ImageMath)
set(BRAINSFitPath   BRAINSTools/bin/BRAINSFit)
set(ResampleDTIlogEuclideanPath  ResampleDTIlogEuclidean/bin/ResampleDTIlogEuclidean)
set(ITKTransformToolsPath        ITKTransformTools/bin/ITKTransformTools)

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/DTIPlaygroundToolPaths.yml.in ${CMAKE_INSTALL_PREFIX}/${INSTALL_RUNTIME_DESTINATION}/software_paths.yml)

# install(PROGRAMS ${AtlasWerks_BINARY_DIR}/GreedyAtlas 
#                  ${AtlasWerks_BINARY_DIR}/GreedyWarp 
#                  ${DTI-Reg_BINARY_DIR}/DTI-Reg 
#                  ${DTIProcess_BINARY_DIR}/dtiaverage 
#                  ${DTIProcess_BINARY_DIR}/dtiestim
#                  ${DTIProcess_BINARY_DIR}/dtiprocess
#                  ${teem_BINARY_DIR}/unu
#                  ${niral_utilities_BINARY_DIR}/CropDTI
#                  ${niral_utilities_BINARY_DIR}/ImageMath
#                  ${BRAINSTools_BINARY_DIR}/BRAINSFit
#                  ${ResampleDTIlogEuclidean_BINARY_DIR}/ResampleDTIlogEuclidean
#                  ${ITKTransformTools_BINARY_DIR}/ITKTransformTools
# DESTINATION ${INSTALL_RUNTIME_DESTINATION}
# COMPONENT RUNTIME)

install (PROGRAMS ${MriWatcher_BINARY_DIR}/MriWatcher
         DESTINATION ${INSTALL_RUNTIME_DESTINATION}
         COMPONENT RUNTIME)


install(DIRECTORY ${Trafic_DIR}/../../../  # Trailing / ignores parent directory name and just copy sub directories
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}/Trafic
        COMPONENT RUNTIME
        USE_SOURCE_PERMISSIONS)


install(DIRECTORY ${DCMTK_DIR}/../../../  # Trailing / ignores parent directory name and just copy sub directories
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}/DCMTK
        COMPONENT RUNTIME
        USE_SOURCE_PERMISSIONS)

install(DIRECTORY ${niral_utilities_BINARY_DIR}/../  # Trailing / ignores parent directory name and just copy sub directories
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}/niral_utilities
        COMPONENT RUNTIME
        USE_SOURCE_PERMISSIONS)

install(DIRECTORY ${teem_BINARY_DIR}/../  # Trailing / ignores parent directory name and just copy sub directories
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}/teem
        COMPONENT RUNTIME
        USE_SOURCE_PERMISSIONS)

install(DIRECTORY ${ANTs_DIR}/  # Trailing / ignores parent directory name and just copy sub directories
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}/ANTs
        COMPONENT RUNTIME
        USE_SOURCE_PERMISSIONS)

install(DIRECTORY ${AtlasWerks_DIR}/  # Trailing / ignores parent directory name and just copy sub directories
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}/AtlasWerks
        COMPONENT RUNTIME
        USE_SOURCE_PERMISSIONS)

install(DIRECTORY ${DTI-Reg_DIR}/  # Trailing / ignores parent directory name and just copy sub directories
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}/DTI-Reg
        COMPONENT RUNTIME
        USE_SOURCE_PERMISSIONS)

install(DIRECTORY ${DTIProcess_DIR}/  # Trailing / ignores parent directory name and just copy sub directories
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}/DTIProcess
        COMPONENT RUNTIME
        USE_SOURCE_PERMISSIONS)

install(DIRECTORY ${BRAINSTools_DIR}/  # Trailing / ignores parent directory name and just copy sub directories
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}/BRAINSTools
        COMPONENT RUNTIME
        USE_SOURCE_PERMISSIONS)

install(DIRECTORY ${ResampleDTIlogEuclidean_DIR}/  # Trailing / ignores parent directory name and just copy sub directories
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}/ResampleDTIlogEuclidean
        COMPONENT RUNTIME
        USE_SOURCE_PERMISSIONS)

install(DIRECTORY ${ITKTransformTools_DIR}/  # Trailing / ignores parent directory name and just copy sub directories
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}/ITKTransformTools
        COMPONENT RUNTIME
        USE_SOURCE_PERMISSIONS)

