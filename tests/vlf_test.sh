#!/bin/bash
#set -x
if [ -t 1 ] ; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    NC=''
fi

pushd ../submodules/Vulkan-LoaderAndValidationLayers/demos

VK_ICD_FILENAMES=../icd/VkICD_mock_icd.json VK_LAYER_PATH=../../../layers VK_INSTANCE_LAYERS=VK_LAYER_LUNARG_demo_layer ./vulkaninfo > file.tmp

printf "$GREEN[ RUNNING VLF TEST ]$NC $0\n"
if [ -f file.tmp ]
then
    count=$(grep vkGetPhysicalDeviceFormatProperties file.tmp | wc -l)
    if [ $count -gt 100 ]
    then
        printf "$GREEN[ PASS             ]$NC $0\n"
    else
        printf "$RED[ FAIL             ]$NC $0\n"
        rm file.tmp
        popd
        exit 1
    fi
fi

rm file.tmp
popd

exit 0
