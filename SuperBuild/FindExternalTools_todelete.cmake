# Find external tools

#===== Macro set paths ===============================================
macro( SetPathsRecompile INSTALL_PATH)
  foreach( tool ${Tools} )
 #   set(InstallPath ${CMAKE_INSTALL_PREFIX}) # Non cache variable so its value can change and be updated
    set(TOOL${tool} ${INSTALL_PATH}/bin/${tool} CACHE STRING "Path to the ${tool} executable" FORCE)
    get_filename_component(${tool}Path ${TOOL${tool}} REALPATH ABSOLUTE) # Set the real path in the config file
#    set(${tool}Path ${TOOL${tool}}) # ${proj}Path =  variable changed in the DTIAB config file (non cache)
    mark_as_advanced(CLEAR TOOL${tool}) # Show the option in the gui
    if(DEFINED TOOL${tool}Sys)
      mark_as_advanced(FORCE TOOL${tool}Sys) # Hide the unuseful option in the gui
    endif()
  endforeach()
endmacro( SetPathsRecompile )

macro( SetPathsSystem )
  foreach( tool ${Tools} )
    get_filename_component(${tool}Path ${TOOL${tool}}Sys REALPATH ABSOLUTE) # Set the real path in the config file
#    set(${tool}Path ${TOOL${tool}Sys})
    mark_as_advanced(CLEAR TOOL${tool}Sys) # Show the option in the gui
    if(DEFINED TOOL${tool})
      mark_as_advanced(FORCE TOOL${tool}) # Hide the option in the gui
    endif()
  endforeach()
endmacro( SetPathsSystem )

#===== Macro search tools ===============================================
macro( FindToolsMacro Proj )
  set( AllToolsFound ON )
  foreach( tool ${Tools} )
    find_program( TOOL${tool}Sys ${tool}) # search TOOL${tool}Sys in the PATH
    if(${TOOL${tool}Sys} STREQUAL "TOOL${tool}Sys-NOTFOUND") # If program not found, give a warning message and set AllToolsFound variable to OFF
      message( WARNING "${tool} not found. It will not be recompiled, so either set it to ON, or get ${Proj} manually." )
      set( AllToolsFound OFF )
    endif() # Found on system
  endforeach()
endmacro()

#===== Macro add tool ===============================================
 # if SourceCodeArgs or CMAKE_ExtraARGS passed to the macro as arguments, only the first word is used (each element of the list is taken as ONE argument) => use as "global variables"
macro( AddToolMacro Proj )
  set( INSTALL_PATH ${CMAKE_CURRENT_BINARY_DIR}/${Proj}-install)
  # Update and test tools
  if(COMPILE_EXTERNAL_${Proj}) # If need to recompile, just set the paths here
    SetPathsRecompile(${INSTALL_PATH}) # Uses the list "Tools"
  else(COMPILE_EXTERNAL_${Proj}) # If no need to recompile, search the tools on the system and need to recompile if some tool not found

    # search the tools on the system and warning if not found
    # If SlicerExtension, OFF packages are already in Slicer but can be not found -> don't recompile
    if( NOT DTIAtlasBuilder_BUILD_SLICER_EXTENSION )
      FindToolsMacro( ${Proj} )
      # If some program not found, reset all tools to the recompiled path and recompile the whole package
      if(NOT AllToolsFound) # AllToolsFound set or reset in FindToolsMacro()
        set( COMPILE_EXTERNAL_${Proj} ON CACHE BOOL "" FORCE)
        SetPathsRecompile(${INSTALL_PATH}) # Uses the list "Tools"
      else()
        SetPathsSystem() # Uses the list "Tools"
      endif()
    endif( NOT DTIAtlasBuilder_BUILD_SLICER_EXTENSION )

  endif(COMPILE_EXTERNAL_${Proj})
  # After the main if() because we could need to recompile after not having found all tools on system
  if(COMPILE_EXTERNAL_${Proj})
    # Add project
    ExternalProject_Add(${Proj}
      ${SourceCodeArgs} # No difference between args passed separated with ';', spaces or return to line
      BINARY_DIR ${Proj}-build
      SOURCE_DIR ${Proj} # creates the folder if it doesn't exist
      CMAKE_GENERATOR ${gen}
      CMAKE_ARGS
        ${COMMON_BUILD_OPTIONS_FOR_EXTERNALPACKAGES}
#       -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_CURRENT_BINARY_DIR}/DTIAtlasBuilder-build/${Proj}-build/bin
#       -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_CURRENT_BINARY_DIR}/DTIAtlasBuilder-build/${Proj}-build/bin
#       -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_CURRENT_BINARY_DIR}/DTIAtlasBuilder-build/${Proj}-build/bin
#       -DCMAKE_BUNDLE_OUTPUT_DIRECTORY:PATH=${CMAKE_CURRENT_BINARY_DIR}/DTIAtlasBuilder-build/${Proj}-build/bin
       -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_PATH}
       ${CMAKE_ExtraARGS}
     #INSTALL_COMMAND "" # So the install step of the external project is not done
    )

    list(APPEND DTIAtlasBuilderExternalToolsDependencies ${Proj})

  endif(COMPILE_EXTERNAL_${Proj})
endmacro( AddToolMacro )

#====================================================================
#====================================================================
## Libraries for tools =============================================

# VTK
set(RecompileVTK OFF)
set(VTK_DEPEND "")

if(COMPILE_EXTERNAL_dtiprocessTK OR COMPILE_EXTERNAL_AtlasWerks OR COMPILE_EXTERNAL_BRAINS )
  find_package(VTK QUIET)
  if (VTK_FOUND)
    set(VTK_USE_QVTK TRUE)
    set(VTK_USE_GUISUPPORT TRUE)
    include(${VTK_USE_FILE}) # creates VTK_DIR
  else(VTK_FOUND)
    message("VTK not found. It will be downloaded and recompiled, unless a path is manually specified in the VTK_DIR variable.") # Not a Warning = just info
    set(RecompileVTK ON) # If not found, recompile it
  endif(VTK_FOUND)
endif()

#set(VTK_VERSION_MAJOR 5 CACHE STRING "Choose the expected VTK major version to build Slicer (5 or 6).")
# Set the possible values of VTK major version for cmake-gui
#set_property(CACHE VTK_VERSION_MAJOR PROPERTY STRINGS "5" "6")
#if(NOT "${VTK_VERSION_MAJOR}" STREQUAL "5" AND NOT "${VTK_VERSION_MAJOR}" STREQUAL "6")
#  set(VTK_VERSION_MAJOR 5 CACHE STRING "Choose the expected VTK major version to build Slicer (5 or 6)." FORCE)
#  message(WARNING "Setting VTK_VERSION_MAJOR to '5' as an valid value was specified.")
#endif()

#set(USE_VTKv5 ON)
#set(USE_VTKv6 OFF)
#if(${VTK_VERSION_MAJOR} STREQUAL "6")
#  set(USE_VTKv5 OFF)
#  set(USE_VTKv6 ON)
#endif()

#if(RecompileVTK) # BRAINSStandAlone/SuperBuild/External_VTK.cmake
#  if(USE_VTKv6)
#    set(VTK_GIT_TAG "v6.1.0")
#    set(VTK_REPOSITORY ${git_protocol}://vtk.org/VTK.git)
#  else()
#    set(VTK_REPOSITORY ${git_protocol}://github.com/BRAINSia/VTK.git)
#    set(VTK_GIT_TAG "FixClangFailure_VTK5.10_release")
#  endif()
#  ExternalProject_Add(VTK
#    GIT_REPOSITORY ${VTK_REPOSITORY}
#    GIT_TAG ${VTK_GIT_TAG}
#    SOURCE_DIR VTK
#    BINARY_DIR VTK-build
#    CMAKE_GENERATOR ${gen}
#    CMAKE_ARGS
#      ${COMMON_BUILD_OPTIONS_FOR_EXTERNALPACKAGES}
#      -DBUILD_EXAMPLES:BOOL=OFF
#      -DBUILD_TESTING:BOOL=OFF
#      -DBUILD_SHARED_LIBS:BOOL=OFF
#      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/VTK-install
#      -DVTK_USE_PARALLEL:BOOL=ON
#      -DVTK_LEGACY_REMOVE:BOOL=OFF
#      -DVTK_WRAP_TCL:BOOL=OFF
#      -DVTK_WRAP_PYTHON:BOOL=${VTK_WRAP_PYTHON}
#      -DVTK_INSTALL_LIB_DIR:PATH=${Slicer_INSTALL_LIB_DIR}
#    )
#    if(USE_VTKv6)
#      set(VTK_DIR ${CMAKE_CURRENT_BINARY_DIR}/VTK-install/lib/cmake/vtk-6.1)
#    else()
#      set(VTK_DIR ${CMAKE_CURRENT_BINARY_DIR}/VTK-install/lib/vtk-5.10)
#    endif()
#    mark_as_advanced(CLEAR VTK_DIR)
#    set(VTK_DEPEND VTK)
#endif(RecompileVTK)

# FFTW and CLAPACK for GreedyAtlas
if(COMPILE_EXTERNAL_AtlasWerks) # FFTW D + F build one on(after) another
  # FFTW
  if(WIN32) # If windows, no recompilation so just download binary
    set(FFTW_DOWNLOAD_ARGS
        URL "ftp://ftp.fftw.org/pub/fftw/fftw-3.3.3-dll64.zip")
  else(WIN32) # Download source code and recompile
    set(FFTW_DOWNLOAD_ARGS
        URL "http://www.fftw.org/fftw-3.3.3.tar.gz"
        URL_MD5 0a05ca9c7b3bfddc8278e7c40791a1c2)
  endif(WIN32)
  ExternalProject_Add(FFTW    # FFTW has no CMakeLists.txt # Example : Slicer/SuperBuild/External_python.cmake
    ${FFTW_DOWNLOAD_ARGS}
    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/FFTW-install
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/FFTW
    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/FFTW-build
    CONFIGURE_COMMAND ""
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
      ${COMMON_BUILD_OPTIONS_FOR_EXTERNALPACKAGES} # So we can give CC to configure*
    INSTALL_COMMAND ""
    BUILD_COMMAND ${CMAKE_COMMAND} -DTOP_BINARY_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR} -P ${CMAKE_CURRENT_SOURCE_DIR}/SuperBuild/InstallFFTW.cmake # -DARGNAME:TYPE=VALUE -P <cmake file> = Process script mode
    )
  set(FFTW_DIR ${CMAKE_CURRENT_BINARY_DIR}/FFTW-install)

  # CLAPACK (from http://www.nitrc.org/projects/spharm-pdm or http://github.com/Slicer/Slicer/blob/master-411/SuperBuild/External_CLAPACK.cmake)
  ExternalProject_Add(CLAPACK
    URL "http://www.netlib.org/clapack/clapack-3.2.1-CMAKE.tgz"
    URL_MD5 4fd18eb33f3ff8c5d65a7d43913d661b
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/CLAPACK
    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/CLAPACK-build
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
      ${COMMON_BUILD_OPTIONS_FOR_EXTERNALPACKAGES}
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_TESTING:BOOL=OFF
    INSTALL_COMMAND "" # No install step
    )

  set(AtlasWerks_DIR ${CMAKE_CURRENT_BINARY_DIR}/AtlasWerks-install)
  
endif(COMPILE_EXTERNAL_AtlasWerks)

# ITK and SlicerExecutionModel
if( NOT DTIAtlasBuilder_BUILD_SLICER_EXTENSION )
  set(RecompileITK OFF)
  set(RecompileSEM OFF)
  find_package(ITK QUIET) # Not required because will be recompiled if not found
endif()

if(ITK_FOUND)
  include(${ITK_USE_FILE}) # set ITK_DIR and ITK_VERSION_MAJOR
  if(NOT ${ITK_VERSION_MAJOR} EQUAL 4)
    set(RecompileITK ON)
  else() # NO recompile ITK
    # If ITK not recompiled, look for SlicerExecutionModel
    find_package(SlicerExecutionModel) # Not required because will be recompiled if not found
    if(SlicerExecutionModel_FOUND)
      include(${SlicerExecutionModel_USE_FILE}) # creates SlicerExecutionModel_DIR (DTI-Reg & BRAINSFit)
    else(SlicerExecutionModel_FOUND)
      message(WARNING "SlicerExecutionModel not found. It will be downloaded and recompiled.")
      set(RecompileSEM ON)
    endif(SlicerExecutionModel_FOUND)
  endif() # (${ITK_VERSION_MAJOR} NOT EQUAL 4)
else(ITK_FOUND)
  set(RecompileITK ON) # Automatically recompile SlicerExecutionModel
endif(ITK_FOUND)

set(ITK_DEPEND "")
if(RecompileITK)
  message("ITKv4 not found. It will be downloaded and recompiled, unless a path is manually specified in the ITK_DIR variable.") # Not a Warning = just info
  # Download and compile ITKv4
  ExternalProject_Add(I4 # BRAINSStandAlone/SuperBuild/External_ITKv4.cmake # !! All args needed as they are # Name shorten from ITKv4 because Windows ITKv4 path limited to 50 chars
    GIT_REPOSITORY "${git_protocol}://github.com/InsightSoftwareConsortium/ITK"
    GIT_TAG 8f7c404aff99f5ae3dfedce6e480701f0304864c
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/I4 # Path shorten from ITKv4 because Windows SOURCE_DIR path limited to 50 chars
    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/I4-b # Path shorten from ITKv4 because Windows SOURCE_DIR path limited to 50 chars
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS # !! ALL options need to be here for all tools to compile with this version of ITK
      ${COMMON_BUILD_OPTIONS_FOR_EXTERNALPACKAGES}
      -Wno-dev
      --no-warn-unused-cli
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/I4-i # Path shorten from ITKv4 because Windows SOURCE_DIR path limited to 50 chars
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_TESTING:BOOL=OFF
      -DITK_LEGACY_REMOVE:BOOL=ON
      -DITKV3_COMPATIBILITY:BOOL=OFF
      -DITK_BUILD_DEFAULT_MODULES:BOOL=ON
      -DModule_ITKReview:BOOL=ON
 -DModule_ITKIODCMTK:BOOL=ON
 -DModule_MGHIO:BOOL=ON #To provide FreeSurfer Compatibility
      -DITK_USE_REVIEW:BOOL=OFF # ON ok with BRAINSFit and ANTS not with dtiprocess and ResampleDTI # OFF ok with BRAINSFit
      -DKWSYS_USE_MD5:BOOL=ON # Required by SlicerExecutionModel
      -DUSE_WRAP_ITK:BOOL=OFF ## HACK:  QUICK CHANGE
      -DITK_USE_SYSTEM_DCMTK:BOOL=OFF
#      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/lib # Needed for BRAINSTools to compile
#      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/lib # Needed for BRAINSTools to compile
#      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/bin # Needed for BRAINSTools to compile
    )
  set(ITK_DIR ${CMAKE_CURRENT_BINARY_DIR}/I4-i/lib/cmake/ITK-4.8 FORCE) # Use the downloaded ITK for all tools # Path shorten from ITKv4 because Windows SOURCE_DIR path limited to 50 chars
  set(ITK_DEPEND I4)
  set(RecompileSEM ON) # If recompile ITK, recompile SlicerExecutionModel
endif(RecompileITK)

if(RecompileSEM)
  # Download and compile SlicerExecutionModel with the downloaded ITKv4
  ExternalProject_Add(SlicerExecutionModel # BRAINSStandAlone/SuperBuild/External_SlicerExecutionModel.cmake
    GIT_REPOSITORY "${git_protocol}://github.com/Slicer/SlicerExecutionModel.git"
    GIT_TAG e00851314ab17d4f1e8eba097e47947df13c100f
    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/SlicerExecutionModel
    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/SlicerExecutionModel-build
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
      ${COMMON_BUILD_OPTIONS_FOR_EXTERNALPACKAGES}
      -Wno-dev
      --no-warn-unused-cli
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/SlicerExecutionModel-install
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_TESTING:BOOL=OFF
      -DITK_DIR:PATH=${ITK_DIR}
    INSTALL_COMMAND ""
    DEPENDS ${ITK_DEPEND} # either ITKv4 if recompiled, or empty
    )
  set(SlicerExecutionModel_DIR ${CMAKE_CURRENT_BINARY_DIR}/SlicerExecutionModel-build) # Use the downloaded SlicerExecutionModel for all tools
  mark_as_advanced(CLEAR SlicerExecutionModel_DIR)
  set(GenerateCLP_DIR ${SlicerExecutionModel_DIR}/GenerateCLP)
  set(ModuleDescriptionParser_DIR ${SlicerExecutionModel_DIR}/ModuleDescriptionParser)
  set(TCLAP_DIR ${SlicerExecutionModel_DIR}/tclap)
  set( SlicerExecutionModel_DEPEND SlicerExecutionModel)

endif(RecompileSEM)


## GLUT for MriWatcher -> disable MriWatcher if Slicer Ext for the moment
#  ExternalProject_Add(GLUT
#    URL http://www.opengl.org/resources/libraries/glut/glut-3.7.tar.gz
#    URL_MD5 dc932666e2a1c8a0b148a4c32d111ef3 # $ md5sum (file)
#    DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/FFTW-install
#    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/FFTW
#    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/FFTW-build
#    CONFIGURE_COMMAND ""
#    INSTALL_COMMAND ""
#    BUILD_COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/FFTW-install/InstallFFTW.cmake # -DARGNAME:TYPE=VALUE -P <cmake file> = Process script mode
#    )
#set(GLUT_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/GLUT-install/include)

#====================================================================
#===== TOOLS ========================================================
#       ||
#       VV

### For Slicer Extension:
## CLI Modules # CLI= (pgm) --xml exists # So the cli_modules go to Extensions/DTIAtlaBuilder/lib/Slicer4.2/cli_module
# dtiprocessTK -> extension
# ResampleDTIlogEuclidean -> extension
# DTI-Reg -> extension (# ANTS)
# BRAINS is a cli_module but needs to be in non cli_module to prevent conflict with actual Slicer's BRAINS
## No CLI Modules # So the non cli_modules don't go to Extensions/DTIAtlaBuilder/lib/SlicerX.X/cli_module
# AtlasWerks
# MriWatcher
# NIRALUtilities
# teem # teem is in Slicer but not a cli_module

# ===== dtiprocessTK ==============================================================
set( SourceCodeArgs
  GIT_REPOSITORY ${git_protocol}://github.com/NIRALUser/DTIProcessToolkit.git
  GIT_TAG 8205274f37ddbdffceb3a9b71992b2151c4259c8
  )
set( CMAKE_ExtraARGS
  -DBUILD_TESTING:BOOL=OFF
  -DITK_DIR:PATH=${ITK_DIR}
#  -DUSE_SYSTEM_ITK:BOOL=ON
  -DVTK_DIR:PATH=${VTK_DIR}
#  -DUSE_SYSTEM_VTK:BOOL=ON
#  -DUSE_SYSTEM_SlicerExecutionModel:BOOL=ON
  -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
  -DDTIProcess_BUILD_SLICER_EXTENSION:BOOL=OFF
  -DEXECUTABLES_ONLY:BOOL=ON
  -DDTIProcess_SUPERBUILD:BOOL=OFF
  -DBUILD_PolyDataTransform:BOOL=OFF
  -DBUILD_PolyDataMerge:BOOL=OFF
  -DBUILD_CropDTI:BOOL=OFF
  -DVTK_VERSION_MAJOR:STRING=${VTK_VERSION_MAJOR}
  -DSlicerExecutionModel_DEFAULT_CLI_INSTALL_RUNTIME_DESTINATION:PATH=bin
  DEPENDS ${ITK_DEPEND} ${VTK_DEPEND} ${SlicerExecutionModel_DEPEND}
  )
set( Tools
  dtiprocess
  dtiaverage
  )
AddToolMacro( dtiprocessTK ) # AddToolMacro( proj ) + uses SourceCodeArgs CMAKE_ExtraARGS Tools

# ===== AtlasWerks ================================================================
# code for external tools from http://github.com/Chaircrusher/AtlasWerksBuilder/blob/master/CMakeLists.txt
set( SourceCodeArgs
  GIT_REPOSITORY "${git_protocol}://github.com/NIRALUser/AtlasWerks.git"
  GIT_TAG master
  )

set( CMAKE_ExtraARGS
  -DITK_DIR:PATH=${ITK_DIR}
  -DVTK_DIR:PATH=${VTK_DIR}
  -DLAPACK_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/CLAPACK-build
  -DFFTW_INSTALL_BASE_PATH:PATH=${FFTW_DIR} # will use find_library to find the libs
  -DFFTWF_LIB:PATH=${FFTW_DIR}/lib/libfftw3f.a # FFTW in float
  -DFFTWD_LIB:PATH=${FFTW_DIR}/lib/libfftw3.a # FFTW in double # needed for AtlasWerks to configure, not to compile with
  -DFFTWF_THREADS_LIB:PATH=${FFTW_DIR}/lib/libfftw3f_threads.a
  -DFFTWD_THREADS_LIB:PATH=${FFTW_DIR}/lib/libfftw3_threads.a
  -DFFTW_INCLUDE_PATH:PATH=${FFTW_DIR}/include # will be used to set FFTW_INSTALL_BASE_PATH by finding the path = remove the /include
  -DAtlasWerks_COMPILE_TESTING:BOOL=OFF
  -DatlasWerks_COMPILE_APP_Affine:BOOL=OFF
  -DatlasWerks_COMPILE_APP_AffineAtlas:BOOL=OFF
  -DatlasWerks_COMPILE_APP_ATLAS_WERKS:BOOL=OFF
  -DatlasWerks_COMPILE_APP_VECTOR_ATLAS_WERKS:BOOL=OFF
  -DatlasWerks_COMPILE_APP_FGROWTH:BOOL=OFF
  -DatlasWerks_COMPILE_APP_FWARP:BOOL=OFF
  -DatlasWerks_COMPILE_APP_ImageConvert:BOOL=OFF
  -DatlasWerks_COMPILE_APP_IMMAP:BOOL=OFF
  -DatlasWerks_COMPILE_APP_LDMM:BOOL=OFF
  -DatlasWerks_COMPILE_APP_GREEDY:BOOL=ON  # Compile Only GreedyAtlas
  -DatlasWerks_COMPILE_APP_TX_APPLY:BOOL=OFF
  -DatlasWerks_COMPILE_APP_TX_WERKS:BOOL=OFF
  -DatlasWerks_COMPILE_APP_UTILITIES:BOOL=OFF
  -DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
  #We only care about GreedyAtlas so we only build this target.
  BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} GreedyAtlas
  #There is no install in AtlasWerks. We only care about GreedyAtlas so we just copy it. We only do that on Linux since AtlasWerks does not work on the other plateform
  DEPENDS ${ITK_DEPEND} ${VTK_DEPEND} FFTW CLAPACK # Not CMake Arg -> directly after CMakeArg in ExternalProject_Add()
  )
set( Tools
  GreedyAtlas
  )
AddToolMacro( AtlasWerks ) # AddToolMacro( proj ) + uses SourceCodeArgs CMAKE_ExtraARGS Tools

# ===== BRAINSFit =============================================================
set( SourceCodeArgs
  GIT_REPOSITORY "${git_protocol}://github.com/BRAINSia/BRAINSTools.git"
  GIT_TAG f8c7d5c658f8c31dec95151ec4dc9d09af42fd1c
  )

set( CMAKE_ExtraARGS
  -DBUILD_SHARED_LIBS:BOOL=OFF
  -DINTEGRATE_WITH_SLICER:BOOL=OFF
  -DBRAINSTools_SUPERBUILD:BOOL=OFF
  -DSuperBuild_BRAINSTools_USE_GIT:BOOL=${USE_GIT_PROTOCOL}
  -DITK_VERSION_MAJOR:STRING=4
  -DITK_DIR:PATH=${ITK_DIR}
  -DVTK_DIR:PATH=${VTK_DIR}
  -DUSE_SYSTEM_ITK=ON
  -DUSE_SYSTEM_SlicerExecutionModel=ON
  -DUSE_SYSTEM_VTK=ON
  -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
  -DModuleDescriptionParser_DIR:PATH=${ModuleDescriptionParser_DIR}
  -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
  -DBUILD_TESTING:BOOL=OFF
  -DUSE_BRAINSDemonWarp:BOOL=ON
  -DUSE_BRAINSFit:BOOL=ON
  -DUSE_BRAINSResample:BOOL=OFF
  -DUSE_AutoWorkup:BOOL=OFF
  -DUSE_ANTS:BOOL=OFF
  -DUSE_BRAINSDWICleanup:BOOL=OFF
  -DUSE_BRAINSContinuousClass:BOOL=OFF
  -DUSE_BRAINSFitEZ:BOOL=OFF
  -DUSE_BRAINSROIAuto:BOOL=OFF
  -DUSE_BRAINSSurfaceTools:BOOL=OFF
  -DUSE_BRAINSLabelStats:BOOL=OFF
  -DUSE_DebugImageViewer:BOOL=OFF
  -DUSE_BRAINSMultiSTAPLE:BOOL=OFF
  -DUSE_BRAINSStripRotation:BOOL=OFF
  -DUSE_BRAINSTalairach:BOOL=OFF
  -DUSE_BRAINSABC:BOOL=OFF
  -DUSE_BRAINSConstellationDetector:BOOL=OFF
  -DUSE_BRAINSCreateLabelMapFromProbabilityMaps:BOOL=OFF
  -DUSE_BRAINSCut:BOOL=OFF
  -DUSE_BRAINSImageConvert:BOOL=OFF
  -DUSE_BRAINSInitializedControlPoints:BOOL=OFF
  -DUSE_BRAINSLandmarkInitializer:BOOL=OFF
  -DUSE_BRAINSMultiModeSegment:BOOL=OFF
  -DUSE_BRAINSMush:BOOL=OFF
  -DUSE_BRAINSSnapShotWriter:BOOL=OFF
  -DUSE_BRAINSTransformConvert:BOOL=OFF
  -DUSE_ConvertBetweenFileFormats:BOOL=OFF
  -DUSE_DWIConvert:BOOL=OFF
  -DUSE_DebugImageViewer:BOOL=OFF
  -DUSE_ICCDEF:BOOL=OFF
  -DUSE_ImageCalculator:BOOL=OFF
  -DUSE_GTRACT:BOOL=OFF
  -DLOCAL_SEM_EXECUTABLE_ONLY:BOOL=ON # Variable used in SlicerExecutionModel/CMake/SEMMacroBuildCLI.cmake:l.120 : if true, will only create executable without shared lib lib(exec)Lib.so
  DEPENDS ${ITK_DEPEND} ${VTK_DEPEND} ${SlicerExecutionModel_DEPEND}# So ITK is compiled before
  )
set( Tools
  BRAINSFit
  BRAINSDemonWarp
  )
AddToolMacro( BRAINS ) # AddToolMacro( proj ) + uses SourceCodeArgs CMAKE_ExtraARGS Tools

# ===== ANTS/WarpMultiTransform =====================================================
set( SourceCodeArgs
  GIT_REPOSITORY "${git_protocol}://github.com/stnava/ANTs.git"
  GIT_TAG 4d37532aa6a73b72deedf2663a0d002b267c464f
  )
#if( MSVC )
#  set( INSTALL_CONFIG ANTS-build/ANTS.sln /Build Release /Project INSTALL.vcproj )
#else()
#  set( INSTALL_CONFIG -C ANTS-build install )
#endif()
set( CMAKE_ExtraARGS
  -DBUILD_SHARED_LIBS:BOOL=OFF
  -DBUILD_TESTING:BOOL=OFF
  -DBUILD_EXAMPLES:BOOL=OFF
  -DBUILD_EXTERNAL_APPLICATIONS:BOOL=OFF
#  -DANTS_SUPERBUILD:BOOL=ON
  -DANTS_SUPERBUILD:BOOL=OFF
#  -DSuperBuild_ANTS_USE_GIT_PROTOCOL:BOOL=${USE_GIT_PROTOCOL}
#  -DUSE_SYSTEM_ITK:BOOL=ON
  -DITK_DIR:PATH=${ITK_DIR}
  -DITK_VERSION_MAJOR:STRING=4
#  -DUSE_SYSTEM_SlicerExecutionModel:BOOL=ON
  -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
#  INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} ${INSTALL_CONFIG}
  DEPENDS ${ITK_DEPEND} ${SlicerExecutionModel_DEPEND}
  )
set( Tools
  ANTS
  WarpImageMultiTransform
  )
AddToolMacro( ANTS ) # AddToolMacro( proj ) + uses SourceCodeArgs CMAKE_ExtraARGS Tools

# ===== ResampleDTIlogEuclidean =====================================================
set( SourceCodeArgs
  GIT_REPOSITORY "${git_protocol}://github.com/NIRALUser/ResampleDTIlogEuclidean.git"
  GIT_TAG 3842355f700fddad40d97b985d9aac42d21ea42b
  )
set( CMAKE_ExtraARGS
  -DBUILD_TESTING:BOOL=OFF
  -DBUILD_GENERATECLP:BOOL=OFF
  -DITK_DIR:PATH=${ITK_DIR}
  -DSlicerExecutionModel_DIR:PATH=${SlicerExecutionModel_DIR}
  DEPENDS ${ITK_DEPEND} ${SlicerExecutionModel_DEPEND}
  )
set( Tools
  ResampleDTIlogEuclidean
  )
AddToolMacro( ResampleDTI ) # AddToolMacro( proj ) + uses SourceCodeArgs CMAKE_ExtraARGS Tools


# ===== teem (unu) =====================================================================
set( SourceCodeArgs
  SVN_REPOSITORY "http://svn.code.sf.net/p/teem/code/teem/trunk"  
  SVN_USERNAME slicerbot
  SVN_PASSWORD slicer
  SVN_REVISION -r 6187
  )
set( CMAKE_ExtraARGS
  -DITK_DIR:PATH=${ITK_DIR}
  DEPENDS ${ITK_DEPEND}
  )
set( Tools
  unu
  )
AddToolMacro( teem ) # AddToolMacro( proj ) + uses SourceCodeArgs CMAKE_ExtraARGS Tools

# ===== MriWatcher =====================================================================
set( SourceCodeArgs
  GIT_REPOSITORY ${git_protocol}://github.com/NIRALUser/MriWatcher.git
  GIT_TAG bd82f023f5fbcf9ecef232698809c19708bccfe4
  )
set( CMAKE_ExtraARGS
  -DQT_QMAKE_EXECUTABLE:PATH=${QT_QMAKE_EXECUTABLE}
  -DITK_DIR:PATH=${ITK_DIR}
  DEPENDS ${ITK_DEPEND}
  )
set( Tools
  MriWatcher
  )
AddToolMacro( MriWatcher ) # AddToolMacro( proj ) + uses SourceCodeArgs CMAKE_ExtraARGS Tools

# ===== NIRALUtilities ===================================================================
set( SourceCodeArgs
  GIT_REPOSITORY ${git_protocol}://github.com/NIRALUser/niral_utilities.git
  GIT_TAG 0e4a5b676e3c95eec9adc771e4fc9ab61167fc63
  )
set( CMAKE_ExtraARGS
  -DCOMPILE_CONVERTITKFORMATS:BOOL=OFF
  -DCOMPILE_CROPTOOLS:BOOL=ON
  -DCOMPILE_CURVECOMPARE:BOOL=OFF
  -DCOMPILE_DTIAtlasBuilder:BOOL=OFF
  -DCOMPILE_DWI_NIFTINRRDCONVERSION:BOOL=OFF
  -DCOMPILE_IMAGEMATH:BOOL=ON
  -DCOMPILE_IMAGESTAT:BOOL=OFF
  -DCOMPILE_POLYDATAMERGE:BOOL=OFF
  -DCOMPILE_POLYDATATRANSFORM:BOOL=OFF
  -DCOMPILE_TRANSFORMDEFORMATIONFIELD:BOOL=OFF
  -DCOMPILE_MULTIATLASSEG:BOOL=OFF
  -DCOMPILE_CORREVAL:BOOL=OFF
  -DCOMPILE_TEXTUREBIOMARKERTOOL:BOOL=OFF
  -DCOMPILE_DMDBIOMARKERTOOL:BOOL=OFF
  -DITK_DIR:PATH=${ITK_DIR}
  -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
  -DModuleDescriptionParser_DIR:PATH=${ModuleDescriptionParser_DIR}
  -DTCLAP_DIR:PATH=${TCLAP_DIR}
  DEPENDS ${ITK_DEPEND}
  )
set( Tools
  ImageMath
  CropDTI
  )
AddToolMacro( NIRALUtilities ) # AddToolMacro( proj ) + uses SourceCodeArgs CMAKE_ExtraARGS Tools

if( Slicer_CLIMODULES_BIN_DIR )
  set( Slicer_CLIMODULES_BIN_DIR_OPTION -DSlicer_CLIMODULES_BIN_DIR:STRING=${Slicer_CLIMODULES_BIN_DIR} )
endif()
# ===== DTI-Reg =====================================================================
set( SourceCodeArgs
  GIT_REPOSITORY ${git_protocol}://github.com/NIRALUser/DTI-Reg.git
  GIT_TAG 3161943f6b6f860d946f926330f64de62d9ee07b
  )
set( CMAKE_ExtraARGS
  -DANTSTOOL:PATH=${TOOLANTS}
  -DBRAINSDemonWarpTOOL:PATH=${TOOLBRAINSDemonWarp}
  -DBRAINSFitTOOL:PATH=${TOOLBRAINSFit}
  -DCOMPILE_EXTERNAL_dtiprocess:BOOL=OFF
  -DCOMPILE_EXTERNAL_ITKTransformTools:BOOL=ON
  -DBUILD_SHARED_LIBS:BOOL=OFF
  -DResampleDTITOOL:PATH=${TOOLResampleDTIlogEuclidean}
  -DWARPIMAGEMULTITRANSFORMTOOL:PATH=${TOOLWarpImageMultiTransform}
  -DdtiprocessTOOL:PATH=${TOOLdtiprocess}
  -DUSE_GIT_PROTOCOL_SuperBuild_DTIReg:STRING=${USE_GIT_PROTOCOL}
  ${Slicer_CLIMODULES_BIN_DIR_OPTION}
  #To reduce path length, we put everything in current binary directory
  -DEXTERNAL_SOURCE_DIRECTORY:PATH=${CMAKE_CURRENT_BINARY_DIR}
  -DEXTERNAL_BINARY_DIRECTORY:PATH=${CMAKE_CURRENT_BINARY_DIR}
  )
if( RecompileITK )
list( APPEND CMAKE_ExtraARGS
      -DUSE_SYSTEM_ITK:BOOL=ON
      -DITK_DIR:PATH=${ITK_DIR}
      DEPENDS ${ITK_DEPEND}
    )
endif()
list(APPEND CMAKE_ExtraARGS
     INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "DTI-Reg - No install"
    )
set( Tools
  DTI-Reg
  ITKTransformTools
  )
AddToolMacro( DTI-Reg ) # AddToolMacro( proj ) + uses SourceCodeArgs CMAKE_ExtraARGS Tools

