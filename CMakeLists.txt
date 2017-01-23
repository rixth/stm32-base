SET(CMAKE_SYSTEM_NAME Windows)
SET(CMAKE_C_FLAGS "-g -gdwarf-version")

PROJECT(stm32-base)

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
ENABLE_LANGUAGE(ASM)

FIND_PACKAGE(CMSIS REQUIRED)
FIND_PACKAGE(STM32HAL COMPONENTS gpio tim REQUIRED)

INCLUDE_DIRECTORIES(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/inc
    ${CMSIS_INCLUDE_DIRS}
    ${STM32HAL_INCLUDE_DIR}
    freertos/FreeRTOS/Source/include
    freertos/FreeRTOS/Source/portable/GCC/ARM_CM3/
)

SET(PROJECT_SOURCES
    freertos/FreeRTOS/Source/portable/MemMang/heap_1.c
    freertos/FreeRTOS/Source/portable/GCC/ARM_CM3/port.c
    freertos/FreeRTOS/Source/tasks.c
    freertos/FreeRTOS/Source/queue.c
    freertos/FreeRTOS/Source/list.c
    freertos/FreeRTOS/Source/timers.c
    main.c
)

ADD_EXECUTABLE(${CMAKE_PROJECT_NAME} ${PROJECT_SOURCES} ${CMSIS_SOURCES} ${STM32HAL_SOURCES})

STM32_SET_TARGET_PROPERTIES(${CMAKE_PROJECT_NAME})
STM32_ADD_HEX_BIN_TARGETS(${CMAKE_PROJECT_NAME})
