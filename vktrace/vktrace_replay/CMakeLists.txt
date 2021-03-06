cmake_minimum_required(VERSION 2.8)
project(vkreplay)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/../)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/../)

if(WIN32)
  set (LIBRARIES "${API_LOWERCASE}-${MAJOR}")
elseif(UNIX)
  set (LIBRARIES "${API_LOWERCASE}")
else()
endif()

# Run a codegen script to generate vktrace-specific vulkan utils
execute_process(COMMAND ${PYTHON_EXECUTABLE} ${VT_SCRIPTS_DIR}/lvl_genvk.py -registry ${LVL_SCRIPTS_DIR}/vk.xml -o ${GENERATED_FILES_DIR} vktrace_vk_packet_id.h)
execute_process(COMMAND ${PYTHON_EXECUTABLE} ${VT_SCRIPTS_DIR}/lvl_genvk.py -registry ${LVL_SCRIPTS_DIR}/vk.xml -o ${GENERATED_FILES_DIR} vktrace_vk_vk_packets.h)
execute_process(COMMAND ${PYTHON_EXECUTABLE} ${VT_SCRIPTS_DIR}/lvl_genvk.py -registry ${LVL_SCRIPTS_DIR}/vk.xml -o ${GENERATED_FILES_DIR} vkreplay_vk_replay_gen.cpp)
execute_process(COMMAND ${PYTHON_EXECUTABLE} ${VT_SCRIPTS_DIR}/lvl_genvk.py -registry ${LVL_SCRIPTS_DIR}/vk.xml -o ${GENERATED_FILES_DIR} vkreplay_vk_objmapper.h)

if (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

    if(BUILD_WSI_XCB_SUPPORT AND VKREPLAY_WSI_SELECTION STREQUAL XCB)
        set(OS_REPLAYER_LIBS xcb ${LIBRARIES})
    elseif(BUILD_WSI_WAYLAND_SUPPORT AND VKREPLAY_WSI_SELECTION STREQUAL WAYLAND)
        set(OS_REPLAYER_LIBS ${WAYLAND_CLIENT_LIBRARIES} ${LIBRARIES})
    endif()
    
    # TODO Add Mir Support
endif()

if (${CMAKE_SYSTEM_NAME} MATCHES "Windows" OR
    ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(OS_REPLAYER_LIBS ${LIBRARIES})
endif()
set(SRC_LIST
    ${SRC_LIST}
    vkreplay.cpp
    vkreplay_settings.cpp
    vkreplay_vkreplay.cpp
    vkreplay_vkdisplay.cpp
    ${GENERATED_FILES_DIR}/vkreplay_vk_replay_gen.cpp
    vkreplay_factory.h
    vkreplay_seq.h
    vkreplay_window.h
    vkreplay_main.cpp
    vkreplay_seq.cpp
    vkreplay_factory.cpp
    ${SRC_DIR}/../layersvt/screenshot_parsing.cpp
)

set (HDR_LIST
    vkreplay.h
    vkreplay_settings.h
    vkreplay_vkreplay.h
    ${SRC_DIR}/../layersvt/screenshot_parsing.h
    ${GENERATED_FILES_DIR}/vkreplay_vk_objmapper.h
    ${GENERATED_FILES_DIR}/vktrace_vk_packet_id.h
    ${GENERATED_FILES_DIR}/vktrace_vk_vk_packets.h
)

include_directories(
    codegen
    ${SRC_DIR}/vktrace_common
    ${SRC_DIR}/thirdparty
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../include/vulkan
    ${VULKAN_TOOLS_SOURCE_DIR}/layersvt
    ${GENERATED_FILES_DIR}
    ${VKTRACE_VULKAN_INCLUDE_DIR}
    ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/${V_LVL_RELATIVE_LOCATION}
)


add_definitions(-DAPI_LOWERCASE="${API_LOWERCASE}")
add_executable(${PROJECT_NAME} ${SRC_LIST} ${HDR_LIST})

if(WIN32)
    add_dependencies(${PROJECT_NAME} generate_helper_files "${API_LOWERCASE}-${MAJOR}")
else()
    add_dependencies(${PROJECT_NAME} generate_helper_files "${API_LOWERCASE}")
endif()

target_link_libraries(${PROJECT_NAME}
    ${OS_REPLAYER_LIBS}
    ${VKTRACE_VULKAN_LIB}
    vktrace_common
)

build_options_finalize()
if(UNIX)
    install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()
