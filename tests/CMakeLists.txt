
if (NOT WIN32)
    # extra setup for out-of-tree builds
    if (NOT (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_CURRENT_BINARY_DIR))
        add_custom_target(vt_test-dir-symlinks ALL
            COMMAND ln -sf ${CMAKE_CURRENT_SOURCE_DIR}/vktracereplay.sh
            COMMAND ln -sf ${CMAKE_CURRENT_SOURCE_DIR}/devsim_layer_test.sh
            COMMAND ln -sf ${CMAKE_CURRENT_SOURCE_DIR}/devsim_test1_in.json
            COMMAND ln -sf ${CMAKE_CURRENT_SOURCE_DIR}/devsim_test1_in_ArrayOfVkFormatProperties.json
            COMMAND ln -sf ${CMAKE_CURRENT_SOURCE_DIR}/devsim_test1_gold.json
            VERBATIM
            )
        set_target_properties(vt_test-dir-symlinks PROPERTIES FOLDER ${VULKANTOOLS_TARGET_FOLDER})
    endif()
else()
    if (NOT (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_CURRENT_BINARY_DIR))
        FILE(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/_vktracereplay.ps1 VKTRACEREPLAY)
        FILE(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/trace_positive_validation.ps1 VKTRACEPOSITIVE)
        add_custom_target(vt_test-dir-symlinks ALL
            COMMAND ${CMAKE_COMMAND} -E copy_if_different ${VKTRACEREPLAY} _vktracereplay.ps1
            COMMAND ${CMAKE_COMMAND} -E copy_if_different ${VKTRACEPOSITIVE} trace_positive_validation.ps1
            VERBATIM
            )
    endif()
endif()

